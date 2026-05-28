import 'package:driverapp/data/models/shipment.dart';
import 'package:driverapp/data/repositories/auth_repository.dart';
import 'package:driverapp/data/repositories/shipment_repository.dart';
import 'package:driverapp/modules/home/orders/orders_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';

// ─── Fixtures ─────────────────────────────────────────────────────────────────

Shipment makeShipment({
  int id = 1,
  String code = 'SHP-001',
  ShipmentStatus status = ShipmentStatus.assignedToDriver,
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
  late OrdersController controller;

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

    controller = OrdersController();
    // onInit() is NOT called in setUp — tests invoke fetchShipments() directly.
  });

  tearDown(() => Get.reset());

  // ─── Initial state ──────────────────────────────────────────────────────────

  group('OrdersController initial state', () {
    test('shipments is empty', () => expect(controller.shipments, isEmpty));
    test('isLoading is false', () => expect(controller.isLoading.value, isFalse));
    test('isLoadingMore is false',
        () => expect(controller.isLoadingMore.value, isFalse));
    test('errorMessage is empty', () => expect(controller.errorMessage.value, ''));
    test('selectedStatus is null',
        () => expect(controller.selectedStatus.value, isNull));
    test('hasMoreShipments is true', () => expect(controller.hasMoreShipments, isTrue));
    test('detailShipment is null',
        () => expect(controller.detailShipment.value, isNull));
    test('isPickingUp is false', () => expect(controller.isPickingUp.value, isFalse));
    test('isVerifyingDelivery is false',
        () => expect(controller.isVerifyingDelivery.value, isFalse));
    test('isFailingShipment is false',
        () => expect(controller.isFailingShipment.value, isFalse));
    test('actionError is empty', () => expect(controller.actionError.value, ''));
  });

  // ─── onInit ─────────────────────────────────────────────────────────────────

  group('OrdersController.onInit', () {
    test('triggers an initial fetchShipments', () async {
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

  group('OrdersController.fetchShipments', () {
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
      controller.selectedStatus.value = ShipmentStatus.inTransit;
      await controller.fetchShipments();
      verify(
        () => mockShipmentRepo.getShipments(
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
          status: ShipmentStatus.inTransit,
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

    // ── Client-side isActive filter (no active status filter) ─────────────────

    group('when no status filter is set', () {
      test('includes assignedToDriver shipments', () async {
        stubGetShipments(
            makePage([makeShipment(status: ShipmentStatus.assignedToDriver)]));
        await controller.fetchShipments();
        expect(controller.shipments.length, 1);
      });

      test('includes inTransit shipments', () async {
        stubGetShipments(makePage([makeShipment(status: ShipmentStatus.inTransit)]));
        await controller.fetchShipments();
        expect(controller.shipments.length, 1);
      });

      test('excludes delivered shipments', () async {
        stubGetShipments(makePage([makeShipment(status: ShipmentStatus.delivered)]));
        await controller.fetchShipments();
        expect(controller.shipments, isEmpty);
      });

      test('excludes failed shipments', () async {
        stubGetShipments(makePage([makeShipment(status: ShipmentStatus.failed)]));
        await controller.fetchShipments();
        expect(controller.shipments, isEmpty);
      });

      test('excludes pending shipments', () async {
        stubGetShipments(makePage([makeShipment(status: ShipmentStatus.pending)]));
        await controller.fetchShipments();
        expect(controller.shipments, isEmpty);
      });

      test('keeps only active shipments from a mixed list', () async {
        stubGetShipments(makePage([
          makeShipment(id: 1, status: ShipmentStatus.assignedToDriver),
          makeShipment(id: 2, status: ShipmentStatus.inTransit),
          makeShipment(id: 3, status: ShipmentStatus.delivered),
          makeShipment(id: 4, status: ShipmentStatus.failed),
        ]));
        await controller.fetchShipments();
        expect(controller.shipments.length, 2);
        expect(controller.shipments.map((s) => s.id), containsAll([1, 2]));
      });
    });

    group('when a status filter is active', () {
      test('includes all shipments returned by the API', () async {
        controller.selectedStatus.value = ShipmentStatus.delivered;
        stubGetShipments(makePage([
          makeShipment(id: 1, status: ShipmentStatus.delivered),
          makeShipment(id: 2, status: ShipmentStatus.failed), // normally excluded
        ]));
        await controller.fetchShipments();
        expect(controller.shipments.length, 2);
      });
    });
  });

  // ─── fetchShipments — error cases ───────────────────────────────────────────

  group('OrdersController.fetchShipments errors', () {
    void stubThrow(Object error) {
      when(
        () => mockShipmentRepo.getShipments(
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
          status: any(named: 'status'),
        ),
      ).thenThrow(error);
    }

    test('sets errorMessage on ShipmentException', () async {
      stubThrow(ShipmentException.network());
      await controller.fetchShipments();
      expect(controller.errorMessage.value, 'Connection error. Please try again.');
    });

    test('sets a non-empty errorMessage for non-ShipmentException errors', () async {
      stubThrow(Exception('Unexpected'));
      await controller.fetchShipments();
      expect(controller.errorMessage.value, isNotEmpty);
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
  });

  // ─── setFilter ──────────────────────────────────────────────────────────────

  group('OrdersController.setFilter', () {
    test('updates selectedStatus to the provided value', () {
      controller.setFilter(ShipmentStatus.inTransit);
      expect(controller.selectedStatus.value, ShipmentStatus.inTransit);
    });

    test('does not call repository when the same status is set again', () {
      controller.setFilter(null); // selectedStatus is already null → no-op
      verifyNever(
        () => mockShipmentRepo.getShipments(
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
          status: any(named: 'status'),
        ),
      );
    });

    test('triggers a fetch with the new status when it changes', () async {
      controller.setFilter(ShipmentStatus.inTransit);
      await Future<void>.delayed(Duration.zero);
      verify(
        () => mockShipmentRepo.getShipments(
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
          status: ShipmentStatus.inTransit,
        ),
      ).called(1);
    });
  });

  // ─── setDetailShipment ──────────────────────────────────────────────────────

  group('OrdersController.setDetailShipment', () {
    test('sets detailShipment to the provided shipment', () {
      final shipment = makeShipment(id: 42);
      controller.setDetailShipment(shipment);
      expect(controller.detailShipment.value, shipment);
    });

    test('clears actionError when setting a new detail shipment', () {
      controller.actionError.value = 'previous error';
      controller.setDetailShipment(makeShipment());
      expect(controller.actionError.value, '');
    });

    test('replacing detail shipment updates detailShipment', () {
      final first = makeShipment(id: 1);
      final second = makeShipment(id: 2);
      controller.setDetailShipment(first);
      controller.setDetailShipment(second);
      expect(controller.detailShipment.value?.id, 2);
    });
  });

  // ─── pickUpShipment ─────────────────────────────────────────────────────────

  group('OrdersController.pickUpShipment', () {
    late Shipment shipment;

    setUp(() async {
      shipment = makeShipment(id: 1, code: 'SHP-001',
          status: ShipmentStatus.assignedToDriver);

      // Put the shipment into the list via fetchShipments
      stubGetShipments(makePage([shipment]));
      await controller.fetchShipments();

      controller.setDetailShipment(shipment);
      when(() => mockShipmentRepo.pickUp(any())).thenAnswer((_) async {});
    });

    test('does nothing when detailShipment is null', () async {
      controller.detailShipment.value = null;
      await controller.pickUpShipment();
      verifyNever(() => mockShipmentRepo.pickUp(any()));
    });

    test('does nothing when already picking up', () async {
      controller.isPickingUp.value = true;
      await controller.pickUpShipment();
      verifyNever(() => mockShipmentRepo.pickUp(any()));
    });

    test('calls pickUp with the shipment code', () async {
      await controller.pickUpShipment();
      verify(() => mockShipmentRepo.pickUp('SHP-001')).called(1);
    });

    test('updates detailShipment status to inTransit on success', () async {
      await controller.pickUpShipment();
      expect(controller.detailShipment.value?.status, ShipmentStatus.inTransit);
    });

    test('updates the shipment in the list to inTransit on success', () async {
      await controller.pickUpShipment();
      expect(controller.shipments.first.status, ShipmentStatus.inTransit);
    });

    test('sets pickedUpAt on the updated shipment', () async {
      await controller.pickUpShipment();
      expect(controller.detailShipment.value?.pickedUpAt, isNotNull);
    });

    test('isPickingUp is false after success', () async {
      await controller.pickUpShipment();
      expect(controller.isPickingUp.value, isFalse);
    });

    test('sets actionError on a ShipmentException', () async {
      when(() => mockShipmentRepo.pickUp(any()))
          .thenThrow(ShipmentException.badRequest('Cannot pick up'));
      await controller.pickUpShipment();
      expect(controller.actionError.value, 'Cannot pick up');
    });

    test('isPickingUp is false after an error', () async {
      when(() => mockShipmentRepo.pickUp(any()))
          .thenThrow(ShipmentException.network());
      await controller.pickUpShipment();
      expect(controller.isPickingUp.value, isFalse);
    });

    test('calls logout on an unauthorized exception', () async {
      when(() => mockShipmentRepo.pickUp(any()))
          .thenThrow(ShipmentException.unauthorized());
      await controller.pickUpShipment();
      verify(() => mockAuthRepo.logout()).called(1);
    });

    test('does not set actionError on an unauthorized exception', () async {
      when(() => mockShipmentRepo.pickUp(any()))
          .thenThrow(ShipmentException.unauthorized());
      await controller.pickUpShipment();
      expect(controller.actionError.value, '');
    });
  });

  // ─── verifyDelivery ─────────────────────────────────────────────────────────

  group('OrdersController.verifyDelivery', () {
    late Shipment shipment;

    setUp(() {
      shipment =
          makeShipment(id: 1, code: 'SHP-002', status: ShipmentStatus.inTransit);
      controller.setDetailShipment(shipment);
      when(() => mockShipmentRepo.verifyDelivery(any(), any()))
          .thenAnswer((_) async {});
      // getShipments is already stubbed to return empty page (for refreshShipments)
    });

    test('returns false when detailShipment is null', () async {
      controller.detailShipment.value = null;
      final result = await controller.verifyDelivery('DEL-123');
      expect(result, isFalse);
    });

    test('returns false when already verifying', () async {
      controller.isVerifyingDelivery.value = true;
      final result = await controller.verifyDelivery('DEL-123');
      expect(result, isFalse);
      verifyNever(() => mockShipmentRepo.verifyDelivery(any(), any()));
    });

    test('calls verifyDelivery with the shipment code and delivery code', () async {
      await controller.verifyDelivery('DEL-XYZ');
      verify(() => mockShipmentRepo.verifyDelivery('SHP-002', 'DEL-XYZ')).called(1);
    });

    test('returns true on success', () async {
      final result = await controller.verifyDelivery('DEL-123');
      expect(result, isTrue);
    });

    test('calls refreshShipments on success', () async {
      await controller.verifyDelivery('DEL-123');
      // refreshShipments triggers a getShipments call
      verify(
        () => mockShipmentRepo.getShipments(
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
          status: any(named: 'status'),
        ),
      ).called(1);
    });

    test('isVerifyingDelivery is false after success', () async {
      await controller.verifyDelivery('DEL-123');
      expect(controller.isVerifyingDelivery.value, isFalse);
    });

    test('returns false on a ShipmentException', () async {
      when(() => mockShipmentRepo.verifyDelivery(any(), any()))
          .thenThrow(ShipmentException.badRequest('Wrong code'));
      final result = await controller.verifyDelivery('DEL-BAD');
      expect(result, isFalse);
    });

    test('sets actionError on a ShipmentException', () async {
      when(() => mockShipmentRepo.verifyDelivery(any(), any()))
          .thenThrow(ShipmentException.badRequest('Wrong code'));
      await controller.verifyDelivery('DEL-BAD');
      expect(controller.actionError.value, 'Wrong code');
    });

    test('isVerifyingDelivery is false after an error', () async {
      when(() => mockShipmentRepo.verifyDelivery(any(), any()))
          .thenThrow(ShipmentException.network());
      await controller.verifyDelivery('DEL-BAD');
      expect(controller.isVerifyingDelivery.value, isFalse);
    });

    test('calls logout on an unauthorized exception', () async {
      when(() => mockShipmentRepo.verifyDelivery(any(), any()))
          .thenThrow(ShipmentException.unauthorized());
      await controller.verifyDelivery('DEL-BAD');
      verify(() => mockAuthRepo.logout()).called(1);
    });

    test('returns false on an unauthorized exception', () async {
      when(() => mockShipmentRepo.verifyDelivery(any(), any()))
          .thenThrow(ShipmentException.unauthorized());
      final result = await controller.verifyDelivery('DEL-BAD');
      expect(result, isFalse);
    });
  });

  // ─── failShipment ───────────────────────────────────────────────────────────

  group('OrdersController.failShipment', () {
    late Shipment shipment;

    setUp(() async {
      shipment =
          makeShipment(id: 1, code: 'SHP-003', status: ShipmentStatus.inTransit);

      stubGetShipments(makePage([shipment]));
      await controller.fetchShipments();
      controller.setDetailShipment(shipment);

      when(() => mockShipmentRepo.failShipment(any(), any()))
          .thenAnswer((_) async {});
    });

    test('returns false when detailShipment is null', () async {
      controller.detailShipment.value = null;
      final result = await controller.failShipment('Not home');
      expect(result, isFalse);
    });

    test('returns false when already failing', () async {
      controller.isFailingShipment.value = true;
      final result = await controller.failShipment('Not home');
      expect(result, isFalse);
      verifyNever(() => mockShipmentRepo.failShipment(any(), any()));
    });

    test('calls failShipment with the shipment code and remark', () async {
      await controller.failShipment('Customer not home');
      verify(() => mockShipmentRepo.failShipment('SHP-003', 'Customer not home'))
          .called(1);
    });

    test('returns true on success', () async {
      final result = await controller.failShipment('Not home');
      expect(result, isTrue);
    });

    test('updates detailShipment status to failed on success', () async {
      await controller.failShipment('Not home');
      expect(controller.detailShipment.value?.status, ShipmentStatus.failed);
    });

    test('updates the shipment in the list to failed on success', () async {
      await controller.failShipment('Not home');
      expect(controller.shipments.first.status, ShipmentStatus.failed);
    });

    test('sets failedAt on the updated shipment', () async {
      await controller.failShipment('Not home');
      expect(controller.detailShipment.value?.failedAt, isNotNull);
    });

    test('isFailingShipment is false after success', () async {
      await controller.failShipment('Not home');
      expect(controller.isFailingShipment.value, isFalse);
    });

    test('returns false on a ShipmentException', () async {
      when(() => mockShipmentRepo.failShipment(any(), any()))
          .thenThrow(ShipmentException.badRequest('Cannot fail'));
      final result = await controller.failShipment('reason');
      expect(result, isFalse);
    });

    test('sets actionError on a ShipmentException', () async {
      when(() => mockShipmentRepo.failShipment(any(), any()))
          .thenThrow(ShipmentException.badRequest('Cannot fail delivered shipment'));
      await controller.failShipment('reason');
      expect(controller.actionError.value, 'Cannot fail delivered shipment');
    });

    test('isFailingShipment is false after an error', () async {
      when(() => mockShipmentRepo.failShipment(any(), any()))
          .thenThrow(ShipmentException.network());
      await controller.failShipment('reason');
      expect(controller.isFailingShipment.value, isFalse);
    });

    test('calls logout on an unauthorized exception', () async {
      when(() => mockShipmentRepo.failShipment(any(), any()))
          .thenThrow(ShipmentException.unauthorized());
      await controller.failShipment('reason');
      verify(() => mockAuthRepo.logout()).called(1);
    });

    test('returns false on an unauthorized exception', () async {
      when(() => mockShipmentRepo.failShipment(any(), any()))
          .thenThrow(ShipmentException.unauthorized());
      final result = await controller.failShipment('reason');
      expect(result, isFalse);
    });
  });

  // ─── loadMoreShipments ──────────────────────────────────────────────────────

  group('OrdersController.loadMoreShipments', () {
    Future<void> fillFirstPage() async {
      stubGetShipments(makePage(
        List.generate(
            10, (i) => makeShipment(id: i + 1, status: ShipmentStatus.inTransit)),
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

    test('does not call repository when hasMoreShipments is false', () async {
      stubGetShipments(makePage(
        List.generate(3, (i) => makeShipment(id: i, status: ShipmentStatus.inTransit)),
      ));
      await controller.fetchShipments(); // 1 call, sets _hasNextPage = false

      await controller.loadMoreShipments(); // should be skipped

      verify(
        () => mockShipmentRepo.getShipments(
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
          status: any(named: 'status'),
        ),
      ).called(1); // exactly 1 total (from fetchShipments only)
    });

    test('appends next-page shipments to the list', () async {
      await fillFirstPage();
      expect(controller.shipments.length, 10);

      when(
        () => mockShipmentRepo.getShipments(page: 2, pageSize: 10, status: null),
      ).thenAnswer((_) async => makePage(
            [makeShipment(id: 11, status: ShipmentStatus.inTransit)],
            page: 2,
          ));

      await controller.loadMoreShipments();
      expect(controller.shipments.length, 11);
    });

    test('filters non-active shipments from the next page when no filter is set',
        () async {
      await fillFirstPage();

      when(
        () => mockShipmentRepo.getShipments(page: 2, pageSize: 10, status: null),
      ).thenAnswer((_) async => makePage(
            [
              makeShipment(id: 11, status: ShipmentStatus.inTransit),
              makeShipment(id: 12, status: ShipmentStatus.delivered), // excluded
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

    test('sets loadMoreErrorMessage on error', () async {
      await fillFirstPage();
      when(
        () => mockShipmentRepo.getShipments(page: 2, pageSize: 10, status: null),
      ).thenThrow(ShipmentException.network());

      await controller.loadMoreShipments();
      expect(
          controller.loadMoreErrorMessage.value, 'Connection error. Please try again.');
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
      // Set a filter so the else-branch (result.shipments) is taken instead
      // of the isActive client-side filter.
      controller.selectedStatus.value = ShipmentStatus.inTransit;
      stubGetShipments(makePage(
        List.generate(10, (i) => makeShipment(id: i + 1, status: ShipmentStatus.inTransit)),
      ));
      await controller.fetchShipments();
      expect(controller.shipments.length, 10);

      when(
        () => mockShipmentRepo.getShipments(
            page: 2, pageSize: 10, status: ShipmentStatus.inTransit),
      ).thenAnswer((_) async => makePage(
            [
              makeShipment(id: 11, status: ShipmentStatus.inTransit),
              makeShipment(
                  id: 12,
                  status: ShipmentStatus.delivered), // kept — filter bypasses isActive check
            ],
            page: 2,
          ));

      await controller.loadMoreShipments();
      expect(controller.shipments.length, 12);
    });

    test('calls logout on an unauthorized exception during loadMore', () async {
      await fillFirstPage();
      when(
        () => mockShipmentRepo.getShipments(page: 2, pageSize: 10, status: null),
      ).thenThrow(ShipmentException.unauthorized());

      await controller.loadMoreShipments();
      verify(() => mockAuthRepo.logout()).called(1);
    });
  });

  // ─── refreshShipments ───────────────────────────────────────────────────────

  group('OrdersController.refreshShipments', () {
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

  group('OrdersController.displayAddress', () {
    test('returns the label from "Label | lat;lng" format', () {
      expect(controller.displayAddress('Pickup Point | 9.0;38.7'), 'Pickup Point');
    });

    test('returns the raw string when no pipe separator is present', () {
      expect(controller.displayAddress('456 Drop-off Ave'), '456 Drop-off Ave');
    });

    test('trims whitespace around the label', () {
      expect(controller.displayAddress('  HQ  | 9.0;38.7'), 'HQ');
    });
  });
}
