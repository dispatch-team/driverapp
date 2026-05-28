import 'package:driverapp/data/models/shipment.dart';
import 'package:driverapp/data/repositories/auth_repository.dart';
import 'package:driverapp/data/repositories/shipment_repository.dart';
import 'package:driverapp/modules/home/history/history_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';

// ─── Fixtures ─────────────────────────────────────────────────────────────────

Shipment makeShipment({
  int id = 1,
  String code = 'SHP-001',
  ShipmentStatus status = ShipmentStatus.delivered,
}) =>
    Shipment(
      id: id,
      code: code,
      merchantId: 1,
      merchantUserId: 'u1',
      description: '',
      weightKg: 1.0,
      dimensions: '',
      totalFee: 10.0,
      status: status,
      remark: '',
      courierCompanyId: 1,
      assignedDriverId: 1,
      startAddress: 'Pickup | 9.0;38.7',
      startAddressContactName: '',
      startAddressPhoneNumber: '',
      startAddressAdditionalContact: '',
      endAddress: 'Dropoff | 9.1;38.8',
      endAddressContactName: '',
      endAddressPhoneNumber: '',
      endAddressAdditionalContact: '',
      rating: 0.0,
      webhookUrl: '',
      createdAt: DateTime(2024, 1, 1),
    );

ShipmentPage makePage(
  List<Shipment> shipments, {
  int page = 1,
  int pageSize = 10,
}) =>
    ShipmentPage(
      shipments: shipments,
      total: shipments.length,
      page: page,
      pageSize: pageSize,
    );

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  late MockShipmentRepository mockShipmentRepo;
  late MockAuthRepository mockAuthRepo;
  late HistoryController controller;

  void stubGetShipments(ShipmentPage page) {
    when(
      () => mockShipmentRepo.getShipments(
        page: any(named: 'page'),
        pageSize: any(named: 'pageSize'),
        status: any(named: 'status'),
      ),
    ).thenAnswer((_) async => page);
  }

  setUpAll(() {
    registerFallbackValue(ShipmentStatus.pending);
  });

  setUp(() {
    Get.testMode = true;
    mockShipmentRepo = MockShipmentRepository();
    mockAuthRepo = MockAuthRepository();
    Get.put<ShipmentRepository>(mockShipmentRepo);
    Get.put<AuthRepository>(mockAuthRepo);

    when(() => mockAuthRepo.logout()).thenAnswer((_) async {});
    stubGetShipments(makePage([])); // safe default for every test

    controller = HistoryController();
    // onInit() is NOT called in setUp — tests call fetchShipments() directly
    // (or call onInit() explicitly in the onInit group).
  });

  tearDown(() => Get.reset());

  // ─── Initial state ──────────────────────────────────────────────────────────

  group('HistoryController initial state', () {
    test('shipments is empty', () => expect(controller.shipments, isEmpty));
    test('isLoading is false', () => expect(controller.isLoading.value, isFalse));
    test('isLoadingMore is false', () => expect(controller.isLoadingMore.value, isFalse));
    test('errorMessage is empty', () => expect(controller.errorMessage.value, ''));
    test('loadMoreErrorMessage is empty',
        () => expect(controller.loadMoreErrorMessage.value, ''));
    test('selectedStatus is null',
        () => expect(controller.selectedStatus.value, isNull));
    test('hasMoreShipments is true', () => expect(controller.hasMoreShipments, isTrue));
  });

  // ─── onInit ─────────────────────────────────────────────────────────────────

  group('HistoryController.onInit', () {
    test('triggers an initial fetchShipments', () async {
      // onInit() returns void; fetchShipments() is called unawaited inside it.
      // Drain the async work before verifying.
      controller.onInit();
      await Future<void>.delayed(Duration.zero);
      verify(
        () => mockShipmentRepo.getShipments(
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
          status: any(named: 'status'),
        ),
      ).called(1);
    });
  });

  // ─── fetchShipments — success ───────────────────────────────────────────────

  group('HistoryController.fetchShipments', () {
    test('calls repository with page=1 and pageSize=10', () async {
      await controller.fetchShipments();
      verify(
        () => mockShipmentRepo.getShipments(
          page: 1,
          pageSize: 10,
          status: any(named: 'status'),
        ),
      ).called(1);
    });

    test('isLoading is false after a successful fetch', () async {
      await controller.fetchShipments();
      expect(controller.isLoading.value, isFalse);
    });

    test('forwards selectedStatus to the repository', () async {
      controller.selectedStatus.value = ShipmentStatus.failed;
      await controller.fetchShipments();
      verify(
        () => mockShipmentRepo.getShipments(
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
          status: ShipmentStatus.failed,
        ),
      ).called(1);
    });

    test('resets the shipments list on each fetch', () async {
      stubGetShipments(makePage([makeShipment(id: 1)]));
      await controller.fetchShipments();
      expect(controller.shipments.length, 1);

      stubGetShipments(makePage([]));
      await controller.fetchShipments();
      expect(controller.shipments, isEmpty);
    });

    test('hasMoreShipments is true when a full page (10 items) is returned', () async {
      stubGetShipments(makePage(
        List.generate(10, (i) => makeShipment(id: i)),
      ));
      await controller.fetchShipments();
      expect(controller.hasMoreShipments, isTrue);
    });

    test('hasMoreShipments is false when fewer than 10 items are returned', () async {
      stubGetShipments(makePage(
        List.generate(3, (i) => makeShipment(id: i)),
      ));
      await controller.fetchShipments();
      expect(controller.hasMoreShipments, isFalse);
    });

    // ── Client-side status filter (no active status filter) ──────────────────

    group('when no status filter is set', () {
      test('includes delivered shipments', () async {
        stubGetShipments(makePage([makeShipment(status: ShipmentStatus.delivered)]));
        await controller.fetchShipments();
        expect(controller.shipments.length, 1);
      });

      test('includes failed shipments', () async {
        stubGetShipments(makePage([makeShipment(status: ShipmentStatus.failed)]));
        await controller.fetchShipments();
        expect(controller.shipments.length, 1);
      });

      test('excludes in-transit shipments', () async {
        stubGetShipments(makePage([makeShipment(status: ShipmentStatus.inTransit)]));
        await controller.fetchShipments();
        expect(controller.shipments, isEmpty);
      });

      test('excludes assigned-to-driver shipments', () async {
        stubGetShipments(
            makePage([makeShipment(status: ShipmentStatus.assignedToDriver)]));
        await controller.fetchShipments();
        expect(controller.shipments, isEmpty);
      });

      test('excludes pending shipments', () async {
        stubGetShipments(makePage([makeShipment(status: ShipmentStatus.pending)]));
        await controller.fetchShipments();
        expect(controller.shipments, isEmpty);
      });

      test('keeps only delivered and failed from a mixed list', () async {
        stubGetShipments(makePage([
          makeShipment(id: 1, status: ShipmentStatus.inTransit),
          makeShipment(id: 2, status: ShipmentStatus.delivered),
          makeShipment(id: 3, status: ShipmentStatus.failed),
          makeShipment(id: 4, status: ShipmentStatus.pending),
        ]));
        await controller.fetchShipments();
        expect(controller.shipments.length, 2);
        expect(controller.shipments.map((s) => s.id), containsAll([2, 3]));
      });
    });

    // ── Active status filter — no client-side filtering ──────────────────────

    group('when a status filter is active', () {
      test('includes all shipments returned by the API', () async {
        controller.selectedStatus.value = ShipmentStatus.delivered;
        stubGetShipments(makePage([
          makeShipment(id: 1, status: ShipmentStatus.inTransit),
          makeShipment(id: 2, status: ShipmentStatus.delivered),
        ]));
        await controller.fetchShipments();
        expect(controller.shipments.length, 2);
      });
    });
  });

  // ─── fetchShipments — error cases ───────────────────────────────────────────

  group('HistoryController.fetchShipments errors', () {
    void stubThrow(Object error) {
      when(
        () => mockShipmentRepo.getShipments(
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
          status: any(named: 'status'),
        ),
      ).thenThrow(error);
    }

    test('sets errorMessage to the exception message on a ShipmentException', () async {
      stubThrow(ShipmentException.network());
      await controller.fetchShipments();
      expect(controller.errorMessage.value, 'Connection error. Please try again.');
    });

    test('sets errorMessage for a badRequest ShipmentException', () async {
      stubThrow(ShipmentException.badRequest('Custom server error'));
      await controller.fetchShipments();
      expect(controller.errorMessage.value, 'Custom server error');
    });

    test('sets a non-empty errorMessage for non-ShipmentException errors', () async {
      stubThrow(Exception('Unexpected'));
      await controller.fetchShipments();
      expect(controller.errorMessage.value, isNotEmpty);
    });

    test('clears errorMessage at the start of the next successful fetch', () async {
      stubThrow(ShipmentException.network());
      await controller.fetchShipments();
      expect(controller.errorMessage.value, isNotEmpty);

      stubGetShipments(makePage([]));
      await controller.fetchShipments();
      expect(controller.errorMessage.value, '');
    });

    test('isLoading is false after any error', () async {
      stubThrow(ShipmentException.network());
      await controller.fetchShipments();
      expect(controller.isLoading.value, isFalse);
    });

    test('calls logout on an unauthorized ShipmentException', () async {
      stubThrow(ShipmentException.unauthorized());
      await controller.fetchShipments();
      verify(() => mockAuthRepo.logout()).called(1);
    });

    test('does not set errorMessage on an unauthorized exception', () async {
      stubThrow(ShipmentException.unauthorized());
      await controller.fetchShipments();
      expect(controller.errorMessage.value, '');
    });

    test('isLoading is false after an unauthorized exception', () async {
      stubThrow(ShipmentException.unauthorized());
      await controller.fetchShipments();
      expect(controller.isLoading.value, isFalse);
    });
  });

  // ─── setFilter ──────────────────────────────────────────────────────────────

  group('HistoryController.setFilter', () {
    test('updates selectedStatus to the provided value', () {
      controller.setFilter(ShipmentStatus.delivered);
      expect(controller.selectedStatus.value, ShipmentStatus.delivered);
    });

    test('resets selectedStatus to null', () {
      controller.selectedStatus.value = ShipmentStatus.failed;
      controller.setFilter(null);
      expect(controller.selectedStatus.value, isNull);
    });

    test('does not call repository when the same status is set again', () {
      // selectedStatus is already null; setFilter(null) is a no-op
      controller.setFilter(null);
      verifyNever(
        () => mockShipmentRepo.getShipments(
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
          status: any(named: 'status'),
        ),
      );
    });

    test('triggers a fetch with the new status when it changes', () async {
      controller.setFilter(ShipmentStatus.delivered);
      // setFilter calls fetchShipments() unawaited; drain the async work
      await Future<void>.delayed(Duration.zero);
      verify(
        () => mockShipmentRepo.getShipments(
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
          status: ShipmentStatus.delivered,
        ),
      ).called(1);
    });
  });

  // ─── loadMoreShipments ──────────────────────────────────────────────────────

  group('HistoryController.loadMoreShipments', () {
    // Helper: put 10 delivered items in the list so _hasNextPage = true
    Future<void> fillFirstPage() async {
      stubGetShipments(makePage(
        List.generate(10, (i) => makeShipment(id: i + 1, status: ShipmentStatus.delivered)),
      ));
      await controller.fetchShipments();
    }

    test('does not call repository when isLoading is true', () async {
      controller.isLoading.value = true;
      await controller.loadMoreShipments();
      verifyNever(
        () => mockShipmentRepo.getShipments(
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
          status: any(named: 'status'),
        ),
      );
    });

    test('does not call repository when isLoadingMore is true', () async {
      controller.isLoadingMore.value = true;
      await controller.loadMoreShipments();
      verifyNever(
        () => mockShipmentRepo.getShipments(
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
          status: any(named: 'status'),
        ),
      );
    });

    test('does not call repository when hasMoreShipments is false', () async {
      // Partial page → _hasNextPage = false
      stubGetShipments(makePage(
        List.generate(3, (i) => makeShipment(id: i, status: ShipmentStatus.delivered)),
      ));
      await controller.fetchShipments(); // 1 call

      await controller.loadMoreShipments(); // should be skipped

      // Exactly one total call (the fetchShipments one, NOT loadMore)
      verify(
        () => mockShipmentRepo.getShipments(
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
          status: any(named: 'status'),
        ),
      ).called(1);
    });

    test('appends next-page shipments to the list', () async {
      await fillFirstPage();
      expect(controller.shipments.length, 10);

      when(
        () => mockShipmentRepo.getShipments(page: 2, pageSize: 10, status: null),
      ).thenAnswer((_) async => makePage(
            [
              makeShipment(id: 11, status: ShipmentStatus.delivered),
              makeShipment(id: 12, status: ShipmentStatus.delivered),
            ],
            page: 2,
          ));

      await controller.loadMoreShipments();
      expect(controller.shipments.length, 12);
    });

    test('filters non-history shipments from the next page when no filter is set',
        () async {
      await fillFirstPage();

      when(
        () => mockShipmentRepo.getShipments(page: 2, pageSize: 10, status: null),
      ).thenAnswer((_) async => makePage(
            [
              makeShipment(id: 11, status: ShipmentStatus.delivered),
              makeShipment(id: 12, status: ShipmentStatus.inTransit), // excluded
            ],
            page: 2,
          ));

      await controller.loadMoreShipments();
      expect(controller.shipments.length, 11);
    });

    test('isLoadingMore is false after a successful load', () async {
      await fillFirstPage();
      when(
        () => mockShipmentRepo.getShipments(page: 2, pageSize: 10, status: null),
      ).thenAnswer((_) async => makePage([], page: 2));

      await controller.loadMoreShipments();
      expect(controller.isLoadingMore.value, isFalse);
    });

    test('sets loadMoreErrorMessage on a ShipmentException', () async {
      await fillFirstPage();
      when(
        () => mockShipmentRepo.getShipments(page: 2, pageSize: 10, status: null),
      ).thenThrow(ShipmentException.network());

      await controller.loadMoreShipments();
      expect(
          controller.loadMoreErrorMessage.value, 'Connection error. Please try again.');
    });

    test('calls logout on an unauthorized exception during loadMore', () async {
      await fillFirstPage();
      when(
        () => mockShipmentRepo.getShipments(page: 2, pageSize: 10, status: null),
      ).thenThrow(ShipmentException.unauthorized());

      await controller.loadMoreShipments();
      verify(() => mockAuthRepo.logout()).called(1);
    });

    test('isLoadingMore is false after an error', () async {
      await fillFirstPage();
      when(
        () => mockShipmentRepo.getShipments(page: 2, pageSize: 10, status: null),
      ).thenThrow(ShipmentException.network());

      await controller.loadMoreShipments();
      expect(controller.isLoadingMore.value, isFalse);
    });

    test('includes all shipments from next page when a status filter is set',
        () async {
      // Set a filter so the else-branch (result.shipments) is taken on page 2
      // instead of the history-status client-side filter.
      controller.selectedStatus.value = ShipmentStatus.delivered;
      stubGetShipments(makePage(
        List.generate(10, (i) => makeShipment(id: i + 1, status: ShipmentStatus.delivered)),
      ));
      await controller.fetchShipments();
      expect(controller.shipments.length, 10);

      when(
        () => mockShipmentRepo.getShipments(
            page: 2, pageSize: 10, status: ShipmentStatus.delivered),
      ).thenAnswer((_) async => makePage(
            [
              makeShipment(id: 11, status: ShipmentStatus.delivered),
              makeShipment(
                  id: 12,
                  status: ShipmentStatus.inTransit), // kept — filter bypasses history check
            ],
            page: 2,
          ));

      await controller.loadMoreShipments();
      expect(controller.shipments.length, 12);
    });
  });

  // ─── refreshShipments ───────────────────────────────────────────────────────

  group('HistoryController.refreshShipments', () {
    test('delegates to fetchShipments (calls repository with page=1)', () async {
      await controller.refreshShipments();
      verify(
        () => mockShipmentRepo.getShipments(
          page: 1,
          pageSize: 10,
          status: any(named: 'status'),
        ),
      ).called(1);
    });
  });

  // ─── displayAddress ─────────────────────────────────────────────────────────

  group('HistoryController.displayAddress', () {
    test('returns the label from "Label | lat;lng" format', () {
      expect(controller.displayAddress('Warehouse A | 9.0;38.7'), 'Warehouse A');
    });

    test('returns the raw string when no pipe separator is present', () {
      expect(controller.displayAddress('123 Main Street'), '123 Main Street');
    });

    test('trims whitespace around the label', () {
      expect(controller.displayAddress('  Depot B  | 9.0;38.7'), 'Depot B');
    });
  });
}
