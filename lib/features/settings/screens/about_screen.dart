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
        title: const Text('ስለ አፕሊኬሽኑ'),
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
                  'የሳዳት ከማል መጽሐፍት',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'የሳዳት ከማል (አቡ መርየም) ኪታቦች (ደርሶች) የሚለቀቁበት የሞባይል መተግበሪያ',
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
            title: 'ስለ አፕሊኬሽኑ',
            children: [
              _buildInfoRow(
                icon: Icons.description_rounded,
                text:
                    'የተለያዩ ኪታቦችን ከድምጽ ጋረ ከኢንተርኔት ውጭ የሚሰራ አፕልኬሽን።',
              ),
              _buildInfoRow(
                icon: Icons.featured_play_list_rounded,
                text: 'መጽሐፍትን በቀላሉ ያንብቡ፣ ያዳምጡ እና የደረሱበትን ደረጃ ይከታተሉ',
              ),
              _buildInfoRow(
                icon: Icons.book_rounded,
                text:
                    'በኡስታዝ ሳዳት ከማል የተዘጋጁ የኢስላማዊ ጽሑፎች ስብስብ።',
              ),
              _buildInfoRow(
                icon: Icons.audio_file_rounded,
                text: 'ከጽሁፉ ጋር አንድላይ የሚገኝ የድምጽ ቅጂ',
              ),
              _buildInfoRow(
                icon: Icons.auto_awesome_rounded,
                text: 'እጅ ሳይጠቀሙ ለማንበብ የሚረዳ የራስ-ሰር ገጽ የመቀያየር ሁኔታ።',
              ),
              _buildInfoRow(
                icon: Icons.speed_rounded,
                text: 'ለድምጽ ምዕራፎች የሚቀያየር የማጫወቻ ፍጥነት።',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ---- Credits / Built by ----
          _buildSection(
            context,
            title: 'ያበለጸገው',
            children: [
              _buildInfoRow(
                icon: Icons.business_rounded,
                text: 'በአላርም ቴክኖሎጂ የበለጸገ',
              ),
              _buildInfoRow(
                icon: Icons.email_rounded,
                text: 'alarmtechsolution9@gmail.com',
                onTap: () => _launchEmail('alarmtechsolution9@gmail.com'),
              ),
              _buildInfoRow(
                icon: Icons.phone_rounded,
                text: '0933330933',
                onTap: () => _launchPhone('0933330933'),
              ),
              _buildInfoRow(
                icon: Icons.phone_rounded,
                text: '0933313133',
                onTap: () => _launchPhone('0933313133'),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // ---- Footer ----
          Center(
            child: Text(
              '© 2026 አላርም ቴክኖሎጂ። መብቱ በህግ የተጠበቀ ነው።',
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

  void _launchPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
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
