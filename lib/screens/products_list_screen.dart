import 'dart:io';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/app_settings.dart';
import '../services/database_helper.dart';
import '../services/settings_service.dart';
import '../services/pdf_service.dart';
import 'product_form_screen.dart';
import 'settings_screen.dart';

class ProductsListScreen extends StatefulWidget {
  const ProductsListScreen({super.key});
  @override
  State<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> {
  List<Product> _products = [];
  AppSettings _settings = AppSettings();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await DatabaseHelper.instance.getAll();
    final settings = await SettingsService.load();
    setState(() { 
      _products = list; 
      _settings = settings;
      _loading = false; 
    });
  }

  Future<void> _openForm([Product? product]) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ProductFormScreen(product: product)),
    );
    if (saved == true) _load();
  }

  Future<void> _openSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
    _load(); // إعادة تحميل الإعدادات بعد الرجوع
  }

  Future<void> _delete(Product p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف'),
        content: Text('متأكد من حذف "${p.name}"؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حذف')),
        ],
      ),
    );
    if (ok == true) {
      await DatabaseHelper.instance.delete(p.id!);
      _load();
    }
  }

  Future<void> _exportPdf() async {
    if (_products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لا يوجد منتجات لتصديرها')));
      return;
    }
    try {
      await PdfService.generateAndSave(_products, _settings);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('قائمة الأسعار'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'إعدادات الشركة',
            onPressed: _openSettings,
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'تصدير PDF',
            onPressed: _exportPdf,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? const Center(
                  child: Text('لا يوجد منتجات بعد\nاضغط + لإضافة منتج',
                      textAlign: TextAlign.center, style: TextStyle(fontSize: 16)))
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: _products.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (_, i) {
                    final p = _products[i];
                    return ListTile(
                      leading: p.imagePath != null && File(p.imagePath!).existsSync()
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(File(p.imagePath!),
                                  width: 50, height: 50, fit: BoxFit.cover))
                          : Container(
                              width: 50, height: 50,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.image)),
                      title: Text(p.name),
                      subtitle: p.category != null ? Text(p.category!) : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${p.price}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          PopupMenuButton<String>(
                            onSelected: (v) {
                              if (v == 'edit') _openForm(p);
                              if (v == 'delete') _delete(p);
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: 'edit', child: Text('تعديل')),
                              PopupMenuItem(value: 'delete', child: Text('حذف')),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
