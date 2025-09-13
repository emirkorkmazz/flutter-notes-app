import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/core/core.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: Assets.images.imBackgroundFirst.provider(),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            bottom: 80, // Bottom bar yüksekliği kadar
          ),
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(child: _buildAboutContent()),
            ],
          ),
        ),
      ),
    );
  }

  /// Üst kısım - Header
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Geri butonu
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Logo
          Image.asset(Assets.icons.icAppLogo.path, height: 50, width: 50),
          const SizedBox(width: 16),
          // Başlık
          const Expanded(
            child: Text(
              'Hakkında',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Hakkında içeriği
  Widget _buildAboutContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Uygulama kartı
          _buildAppCard(),
          const SizedBox(height: 24),

          // Sürüm bilgisi
          _buildVersionCard(),
          const SizedBox(height: 24),

          // Özellikler
          _buildSectionTitle('Özellikler'),
          const SizedBox(height: 16),
          _buildFeaturesSection(),

          const SizedBox(height: 32),

          // Geliştirici bilgisi
          _buildSectionTitle('Geliştirici'),
          const SizedBox(height: 16),
          _buildDeveloperSection(),

          const SizedBox(height: 32),

          // Lisans ve yasal
          _buildSectionTitle('Yasal Bilgiler'),
          const SizedBox(height: 16),
          _buildLegalSection(),
        ],
      ),
    );
  }

  /// Uygulama kartı
  Widget _buildAppCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.15),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.purple.shade400],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.note_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),

          // Uygulama adı
          const Text(
            'Not Uygulaması',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),

          // Açıklama
          Text(
            'Modern ve kullanıcı dostu not alma uygulaması. Notlarınızı organize edin, AI önerileri alın ve verimliliğinizi artırın.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Sürüm kartı
  Widget _buildVersionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.info_rounded,
              color: Colors.green,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sürüm Bilgisi',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Versiyon 1.0.0 (Build 1)',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Son güncelleme: ${_getCurrentDate()}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Bölüm başlığı
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  /// Özellikler bölümü
  Widget _buildFeaturesSection() {
    final features = [
      {
        'icon': Icons.note_add_rounded,
        'title': 'Not Oluşturma',
        'description': 'Başlık, içerik, tarih ve etiketlerle notlar oluşturun',
      },
      {
        'icon': Icons.auto_awesome_rounded,
        'title': 'AI Önerileri',
        'description': 'Yapay zeka destekli not analizi ve önerileri',
      },
      {
        'icon': Icons.search_rounded,
        'title': 'Gelişmiş Arama',
        'description': 'Notlarınızı hızlıca bulun ve filtreleyin',
      },
      {
        'icon': Icons.sync_rounded,
        'title': 'Senkronizasyon',
        'description': 'Notlarınız tüm cihazlarınızda senkronize',
      },
      {
        'icon': Icons.security_rounded,
        'title': 'Güvenlik',
        'description': 'Verileriniz güvenli şekilde saklanır',
      },
    ];

    return Column(
      children:
          features
              .map(
                (feature) => _buildFeatureItem(
                  feature['icon']! as IconData,
                  feature['title']! as String,
                  feature['description']! as String,
                ),
              )
              .toList(),
    );
  }

  /// Özellik öğesi
  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.blue.shade400, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Geliştirici bölümü
  Widget _buildDeveloperSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.code_rounded,
                  color: Colors.purple,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Geliştirici',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDeveloperInfo(
            'Flutter Team',
            'Modern mobil uygulama geliştirme',
            Icons.flutter_dash_rounded,
          ),
          const SizedBox(height: 12),
          _buildDeveloperInfo(
            'AI Integration',
            'Yapay zeka özellikleri ve analiz',
            Icons.psychology_rounded,
          ),
        ],
      ),
    );
  }

  /// Geliştirici bilgi öğesi
  Widget _buildDeveloperInfo(String name, String role, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.7), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  role,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Yasal bilgiler bölümü
  Widget _buildLegalSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          _buildLegalItem(
            'Gizlilik Politikası',
            'Veri kullanımı ve gizlilik haklarınız',
            Icons.privacy_tip_rounded,
            () {
              // Gizlilik politikası
            },
          ),
          const SizedBox(height: 12),
          _buildLegalItem(
            'Kullanım Şartları',
            'Uygulama kullanım koşulları',
            Icons.description_rounded,
            () {
              // Kullanım şartları
            },
          ),
          const SizedBox(height: 12),
          _buildLegalItem(
            'Lisans Bilgisi',
            'Açık kaynak lisansları',
            Icons.copyright_rounded,
            () {
              // Lisans bilgisi
            },
          ),
        ],
      ),
    );
  }

  /// Yasal öğe
  Widget _buildLegalItem(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white.withValues(alpha: 0.7), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  /// Güncel tarihi al
  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year}';
  }
}
