import 'package:flutter/material.dart';
import '../constants/colors.dart';

// ════════════════════════════════════════════════════════════════════════════
//  SYSTÈME DE DÉCLINAISONS DU LOGO TECHSOS
// ════════════════════════════════════════════════════════════════════════════
//
//  VARIANTES DE COULEUR :
//  ┌─────────────────┬──────────────────────────────────────────────────────┐
//  │ color           │ Officiel : bouclier bleu + éclair orange (fond clair)│
//  │ white           │ Tout blanc pur — sur fond sombre (bleu nuit, noir)   │
//  │ orange          │ Tout orange/ambre — sur fond sombre ou neutre        │
//  │ monochrome      │ Nuances de gris — impression, filigrane              │
//  │ darkBadge       │ Fond bleu nuit intégré, éléments blancs+orange       │
//  │ primaryOnDark   │ Bouclier blanc + éclair orange — sur fond coloré     │
//  └─────────────────┴──────────────────────────────────────────────────────┘
//
//  FORMATS :
//  ┌─────────────────┬──────────────────────────────────────────────────────┐
//  │ TechSosLogo     │ Icône carrée seule (withText: true → + wordmark bas) │
//  │ TechSosLogoH    │ Paysage : icône + wordmark + sous-titre              │
//  │ TechSosWordmark │ Wordmark texte seul (Tech + SOS), sans icône         │
//  │ TechSosBadge    │ Pill arrondie avec logo + nom (signature compacte)   │
//  │ TechSosIconOnly │ Juste l'éclair (sans bouclier) — navigation miniature│
//  └─────────────────┴──────────────────────────────────────────────────────┘

/// Variante de couleur du logo TechSOS
enum TechSosLogoVariant {
  /// ✅ Officiel — Bouclier bleu nuit + éclair orange → sur fond clair (#F7F8FA, blanc)
  color,

  /// ⬜ Blanc pur — tout blanc, sans ombre → sur fond sombre (bleu nuit, noir, dégradé)
  white,

  /// 🟠 Orange/Ambre — tout orange → sur fond sombre ou foncé
  orange,

  /// ⬛ Monochrome gris — nuances de gris → impression, filigrane, fond neutre
  monochrome,

  /// 🔵 Badge foncé intégré — fond bleu nuit, logo blanc + éclair orange (auto-contenu)
  darkBadge,

  /// 🔶 Bouclier blanc + éclair orange → sur fond coloré foncé non-bleu (vert, rouge…)
  primaryOnDark,
}

// ─────────────────────────────────────────────────────────────────────────────
//  RÉSOLUTION DES COULEURS PAR VARIANTE
// ─────────────────────────────────────────────────────────────────────────────

class _LogoColors {
  final Color shieldTop;
  final Color shieldMid;
  final Color shieldBot;
  final Color boltTop;
  final Color boltMid;
  final Color boltBot;
  final Color highlight;
  final Color circuit;
  final Color sos;
  final Color border;
  final Color shadow;
  final Color textTech;
  final Color textSos;
  final Color textSub;

  const _LogoColors({
    required this.shieldTop,
    required this.shieldMid,
    required this.shieldBot,
    required this.boltTop,
    required this.boltMid,
    required this.boltBot,
    required this.highlight,
    required this.circuit,
    required this.sos,
    required this.border,
    required this.shadow,
    required this.textTech,
    required this.textSos,
    required this.textSub,
  });

  static _LogoColors resolve(TechSosLogoVariant v) {
    switch (v) {
      case TechSosLogoVariant.color:
        return const _LogoColors(
          shieldTop: Color(0xFF274A73),
          shieldMid: TechSosColors.primary,
          shieldBot: Color(0xFF152D4A),
          boltTop: Color(0xFFFFA040),
          boltMid: TechSosColors.accent,
          boltBot: Color(0xFFD9A441),
          highlight: Color(0x66FFFFFF),
          circuit: Color(0x38FFFFFF),
          sos: Color(0x8CFFFFFF),
          border: Color(0x2EFFFFFF),
          shadow: Color(0x591F3A5F),
          textTech: TechSosColors.primary,
          textSos: TechSosColors.accent,
          textSub: TechSosColors.textSecondary,
        );

      case TechSosLogoVariant.white:
        return const _LogoColors(
          shieldTop: Color(0xFFFFFFFF),
          shieldMid: Color(0xFFE8E8E8),
          shieldBot: Color(0xFFCCCCCC),
          boltTop: Color(0xFFFFFFFF),
          boltMid: Color(0xFFFFFFFF),
          boltBot: Color(0xFFEEEEEE),
          highlight: Color(0x55FFFFFF),
          circuit: Color(0x66CCCCCC),
          sos: Color(0xAAFFFFFF),
          border: Color(0x44FFFFFF),
          shadow: Color(0x22000000),
          textTech: Color(0xFFFFFFFF),
          textSos: Color(0xFFFFFFFF),
          textSub: Color(0xAAFFFFFF),
        );

      case TechSosLogoVariant.orange:
        return const _LogoColors(
          shieldTop: Color(0xFFFFA040),
          shieldMid: TechSosColors.accent,
          shieldBot: Color(0xFFCC5010),
          boltTop: Color(0xFFFFFFFF),
          boltMid: Color(0xFFFFEECC),
          boltBot: Color(0xFFFFDDA0),
          highlight: Color(0x55FFFFFF),
          circuit: Color(0x44FFFFFF),
          sos: Color(0xBBFFFFFF),
          border: Color(0x33FFFFFF),
          shadow: Color(0x44E8641C),
          textTech: TechSosColors.accent,
          textSos: Color(0xFFD9A441),
          textSub: Color(0x99E8641C),
        );

      case TechSosLogoVariant.monochrome:
        return const _LogoColors(
          shieldTop: Color(0xFF555555),
          shieldMid: Color(0xFF333333),
          shieldBot: Color(0xFF111111),
          boltTop: Color(0xFFCCCCCC),
          boltMid: Color(0xFFAAAAAA),
          boltBot: Color(0xFF888888),
          highlight: Color(0x44FFFFFF),
          circuit: Color(0x33FFFFFF),
          sos: Color(0x77FFFFFF),
          border: Color(0x22FFFFFF),
          shadow: Color(0x33000000),
          textTech: Color(0xFF333333),
          textSos: Color(0xFF666666),
          textSub: Color(0xFF999999),
        );

      case TechSosLogoVariant.darkBadge:
        // Rendu identique au color mais avec fond auto-intégré
        return const _LogoColors(
          shieldTop: Color(0xFF274A73),
          shieldMid: TechSosColors.primary,
          shieldBot: Color(0xFF152D4A),
          boltTop: Color(0xFFFFA040),
          boltMid: TechSosColors.accent,
          boltBot: Color(0xFFD9A441),
          highlight: Color(0x66FFFFFF),
          circuit: Color(0x38FFFFFF),
          sos: Color(0x8CFFFFFF),
          border: Color(0x2EFFFFFF),
          shadow: Color(0x591F3A5F),
          textTech: Color(0xFFFFFFFF),
          textSos: TechSosColors.accent,
          textSub: Color(0xAAFFFFFF),
        );

      case TechSosLogoVariant.primaryOnDark:
        return const _LogoColors(
          shieldTop: Color(0xFFFFFFFF),
          shieldMid: Color(0xFFF0F0F0),
          shieldBot: Color(0xFFDDDDDD),
          boltTop: Color(0xFFFFA040),
          boltMid: TechSosColors.accent,
          boltBot: Color(0xFFD9A441),
          highlight: Color(0x66FFFFFF),
          circuit: Color(0x44E8641C),
          sos: Color(0xAAE8641C),
          border: Color(0x33FFFFFF),
          shadow: Color(0x33000000),
          textTech: Color(0xFFFFFFFF),
          textSos: TechSosColors.accent,
          textSub: Color(0xAAFFFFFF),
        );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  PAINTER PARAMÉTRABLE
// ─────────────────────────────────────────────────────────────────────────────

class _TechSosLogoPainter extends CustomPainter {
  final _LogoColors c;
  const _TechSosLogoPainter(this.c);

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final shieldPath = _buildShieldPath(w, h);
    final boltPath = _buildLightningPath(w, h);

    // ── Ombre ──────────────────────────────────────────────────────────────
    final shadowPaint = Paint()
      ..color = c.shadow
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.save();
    canvas.translate(0, h * 0.04);
    canvas.drawPath(shieldPath, shadowPaint);
    canvas.restore();

    // ── Bouclier ───────────────────────────────────────────────────────────
    final shieldGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [c.shieldTop, c.shieldMid, c.shieldBot],
      stops: const [0.0, 0.5, 1.0],
    );
    final shieldPaint = Paint()
      ..shader = shieldGradient.createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;
    canvas.drawPath(shieldPath, shieldPaint);

    // ── Reflet haut du bouclier ────────────────────────────────────────────
    final reflectPath = Path()
      ..moveTo(w * 0.18, h * 0.08)
      ..quadraticBezierTo(w * 0.5, h * 0.05, w * 0.82, h * 0.15)
      ..quadraticBezierTo(w * 0.82, h * 0.3, w * 0.5, h * 0.35)
      ..quadraticBezierTo(w * 0.18, h * 0.3, w * 0.18, h * 0.08);
    final reflectPaint = Paint()
      ..color = c.highlight.withValues(alpha: 0.13)
      ..style = PaintingStyle.fill;
    canvas.save();
    canvas.clipPath(shieldPath);
    canvas.drawPath(reflectPath, reflectPaint);
    canvas.restore();

    // ── Bordure bouclier ───────────────────────────────────────────────────
    canvas.drawPath(
      shieldPath,
      Paint()
        ..color = c.border
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.025,
    );

    // ── Éclair ─────────────────────────────────────────────────────────────
    final boltGradient = LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [c.boltTop, c.boltMid, c.boltBot],
    );
    final boltPaint = Paint()
      ..shader = boltGradient.createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;
    canvas.drawPath(boltPath, boltPaint);

    // ── Reflet éclair ──────────────────────────────────────────────────────
    final boltHigh = Path()
      ..moveTo(w * 0.62, h * 0.11)
      ..lineTo(w * 0.43, h * 0.35)
      ..lineTo(w * 0.52, h * 0.35)
      ..lineTo(w * 0.67, h * 0.11)
      ..close();
    canvas.drawPath(
      boltHigh,
      Paint()
        ..color = c.highlight
        ..style = PaintingStyle.fill,
    );

    // ── Texture circuit imprimé ────────────────────────────────────────────
    _drawCircuit(canvas, w, h, boltPath);

    // ── Morse SOS en bas ───────────────────────────────────────────────────
    _drawSos(canvas, w, h);
  }

  Path _buildShieldPath(double w, double h) {
    final r = w * 0.18;
    return Path()
      ..moveTo(w * 0.12 + r, h * 0.07)
      ..lineTo(w * 0.88 - r, h * 0.07)
      ..quadraticBezierTo(w * 0.88, h * 0.07, w * 0.88, h * 0.07 + r)
      ..lineTo(w * 0.88, h * 0.55)
      ..cubicTo(w * 0.88, h * 0.75, w * 0.65, h * 0.87, w * 0.50, h * 0.94)
      ..cubicTo(w * 0.35, h * 0.87, w * 0.12, h * 0.75, w * 0.12, h * 0.55)
      ..lineTo(w * 0.12, h * 0.07 + r)
      ..quadraticBezierTo(w * 0.12, h * 0.07, w * 0.12 + r, h * 0.07)
      ..close();
  }

  Path _buildLightningPath(double w, double h) {
    return Path()
      ..moveTo(w * 0.62, h * 0.11)
      ..lineTo(w * 0.36, h * 0.49)
      ..lineTo(w * 0.50, h * 0.49)
      ..lineTo(w * 0.30, h * 0.89)
      ..lineTo(w * 0.60, h * 0.52)
      ..lineTo(w * 0.46, h * 0.52)
      ..close();
  }

  void _drawCircuit(Canvas canvas, double w, double h, Path clip) {
    canvas.save();
    canvas.clipPath(clip);
    final p = Paint()
      ..color = c.circuit
      ..strokeWidth = w * 0.012
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final dot = Paint()..color = c.circuit;

    canvas.drawLine(Offset(w * 0.55, h * 0.21), Offset(w * 0.64, h * 0.21), p);
    canvas.drawCircle(Offset(w * 0.64, h * 0.21), w * 0.018, dot);
    canvas.drawLine(Offset(w * 0.38, h * 0.43), Offset(w * 0.48, h * 0.43), p);
    canvas.drawCircle(Offset(w * 0.38, h * 0.43), w * 0.016, dot);
    canvas.drawLine(Offset(w * 0.54, h * 0.60), Offset(w * 0.54, h * 0.72), p);
    canvas.drawCircle(Offset(w * 0.54, h * 0.72), w * 0.015, dot);
    canvas.restore();
  }

  void _drawSos(Canvas canvas, double w, double h) {
    final p = Paint()
      ..color = c.sos
      ..style = PaintingStyle.fill;
    const double yRatio = 0.845;
    final double y = h * yRatio;
    final double dotR = w * 0.022;
    final double dashW = w * 0.055;
    final double dashH = w * 0.028;
    final double gap = w * 0.032;

    double x = w * 0.26;
    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(Offset(x, y), dotR, p);
      x += dotR * 2 + gap;
    }
    x += gap * 0.6;
    for (int i = 0; i < 3; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(x + dashW / 2, y), width: dashW, height: dashH),
          Radius.circular(dashH / 2),
        ),
        p,
      );
      x += dashW + gap;
    }
    x += gap * 0.6;
    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(Offset(x, y), dotR, p);
      x += dotR * 2 + gap;
    }
  }

  @override
  bool shouldRepaint(_TechSosLogoPainter old) => old.c != c;
}

// ─────────────────────────────────────────────────────────────────────────────
//  PAINTER ÉCLAIR SEUL (sans bouclier)
// ─────────────────────────────────────────────────────────────────────────────

class _TechSosBoltPainter extends CustomPainter {
  final _LogoColors c;
  const _TechSosBoltPainter(this.c);

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final boltPath = Path()
      ..moveTo(w * 0.62, h * 0.05)
      ..lineTo(w * 0.30, h * 0.52)
      ..lineTo(w * 0.48, h * 0.52)
      ..lineTo(w * 0.18, h * 0.95)
      ..lineTo(w * 0.54, h * 0.56)
      ..lineTo(w * 0.38, h * 0.56)
      ..close();

    final boltGradient = LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [c.boltTop, c.boltMid, c.boltBot],
    );
    canvas.drawPath(
      boltPath,
      Paint()
        ..shader = boltGradient.createShader(Rect.fromLTWH(0, 0, w, h))
        ..style = PaintingStyle.fill,
    );

    // Reflet
    final high = Path()
      ..moveTo(w * 0.62, h * 0.05)
      ..lineTo(w * 0.44, h * 0.32)
      ..lineTo(w * 0.54, h * 0.32)
      ..lineTo(w * 0.70, h * 0.05)
      ..close();
    canvas.drawPath(
      high,
      Paint()
        ..color = c.highlight
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_TechSosBoltPainter old) => old.c != c;
}

// ════════════════════════════════════════════════════════════════════════════
//  WIDGETS PUBLICS
// ════════════════════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────────────────────────────────────
//  1. TechSosLogo — icône carrée (± wordmark en dessous)
// ─────────────────────────────────────────────────────────────────────────────
/// Icône carré du bouclier TechSOS.
///
/// ```dart
/// TechSosLogo(size: 96, withText: true)               // accueil
/// TechSosLogo(size: 72, variant: TechSosLogoVariant.white)  // fond sombre
/// ```
class TechSosLogo extends StatelessWidget {
  final double size;
  final bool withText;
  final TechSosLogoVariant variant;

  const TechSosLogo({
    super.key,
    this.size = 72,
    this.withText = false,
    this.variant = TechSosLogoVariant.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = _LogoColors.resolve(variant);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(painter: _TechSosLogoPainter(c)),
        ),
        if (withText) ...[
          SizedBox(height: size * 0.14),
          _Wordmark(size: size * 0.28, c: c),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  2. TechSosLogoHorizontal — paysage : icône + wordmark + sous-titre
// ─────────────────────────────────────────────────────────────────────────────
/// Version paysage pour AppBar, headers, cartes de présentation.
///
/// ```dart
/// TechSosLogoHorizontal(height: 38)                        // AppBar claire
/// TechSosLogoHorizontal(height: 38, variant: TechSosLogoVariant.white) // AppBar sombre
/// TechSosLogoHorizontal(height: 38, showSubtitle: false)   // compact sans tagline
/// ```
class TechSosLogoHorizontal extends StatelessWidget {
  final double height;
  final TechSosLogoVariant variant;
  final bool showSubtitle;

  const TechSosLogoHorizontal({
    super.key,
    this.height = 40,
    this.variant = TechSosLogoVariant.color,
    this.showSubtitle = true,
  });

  @override
  Widget build(BuildContext context) {
    final c = _LogoColors.resolve(variant);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: height,
          height: height,
          child: CustomPaint(painter: _TechSosLogoPainter(c)),
        ),
        SizedBox(width: height * 0.25),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Wordmark(size: height * 0.40, c: c),
            if (showSubtitle)
              Text(
                'Réparations · Bamako',
                style: TextStyle(
                  fontSize: (height * 0.20).clamp(10.0, 13.0),
                  fontWeight: FontWeight.w500,
                  color: c.textSub,
                  letterSpacing: 0.2,
                  height: 1,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  3. TechSosWordmark — texte seul (Tech + SOS), sans icône
// ─────────────────────────────────────────────────────────────────────────────
/// Texte wordmark uniquement. Utile dans les titres de page ou légendes.
///
/// ```dart
/// TechSosWordmark(fontSize: 22)
/// TechSosWordmark(fontSize: 18, variant: TechSosLogoVariant.white)
/// ```
class TechSosWordmark extends StatelessWidget {
  final double fontSize;
  final TechSosLogoVariant variant;

  const TechSosWordmark({
    super.key,
    this.fontSize = 22,
    this.variant = TechSosLogoVariant.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = _LogoColors.resolve(variant);
    return _Wordmark(size: fontSize, c: c);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  4. TechSosBadge — pill signature compacte avec fond intégré
// ─────────────────────────────────────────────────────────────────────────────
/// Badge pill auto-contenu avec fond, icône miniature et nom.
/// Idéal : footers, email signatures, watermarks, cartes partenaire.
///
/// ```dart
/// TechSosBadge()                                    // fond bleu nuit
/// TechSosBadge(variant: TechSosLogoVariant.orange)  // fond orange
/// TechSosBadge(variant: TechSosLogoVariant.white, bgColor: Color(0xFF1F3A5F))
/// ```
class TechSosBadge extends StatelessWidget {
  final TechSosLogoVariant variant;
  final Color? bgColor;
  final double height;

  const TechSosBadge({
    super.key,
    this.variant = TechSosLogoVariant.white,
    this.bgColor,
    this.height = 36,
  });

  @override
  Widget build(BuildContext context) {
    final c = _LogoColors.resolve(variant);
    final bg = bgColor ??
        (variant == TechSosLogoVariant.orange
            ? TechSosColors.accent
            : variant == TechSosLogoVariant.white || variant == TechSosLogoVariant.darkBadge
                ? TechSosColors.primary
                : TechSosColors.primary);

    return Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: height * 0.38, vertical: height * 0.14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(height / 2),
        boxShadow: [
          BoxShadow(
            color: bg.withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: height * 0.55,
            height: height * 0.55,
            child: CustomPaint(painter: _TechSosLogoPainter(c)),
          ),
          SizedBox(width: height * 0.22),
          _Wordmark(size: height * 0.32, c: c),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  5. TechSosIconOnly — éclair seul, sans bouclier (navigation miniature)
// ─────────────────────────────────────────────────────────────────────────────
/// Uniquement l'éclair — très compact, pour bottom navigation, loading,
/// splash minimal, favicon ou overlay.
///
/// ```dart
/// TechSosIconOnly(size: 24)                                    // nav bar
/// TechSosIconOnly(size: 20, variant: TechSosLogoVariant.white) // fond sombre
/// ```
class TechSosIconOnly extends StatelessWidget {
  final double size;
  final TechSosLogoVariant variant;

  const TechSosIconOnly({
    super.key,
    this.size = 24,
    this.variant = TechSosLogoVariant.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = _LogoColors.resolve(variant);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _TechSosBoltPainter(c)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  6. TechSosSplash — splash screen / loading screen plein écran auto-contenu
// ─────────────────────────────────────────────────────────────────────────────
/// Fond bleu nuit + logo blanc centré + tagline.
/// À utiliser comme premier widget de l'app avant chargement.
class TechSosSplash extends StatelessWidget {
  const TechSosSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: TechSosColors.primary,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TechSosLogo(
              size: 110,
              withText: false,
              variant: TechSosLogoVariant.white,
            ),
            SizedBox(height: 28),
            TechSosWordmark(
              fontSize: 32,
              variant: TechSosLogoVariant.white,
            ),
            SizedBox(height: 10),
            Text(
              'Réparations électroniques à Bamako',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xAAFFFFFF),
                letterSpacing: 0.3,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  WIDGET INTERNE — Wordmark bicolore Tech|SOS
// ─────────────────────────────────────────────────────────────────────────────

class _Wordmark extends StatelessWidget {
  final double size;
  final _LogoColors c;

  const _Wordmark({required this.size, required this.c});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          'Tech',
          style: TextStyle(
            fontSize: size.clamp(12.0, 200.0),
            fontWeight: FontWeight.w700,
            color: c.textTech,
            letterSpacing: -0.5,
            height: 1,
          ),
        ),
        Text(
          'SOS',
          style: TextStyle(
            fontSize: size.clamp(12.0, 200.0),
            fontWeight: FontWeight.w900,
            color: c.textSos,
            letterSpacing: -0.5,
            height: 1,
          ),
        ),
      ],
    );
  }
}
