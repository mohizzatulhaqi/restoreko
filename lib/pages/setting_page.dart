import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:restoreko/providers/theme_provider.dart';
import 'package:restoreko/services/background_service.dart';
import 'package:restoreko/services/notification_service.dart';
import 'package:restoreko/providers/settings_provider.dart';
import 'dart:developer' as developer;

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  bool _isLoading = false;
  bool _isDailyReminderEnabled = false;
  bool _isRestaurantRecommendationEnabled = false;
  
  late final SettingsProvider _settingsProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    _loadSettings();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> _loadSettings() async {
    if (!mounted) return;

    setState(() => _isLoading = true);
    try {
      await _settingsProvider.loadSettings();

      if (!mounted) return;

      setState(() {
        _isDailyReminderEnabled = _settingsProvider.isDailyReminderEnabled;
        _isRestaurantRecommendationEnabled = _settingsProvider.isRestaurantRecommendationEnabled;
      });
    } catch (e) {
      if (mounted) _showErrorSnackBar('Gagal memuat pengaturan: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final brightness = Theme.of(context).brightness;
    final backgroundColor = brightness == Brightness.dark
        ? Theme.of(context).scaffoldBackgroundColor
        : Colors.grey[50];

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PENGATURAN',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[800],
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Atur preferensi aplikasi Anda',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionHeader('Tampilan'),
                _buildSettingsCard([
                  _buildSettingsTile(
                    icon: Icons.palette_outlined,
                    title: 'Mode Gelap',
                    subtitle: 'Sesuaikan dengan sistem',
                    trailing: Switch(
                      value: context.watch<ThemeProvider>().isDarkMode,
                      onChanged: (value) {
                        context.read<ThemeProvider>().toggleTheme(value);
                      },
                      activeColor: Colors.orange[800],
                    ),
                  ),
                ]),
                const SizedBox(height: 16),
                _buildSectionHeader('Notifikasi'),
                _buildSettingsCard([
                  _buildSettingsTile(
                    icon: Icons.notifications_active_outlined,
                    title: 'Pengingat Makan Siang',
                    subtitle:
                        'Aktifkan untuk menerima notifikasi pukul 11.00 WIB',
                    trailing: Switch(
                      value: _isDailyReminderEnabled,
                      onChanged: (value) async {
                        final confirmed = await _showConfirmationDialog(value);
                        if (confirmed == true) {
                          await _toggleReminder(value);
                          setState(() {
                            _isDailyReminderEnabled = value;
                          });
                        }
                      },
                      activeColor: Colors.orange[800],
                    ),
                  ),
                  _buildSettingsTile(
                    icon: Icons.restaurant_outlined,
                    title: 'Rekomendasi Restoran Harian',
                    subtitle:
                        'Dapatkan rekomendasi restoran setiap hari pukul 18.00 WIB',
                    trailing: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Switch(
                            value: _isRestaurantRecommendationEnabled,
                            onChanged: (value) async {
                              final confirmed =
                                  await _showRestaurantRecommendationConfirmation(
                                    value,
                                  );
                              if (confirmed == true) {
                                await _toggleRestaurantRecommendation(value);
                                setState(() {
                                  _isRestaurantRecommendationEnabled = value;
                                });
                              }
                            },
                            activeColor: Colors.orange[800],
                          ),
                  ),
                ]),
                const SizedBox(height: 16),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.orange[800], size: 24),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 16),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
      ),
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Future<bool?> _showConfirmationDialog(bool newValue) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          newValue ? 'Aktifkan Pengingat' : 'Nonaktifkan Pengingat',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          newValue
              ? 'Anda akan menerima notifikasi pukul 11.00 WIB setiap hari. Lanjutkan?'
              : 'Anda tidak akan menerima notifikasi pengingat lagi. Lanjutkan?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Ya, Lanjutkan',
              style: GoogleFonts.poppins(
                color: Colors.orange[800],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showRestaurantRecommendationConfirmation(bool newValue) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          newValue
              ? 'Aktifkan Rekomendasi Restoran'
              : 'Nonaktifkan Rekomendasi Restoran',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          newValue
              ? 'Anda akan menerima rekomendasi restoran pukul 18.00 WIB setiap hari. Lanjutkan?'
              : 'Anda tidak akan menerima rekomendasi restoran lagi. Lanjutkan?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Ya, Lanjutkan',
              style: GoogleFonts.poppins(
                color: Colors.orange[800],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleReminder(bool value) async {
    developer.log('[SettingsPage] Toggling lunch reminder to: $value', name: 'Restoreko');
    try {
      final notificationService = NotificationService();
      final success = await _settingsProvider.toggleDailyReminder(value);

      if (success) {
        developer.log('[SettingsPage] Scheduling lunch reminder...', name: 'Restoreko');
        await notificationService.scheduleLunchReminder();
        developer.log('[SettingsPage] Lunch reminder scheduled', name: 'Restoreko');
      } else {
        developer.log('[SettingsPage] Cancelling lunch reminder...', name: 'Restoreko');
        await notificationService.cancelLunchReminder();
        developer.log('[SettingsPage] Lunch reminder cancelled', name: 'Restoreko');
      }

      _showSuccessSnackBar(
        value
            ? 'Pengingat makan siang diaktifkan'
            : 'Pengingat makan siang dinonaktifkan',
      );
    } catch (e) {
      developer.log('[SettingsPage] Error toggling lunch reminder: $e', name: 'Restoreko', error: e);
      _showErrorSnackBar('Gagal mengubah pengaturan: $e');
    }
  }

  Future<void> _toggleRestaurantRecommendation(bool value) async {
    if (!mounted) return;
    developer.log('[SettingsPage] Toggling restaurant recommendation to: $value', name: 'Restoreko');

    setState(() => _isLoading = true);

    try {
      await _settingsProvider.toggleRestaurantRecommendation(value);
      developer.log('[SettingsPage] Restaurant recommendation setting saved: $value', name: 'Restoreko');

      if (value) {
        developer.log('[SettingsPage] Scheduling daily restaurant notification...', name: 'Restoreko');
        await BackgroundService.scheduleDailyNotification();
        developer.log('[SettingsPage] Daily restaurant notification scheduled', name: 'Restoreko');
      } else {
        developer.log('[SettingsPage] Cancelling daily restaurant notification...', name: 'Restoreko');
        await BackgroundService.cancelDailyNotification();
        developer.log('[SettingsPage] Daily restaurant notification cancelled', name: 'Restoreko');
      }

      _showSuccessSnackBar(
        value
            ? 'Rekomendasi restoran harian diaktifkan'
            : 'Rekomendasi restoran harian dinonaktifkan',
      );
    } catch (e) {
      developer.log('[SettingsPage] Error toggling restaurant recommendation: $e', name: 'Restoreko', error: e);
      _showErrorSnackBar('Gagal mengubah pengaturan: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final snackBar = SnackBar(
      content: Text(
        message,
        style: GoogleFonts.poppins(color: isDark ? Colors.black : null),
      ),
      backgroundColor: isDark ? Colors.grey[300] : Colors.red[300],
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final snackBar = SnackBar(
      content: Text(
        message,
        style: GoogleFonts.poppins(color: isDark ? Colors.black : null),
      ),
      backgroundColor: isDark ? Colors.grey[300] : null,
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
