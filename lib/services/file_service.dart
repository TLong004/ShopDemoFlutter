import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class FileService {
  static Future<String> saveFile(File file) async {
    final directory = await getApplicationDocumentsDirectory();
    
    final String originalName = basename(file.path);
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String newFileName = '$timestamp-$originalName';

    final String fullPath = join(directory.path, newFileName);

    await file.copy(fullPath);
    print("Đã lưu file $fullPath");

    return fullPath;
  }

  static Future<void> deleteFil(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        print("Đã xóa file $filePath");
      }
    } catch (e) {
      print("Lỗi khi xóa file $filePath: $e");
    }
  }
}