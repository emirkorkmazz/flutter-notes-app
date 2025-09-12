/// Result sınıfı - başarılı veya başarısız sonuçları temsil eder
sealed class Result<T> {
  const Result();

  /// Başarılı sonuç oluştur
  factory Result.success(T data) = Success<T>;

  /// Başarısız sonuç oluştur
  factory Result.failure(AuthFailure failure) = Failure<T>;

  /// Sonucun başarılı olup olmadığını kontrol et
  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  /// Başarılı sonuçta data'yı, başarısız sonuçta failure'ı döndür
  T? get data => isSuccess ? (this as Success<T>).data : null;
  AuthFailure? get failure => isFailure ? (this as Failure<T>).failure : null;

  /// fold metodu - başarılı veya başarısız duruma göre işlem yapar
  R fold<R>(
    R Function(AuthFailure failure) onFailure,
    R Function(T data) onSuccess,
  ) {
    if (isSuccess) {
      return onSuccess((this as Success<T>).data);
    } else {
      return onFailure((this as Failure<T>).failure);
    }
  }
}

/// Başarılı sonuç
class Success<T> extends Result<T> {
  const Success(this.data);
  @override
  final T data;
}

/// Başarısız sonuç
class Failure<T> extends Result<T> {
  const Failure(this.failure);
  @override
  final AuthFailure failure;
}

/// Auth hata sınıfı
class AuthFailure {
  const AuthFailure({required this.message});
  final String message;

  @override
  String toString() => 'AuthFailure: $message';
}
