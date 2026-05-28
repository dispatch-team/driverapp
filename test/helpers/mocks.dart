import 'package:driverapp/core/services/api_client.dart';
import 'package:driverapp/data/providers/auth_provider.dart';
import 'package:driverapp/data/providers/profile_provider.dart';
import 'package:driverapp/data/providers/shipment_provider.dart';
import 'package:driverapp/data/repositories/auth_repository.dart';
import 'package:driverapp/data/repositories/profile_repository.dart';
import 'package:driverapp/data/repositories/shipment_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockAuthProvider extends Mock implements AuthProvider {}

class MockProfileProvider extends Mock implements ProfileProvider {}

class MockShipmentProvider extends Mock implements ShipmentProvider {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockShipmentRepository extends Mock implements ShipmentRepository {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}
