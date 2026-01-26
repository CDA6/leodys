import 'package:leodys/common/mixins/connectivity_mixin.dart';
import 'package:leodys/features/ocr-reader/presentation/viewmodels/base_ocr_viewmodel.dart';

class HandwrittenTextViewModel extends BaseOcrViewModel with ConnectivityMixin{

  HandwrittenTextViewModel({required super.recognizeTextUseCase}) {
    initConnectivity();
  }

  @override
  bool get canAnalyze {
    return super.canAnalyze && hasConnection;
  }

  @override
  Future<void> analyzeImage() async {
    if (!hasConnection) {
      notifyListeners();
      return;
    }
    await super.analyzeImage();
  }
}