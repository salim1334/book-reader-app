import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---- App Logo & Name ----
          Center(
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    Icons.menu_book_rounded,
                    size: 60,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Book Reader',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version 1.0.0',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your digital library for Islamic books.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // ---- About the App ----
          _buildSection(
            context,
            title: 'About the App',
            children: [
              _buildInfoRow(
                icon: Icons.description_rounded,
                text:
                    'A modern, offline-first book reader and audiobook player for Islamic literature.',
              ),
              _buildInfoRow(
                icon: Icons.featured_play_list_rounded,
                text: 'Read, listen, and organize your books with ease.',
              ),
              _buildInfoRow(
                icon: Icons.cloud_sync_rounded,
                text: 'Sync progress across devices (coming soon).',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ---- About the Books ----
          _buildSection(
            context,
            title: 'About the Books',
            children: [
              _buildInfoRow(
                icon: Icons.book_rounded,
                text:
                    'Collection of authentic Islamic texts by Ustadh Sadat Kemal.',
              ),
              _buildInfoRow(
                icon: Icons.audio_file_rounded,
                text: 'High-quality audio narrations for immersive listening.',
              ),
              _buildInfoRow(
                icon: Icons.translate_rounded,
                text:
                    'Texts available in multiple languages (Amharic, Arabic, English).',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ---- About the Reader ----
          _buildSection(
            context,
            title: 'Reader Features',
            children: [
              _buildInfoRow(
                icon: Icons.text_fields_rounded,
                text: 'Adjustable font size and reading direction (LTR/RTL).',
              ),
              _buildInfoRow(
                icon: Icons.auto_awesome_rounded,
                text: 'Auto-scroll mode for hands-free reading.',
              ),
              _buildInfoRow(
                icon: Icons.speed_rounded,
                text: 'Variable playback speed for audio chapters.',
              ),
              _buildInfoRow(
                icon: Icons.bedtime_rounded,
                text: 'Sleep timer for audio playback.',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ---- Credits / Built by ----
          _buildSection(
            context,
            title: 'Built by',
            children: [
              _buildInfoRow(
                icon: Icons.person_rounded,
                text: 'Developed with ❤️ by the Book Reader Team.',
              ),
              _buildInfoRow(
                icon: Icons.code_rounded,
                text: 'Flutter • GetX • SQLite • audio_service',
              ),
              _buildInfoRow(
                icon: Icons.email_rounded,
                text: 'support@bookreader.com',
                onTap: () => _launchEmail('support@bookreader.com'),
              ),
              _buildInfoRow(
                icon: Icons.link_rounded,
                text: 'Visit our website',
                onTap: () => _launchUrl('https://bookreader.com'),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // ---- Footer ----
          Center(
            child: Text(
              '© 2026 Book Reader App. All rights reserved.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(Get.context!).colorScheme.primary),
      title: Text(text),
      onTap: onTap,
      trailing: onTap != null
          ? const Icon(Icons.arrow_forward_ios_rounded, size: 16)
          : null,
    );
  }

  void _launchEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
