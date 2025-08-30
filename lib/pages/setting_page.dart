import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:restoreko/providers/theme_provider.dart';
import 'package:restoreko/services/notification_service.dart';
import 'package:restoreko/services/settings_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final settingsService = SettingsService();
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

                // Notifications Section
                _buildSectionHeader('Notifikasi'),
                _buildSettingsCard([
                  _buildSettingsTile(
                    icon: Icons.notifications_active_outlined,
                    title: 'Pengingat Makan Siang',
                    subtitle: 'Aktifkan untuk menerima notifikasi pukul 11.00 WIB',
                    trailing: FutureBuilder<bool>(
                      future: settingsService.initialize().then((_) => settingsService.isDailyReminderEnabled),
                      builder: (context, snapshot) {
                        final isEnabled = snapshot.data ?? false;
                        return Switch(
                          value: isEnabled,
                          onChanged: (value) => _showConfirmationDialog(value),
                          activeColor: Colors.orange[800],
                        );
                      },
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

  Future<void> _showConfirmationDialog(bool newValue) async {
    final confirmed = await showDialog<bool>(
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

    if (confirmed == true) {
      await _toggleReminder(newValue);
    }
  }

  Future<void> _toggleReminder(bool value) async {
    try {
      final notificationService = NotificationService();
      final settingsService = SettingsService();
      
      if (value) {
        await notificationService.scheduleLunchReminder();
      } else {
        await notificationService.cancelLunchReminder();
      }
      
      await settingsService.setDailyReminder(value);
      
      if (mounted) {
        setState(() {});
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final snackBar = SnackBar(
          content: Text(
            value 
                ? 'Pengingat makan siang diaktifkan' 
                : 'Pengingat makan siang dinonaktifkan',
            style: GoogleFonts.poppins(
              color: isDark ? Colors.black : null,
            ),
          ),
          backgroundColor: isDark ? Colors.grey[300] : null,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      if (mounted) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final errorSnackBar = SnackBar(
          content: Text(
            'Gagal mengubah pengaturan: $e',
            style: GoogleFonts.poppins(
              color: isDark ? Colors.black : null,
            ),
          ),
          backgroundColor: isDark ? Colors.grey[300] : null,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(errorSnackBar);
      }
    }
  }

  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }
}
