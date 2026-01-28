import 'dart:io';

import 'package:leodys/features/vehicle_recognition/data/services/vehicle_recongnizer_service.dart';
import 'package:leodys/features/vehicle_recognition/domain/models/plate_scan.dart';
import 'package:leodys/features/vehicle_recognition/domain/models/vehicle_info.dart';
import 'package:leodys/features/vehicle_recognition/domain/repositories/vehicle_repository.dart';

class VehicleRepositoryImpl implements VehicleRepository{

  final VehicleRecognizerService vehicleRecognitionService;
  VehicleRepositoryImpl(this.vehicleRecognitionService);

  @override
  Future<VehicleInfo?> identifyVehicle(File image) {
    return vehicleRecognitionService.recognizeVehicle(image);
  }


}