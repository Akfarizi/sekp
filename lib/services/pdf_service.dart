import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';

class ExportService {
  static pw.Document generatePDF() {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (_) => pw.Text("Laporan Kinerja Karyawan"),
      ),
    );
    return pdf;
  }

  static Excel generateExcel() {
    final excel = Excel.createExcel();
    final sheet = excel['Laporan'];
    sheet.appendRow(["Nama", "Disiplin", "Etos"]);
    return excel;
  }
}
