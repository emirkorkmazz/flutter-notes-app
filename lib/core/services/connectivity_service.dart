import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@Injectable()
class ConnectivityService {
  ConnectivityService() {
    // İlk durumu false olarak ayarla, sonra asenkron güncellenecek
    _isConnected = false;
    _initConnectivity();
  }

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  /// Bağlantı durumu stream'i
  Stream<bool> get connectionStream => _connectionController.stream;

  /// Bağlantı durumunu initialize et
  Future<void> _initConnectivity() async {
    // İlk durum kontrolü - senkron olarak ayarla
    try {
      final initialConnection = await _checkRealConnectivity();
      _isConnected = initialConnection;
      _connectionController.add(_isConnected);
      debugPrint(
        '🌐 İlk bağlantı durumu: ${_isConnected ? "Bağlı" : "Bağlı değil"}',
      );
    } catch (e) {
      _isConnected = false;
      _connectionController.add(_isConnected);
      debugPrint('🌐 İlk bağlantı kontrolü başarısız: $e');
    }

    // Connectivity plugin'i dinle (eğer çalışıyorsa)
    try {
      _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
      debugPrint('📡 Connectivity plugin başlatıldı');
    } catch (e) {
      debugPrint('⚠️ Connectivity plugin hatası: $e');
      // Plugin çalışmıyorsa periyodik kontrol yap
      _startPeriodicCheck();
    }
  }

  /// Periyodik bağlantı kontrolü başlat
  void _startPeriodicCheck() {
    Timer.periodic(const Duration(seconds: 10), (timer) async {
      final isConnected = await _checkRealConnectivity();
      if (_isConnected != isConnected) {
        _isConnected = isConnected;
        _connectionController.add(_isConnected);
      }
    });
  }

  /// Bağlantı durumunu güncelle
  void _updateConnectionStatus(List<ConnectivityResult> result) async {
    final hasNetworkInterface = result.any(
      (result) =>
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet,
    );

    // Network interface varsa gerçek bağlantıyı test et
    if (hasNetworkInterface) {
      final realConnection = await _checkRealConnectivity();
      if (_isConnected != realConnection) {
        _isConnected = realConnection;
        _connectionController.add(_isConnected);
      }
    } else {
      // Network interface yoksa direkt false
      if (_isConnected != false) {
        _isConnected = false;
        _connectionController.add(_isConnected);
      }
    }
  }

  /// Mevcut bağlantı durumunu kontrol et
  Future<bool> checkConnection() async {
    final realConnection = await _checkRealConnectivity();

    if (_isConnected != realConnection) {
      _isConnected = realConnection;
      _connectionController.add(_isConnected);
    }

    return realConnection;
  }

  /// Gerçek internet bağlantısını test et
  Future<bool> _checkRealConnectivity() async {
    try {
      // Google DNS'e ping at
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      try {
        // Alternatif: CloudFlare DNS
        final result = await InternetAddress.lookup('1.1.1.1');
        return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      } catch (e) {
        debugPrint('İnternet bağlantısı testi başarısız: $e');
        return false;
      }
    }
  }

  /// Service'i temizle
  void dispose() {
    _connectionController.close();
  }
}
