import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:book_store/core/constants/app_texts.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppTexts.aboutAppBarTitle),
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
                  AppTexts.aboutAppName,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppTexts.aboutAppTagline,
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
            title: AppTexts.aboutSectionAboutApp,
            children: [
              _buildInfoRow(
                icon: Icons.description_rounded,
                text:
                    AppTexts.aboutFeatureOffline,
              ),
              _buildInfoRow(
                icon: Icons.featured_play_list_rounded,
                text: AppTexts.aboutFeatureReadListenTrack,
              ),
              _buildInfoRow(
                icon: Icons.book_rounded,
                text:
                    AppTexts.aboutFeatureIslamicCollection,
              ),
              _buildInfoRow(
                icon: Icons.audio_file_rounded,
                text: AppTexts.aboutFeatureAudio,
              ),
              _buildInfoRow(
                icon: Icons.auto_awesome_rounded,
                text: AppTexts.aboutFeatureAutoPage,
              ),
              _buildInfoRow(
                icon: Icons.speed_rounded,
                text: AppTexts.aboutFeatureSpeed,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ---- Credits / Built by ----
          _buildSection(
            context,
            title: AppTexts.aboutSectionCredits,
            children: [
              _buildInfoRow(
                icon: Icons.business_rounded,
                text: AppTexts.aboutCreditCompany,
              ),
              _buildInfoRow(
                icon: Icons.email_rounded,
                text: AppTexts.aboutEmail,
                onTap: () => _launchEmail('alarmtechsolution9@gmail.com'),
              ),
              _buildInfoRow(
                icon: Icons.phone_rounded,
                text: AppTexts.aboutPhone1,
                onTap: () => _launchPhone('0933330933'),
              ),
              _buildInfoRow(
                icon: Icons.phone_rounded,
                text: AppTexts.aboutPhone2,
                onTap: () => _launchPhone('0933313133'),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // ---- Footer ----
          Center(
            child: Text(
              AppTexts.aboutFooter,
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
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _launchPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
