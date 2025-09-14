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
          child: Row(
            children: [
              // Profil fotoğrafı
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.purple.shade400],
                  ),
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 35,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 20),
              // Kullanıcı bilgileri
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.userInfo?.data?.email ?? 'Kullanıcı',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (state.userInfo?.data?.createdAt != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 14,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Üyelik: ${_formatDate(state.userInfo?.data?.createdAt ?? '')}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
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
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildSettingsItem(
            icon: Icons.help_center_rounded,
            title: 'Yardım',
            subtitle: 'Sık sorulan sorular ve destek',
            onTap: () {
              context.push(AppRouteName.help.path);
            },
          ),
          _buildDivider(),
          _buildSettingsItem(
            icon: Icons.info_rounded,
            title: 'Hakkında',
            subtitle: 'Uygulama bilgileri ve sürüm',
            onTap: () {
              context.push(AppRouteName.about.path);
            },
          ),
          _buildDivider(),
          _buildSettingsItem(
            icon: Icons.logout_rounded,
            title: 'Çıkış Yap',
            subtitle: 'Hesabınızdan güvenli çıkış',
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color:
                isDestructive
                    ? Colors.red.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isDestructive ? Colors.red.shade400 : Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red.shade400 : Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
        onTap: onTap,
      ),
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
      return DateFormatter.formatToDisplayFormat(date);
    } on FormatException {
      return dateString;
    }
  }
}
