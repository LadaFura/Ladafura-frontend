import 'package:flutter/material.dart';

/// Widget permettant d'afficher du texte enrichi HTML (Gras, Italique, Souligné,
/// Listes à puces, Listes numérotées, Citations) de façon fluide et native dans Flutter
/// sans nécessiter de dépendance externe lourde.
class FormattedHtmlText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  const FormattedHtmlText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    final defaultStyle = DefaultTextStyle.of(context).style;
    final effectiveStyle = defaultStyle.merge(style);

    final span = buildTextSpan(
      html: text,
      baseStyle: effectiveStyle,
      singleLineFallback: maxLines == 1,
    );

    return Text.rich(
      span,
      maxLines: maxLines,
      overflow: overflow ?? (maxLines != null ? TextOverflow.ellipsis : TextOverflow.clip),
      textAlign: textAlign ?? TextAlign.start,
    );
  }

  /// Convertit une chaîne contenant des balises HTML simples en une arborescence de TextSpan.
  static TextSpan buildTextSpan({
    required String html,
    TextStyle? baseStyle,
    bool singleLineFallback = false,
  }) {
    if (html.isEmpty) {
      return TextSpan(text: '', style: baseStyle);
    }

    // Si le texte ne contient aucune balise HTML, retour direct optimisé
    if (!html.contains('<') || !html.contains('>')) {
      return TextSpan(text: html, style: baseStyle);
    }

    final tagExp = RegExp(r'<(/?[a-zA-Z0-9]+)([^>]*)>');
    final spans = <InlineSpan>[];
    int lastIndex = 0;

    bool isBold = false;
    bool isItalic = false;
    bool isUnderline = false;
    bool isStrikeThrough = false;
    bool inOrderedList = false;
    int listCounter = 1;

    void addChunk(String raw) {
      if (raw.isEmpty) return;
      var clean = raw
          .replaceAll('&nbsp;', ' ')
          .replaceAll('&amp;', '&')
          .replaceAll('&lt;', '<')
          .replaceAll('&gt;', '>')
          .replaceAll('&quot;', '"')
          .replaceAll('&#39;', "'");

      if (singleLineFallback) {
        clean = clean.replaceAll(RegExp(r'[\r\n]+'), ' ');
      }

      TextStyle chunkStyle = baseStyle ?? const TextStyle();
      if (isBold) {
        chunkStyle = chunkStyle.copyWith(fontWeight: FontWeight.bold);
      }
      if (isItalic) {
        chunkStyle = chunkStyle.copyWith(fontStyle: FontStyle.italic);
      }
      if (isUnderline && isStrikeThrough) {
        chunkStyle = chunkStyle.copyWith(
          decoration: TextDecoration.combine([
            TextDecoration.underline,
            TextDecoration.lineThrough,
          ]),
        );
      } else if (isUnderline) {
        chunkStyle = chunkStyle.copyWith(decoration: TextDecoration.underline);
      } else if (isStrikeThrough) {
        chunkStyle = chunkStyle.copyWith(decoration: TextDecoration.lineThrough);
      }

      spans.add(TextSpan(text: clean, style: chunkStyle));
    }

    for (final match in tagExp.allMatches(html)) {
      if (match.start > lastIndex) {
        addChunk(html.substring(lastIndex, match.start));
      }

      final rawTag = match.group(1)!.toLowerCase();
      switch (rawTag) {
        case 'b':
        case 'strong':
          isBold = true;
          break;
        case '/b':
        case '/strong':
          isBold = false;
          break;

        case 'i':
        case 'em':
          isItalic = true;
          break;
        case '/i':
        case '/em':
          isItalic = false;
          break;

        case 'u':
          isUnderline = true;
          break;
        case '/u':
          isUnderline = false;
          break;

        case 's':
        case 'del':
        case 'strike':
          isStrikeThrough = true;
          break;
        case '/s':
        case '/del':
        case '/strike':
          isStrikeThrough = false;
          break;

        case 'br':
        case 'br/':
          if (!singleLineFallback) addChunk('\n');
          break;

        case 'p':
          if (!singleLineFallback && spans.isNotEmpty) {
            final last = spans.last;
            if (last is TextSpan && last.text != null && !last.text!.endsWith('\n')) {
              addChunk('\n');
            }
          }
          break;
        case '/p':
          if (!singleLineFallback) addChunk('\n');
          break;

        case 'ul':
          inOrderedList = false;
          if (!singleLineFallback && spans.isNotEmpty) {
            final last = spans.last;
            if (last is TextSpan && last.text != null && !last.text!.endsWith('\n')) {
              addChunk('\n');
            }
          }
          break;

        case 'ol':
          inOrderedList = true;
          listCounter = 1;
          if (!singleLineFallback && spans.isNotEmpty) {
            final last = spans.last;
            if (last is TextSpan && last.text != null && !last.text!.endsWith('\n')) {
              addChunk('\n');
            }
          }
          break;

        case 'li':
          if (!singleLineFallback) {
            final prefix = inOrderedList ? '${listCounter++}. ' : '• ';
            addChunk(prefix);
          } else {
            addChunk(' • ');
          }
          break;
        case '/li':
          if (!singleLineFallback) addChunk('\n');
          break;

        case 'blockquote':
          isItalic = true;
          addChunk('« ');
          break;
        case '/blockquote':
          isItalic = false;
          addChunk(' »\n');
          break;

        case 'h1':
        case 'h2':
        case 'h3':
        case 'h4':
        case 'h5':
        case 'h6':
          isBold = true;
          break;
        case '/h1':
        case '/h2':
        case '/h3':
        case '/h4':
        case '/h5':
        case '/h6':
          isBold = false;
          if (!singleLineFallback) addChunk('\n');
          break;
      }

      lastIndex = match.end;
    }

    if (lastIndex < html.length) {
      addChunk(html.substring(lastIndex));
    }

    return TextSpan(children: spans, style: baseStyle);
  }

  /// Débarrasse une chaîne de ses balises HTML et convertit les listes en puces texte.
  static String stripHtml(String html) {
    if (!html.contains('<') || !html.contains('>')) return html;
    return html
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</li>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<li[^>]*>', caseSensitive: false), '• ')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n')
        .replaceAll(RegExp(r'</div>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }
}

