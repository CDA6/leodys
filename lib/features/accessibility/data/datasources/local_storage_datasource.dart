import 'package:hive/hive.dart';
import '../models/settings_model.dart';

abstract class LocalStorageDatasource {
  Future<SettingsModel?> getSettings();
  Future<void> saveSettings(SettingsModel settings);
  Future<void> deleteSettings();
}

class HiveLocalStorageDatasource implements LocalStorageDatasource {
  static const String _boxName = 'accessibility_settings';
  static const String _settingsKey = 'settings';

  @override
  Future<SettingsModel?> getSettings() async {
    final box = await Hive.openBox(_boxName);
    final savedSettings = box.get(_settingsKey);

    if (savedSettings != null) {
      return SettingsModel.fromJson(
        Map<String, dynamic>.from(savedSettings),
      );
    }
    return null;
  }

  @override
  Future<void> saveSettings(SettingsModel settings) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_settingsKey, settings.toJson());
  }

  @override
  Future<void> deleteSettings() async {
    final box = await Hive.openBox(_boxName);
    await box.delete(_settingsKey);
  }
}