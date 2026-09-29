import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  test('Verify all SVG assets parse cleanly in flutter_svg', () async {
    final files = [
      'assets/images/ladafura-logo-horizontal.svg',
      'assets/images/ladafura-logo-icon.svg',
      'assets/images/ladafura-logo-horizontal-darkmode.svg',
      'assets/images/ladafura-logo-icon-darkmode.svg',
    ];

    for (final path in files) {
      final file = File(path);
      expect(file.existsSync(), isTrue, reason: 'File $path must exist');
      final content = file.readAsStringSync();
      expect(content.isNotEmpty, isTrue);
      final loader = SvgStringLoader(content);
      final picture = await loader.loadBytes(null);
      expect(picture, isNotNull, reason: 'SVG $path failed to load');
    }
  });
}
