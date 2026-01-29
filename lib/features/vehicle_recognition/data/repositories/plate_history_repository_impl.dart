import 'package:hive/hive.dart';
import 'package:leodys/features/vehicle_recognition/domain/models/plate_scan.dart';
import 'package:leodys/features/vehicle_recognition/domain/repositories/plate_history_repository.dart';

/// gestion de la sauvegarde des scans
class PlateHistoryRepositoryImpl implements PlateHistoryRepository {

  static const String _boxName = 'plate_box';

  Future<Box> _openBox() async {
    return await Hive.openBox(_boxName);
  }

  @override
  Future<void> deletePlateScan(String plate) async {
    final box = await _openBox();
    await box.delete(plate);
  }

  @override
  Future<List<PlateScan>> getAllPlateScans() async {

    final box = await _openBox();
    final List<PlateScan> plateScans = [];
    for(final key in box.keys){
      final data = box.get(key);
      plateScans.add(
        PlateScan(
            plate: data['plate'],
            vehicleLabel: data['vehicleLabel']
        )
      );
    }
    return plateScans;
  }

  @override
  Future<PlateScan?> getByPlate(String plate) async {
    final box = await _openBox();
    final data = box.get(plate);

    if (data == null){
      return null;
    }

    return PlateScan(
        plate: data['plate'],
        vehicleLabel: data['vehicleLabel']
    );

  }

  @override
  Future<void> savePlateScan(PlateScan ps) async {
    final box = await _openBox();
    await box.put(ps.plate,{
      'plate': ps.plate,
      'vehicleLabel': ps.vehicleLabel,
    });
  }

}