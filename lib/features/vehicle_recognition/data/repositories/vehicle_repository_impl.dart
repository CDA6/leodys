import 'package:leodys/features/vehicle_recognition/data/services/vehicle_recongnition_service.dart';
import 'package:leodys/features/vehicle_recognition/domain/repositories/vehicle_repository.dart';

class VehicleRepositoryImpl implements VehicleRepository{

  final VehicleRecognitionService vehicleRecognitionService;
  VehicleRepositoryImpl(this.vehicleRecognitionService);

  @override
  Future<String?> identifyVehicle(String plate) {
    // TODO: implement identifyVehicle
    throw UnimplementedError();
  }


}