import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '/core/core.dart';
import '/presentation/presentation.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SettingsCubit>()..loadUserInfo(),
      child: const _SettingsViewContent(),
    );
  }
}

class _SettingsViewContent extends StatelessWidget {
  const _SettingsViewContent();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
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
            _buildHeader(),
            Expanded(child: _buildSettingsContent(context)),
          ],
        ),
      ),
    );
  }

  /// Üst kısım - Logo
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Logo
          Image.asset(Assets.icons.icAppLogo.path, height: 70, width: 70),
          const SizedBox(width: 16),
          // Başlık
          const Text(
            'Ayarlar',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Ayarlar içeriği
  Widget _buildSettingsContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profil kartı
          _buildProfileCard(context),
          const SizedBox(height: 24),

          // Ayarlar listesi
          Expanded(child: _buildSettingsList(context)),
        ],
      ),
    );
  }

  /// Profil kartı
  Widget _buildProfileCard(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              // Profil fotoğrafı
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(Icons.person, size: 30, color: Colors.white),
              ),
              const SizedBox(width: 16),
              // Kullanıcı bilgileri
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.userInfo?.data?.email ?? 'Kullanıcı',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      state.userInfo?.data?.id ?? 'ID: -',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    if (state.userInfo?.data?.createdAt != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Üyelik: ${_formatDate(state.userInfo?.data?.createdAt ?? '')}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Ayarlar listesi
  Widget _buildSettingsList(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildSettingsItem(
            icon: Icons.language,
            title: 'Dil',
            subtitle: 'Uygulama dilini değiştir',
            onTap: () {
              // Dil ayarları
            },
          ),
          _buildDivider(),
          _buildSettingsItem(
            icon: Icons.help,
            title: 'Yardım',
            subtitle: 'Sık sorulan sorular',
            onTap: () {
              // Yardım sayfası
            },
          ),
          _buildDivider(),
          _buildSettingsItem(
            icon: Icons.info,
            title: 'Hakkında',
            subtitle: 'Uygulama bilgileri',
            onTap: () {
              // Hakkında sayfası
            },
          ),
          _buildDivider(),
          _buildSettingsItem(
            icon: Icons.logout,
            title: 'Çıkış Yap',
            subtitle: 'Hesabınızdan çıkış yapın',
            onTap: () => _showLogoutDialog(context),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  /// Ayarlar öğesi
  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : Colors.white),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.7),
          fontSize: 12,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.white.withValues(alpha: 0.5),
      ),
      onTap: onTap,
    );
  }

  /// Ayırıcı çizgi
  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Colors.white.withValues(alpha: 0.1),
      indent: 60,
    );
  }

  /// Çıkış yap dialog'u
  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder:
          (context) => BlocListener<SettingsCubit, SettingsState>(
            listener: (context, state) {
              if (state.status == SettingsStatus.logoutSuccess) {
                context.go(AppRouteName.login.path);
              } else if (state.status == SettingsStatus.failure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: AlertDialog(
              title: const Text('Çıkış Yap'),
              content: const Text(
                'Hesabınızdan çıkış yapmak istediğinizden emin misiniz?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('İptal'),
                ),
                BlocBuilder<SettingsCubit, SettingsState>(
                  builder: (context, state) {
                    return TextButton(
                      onPressed:
                          state.status == SettingsStatus.loading
                              ? null
                              : () {
                                Navigator.of(context).pop();
                                context.read<SettingsCubit>().logout();
                              },
                      child:
                          state.status == SettingsStatus.loading
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text(
                                'Çıkış Yap',
                                style: TextStyle(color: Colors.red),
                              ),
                    );
                  },
                ),
              ],
            ),
          ),
    );
  }

  /// Tarih formatla
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
