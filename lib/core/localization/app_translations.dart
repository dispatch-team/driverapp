import 'package:get/get.dart';

import '../../data/models/shipment.dart';
import 'am_translations.dart';
import 'en_translations.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': EnTranslations.keys,
    'am_ET': AmTranslations.keys,
  };
}

/// Maps each [ShipmentStatus] to its localization key so views
/// can call `status.labelKey.tr` without modifying the model.
extension ShipmentStatusTr on ShipmentStatus {
  String get labelKey => switch (this) {
    ShipmentStatus.pending           => 'status_pending',
    ShipmentStatus.assignedToCourier => 'status_courier_assigned',
    ShipmentStatus.assignedToDriver  => 'status_driver_assigned',
    ShipmentStatus.inTransit         => 'status_in_transit',
    ShipmentStatus.delivered         => 'status_delivered',
    ShipmentStatus.failed            => 'status_failed',
    ShipmentStatus.returned          => 'status_returned',
    ShipmentStatus.cancelled         => 'status_cancelled',
  };
}
