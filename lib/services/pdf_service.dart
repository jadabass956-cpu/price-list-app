import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../models/product.dart';
import '../models/app_settings.dart';

class PdfService {
  static Future<void> generateAndSave(List<Product> products, AppSettings settings) async {
    final pdf = pw.Document();
    final fontData = await rootBundle.load('assets/fonts/Tajawal-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);

    final int itemsPerPage = 10;
    final List<List<Product>> pages = [];
    for (var i = 0; i < products.length; i += itemsPerPage) {
      pages.add(products.sublist(i, i + itemsPerPage > products.length ? products.length : i + itemsPerPage));
    }

    for (var i = 0; i < pages.length; i++) {
      final pageProducts = pages[i];
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            return pw.Directionality(
              textDirection: pw.TextDirection.rtl,
              child: pw.Column(
                children: [
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(settings.companyName, style: pw.TextStyle(font: ttf, fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                          pw.SizedBox(height: 4),
                          pw.Text(settings.address, style: pw.TextStyle(font: ttf, fontSize: 12, color: PdfColors.grey700)),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text('قائمة الأسعار', style: pw.TextStyle(font: ttf, fontSize: 20, fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 4),
                          pw.Text('صفحة ${i + 1} من ${pages.length}', style: pw.TextStyle(font: ttf, fontSize: 12, color: PdfColors.grey700)),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 10),
                  pw.Divider(thickness: 1, color: PdfColors.grey400),
                  pw.SizedBox(height: 10),
                  
                  pw.Expanded(
                    child: pw.Table(
                      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                      columnWidths: {
                        0: const pw.FixedColumnWidth(60),
                        1: const pw.FlexColumnWidth(3),
                        2: const pw.FlexColumnWidth(1.5),
                        3: const pw.FlexColumnWidth(1.2),
                      },
                      children: [
                        pw.TableRow(
                          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                          children: [
                            _buildCell('', ttf, isHeader: true),
                            _buildCell('اسم المنتج', ttf, isHeader: true),
                            _buildCell('التصنيف', ttf, isHeader: true),
                            _buildCell('السعر', ttf, isHeader: true),
                          ],
                        ),
                        ...pageProducts.map((product) {
                          pw.ImageProvider? image;
                          if (product.imagePath != null) {
                            final file = File(product.imagePath!);
                            if (file.existsSync()) {
                              try {
                                image = pw.MemoryImage(file.readAsBytesSync());
                              } catch (_) {}
                            }
                          }
                          
                          return pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(4),
                                child: image != null
                                    ? pw.Image(image, fit: pw.BoxFit.cover, width: 45, height: 45)
                                    : pw.Container(width: 45, height: 45, color: PdfColors.grey100),
                              ),
                              _buildCell(product.name, ttf, isBold: true),
                              _buildCell(product.category ?? '-', ttf),
                              _buildCell('\$ ${product.price}', ttf, isBold: true),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  
                  pw.SizedBox(height: 10),
                  pw.Divider(thickness: 0.5, color: PdfColors.grey300),
                  pw.SizedBox(height: 5),
                  
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      if (settings.phone.isNotEmpty) ...[
                        pw.UrlLink(
                          destination: 'tel:${settings.phone}',
                          child: pw.Text('اتصال: ${settings.phone}', style: pw.TextStyle(font: ttf, fontSize: 12, color: PdfColors.blue900, decoration: pw.TextDecoration.underline)),
                        ),
                        pw.SizedBox(width: 30),
                      ],
                      if (settings.whatsapp.isNotEmpty) ...[
                        pw.UrlLink(
                          destination: 'https://wa.me/${settings.whatsapp}',
                          child: pw.Text('واتساب: ${settings.whatsapp}', style: pw.TextStyle(font: ttf, fontSize: 12, color: PdfColors.green900, decoration: pw.TextDecoration.underline)),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/Price_List_${DateTime.now().millisecondsSinceEpoch}.pdf");
    await file.writeAsBytes(await pdf.save());
    await OpenFilex.open(file.path);
  }

  static pw.Widget _buildCell(String text, pw.Font font, {bool isHeader = false, bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.right,
        style: pw.TextStyle(
          font: font,
          fontSize: isHeader ? 14 : 13,
          fontWeight: (isHeader || isBold) ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}
