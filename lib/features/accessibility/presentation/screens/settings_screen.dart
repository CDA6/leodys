import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import 'package:leodys/features/accessibility/presentation/viewmodels/settings_viewmodel.dart';

import 'package:leodys/features/accessibility/presentation/widgets/font_size_card.dart';
import 'package:leodys/features/accessibility/presentation/widgets/letter_spacing_card.dart';
import 'package:leodys/features/accessibility/presentation/widgets/line_height_card.dart';
import 'package:leodys/features/accessibility/presentation/widgets/theme_card.dart';
import 'package:leodys/features/accessibility/presentation/widgets/font_family_card.dart';
import 'package:leodys/features/accessibility/presentation/widgets/section_title.dart';

import '../../../../common/widget/global_appbar.dart';


class SettingsScreen extends StatelessWidget {
  static const String route = '/accessibility-settings';

  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalAppBar(
        title: 'Préférences',
        showAuthActions: false,
      ),
      body: Consumer<SettingsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final settings = viewModel.settings;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Section Thème
                    const SectionTitle(
                      icon: Icons.palette,
                      title: 'Thème et couleurs',
                    ),
                    const SizedBox(height: 8),
                    ThemeCard(
                      themeMode: settings.themeMode,
                      onUpdateThemeMode: (String? value) async {
                        if (value != null) {
                          await viewModel.updateThemeMode(value);
                        }
                      },
                    ),

                    const SizedBox(height: 24),

                    // Section Typographie
                    const SectionTitle(
                      icon: Icons.font_download,
                      title: 'Typographie',
                    ),
                    const SizedBox(height: 8),
                    FontFamilyCard(
                      currentFontFamily: settings.fontFamily,
                      availableFonts: SettingsViewModel.availableFonts,
                      onFontSelected: (value) {
                        if (value != null) {
                          viewModel.updateFontFamily(value);
                        }
                      },
                    ),
                    const SizedBox(height: 24),

                    // Section Taille du texte
                    const SectionTitle(
                      icon: Icons.format_size,
                      title: 'Taille du texte',
                    ),
                    const SizedBox(height: 8),
                    FontSizeCard(
                      fontSize: settings.fontSize,
                      minFontSize: SettingsViewModel.minFontSize,
                      maxFontSize: SettingsViewModel.maxFontSize,
                      onFontSizeChanged: viewModel.updateFontSize,
                    ),
                    const SizedBox(height: 24),

                    // Section Espacement
                    const SectionTitle(
                      icon: Icons.format_line_spacing,
                      title: 'Espacement',
                    ),
                    const SizedBox(height: 8),
                    LetterSpacingCard(
                      letterSpacing: settings.letterSpacing,
                      minLetterSpacing: SettingsViewModel.minLetterSpacing,
                      maxLetterSpacing: SettingsViewModel.maxLetterSpacing,
                      onLetterSpacingChanged: viewModel.updateLetterSpacing,
                    ),
                    const SizedBox(height: 12),
                    LineHeightCard(
                      lineHeight: settings.lineHeight,
                      minLineHeight: SettingsViewModel.minLineHeight,
                      maxLineHeight: SettingsViewModel.maxLineHeight,
                      onUpdateLineHeight: viewModel.updateLineHeight,
                    ),

                    const SizedBox(height: 72),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
