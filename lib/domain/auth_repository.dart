import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

import '/core/core.dart';
import '/data/data.dart';
import 'domain.dart';

abstract class IAuthRepository {
  /// Kullanıcı kayıt işlemi
  Future<Result<VerifyTokenResponse>> registerUser({
    required String email,
    required String password,
  });

  /// Kullanıcı giriş işlemi
  Future<Result<VerifyTokenResponse>> loginUser({
    required String email,
    required String password,
  });

  /// Kullanıcı çıkış işlemi
  Future<Result<void>> logoutUser();

  /// Mevcut kullanıcıyı getir
  User? getCurrentUser();
}

@Injectable(as: IAuthRepository)
class AuthRepository implements IAuthRepository {
  const AuthRepository({
    required this.auth,
    required this.authClient,
    required this.storageRepository,
  });

  final FirebaseAuth auth;
  final AuthClient authClient;
  final IStorageRepository storageRepository;

  @override
  Future<Result<VerifyTokenResponse>> registerUser({
    required String email,
    required String password,
  }) async {
    try {
      // Firebase'e kullanıcı kaydı
      final credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        return Result.failure(
          const AuthFailure(message: 'Kullanıcı oluşturulamadı'),
        );
      }

      // Firebase'den token al
      final idToken = await credential.user!.getIdToken();
      if (idToken == null) {
        return Result.failure(const AuthFailure(message: 'Token alınamadı'));
      }

      // Kayıt başarılı - kullanıcı bilgilerini döndür
      final user = credential.user!;
      final verifyResponse = VerifyTokenResponse(
        email: user.email ?? email,
        id: user.uid,
        createdAt: DateTime.now().toIso8601String(),
      );

      // Register işleminden sonra kullanıcıyı logout yap
      // Böylece kullanıcının tekrar login yapması gerekir
      await auth.signOut();

      return Result.success(verifyResponse);
    } on FirebaseAuthException catch (e) {
      return Result.failure(AuthFailure(message: _getAuthErrorMessage(e.code)));
    } on Exception catch (e) {
      return Result.failure(
        AuthFailure(message: 'Beklenmeyen bir hata oluştu: $e'),
      );
    }
  }

  @override
  Future<Result<VerifyTokenResponse>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      // Firebase'e giriş yap
      final credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        return Result.failure(const AuthFailure(message: 'Giriş yapılamadı'));
      }

      // Firebase'den yeni token al
      final idToken = await credential.user!.getIdToken();
      if (idToken == null) {
        return Result.failure(const AuthFailure(message: 'Token alınamadı'));
      }

      // Yeni token'ı storage'a kaydet (AuthInterceptor'ın kullanması için)
      await storageRepository.setIdToken(idToken);

      final verifyResponse = await authClient.verifyToken();

      return Result.success(verifyResponse);
    } on FirebaseAuthException catch (e) {
      return Result.failure(AuthFailure(message: _getAuthErrorMessage(e.code)));
    } on Exception catch (e) {
      return Result.failure(
        AuthFailure(message: 'Beklenmeyen bir hata oluştu: $e'),
      );
    }
  }

  @override
  Future<Result<void>> logoutUser() async {
    try {
      await auth.signOut();
      return Result.success(null);
    } on Exception catch (e) {
      return Result.failure(
        AuthFailure(message: 'Çıkış yapılırken hata oluştu: $e'),
      );
    }
  }

  @override
  User? getCurrentUser() {
    return auth.currentUser;
  }

  /// Firebase Auth hata kodlarını Türkçe mesajlara çevir
  String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı';
      case 'wrong-password':
        return 'Hatalı şifre';
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kullanımda';
      case 'weak-password':
        return 'Şifre çok zayıf. En az 6 karakter olmalı';
      case 'invalid-email':
        return 'Geçersiz e-posta adresi';
      case 'user-disabled':
        return 'Bu kullanıcı hesabı devre dışı bırakılmış';
      case 'too-many-requests':
        return 'Çok fazla başarısız deneme. Lütfen daha sonra tekrar deneyin';
      case 'operation-not-allowed':
        return 'Bu işlem şu anda izin verilmiyor';
      default:
        return 'Kimlik doğrulama hatası: $errorCode';
    }
  }
}
