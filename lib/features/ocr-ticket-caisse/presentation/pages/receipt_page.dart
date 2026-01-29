import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:leodys/features/ocr-ticket-caisse/presentation/controllers/receipt_controller.dart';
import 'package:leodys/features/ocr-ticket-caisse/domain/entities/receipt.dart';

class ReceiptPage extends StatelessWidget {
  const ReceiptPage({super.key});
  static const String route = "ticket-caisse";
  Future<void> _pickAndScan(BuildContext context) async {
    final controller = context.read<ReceiptController>();

    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result == null || result.files.isEmpty) return;

    final path = result.files.single.path;
    if (path == null) {
      debugPrint("No file path returned (web?)");
      return;
    }

    final file = File(path);
    await controller.scan(file);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scanner de ticket de caisse")),
      body: Consumer<ReceiptController>(
        builder: (_, controller, __) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.error != null) {
            return Center(
              child: Text(
                controller.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            );
          }
          return Column(
            children: [
              // Action buttons
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Wrap(
                  spacing: 12,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _pickAndScan(context),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text("Camera"),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _pickAndScan(context),
                      icon: const Icon(Icons.photo_library),
                      label: const Text("Gallery"),
                    ),
                  ],
                ),
              ),

              // Receipt info
              Expanded(
                child: controller.receipt == null
                    ? const Center(child: Text("Scan a receipt"))
                    : ReceiptCardView(receipt: controller.receipt!),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ReceiptCardView extends StatelessWidget {
  final Receipt receipt;

  const ReceiptCardView({required this.receipt, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _InfoCard(
          title: 'Magasin',
          child: Center(
            child: Text(
              receipt.shopName,
              style: theme.textTheme.titleMedium,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _InfoCard(
          title: 'Date',
          child: Text(
            receipt.date,
            style: theme.textTheme.bodyLarge,
          ),
        ),
        const SizedBox(height: 12),
        _InfoCard(
          title: 'Articles',
          child: Column(
            children: receipt.items.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                    Text(
                      "${item.price.toStringAsFixed(2)} €",
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        _InfoCard(
          title: 'Total',
          child: Center(
            child: Text(
              "${receipt.total.toStringAsFixed(2)} €",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Card wrapper used for all sections
class _InfoCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _InfoCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}
