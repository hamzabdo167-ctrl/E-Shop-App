import 'package:dio/dio.dart';
import 'product_model.dart';

class ApiService {
  late final Dio _dio;

  ApiService({String? token}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.escuelajs.co/api/v1',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
      ),
    );

    // تم إيقاف responseBody لتجنب كراش الميموري في الويب
    _dio.interceptors.add(
      LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: false,
        error: true,
      ),
    );
  }

  Future<List<Product>> fetchProducts({int offset = 0, int limit = 10}) async {
    try {
      final response = await _dio.get(
        '/products',
        queryParameters: {'offset': offset, 'limit': limit},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('فشل في تحميل البيانات: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع: $e');
    }
  }

  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'انتهت مهلة الاتصال بالخادم، يرجى التحقق من اتصال الإنترنت.';
      case DioExceptionType.badResponse:
        return 'خطأ من الخادم: ${error.response?.statusCode} - ${error.response?.statusMessage}';
      case DioExceptionType.connectionError:
        return 'لا يوجد اتصال بالإنترنت.';
      case DioExceptionType.cancel:
        return 'تم إلغاء الطلب.';
      default:
        return 'حدث خطأ في الاتصال: ${error.message}';
    }
  }
}
