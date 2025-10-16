import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class MasyaudaSubjectsScreen extends StatelessWidget {
  const MasyaudaSubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final subjects = const [
      ('नेपाली', 6),
      ('अंग्रेजी', 5),
      ('समसामयिक/जीके', 4),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('मस्यौदा लेखन'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: subjects.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final (name, count) = subjects[index];
          return ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            tileColor: Colors.white,
            leading: const Icon(Icons.description_outlined),
            title: Text(name),
            subtitle: Text('$count PDF हरू'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MasyaudaPdfViewerScreen(subject: name),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class MasyaudaPdfViewerScreen extends StatelessWidget {
  final String subject;
  const MasyaudaPdfViewerScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: AppColors.primary, title: Text(subject)),
      body: const Center(child: Text('यहाँ PDF दर्शक हुन्छ')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('साझा गर्नुहोस्'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text('प्रिन्ट / सेभ'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
