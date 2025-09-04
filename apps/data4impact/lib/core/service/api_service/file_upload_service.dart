import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FileUploadService {
  final Dio dio;
  final FlutterSecureStorage secureStorage;

  FileUploadService({required this.dio, required this.secureStorage});

  Future<Map<String, dynamic>> uploadAudioFile(
      String studyId,
      String filePath,
      ) async {
    try {
      final cookie = await secureStorage.read(key: 'session_cookie');
      if (cookie == null) {
        throw Exception('No authentication cookie found');
      }

      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Audio file does not exist');
      }

      final fileName = file.path.split('/').last;

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        ),
      });

      final response = await dio.post(
        '/files/$studyId/upload',
        data: formData,
        options: Options(
          headers: {
            'Cookie': cookie,
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      return response.data as Map<String,dynamic>;
    } on DioException catch (e) {
      print('Upload error: ${e.response?.data}');
      rethrow;
    }
  }
}