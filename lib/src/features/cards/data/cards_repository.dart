import 'dart:io';
import 'package:leodys/src/features/cards/data/cards_remote_datasource.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

class CardsRepository {
  final CardsRemoteDatasource remote;
  CardsRepository(this.remote);

  Future<List<File>> getSavedCards() async {
    final Directory output = await getApplicationDocumentsDirectory();
    final files = output.listSync();
    final pdfFiles = files.whereType<File>().where((f) => f.path.endsWith('.pdf')).toList();
    return pdfFiles;
  }

  Future<File> createPdfFromImages(List<String> imagesPaths) async {
    final pdf = pw.Document();
    for (var path in imagesPaths) {
      final image = pw.MemoryImage(File(path).readAsBytesSync());
      pdf.addPage(pw.Page(build: (pw.Context context) => pw.Center(child: pw.Image(image))));
    }

    final Directory output = await getApplicationDocumentsDirectory();
    final now = DateTime.now();
    final pathFile =
        "${output.path}/pdf-${now.day}-${now.month}-${now.year}-${now.hour}-${now.minute}-${now.second}.pdf";
    final file = File(pathFile);
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  Future<void> uploadCard(File file, String userId, String name) async {
    await remote.uploadPdf(file: file, userId: userId, fileName: name);
  }

  Future<List<String>> getCards(String userId) async {
    return await remote.listUserCards(userId);
  }
}