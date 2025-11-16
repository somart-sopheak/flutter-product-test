import 'dart:io';
import 'dart:ui';
import 'package:csv/csv.dart';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';


import '../../models/product.dart';

class ExportService {
  static Future<String> _getDownloadsPath() async {
    if (Platform.isAndroid) {
      // Android uses a common 'Download' folder.
      return '/storage/emulated/0/Download';
    } else if (Platform.isIOS) {
      // iOS saves to app's documents directory.
      final dir = await getApplicationDocumentsDirectory();
      return dir.path;
    } else {
      // Desktop (Windows, macOS, Linux)
      final dir = await getDownloadsDirectory();
      return dir?.path ?? (await getApplicationDocumentsDirectory()).path;
    }
  }

  static Future<String> exportToCsv(List<Product> items) async {
    if (items.isEmpty) {
      throw Exception('No products to export');
    }

    final downloadsPath = await _getDownloadsPath();
    final fileName = 'products_${DateTime.now().millisecondsSinceEpoch}.csv';
    final path = '$downloadsPath/$fileName';

    final headers = ['ID', 'Name', 'Price', 'Stock', 'CreatedAt'];
    final rows = items
        .map(
          (p) => [
            p.id ?? '',
            p.name,
            '\$${(p.price).toStringAsFixed(2)}',
            p.stock,
            p.createdAt != null
                ? DateFormat.yMd().add_Hms().format(p.createdAt!)
                : 'N/A',
          ],
        )
        .toList();
    final csvStr = const ListToCsvConverter().convert([headers, ...rows]);
    final file = File(path);
    await file.writeAsString(csvStr);
    return path;
  }

  static Future<String> exportToPdf(List<Product> items) async {
    if (items.isEmpty) {
      throw Exception('No products to export');
    }
    
    final PdfDocument doc = PdfDocument();
    final PdfPage page = doc.pages.add();
    final Size pageSize = page.getClientSize();

    page.graphics.drawString(
      'Product Report',
      PdfStandardFont(PdfFontFamily.helvetica, 20, style: PdfFontStyle.bold),
      bounds: Rect.fromLTWH(0, 0, pageSize.width, 30),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );
    page.graphics.drawString(
      'Generated on: ${DateFormat.yMd().add_Hms().format(DateTime.now())}',
      PdfStandardFont(PdfFontFamily.helvetica, 12),
      bounds: Rect.fromLTWH(0, 30, pageSize.width, 20),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );

    final PdfGrid grid = PdfGrid();
    grid.columns.add(count: 5);
    grid.headers.add(1);

    final PdfGridRow header = grid.headers[0];
    header.cells[0].value = 'ID';
    header.cells[1].value = 'Name';
    header.cells[2].value = 'Price';
    header.cells[3].value = 'Stock';
    header.cells[4].value = 'Created At';

    final PdfGridCellStyle headerStyle = PdfGridCellStyle(
      backgroundBrush: PdfSolidBrush(PdfColor(37, 99, 235)), // Blue
      textBrush: PdfBrushes.white,
      font: PdfStandardFont(
        PdfFontFamily.helvetica,
        10,
        style: PdfFontStyle.bold,
      ),
      format: PdfStringFormat(
        alignment: PdfTextAlignment.center,
        lineAlignment: PdfVerticalAlignment.middle,
      ),
    );

    for (int i = 0; i < header.cells.count; i++) {
      header.cells[i].style = headerStyle;
    }

    final PdfGridCellStyle evenRowStyle = PdfGridCellStyle(
      backgroundBrush: PdfSolidBrush(PdfColor(248, 250, 252)), // Light Gray
    );

    final PdfStringFormat rightAlign =
        PdfStringFormat(alignment: PdfTextAlignment.right);
    final PdfStringFormat centerAlign =
        PdfStringFormat(alignment: PdfTextAlignment.center);

    for (var p in items) {
      final r = grid.rows.add();
      r.cells[0].value = (p.id ?? '').toString();
      r.cells[1].value = p.name;
      r.cells[2].value = '\$${(p.price).toStringAsFixed(2)}';
      r.cells[3].value = (p.stock).toString();
      r.cells[4].value =
          p.createdAt != null ? DateFormat.yMd().format(p.createdAt!) : 'N/A';

      if (items.indexOf(p) % 2 == 0) {
        r.style = evenRowStyle;
      }
      r.cells[0].stringFormat = centerAlign;
      r.cells[2].stringFormat = rightAlign;
      r.cells[3].stringFormat = centerAlign;
      r.cells[4].stringFormat = centerAlign;
    }

    grid.columns[0].width = 40;
    grid.columns[1].width = 150;
    grid.columns[2].width = 80;
    grid.columns[3].width = 60;

    final PdfLayoutResult? gridResult = grid.draw(
      page: page,
      bounds: Rect.fromLTWH(0, 60, pageSize.width, pageSize.height - 60),
      format: PdfLayoutFormat(layoutType: PdfLayoutType.paginate),
    );

    if (gridResult != null) {
      page.graphics.drawString(
        'Total Products: ${items.length}',
        PdfStandardFont(
          PdfFontFamily.helvetica,
          10,
          style: PdfFontStyle.bold,
        ),
        bounds: Rect.fromLTWH(
          0,
          gridResult.bounds.bottom + 10,
          pageSize.width - 10,
          20,
        ),
        format: PdfStringFormat(alignment: PdfTextAlignment.right),
      );
    }

    final bytes = await doc.save();
    doc.dispose();

    final downloadsPath = await _getDownloadsPath();
    final fileName = 'products_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final path = '$downloadsPath/$fileName';
    final file = File(path);
    await file.writeAsBytes(bytes);
    return path;
  }
}