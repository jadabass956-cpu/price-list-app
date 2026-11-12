import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';

class SettingsService {
  static const _kName = 'company_name';
  static const _kAddress = 'company_address';
  static const _kPhone = 'company_phone';
  static const _kWhatsapp = 'company_whatsapp';

  static Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings(
      companyName: prefs.getString(_kName) ?? 'اسم الشركة',
      address: prefs.getString(_kAddress) ?? 'العنوان هنا',
      phone: prefs.getString(_kPhone) ?? '',
      whatsapp: prefs.getString(_kWhatsapp) ?? '',
    );
  }

  static Future<void> save(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kName, settings.companyName);
    await prefs.setString(_kAddress, settings.address);
    await prefs.setString(_kPhone, settings.phone);
    await prefs.setString(_kWhatsapp, settings.whatsapp);
  }
}
