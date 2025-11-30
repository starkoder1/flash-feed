import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LicensesScreen extends StatelessWidget {
  const LicensesScreen({super.key});

  // This fetches the licenses from the flutter engine
  Future<List<LicenseEntry>> _loadLicenses() async {
    return await LicenseRegistry.licenses.toList();
  }

  @override
  Widget build(BuildContext context) {
    // Access your current theme data
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Open Source Licenses"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<LicenseEntry>>(
        future: _loadLicenses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error loading licenses"));
          }

          final licenses = snapshot.data ?? [];

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: licenses.length,
            separatorBuilder: (c, i) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final license = licenses[index];

              // Get package names (e.g., "flutter_riverpod, riverpod")
              final packages = license.packages.join(', ');

              // Flatten the paragraphs into a single string
              final bodyText = license.paragraphs
                  .map((p) => p.text)
                  .join('\n\n');

              return Container(
                decoration: BoxDecoration(
                  color: theme.cardColor, // Uses your theme card color
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.dividerColor.withOpacity(0.1),
                  ),
                ),
                child: ExpansionTile(
                  shape: Border.all(color: Colors.transparent),
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  title: Text(
                    packages,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    "${license.paragraphs.length} paragraphs",
                    style: theme.textTheme.bodySmall,
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        bodyText,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily:
                              'Courier', // Monospaced looks better for legal text
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
