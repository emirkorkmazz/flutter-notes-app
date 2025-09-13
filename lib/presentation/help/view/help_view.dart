import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/core/core.dart';

class HelpView extends StatelessWidget {
  const HelpView({super.key});

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
              Expanded(child: _buildHelpContent()),
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
              'Yardım & Destek',
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

  /// Yardım içeriği
  Widget _buildHelpContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hoş geldin kartı
          _buildWelcomeCard(),
          const SizedBox(height: 24),

          // SSS Bölümü
          _buildSectionTitle('Sık Sorulan Sorular'),
          const SizedBox(height: 16),
          _buildFAQSection(),

          const SizedBox(height: 32),

          // İletişim Bölümü
          _buildSectionTitle('İletişim'),
          const SizedBox(height: 16),
          _buildContactSection(),

          const SizedBox(height: 32),

          // Özellikler Bölümü
          _buildSectionTitle('Uygulama Özellikleri'),
          const SizedBox(height: 16),
          _buildFeaturesSection(),
        ],
      ),
    );
  }

  /// Hoş geldin kartı
  Widget _buildWelcomeCard() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.purple.shade400],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.help_center_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Size Nasıl Yardımcı Olabiliriz?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Not uygulamanızla ilgili sorularınızın cevaplarını burada bulabilirsiniz. Eğer aradığınızı bulamazsanız, bizimle iletişime geçmekten çekinmeyin.',
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withValues(alpha: 0.8),
              height: 1.5,
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

  /// SSS Bölümü
  Widget _buildFAQSection() {
    final faqs = [
      {
        'question': 'Notlarımı nasıl oluşturabilirim?',
        'answer':
            'Ana sayfadaki + butonuna tıklayarak yeni not oluşturabilirsiniz. Başlık, içerik, tarih ve etiket ekleyebilirsiniz.',
      },
      {
        'question': 'Notlarımı nasıl düzenleyebilirim?',
        'answer':
            'Not kartındaki menü butonuna tıklayıp "Düzenle" seçeneğini seçebilir veya notu sola kaydırarak düzenleme butonuna basabilirsiniz.',
      },
      {
        'question': 'Notlarımı nasıl silebilirim?',
        'answer':
            'Not kartını sola kaydırarak silme butonuna basabilir veya menüden "Sil" seçeneğini seçebilirsiniz. Silme işlemi 5 saniye içinde geri alınabilir.',
      },
      {
        'question': 'AI önerisi nasıl çalışır?',
        'answer':
            'Not kartındaki menüden "AI Önerisi" seçeneğini seçerek notunuz için AI destekli öneriler alabilirsiniz.',
      },
      {
        'question': 'Notlarımı nasıl arayabilirim?',
        'answer':
            'Ana sayfa veya Tüm Notlar sayfasındaki arama çubuğunu kullanarak notlarınızı başlık ve içerik bazında arayabilirsiniz.',
      },
    ];

    return Column(
      children:
          faqs
              .map((faq) => _buildFAQItem(faq['question']!, faq['answer']!))
              .toList(),
    );
  }

  /// FAQ öğesi
  Widget _buildFAQItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        iconColor: Colors.white,
        collapsedIconColor: Colors.white,
        title: Text(
          question,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        children: [
          Text(
            answer,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// İletişim Bölümü
  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          _buildContactItem(
            icon: Icons.email_rounded,
            title: 'E-posta Desteği',
            subtitle: 'destek@noteapp.com',
            onTap: () {
              // E-posta açma
            },
          ),
          const SizedBox(height: 16),
          _buildContactItem(
            icon: Icons.phone_rounded,
            title: 'Telefon Desteği',
            subtitle: '+90 (212) 555 0123',
            onTap: () {
              // Telefon açma
            },
          ),
          const SizedBox(height: 16),
          _buildContactItem(
            icon: Icons.chat_rounded,
            title: 'Canlı Destek',
            subtitle: '7/24 online destek',
            onTap: () {
              // Canlı destek
            },
          ),
        ],
      ),
    );
  }

  /// İletişim öğesi
  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
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
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  /// Özellikler Bölümü
  Widget _buildFeaturesSection() {
    final features = [
      {
        'icon': Icons.note_add_rounded,
        'title': 'Not Oluşturma',
        'description': 'Başlık, içerik, tarih ve etiketlerle notlar oluşturun',
      },
      {
        'icon': Icons.edit_rounded,
        'title': 'Not Düzenleme',
        'description': 'Mevcut notlarınızı kolayca düzenleyin ve güncelleyin',
      },
      {
        'icon': Icons.search_rounded,
        'title': 'Gelişmiş Arama',
        'description': 'Notlarınızı başlık ve içerik bazında arayın',
      },
      {
        'icon': Icons.auto_awesome_rounded,
        'title': 'AI Önerileri',
        'description': 'Yapay zeka destekli not önerileri alın',
      },
      {
        'icon': Icons.push_pin_rounded,
        'title': 'Not Sabitleme',
        'description': 'Önemli notlarınızı sabitleyerek üstte tutun',
      },
      {
        'icon': Icons.label_rounded,
        'title': 'Etiket Sistemi',
        'description': 'Notlarınızı kategorilere ayırın ve organize edin',
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
              color: Colors.green.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.green.shade400, size: 20),
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
}
