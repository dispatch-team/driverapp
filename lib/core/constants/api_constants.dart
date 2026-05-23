class ApiConstants {
  ApiConstants._();

  static const String driversLogin = '/drivers/login';
  static const String driversProfile = '/drivers/profile';
  static const String shipments = '/shipments';

  static String shipmentPickUp(String code) => '/shipments/$code/pick-up';
  static String shipmentVerifyDelivery(String code) =>
      '/shipments/$code/verify-delivery';
  static String shipmentFail(String code) => '/shipments/$code/fail';
}
