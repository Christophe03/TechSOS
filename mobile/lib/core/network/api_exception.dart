import 'dart:io';
import 'package:dio/dio.dart';

/// Exception personnalisée pour les erreurs réseau et API TechSOS
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  const ApiException({
    required this.message,
    this.statusCode,
    this.details,
  });

  /// Convertit une exception Dio en ApiException avec message en français clair
  factory ApiException.fromDioException(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const ApiException(
          message: 'Connexion impossible. Vérifiez votre accès internet.',
        );

      case DioExceptionType.badResponse:
        final response = dioException.response;
        final statusCode = response?.statusCode;
        final data = response?.data;

        String? serverMessage;
        if (data is Map<String, dynamic>) {
          final rawMsg = data['message'];
          if (rawMsg is String) {
            serverMessage = rawMsg;
          } else if (rawMsg is List && rawMsg.isNotEmpty) {
            serverMessage = rawMsg.join(', ');
          }
        }

        switch (statusCode) {
          case 401:
            return ApiException(
              message: serverMessage ?? 'Identifiants invalides ou session expirée.',
              statusCode: statusCode,
              details: data,
            );
          case 403:
            return ApiException(
              message: serverMessage ?? 'Action non autorisée.',
              statusCode: statusCode,
              details: data,
            );
          case 404:
            return ApiException(
              message: serverMessage ?? 'Ressource introuvable.',
              statusCode: statusCode,
              details: data,
            );
          case 409:
            return ApiException(
              message: serverMessage ?? 'Cet élément existe déjà.',
              statusCode: statusCode,
              details: data,
            );
          case 500:
          case 502:
          case 503:
          case 504:
            return ApiException(
              message: 'Erreur serveur. Veuillez réessayer plus tard.',
              statusCode: statusCode,
              details: data,
            );
          default:
            return ApiException(
              message: serverMessage ?? 'Une erreur inattendue est survenue.',
              statusCode: statusCode,
              details: data,
            );
        }

      case DioExceptionType.cancel:
        return const ApiException(
          message: 'La requête a été annulée.',
        );

      case DioExceptionType.unknown:
      default:
        if (dioException.error is SocketException) {
          return const ApiException(
            message: 'Connexion impossible. Vérifiez votre accès internet.',
          );
        }
        return ApiException(
          message: dioException.message ?? 'Connexion impossible. Vérifiez votre accès internet.',
        );
    }
  }

  @override
  String toString() => message;
}
