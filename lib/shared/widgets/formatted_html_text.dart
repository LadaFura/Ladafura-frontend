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

  /// Normalise le contenu HTML ou texte enrichi :
  /// - Convertit les entités HTML (&nbsp;, &amp;...)
  /// - Transforme les blocs <div>, <p>, <br> en retours à la ligne
  /// - Isole chaque puce (•) sur sa propre ligne
  /// - Convertit le Markdown (**gras**, *italique*) en balises simples
  static String normalizeRichContent(String raw, {bool singleLine = false}) {
    if (raw.isEmpty) return raw;

    var text = raw;

    // 1. Convertir les entités HTML fréquentes
    text = text
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");

    // 2. Déplacer les puces à l'extérieur des balises de gras (ex: <b>• Titre</b> -> • <b>Titre</b>)
    text = text.replaceAllMapped(
      RegExp(r'<(b|strong)>\s*([•●▪])\s*', caseSensitive: false),
      (m) => '${m[2]} <${m[1]}>',
    );

    // 3. Normaliser les balises de fin de bloc HTML en sauts de ligne
    text = text.replaceAll(RegExp(r'</(div|p|li|h[1-6])>', caseSensitive: false), '\n');
    text = text.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');

    // 4. Si <div> ou <p> démarre sans saut de ligne devant, insérer un saut de ligne
    text = text.replaceAll(RegExp(r'(?<!\n)\s*<(div|p)[^>]*>', caseSensitive: false), '\n');

    // 5. Traiter les puces : si une puce (•, ●, ▪) apparaît au milieu d'un texte,
    // l'isoler sur une nouvelle ligne pour éviter qu'elle soit collée à la phrase précédente
    text = text.replaceAllMapped(
      RegExp(r'([^\n\r])\s*([•●▪])\s*'),
      (m) => '${m[1]}\n• ',
    );

    // 6. Supprimer les balises orphelines <div>, <p>, <span> qui ne formatent pas
    text = text.replaceAll(RegExp(r'<(div|p|span)[^>]*>', caseSensitive: false), '');
    text = text.replaceAll(RegExp(r'</(span)>', caseSensitive: false), '');

    // 7. Convertir le Markdown courant (**gras** -> <b>gras</b>, *italique* -> <i>italique</i>)
    text = text.replaceAllMapped(
      RegExp(r'\*\*([^*]+)\*\*'),
      (m) => '<b>${m[1]}</b>',
    );
    text = text.replaceAllMapped(
      RegExp(r'(?<!\*)\*([^*]+)\*(?!\*)'),
      (m) => '<i>${m[1]}</i>',
    );

    // 8. Nettoyer et trimmer chaque ligne pour un rendu impeccable
    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .map((l) => l.replaceAll(RegExp(r'([•●▪])\s+'), '• '))
        .toList();

    text = lines.join('\n');

    if (singleLine) {
      text = text.replaceAll(RegExp(r'[\r\n]+'), ' ');
    }

    return text.trim();
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

    // Normalisation préalable du texte
    final normalized = normalizeRichContent(html, singleLine: singleLineFallback);

    // Si le texte ne contient plus aucune balise HTML après normalisation, retour direct
    if (!normalized.contains('<') || !normalized.contains('>')) {
      return TextSpan(text: normalized, style: baseStyle);
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
      var clean = raw;

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

    for (final match in tagExp.allMatches(normalized)) {
      if (match.start > lastIndex) {
        addChunk(normalized.substring(lastIndex, match.start));
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
        case 'div':
        case '/div':
          if (!singleLineFallback && spans.isNotEmpty) {
            final last = spans.last;
            if (last is TextSpan && last.text != null && !last.text!.endsWith('\n')) {
              addChunk('\n');
            }
          }
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

    if (lastIndex < normalized.length) {
      addChunk(normalized.substring(lastIndex));
    }

    return TextSpan(children: spans, style: baseStyle);
  }

  /// Débarrasse une chaîne de ses balises HTML et convertit les listes en puces texte.
  static String stripHtml(String html) {
    if (html.isEmpty) return html;
    final normalized = normalizeRichContent(html);
    return normalized
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .trim();
  }
}

