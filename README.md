# Note App Test Case

## ✨ Özellikler

- 🔐 **Firebase Authentication** - Email/şifre ile kullanıcı kaydı ve girişi
- 📝 **Not Yönetimi** - Not oluşturma, düzenleme, silme ve görüntüleme
- 📌 **Not Sabitleme** - Önemli notları sabitleyebilme
- 🏷️ **Etiketleme Sistemi** - Notları kategorize etmek için etiket sistemi
- 💾 **Yerel Depolama** - SQLite ile çevrimdışı not depolama
- 🔄 **Senkronizasyon** - Sunucu ile otomatik veri senkronizasyonu
- 🌐 **Çevrimdışı Çalışma** - İnternet bağlantısı olmadan da kullanılabilir
- 📱 **Responsive Tasarım** - Tüm ekran boyutlarına uyumlu arayüz
- 🎨 **Modern UI** - Material Design prensiplerine uygun tasarım

## 🛠️ Teknik Gereksinimler

| Teknoloji | Versiyon |
|-----------|----------|
| **Flutter** | ≥ 3.24.0 |
| **Dart** | ≥ 3.7.2 |
| **Android** | API 21+ (Android 5.0+) |
| **iOS** | iOS 12.0+ |

## 🚀 Kurulum

### 1. Bağımlılıkları Yükleyin
```bash
flutter pub get
```

### 2. Code Generation Yapın
```bash
# Tüm kod üretimi işlemlerini gerçekleştirin
flutter packages pub run build_runner build --delete-conflicting-outputs

# Veya kısa versiyonu
dart run build_runner build --delete-conflicting-outputs
```

### 3. iOS podlarını yükleyin
```bash
cd ios && pod install
```

### 4. Projeyi Çalıştırın
```bash
flutter run
```

## 📁 Proje Yapısı
lib/
├── app.dart # Ana uygulama widget'ı
├── main.dart # Uygulama giriş noktası
├── core/ # Temel yapılar ve yardımcılar
│ ├── constants/ # Uygulama sabitleri
│ ├── di/ # Dependency injection
│ ├── enums/ # Enum tanımları
│ ├── helpers/ # Yardımcı fonksiyonlar
│ ├── navigation/ # Router konfigürasyonu
│ ├── services/ # Sistem servisleri
│ ├── theme/ # Tema konfigürasyonu
│ └── widgets/ # Ortak kullanılan widget'lar
├── data/ # Veri katmanı
│ ├── clients/ # API ve veritabanı istemcileri
│ └── models/ # Veri modelleri
├── domain/ # İş mantığı katmanı
│ ├── auth_repository.dart
│ ├── note_repository.dart
│ └── storage_repository.dart
└── presentation/ # Sunum katmanı
├── home/ # Ana sayfa
├── login/ # Giriş ekranı
├── register/ # Kayıt ekranı
├── add_note/ # Not ekleme
├── edit_note/ # Not düzenleme
├── all_notes/ # Tüm notlar
└── settings/ # Ayarlar



## 🔧 Kullanılan Teknolojiler

### Durum Yönetimi
- **flutter_bloc** - BLoC pattern ile durum yönetimi
- **equatable** - Değer karşılaştırmaları için

### Ağ İşlemleri
- **dio** - HTTP client
- **retrofit** - Type-safe HTTP client
- **pretty_dio_logger** - API çağrılarını loglama

### Veri Depolama
- **sqflite** - Yerel SQLite veritabanı
- **shared_preferences** - Basit key-value depolama
- **flutter_secure_storage** - Güvenli veri depolama

### Firebase Entegrasyonu
- **firebase_core** - Firebase temel altyapı
- **firebase_auth** - Kimlik doğrulama
- **firebase_crashlytics** - Hata raporlama
- **firebase_analytics** - Analitik

### UI/UX
- **go_router** - Deklaratif routing
- **shimmer** - Loading animasyonları
- **flutter_slidable** - Kaydırılabilir liste öğeleri
- **tutorial_coach_mark** - Kullanıcı rehberleri

### Kod Üretimi
- **json_annotation** & **json_serializable** - JSON serializasyon
- **injectable** & **injectable_generator** - Dependency injection
- **build_runner** - Kod üretim aracı

## 🌐 API Entegrasyonu

Uygulama, aşağıdaki API endpoint'lerini kullanır:

- `GET /api/notes` - Kullanıcının notlarını getir
- `POST /api/notes` - Yeni not oluştur
- `PUT /api/notes/{id}` - Not güncelle
- `DELETE /api/notes/{id}` - Not sil
- `POST /auth/verify` - Token doğrulama

## 📱 Platform Desteği

- ✅ **Android** (API 21+)
- ✅ **iOS** (iOS 12.0+)
