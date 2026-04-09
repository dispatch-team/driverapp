import 'package:flutter/material.dart';

// ─── Status enum ──────────────────────────────────────────────────────────────

enum ShipmentStatus {
  pending,
  assignedToCourier,
  assignedToDriver,
  inTransit,
  delivered,
  failed,
  returned,
  cancelled;

  static ShipmentStatus fromString(String value) {
    return switch (value) {
      'pending'            => ShipmentStatus.pending,
      'assigned_to_courier' => ShipmentStatus.assignedToCourier,
      'assigned_to_driver'  => ShipmentStatus.assignedToDriver,
      'in_transit'         => ShipmentStatus.inTransit,
      'delivered'          => ShipmentStatus.delivered,
      'failed'             => ShipmentStatus.failed,
      'returned'           => ShipmentStatus.returned,
      'cancelled'          => ShipmentStatus.cancelled,
      _                    => ShipmentStatus.pending,
    };
  }

  String get displayLabel {
    return switch (this) {
      ShipmentStatus.pending            => 'Pending',
      ShipmentStatus.assignedToCourier  => 'Courier Assigned',
      ShipmentStatus.assignedToDriver   => 'Assigned to Driver',
      ShipmentStatus.inTransit          => 'In Transit',
      ShipmentStatus.delivered          => 'Delivered',
      ShipmentStatus.failed             => 'Failed',
      ShipmentStatus.returned           => 'Returned',
      ShipmentStatus.cancelled          => 'Cancelled',
    };
  }

  Color get color {
    return switch (this) {
      ShipmentStatus.pending            => const Color(0xFFFBBC04),
      ShipmentStatus.assignedToCourier  => const Color(0xFF4285F4),
      ShipmentStatus.assignedToDriver   => const Color(0xFFFF8C00),
      ShipmentStatus.inTransit          => const Color(0xFF4285F4),
      ShipmentStatus.delivered          => const Color(0xFF34A853),
      ShipmentStatus.failed             => const Color(0xFFEA4335),
      ShipmentStatus.returned           => const Color(0xFFEA4335),
      ShipmentStatus.cancelled          => const Color(0xFFEA4335),
    };
  }

  bool get isActive {
    return this == ShipmentStatus.assignedToDriver ||
        this == ShipmentStatus.inTransit;
  }
}

// ─── Model ────────────────────────────────────────────────────────────────────

class Shipment {
  const Shipment({
    required this.id,
    required this.code,
    required this.merchantId,
    required this.merchantUserId,
    required this.description,
    required this.weightKg,
    required this.dimensions,
    required this.totalFee,
    required this.status,
    required this.remark,
    required this.courierCompanyId,
    required this.assignedDriverId,
    required this.startAddress,
    required this.startAddressContactName,
    required this.startAddressPhoneNumber,
    required this.startAddressAdditionalContact,
    required this.endAddress,
    required this.endAddressContactName,
    required this.endAddressPhoneNumber,
    required this.endAddressAdditionalContact,
    required this.rating,
    required this.webhookUrl,
    required this.createdAt,
    this.items,
    this.deliveredAt,
    this.assignedToCourierAt,
    this.assignedToDriverAt,
    this.pickedUpAt,
    this.inTransitAt,
    this.failedAt,
    this.returnedAt,
    this.cancelledAt,
  });

  final int id;
  final String code;
  final int merchantId;
  final String merchantUserId;
  final String description;
  final double weightKg;
  final String dimensions;
  final double totalFee;
  final ShipmentStatus status;
  final String remark;
  final int courierCompanyId;
  final int assignedDriverId;
  final String startAddress;
  final String startAddressContactName;
  final String startAddressPhoneNumber;
  final String startAddressAdditionalContact;
  final String endAddress;
  final String endAddressContactName;
  final String endAddressPhoneNumber;
  final String endAddressAdditionalContact;
  final double rating;
  final String webhookUrl;
  final DateTime createdAt;
  final List<String>? items;
  final DateTime? deliveredAt;
  final DateTime? assignedToCourierAt;
  final DateTime? assignedToDriverAt;
  final DateTime? pickedUpAt;
  final DateTime? inTransitAt;
  final DateTime? failedAt;
  final DateTime? returnedAt;
  final DateTime? cancelledAt;

  Shipment copyWith({
    ShipmentStatus? status,
    DateTime? pickedUpAt,
    DateTime? inTransitAt,
    DateTime? deliveredAt,
  }) {
    return Shipment(
      id: id,
      code: code,
      merchantId: merchantId,
      merchantUserId: merchantUserId,
      description: description,
      weightKg: weightKg,
      dimensions: dimensions,
      totalFee: totalFee,
      status: status ?? this.status,
      remark: remark,
      courierCompanyId: courierCompanyId,
      assignedDriverId: assignedDriverId,
      startAddress: startAddress,
      startAddressContactName: startAddressContactName,
      startAddressPhoneNumber: startAddressPhoneNumber,
      startAddressAdditionalContact: startAddressAdditionalContact,
      endAddress: endAddress,
      endAddressContactName: endAddressContactName,
      endAddressPhoneNumber: endAddressPhoneNumber,
      endAddressAdditionalContact: endAddressAdditionalContact,
      rating: rating,
      webhookUrl: webhookUrl,
      createdAt: createdAt,
      items: items,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      assignedToCourierAt: assignedToCourierAt,
      assignedToDriverAt: assignedToDriverAt,
      pickedUpAt: pickedUpAt ?? this.pickedUpAt,
      inTransitAt: inTransitAt ?? this.inTransitAt,
      failedAt: failedAt,
      returnedAt: returnedAt,
      cancelledAt: cancelledAt,
    );
  }

  factory Shipment.fromJson(Map<String, dynamic> json) {
    return Shipment(
      id:               json['id'] as int,
      code:             json['code'] as String,
      merchantId:       json['merchant_id'] as int,
      merchantUserId:   json['merchant_user_id'] as String,
      description:      json['description'] as String? ?? '',
      weightKg:         (json['weight_kg'] as num).toDouble(),
      dimensions:       json['dimensions'] as String? ?? '',
      totalFee:         (json['total_fee'] as num).toDouble(),
      status:           ShipmentStatus.fromString(json['status'] as String),
      remark:           json['remark'] as String? ?? '',
      courierCompanyId: json['courier_company_id'] as int,
      assignedDriverId: json['assigned_driver_id'] as int,
      startAddress:     json['start_address'] as String,
      startAddressContactName:       json['start_address_contact_name'] as String? ?? '',
      startAddressPhoneNumber:       json['start_address_phone_number'] as String? ?? '',
      startAddressAdditionalContact: json['start_address_additional_contact'] as String? ?? '',
      endAddress:       json['end_address'] as String,
      endAddressContactName:         json['end_address_contact_name'] as String? ?? '',
      endAddressPhoneNumber:         json['end_address_phone_number'] as String? ?? '',
      endAddressAdditionalContact:   json['end_address_additional_contact'] as String? ?? '',
      rating:           (json['rating'] as num).toDouble(),
      webhookUrl:       json['webhook_url'] as String? ?? '',
      createdAt:        DateTime.parse(json['created_at'] as String),
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      deliveredAt:       _parseDate(json['delivered_at']),
      assignedToCourierAt: _parseDate(json['assigned_to_courier_at']),
      assignedToDriverAt: _parseDate(json['assigned_to_driver_at']),
      pickedUpAt:        _parseDate(json['picked_up_at']),
      inTransitAt:       _parseDate(json['in_transit_at']),
      failedAt:          _parseDate(json['failed_at']),
      returnedAt:        _parseDate(json['returned_at']),
      cancelledAt:       _parseDate(json['cancelled_at']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value as String);
  }
}

// ─── Paginated result ─────────────────────────────────────────────────────────

class ShipmentPage {
  const ShipmentPage({
    required this.shipments,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  final List<Shipment> shipments;
  final int total;
  final int page;
  final int pageSize;

  factory ShipmentPage.fromJson(Map<String, dynamic> json) {
    final list = (json['shipments'] as List<dynamic>? ?? [])
        .map((e) => Shipment.fromJson(e as Map<String, dynamic>))
        .toList();

    return ShipmentPage(
      shipments: list,
      total:     json['total'] as int,
      page:      json['page'] as int,
      pageSize:  json['page_size'] as int,
    );
  }
}
