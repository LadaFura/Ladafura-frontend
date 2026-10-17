import 'package:flutter/material.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_colors.dart';

/// Barre d'outils de formatage enrichi de texte :
/// - Gras (**texte**)
/// - Puces (• )
/// - Numérotation (1. 2. 3. )
/// - Italique (*texte*)
class FormattingToolbarWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onChanged;
  final String? label;

  const FormattingToolbarWidget({
    super.key,
    required this.controller,
    this.onChanged,
    this.label,
  });

  void _formatBold() {
    final text = controller.text;
    final selection = controller.selection;
    if (selection.isValid && !selection.isCollapsed) {
      final selected = text.substring(selection.start, selection.end);
      final newText =
          text.replaceRange(selection.start, selection.end, '**$selected**');
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection(
          baseOffset: selection.start,
          extentOffset: selection.end + 4,
        ),
      );
    } else {
      final cursor = selection.isValid ? selection.start : text.length;
      final newText = text.replaceRange(cursor, cursor, '**Texte en gras**');
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection(
          baseOffset: cursor + 2,
          extentOffset: cursor + 15,
        ),
      );
    }
    onChanged?.call();
  }

  void _formatItalic() {
    final text = controller.text;
    final selection = controller.selection;
    if (selection.isValid && !selection.isCollapsed) {
      final selected = text.substring(selection.start, selection.end);
      final newText =
          text.replaceRange(selection.start, selection.end, '*$selected*');
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection(
          baseOffset: selection.start,
          extentOffset: selection.end + 2,
        ),
      );
    } else {
      final cursor = selection.isValid ? selection.start : text.length;
      final newText = text.replaceRange(cursor, cursor, '*Italique*');
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection(
          baseOffset: cursor + 1,
          extentOffset: cursor + 9,
        ),
      );
    }
    onChanged?.call();
  }

  void _formatBullet() {
    final text = controller.text;
    final selection = controller.selection;
    final cursor = selection.isValid ? selection.start : text.length;
    final needsNewline = cursor > 0 && text[cursor - 1] != '\n';
    final insert = needsNewline ? '\n• ' : '• ';
    final newText = text.replaceRange(cursor, cursor, insert);
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: cursor + insert.length),
    );
    onChanged?.call();
  }

  void _formatNumbered() {
    final text = controller.text;
    final selection = controller.selection;
    final cursor = selection.isValid ? selection.start : text.length;

    // Détecter le numéro suivant à partir des lignes précédentes
    int nextNumber = 1;
    final beforeCursor = text.substring(0, cursor);
    final lines = beforeCursor.split('\n');
    final regex = RegExp(r'^\s*(\d+)\.\s');
    for (final line in lines.reversed) {
      final match = regex.firstMatch(line);
      if (match != null) {
        nextNumber = (int.tryParse(match.group(1)!) ?? 0) + 1;
        break;
      }
    }

    final needsNewline = cursor > 0 && text[cursor - 1] != '\n';
    final insert = needsNewline ? '\n$nextNumber. ' : '$nextNumber. ';
    final newText = text.replaceRange(cursor, cursor, insert);
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: cursor + insert.length),
    );
    onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF1F5F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : Colors.grey.shade300,
          width: 0.8,
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label != null && label!.trim().isNotEmpty) ...[
              Text(
                label!,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 14,
                width: 1,
                color: isDark ? AppColors.darkBorder : Colors.grey.shade300,
              ),
              const SizedBox(width: 8),
            ],
            // Bouton Gras
            _buildToolButton(
              context: context,
              icon: Icons.format_bold_rounded,
              tooltip: 'Gras (**texte**)',
              onPressed: _formatBold,
              label: 'Gras',
            ),
            const SizedBox(width: 4),
            // Bouton Italique
            _buildToolButton(
              context: context,
              icon: Icons.format_italic_rounded,
              tooltip: 'Italique (*texte*)',
              onPressed: _formatItalic,
            ),
            const SizedBox(width: 4),
            // Bouton Puces
            _buildToolButton(
              context: context,
              icon: Icons.format_list_bulleted_rounded,
              tooltip: 'Liste à puces (•)',
              onPressed: _formatBullet,
              label: 'Puces',
            ),
            const SizedBox(width: 4),
            // Bouton Numérotation
            _buildToolButton(
              context: context,
              icon: Icons.format_list_numbered_rounded,
              tooltip: 'Liste numérotée (1., 2., ...)',
              onPressed: _formatNumbered,
              label: '1. 2.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolButton({
    required BuildContext context,
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    String? label,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: label != null ? 8 : 6,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : Colors.grey.shade300,
                width: 0.6,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isDark ? Colors.white70 : AppColors.primary,
                ),
                if (label != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white70 : AppColors.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

