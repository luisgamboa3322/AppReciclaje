import 'dart:async';
import 'package:dio/dio.dart';
import '../models/pecox_models.dart';
import 'token_storage.dart';

enum ApiFailure {
  network,
  timeout,
  unauthorized,
  conflict,
  validation,
  invalidImage,
  modelUnavailable,
  serverError,
}

class ApiException implements Exception {
  const ApiException({
    required this.failure,
    required this.message,
    this.statusCode,
  });

  final ApiFailure failure;
  final String message;
  final int? statusCode;

  @override
  String toString() => 'ApiException($failure, status=$statusCode): $message';
}

class ApiUserDto {
  const ApiUserDto({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory ApiUserDto.fromJson(Map<String, dynamic> json) {
    return ApiUserDto(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: (json['role'] as String?) ?? 'user',
    );
  }

  final String id;
  final String name;
  final String email;
  final String role;
}

class AuthSessionDto {
  const AuthSessionDto({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthSessionDto.fromJson(Map<String, dynamic> json) {
    return AuthSessionDto(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      user: ApiUserDto.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  final String accessToken;
  final String refreshToken;
  final ApiUserDto user;
}

class ApiClassificationDto {
  const ApiClassificationDto({
    required this.id,
    required this.predictedMaterial,
    required this.confirmedMaterial,
    required this.confidence,
    required this.modelVersion,
    required this.createdAtUtc,
  });

  factory ApiClassificationDto.fromJson(Map<String, dynamic> json) {
    return ApiClassificationDto(
      id: json['id'] as String,
      predictedMaterial: materialKeyFromApi(json['predicted_material'] as String),
      confirmedMaterial: materialKeyFromApi(json['confirmed_material'] as String),
      confidence: (json['confidence'] as num?)?.toDouble(),
      modelVersion: json['model_version'] as String,
      createdAtUtc: DateTime.parse(json['created_at'] as String).toUtc(),
    );
  }

  final String id;
  final MaterialKey predictedMaterial;
  final MaterialKey confirmedMaterial;
  final double? confidence;
  final String modelVersion;
  final DateTime createdAtUtc;
}

class ApiGuideDto {
  const ApiGuideDto({
    required this.materialKey,
    required this.title,
    required this.instructions,
  });

  factory ApiGuideDto.fromJson(Map<String, dynamic> json) {
    return ApiGuideDto(
      materialKey: materialKeyFromApi(json['material_key'] as String),
      title: json['title'] as String,
      instructions: json['instructions'] as String,
    );
  }

  final MaterialKey materialKey;
  final String title;
  final String instructions;
}

abstract class PecoxApiGateway {
  Future<AuthSessionDto> register({
    required String name,
    required String email,
    required String password,
  });

  Future<AuthSessionDto> login({
    required String email,
    required String password,
  });

  Future<ApiUserDto> fetchMe();

  Future<ModelInfoModel> fetchModelInfo();

  Future<List<ApiGuideDto>> fetchGuides();

  Future<PredictionResultModel> predictImage(String imagePath);

  Future<List<ApiClassificationDto>> listClassifications({
    MaterialKey? material,
    int limit = 50,
    int offset = 0,
  });

  Future<ApiClassificationDto> createClassification({
    required MaterialKey predictedMaterial,
    required double? confidence,
    required MaterialKey? confirmedMaterial,
    required String modelVersion,
  });

  Future<ApiClassificationDto> updateClassification({
    required String id,
    required MaterialKey confirmedMaterial,
  });

  Future<void> deleteClassification(String id);
}

class DioPecoxApiGateway implements PecoxApiGateway {
  DioPecoxApiGateway({
    required String baseUrl,
    required TokenStorage tokenStorage,
    Dio? dio,
  })  : _tokenStorage = tokenStorage,
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl,
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 25),
                sendTimeout: const Duration(seconds: 20),
                headers: const {'Accept': 'application/json'},
              ),
            ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final isAuthEndpoint = options.path.startsWith('/auth/');
          if (!isAuthEndpoint && !options.headers.containsKey('Authorization')) {
            final token = await _tokenStorage.readAccessToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final statusCode = error.response?.statusCode;
          final requestOptions = error.requestOptions;
          final alreadyRetried = requestOptions.extra['_retried'] == true;
          final isAuthPath = requestOptions.path.startsWith('/auth/');

          if (statusCode == 401 && !alreadyRetried && !isAuthPath) {
            final refreshed = await _refreshTokens();
            if (refreshed != null) {
              requestOptions.extra['_retried'] = true;
              requestOptions.headers['Authorization'] = 'Bearer $refreshed';
              try {
                final response = await _dio.fetch<dynamic>(requestOptions);
                handler.resolve(response);
                return;
              } on DioException catch (retryErr) {
                handler.next(retryErr);
                return;
              }
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  final Dio _dio;
  final TokenStorage _tokenStorage;
  Future<String?>? _refreshInFlight;

  Future<String?> _refreshTokens() async {
    if (_refreshInFlight != null) {
      return _refreshInFlight;
    }
    final completer = Completer<String?>();
    _refreshInFlight = completer.future;
    try {
      final refreshToken = await _tokenStorage.readRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        completer.complete(null);
        return null;
      }
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      final data = response.data;
      if (data == null) {
        await _tokenStorage.clear();
        completer.complete(null);
        return null;
      }
      final session = AuthSessionDto.fromJson(data);
      await _tokenStorage.saveTokens(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
      );
      completer.complete(session.accessToken);
      return session.accessToken;
    } catch (_) {
      await _tokenStorage.clear();
      completer.complete(null);
      return null;
    } finally {
      _refreshInFlight = null;
    }
  }

  ApiException _mapDioError(DioException exc) {
    if (exc.type == DioExceptionType.connectionTimeout ||
        exc.type == DioExceptionType.receiveTimeout ||
        exc.type == DioExceptionType.sendTimeout) {
      return const ApiException(
        failure: ApiFailure.timeout,
        message: 'La solicitud tardó demasiado. Verifica tu conexión e inténtalo otra vez.',
      );
    }

    if (exc.type == DioExceptionType.connectionError || exc.response == null) {
      return const ApiException(
        failure: ApiFailure.network,
        message: 'No pudimos conectar con el servidor de PECOX.',
      );
    }

    final status = exc.response?.statusCode ?? 500;
    final body = exc.response?.data;
    final serverDetail = body is Map<String, dynamic> && body['detail'] is String
        ? body['detail'] as String
        : null;

    if (status == 401) {
      return ApiException(
        failure: ApiFailure.unauthorized,
        statusCode: status,
        message: serverDetail ?? 'Tu sesión expiró o las credenciales son incorrectas.',
      );
    }
    if (status == 409) {
      return ApiException(
        failure: ApiFailure.conflict,
        statusCode: status,
        message: serverDetail ?? 'Ya existe una cuenta con ese correo electrónico.',
      );
    }
    if (status == 400 || status == 413) {
      return ApiException(
        failure: ApiFailure.invalidImage,
        statusCode: status,
        message: serverDetail ?? 'La imagen no tiene un formato válido o excede el límite.',
      );
    }
    if (status == 422) {
      return const ApiException(
        failure: ApiFailure.validation,
        statusCode: 422,
        message: 'Revisa los datos ingresados; hay campos inválidos.',
      );
    }
    if (status == 503) {
      return ApiException(
        failure: ApiFailure.modelUnavailable,
        statusCode: status,
        message: serverDetail ??
            'El modelo ML no está disponible en el servidor en este momento.',
      );
    }
    return ApiException(
      failure: ApiFailure.serverError,
      statusCode: status,
      message: serverDetail ?? 'El servidor devolvió un error ($status).',
    );
  }

  DioMediaType _inferImageMediaType(String imagePath) {
    final lower = imagePath.toLowerCase();
    if (lower.endsWith('.png')) return DioMediaType('image', 'png');
    if (lower.endsWith('.webp')) return DioMediaType('image', 'webp');
    return DioMediaType('image', 'jpeg');
  }

  @override
  Future<AuthSessionDto> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/register',
        data: {'name': name, 'email': email, 'password': password},
      );
      return AuthSessionDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<AuthSessionDto> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return AuthSessionDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<ApiUserDto> fetchMe() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/users/me');
      return ApiUserDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<ModelInfoModel> fetchModelInfo() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/model/info');
      final json = response.data!;
      return ModelInfoModel(
        status: json['status'] as String,
        activeVersion: json['active_version'] as String?,
        architecture: json['architecture'] as String?,
        identifiedThreshold: (json['identified_threshold'] as num?)?.toDouble(),
        lowConfidenceThreshold:
            (json['low_confidence_threshold'] as num?)?.toDouble(),
        note: json['note'] as String,
      );
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<List<ApiGuideDto>> fetchGuides() async {
    try {
      final response = await _dio.get<List<dynamic>>('/guides');
      return (response.data ?? const [])
          .map((item) => ApiGuideDto.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<PredictionResultModel> predictImage(String imagePath) async {
    try {
      final fileName = imagePath.split(RegExp(r'[/\\]')).last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imagePath,
          filename: fileName.isEmpty ? 'capture.jpg' : fileName,
          contentType: _inferImageMediaType(imagePath),
        ),
      });
      final response = await _dio.post<Map<String, dynamic>>(
        '/predict',
        data: formData,
      );
      final json = response.data!;
      final rawAlts = (json['alternatives'] as List<dynamic>? ?? const []);
      return PredictionResultModel(
        predictionId: json['prediction_id'] as String,
        material: materialKeyFromApi(json['material'] as String),
        confidence: (json['confidence'] as num).toDouble(),
        alternatives: rawAlts
            .map(
              (alt) => MaterialAlternative(
                key: materialKeyFromApi(alt['material'] as String),
                confidence: (((alt['confidence'] as num).toDouble()) * 100)
                    .round()
                    .clamp(0, 100),
              ),
            )
            .toList(),
        modelVersion: json['model_version'] as String,
        architecture: json['architecture'] as String,
        status: predictionStatusFromApi(json['status'] as String),
        inferenceMs: (json['inference_ms'] as num).toDouble(),
      );
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<List<ApiClassificationDto>> listClassifications({
    MaterialKey? material,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/classifications',
        queryParameters: {
          if (material != null) 'material': materialKeyToApi(material),
          'limit': limit,
          'offset': offset,
        },
      );
      final items = (response.data?['items'] as List<dynamic>? ?? const []);
      return items
          .map((item) => ApiClassificationDto.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<ApiClassificationDto> createClassification({
    required MaterialKey predictedMaterial,
    required double? confidence,
    required MaterialKey? confirmedMaterial,
    required String modelVersion,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/classifications',
        data: {
          'predicted_material': materialKeyToApi(predictedMaterial),
          'confidence': confidence,
          if (confirmedMaterial != null)
            'confirmed_material': materialKeyToApi(confirmedMaterial),
          'model_version': modelVersion,
        },
      );
      return ApiClassificationDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<ApiClassificationDto> updateClassification({
    required String id,
    required MaterialKey confirmedMaterial,
  }) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/classifications/$id',
        data: {'confirmed_material': materialKeyToApi(confirmedMaterial)},
      );
      return ApiClassificationDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<void> deleteClassification(String id) async {
    try {
      await _dio.delete<void>('/classifications/$id');
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }
}
