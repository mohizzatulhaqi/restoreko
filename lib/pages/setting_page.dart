import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
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
                // Appearance Section
                _buildSectionHeader('Tampilan'),
                _buildSettingsCard([
                  _buildSettingsTile(
                    icon: Icons.palette_outlined,
                    title: 'Mode Gelap',
                    subtitle: 'Sesuaikan dengan sistem',
                    trailing: Switch(
                      value: isDarkMode,
                      onChanged: (value) {
                        // Implementasi untuk mengubah tema
                      },
                      activeColor: Colors.orange[800],
                    ),
                  ),
                  _buildSettingsTile(
                    icon: Icons.text_fields,
                    title: 'Ukuran Font',
                    subtitle: 'Normal',
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to font size settings
                    },
                  ),
                ]),
                
                const SizedBox(height: 16),
                
                // Notifications Section
                _buildSectionHeader('Notifikasi'),
                _buildSettingsCard([
                  _buildSettingsTile(
                    icon: Icons.notifications_outlined,
                    title: 'Notifikasi Push',
                    subtitle: 'Dapatkan notifikasi terbaru',
                    trailing: Switch(
                      value: true,
                      onChanged: (value) {
                        // Implementasi untuk notifikasi
                      },
                      activeColor: Colors.orange[800],
                    ),
                  ),
                  _buildSettingsTile(
                    icon: Icons.location_on_outlined,
                    title: 'Rekomendasi Lokasi',
                    subtitle: 'Berdasarkan lokasi Anda',
                    trailing: Switch(
                      value: false,
                      onChanged: (value) {
                        // Implementasi untuk lokasi
                      },
                      activeColor: Colors.orange[800],
                    ),
                  ),
                ]),
                
                const SizedBox(height: 16),
                
                // About Section
                _buildSectionHeader('Tentang'),
                _buildSettingsCard([
                  _buildSettingsTile(
                    icon: Icons.info_outlined,
                    title: 'Tentang Aplikasi',
                    subtitle: 'Versi 1.0.0',
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      _showAboutDialog(context);
                    },
                  ),
                  _buildSettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Kebijakan Privasi',
                    subtitle: 'Pelajari cara kami melindungi data Anda',
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to privacy policy
                    },
                  ),
                  _buildSettingsTile(
                    icon: Icons.help_outline,
                    title: 'Bantuan & Dukungan',
                    subtitle: 'FAQ dan hubungi kami',
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to help page
                    },
                  ),
                ]),
                
                const SizedBox(height: 32),
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
      child: Column(
        children: children,
      ),
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
      leading: Icon(
        icon,
        color: Colors.orange[800],
        size: 24,
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: 13,
          color: Colors.grey[600],
        ),
      ),
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Tentang Restoreko',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Restoreko adalah aplikasi rekomendasi restoran terbaik untuk membantu Anda menemukan tempat makan yang sempurna.',
                style: GoogleFonts.poppins(),
              ),
              const SizedBox(height: 16),
              Text(
                'Versi: 1.0.0',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                'Dikembangkan dengan ❤️',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Tutup',
                style: GoogleFonts.poppins(
                  color: Colors.orange[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}