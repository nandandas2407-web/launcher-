import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:liquidos/core/utils/squircle_path.dart';
import 'package:liquidos/core/theme/glass_tokens.dart';
import 'package:liquidos/widgets/liquid_glass_panel.dart';
import 'package:liquidos/widgets/glass_icon.dart';
import 'package:liquidos/widgets/glass_controls.dart';

void main() {
  group('SquirclePath', () {
    test('creates valid squircle path for given rect', () {
      final rect = Rect.fromLTWH(0, 0, 100, 100);
      final path = SquirclePath.createSquirclePath(rect, 18.0);
      expect(path, isNotNull);
      expect(path.getBounds(), equals(rect));
    });

    test('handles zero radius', () {
      final rect = Rect.fromLTWH(0, 0, 100, 100);
      final path = SquirclePath.createSquirclePath(rect, 0.0);
      expect(path, isNotNull);
    });

    test('clamps radius to half of smallest dimension', () {
      final rect = Rect.fromLTWH(0, 0, 100, 50);
      final path = SquirclePath.createSquirclePath(rect, 60.0);
      expect(path, isNotNull);
    });
  });

  group('GlassTokens', () {
    test('blur sigma values are positive', () {
      expect(GlassTokens.blurSigmaHigh, greaterThan(0));
      expect(GlassTokens.blurSigmaStandard, greaterThan(0));
      expect(GlassTokens.blurSigmaLow, greaterThan(0));
    });

    test('accent colors are defined', () {
      expect(GlassTokens.accentAqua, isNotNull);
      expect(GlassTokens.accentIndigo, isNotNull);
      expect(GlassTokens.accentEmerald, isNotNull);
      expect(GlassTokens.accentAmber, isNotNull);
      expect(GlassTokens.accentCrimson, isNotNull);
      expect(GlassTokens.accentTerminalGreen, isNotNull);
    });

    test('glass shadow returns list', () {
      final shadows = GlassTokens.darkGlassShadow();
      expect(shadows, isNotEmpty);
    });
  });

  group('LiquidGlassPanel', () {
    testWidgets('renders with child', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: Colors.black,
            body: LiquidGlassPanel(
              child: const Text('Test'),
            ),
          ),
        ),
      );
      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('renders with custom blur sigma', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: Colors.black,
            body: LiquidGlassPanel(
              blurSigma: 40.0,
              child: const Text('Custom Blur'),
            ),
          ),
        ),
      );
      expect(find.text('Custom Blur'), findsOneWidget);
    });
  });

  group('GlassIcon', () {
    testWidgets('renders with letter fallback', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: Colors.black,
            body: GlassIcon(
              letterFallback: 'T',
              size: 64.0,
            ),
          ),
        ),
      );
      expect(find.text('T'), findsOneWidget);
    });

    testWidgets('renders with badge', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: Colors.black,
            body: GlassIcon(
              letterFallback: 'A',
              size: 64.0,
              showBadge: true,
              badgeText: '3',
            ),
          ),
        ),
      );
      expect(find.text('3'), findsOneWidget);
    });
  });

  group('GlassToggle', () {
    testWidgets('toggles value on tap', (tester) async {
      bool value = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: Colors.black,
            body: GlassToggle(
              value: value,
              onChanged: (v) => value = v,
            ),
          ),
        ),
      );
      await tester.tap(find.byType(GlassToggle));
      expect(value, true);
    });
  });

  group('GlassButton', () {
    testWidgets('calls onPressed on tap', (tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: Colors.black,
            body: GlassButton(
              label: 'Test',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );
      await tester.tap(find.byType(GlassButton));
      expect(pressed, true);
    });
  });
}
