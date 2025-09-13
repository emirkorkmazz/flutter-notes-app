/// AI önerisi durumları
enum AiSuggestionStatus {
  initial, // Başlangıç durumu
  loading, // AI önerisi yükleniyor
  success, // AI önerisi başarıyla alındı
  failure, // AI önerisi alınırken hata oluştu
}
