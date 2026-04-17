import 'package:dio/dio.dart';

class DioExceptions {
  static String fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return "lỗi kết nối quá hạn";
      case DioExceptionType.sendTimeout:
        return "lỗi gửi quá hạn";
      case DioExceptionType.receiveTimeout:
        return "Phản hồi từ server quá chậm";
      case DioExceptionType.badResponse:
        return _handleError(error.response?.statusCode, error.response?.data);
      case DioExceptionType.cancel:
        return "Yêu cầu đã bị hủy";
      case DioExceptionType.unknown:
        return "Đã xảy ra lỗi không xác định: ${error.message}";
      default:
        return "Hệ thống đang gặp sự cố.";
    }
  }

  static String _handleError(int? statusCode, dynamic error) {
    switch (statusCode) {
      case 400:
        return "Yêu cầu không hợp lệ";
      case 401:
        return "Không được phép";
      case 403:
        return "Không có quyền truy cập";
      case 404:
        return "Không tìm thấy tài nguyên";
      case 500:
        return "Lỗi máy chủ nội bộ";
      case 502:
        return "Lỗi cổng kết nối";
      default:
        return "Đã xảy ra lỗi không xác định";
    }
  }
}