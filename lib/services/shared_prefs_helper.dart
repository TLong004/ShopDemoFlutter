import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Lưu ID sản phẩm đã thanh toán vào danh sách
  static Future<void> saveCheckedOutProductId(int id) async {
    List<String> checkedOutIds = _prefs.getStringList('checked_out_ids') ?? [];
    if (!checkedOutIds.contains(id.toString())) {
      checkedOutIds.add(id.toString());
      await _prefs.setStringList('checked_out_ids', checkedOutIds);
    }
  }
  
  static bool isProductCheckedOut(int id) {
    List<String> checkedOutIds = _prefs.getStringList('checked_out_ids') ?? [];
    return checkedOutIds.contains(id.toString());
  }
} 