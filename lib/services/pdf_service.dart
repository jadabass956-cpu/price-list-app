import 'dart:io';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/product.dart';
import '../models/app_settings.dart';

class PdfService {
  static Future<void> generateAndPrint(List<Product> products, AppSettings settings) async {
    final pdf = pw.Document();
    final fontData = await rootBundle.load('assets/fonts/Cairo-Regular.ttf');
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
                  // ======= الهيدر (Header) =======
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(settings.companyName, style: pw.TextStyle(font: ttf, fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                          pw.SizedBox(height: 4),
                          pw.Text(settings.address, style: pw.TextStyle(font: ttf, fontSize: 10, color: PdfColors.grey700)),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text('قائمة الأسعار', style: pw.TextStyle(font: ttf, fontSize: 18, fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 4),
                          pw.Text('صفحة ${i + 1} من ${pages.length}', style: pw.TextStyle(font: ttf, fontSize: 10, color: PdfColors.grey700)),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 10),
                  pw.Divider(thickness: 1, color: PdfColors.grey400),
                  pw.SizedBox(height: 10),

                  // ======= الجدول (Table) =======
                  pw.Expanded(
                    child: pw.Table(
                      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                      columnWidths: {
                        0: const pw.FixedColumnWidth(50), // الصورة
                        1: const pw.FlexColumnWidth(3),  // الاسم
                        2: const pw.FlexColumnWidth(1.5),// التصنيف
                        3: const pw.FlexColumnWidth(1),  // السعر
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
                          if (product.imagePath != null && File(product.imagePath!).existsSync()) {
                            image = pw.MemoryImage(File(product.imagePath!).readAsBytesSync());
                          }
                          return pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(4),
                                child: image != null
                                    ? pw.Image(image, fit: pw.BoxFit.cover, width: 40, height: 40)
                                    : pw.Container(width: 40, height: 40, color: PdfColors.grey100),
                              ),
                              _buildCell(product.name, ttf),
                              _buildCell(product.category ?? '-', ttf),
                              _buildCell('${product.price}', ttf),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  
                  pw.SizedBox(height: 10),
                  // ======= الفوتر (Footer) =======
                  pw.Divider(thickness: 0.5, color: PdfColors.grey300),
                  pw.SizedBox(height: 5),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      if (settings.phone.isNotEmpty) ...[
                        pw.Icon(const pw.IconData(0xe0b0), color: PdfColors.blue800, size: 14), // أيقونة هاتف
                        pw.SizedBox(width: 4),
                        pw.Text(settings.phone, style: pw.TextStyle(font: ttf, fontSize: 11)),
                        pw.SizedBox(width: 20),
                      ],
                      if (settings.whatsapp.isNotEmpty) ...[
                        pw.Icon(const pw.IconData(0xe158), color: PdfColors.green800, size: 14), // أيقونة رسالة (واتساب)
                        pw.SizedBox(width: 4),
                        pw.Text(settings.whatsapp, style: pw.TextStyle(font: ttf, fontSize: 11)),
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

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Price_List.pdf',
    );
  }

  static pw.Widget _buildCell(String text, pw.Font font, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: isHeader ? 12 : 11,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}
