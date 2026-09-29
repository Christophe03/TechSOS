import 'package:flutter/material.dart';
import '../constants/colors.dart';

/// Logo officiel TechSOS — symbole vectoriel pur Flutter
///
/// Design : Bouclier bleu nuit avec un éclair orange qui le traverse en diagonale.
/// L'éclair évoque l'urgence (SOS) et l'électronique (tech). Le bouclier symbolise
/// la protection, la fiabilité et la confiance — valeurs clés de TechSOS Bamako.
///
/// Usage :
///   TechSosLogo(size: 72)       // icon carré pour splash / accueil
///   TechSosLogo(size: 48)       // header barre d'app
///   TechSosLogo(size: 32, withText: false)  // navigation / avatar miniature
///   TechSosLogo(size: 96, withText: true)   // écran de sélection de rôle
class TechSosLogo extends StatelessWidget {
  final double size;
  final bool withText;

  const TechSosLogo({
    super.key,
    this.size = 72,
    this.withText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _TechSosLogoPainter(),
          ),
        ),
        if (withText) ...[
          const SizedBox(height: 12),
          _buildWordmark(),
        ],
      ],
    );
  }

  Widget _buildWordmark() {
    final textSize = size * 0.28;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          'Tech',
          style: TextStyle(
            fontSize: textSize,
            fontWeight: FontWeight.w700,
            color: TechSosColors.primary,
            letterSpacing: -0.5,
            height: 1,
          ),
        ),
        Text(
          'SOS',
          style: TextStyle(
            fontSize: textSize,
            fontWeight: FontWeight.w900,
            color: TechSosColors.accent,
            letterSpacing: -0.5,
            height: 1,
          ),
        ),
      ],
    );
  }
}

class _TechSosLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // ── 1. Bouclier bleu nuit ─────────────────────────────────────────────
    final shieldPath = _buildShieldPath(w, h);

    // Dégradé bleu nuit → bleu marine profond
    const shieldGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF274A73), // bleu légèrement plus clair en haut
        TechSosColors.primary,
        Color(0xFF152D4A), // bleu très profond en bas
      ],
      stops: [0.0, 0.5, 1.0],
    );

    final shieldPaint = Paint()
      ..shader = shieldGradient.createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    // Ombre portée sous le bouclier
    final shadowPaint = Paint()
      ..color = TechSosColors.primary.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.save();
    canvas.translate(0, h * 0.04);
    canvas.drawPath(shieldPath, shadowPaint);
    canvas.restore();

    canvas.drawPath(shieldPath, shieldPaint);

    // ── 2. Reflet / lustre sur le bouclier ───────────────────────────────
    final reflectPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    final reflectPath = Path();
    reflectPath.moveTo(w * 0.18, h * 0.08);
    reflectPath.quadraticBezierTo(w * 0.5, h * 0.05, w * 0.82, h * 0.15);
    reflectPath.quadraticBezierTo(w * 0.82, h * 0.3, w * 0.5, h * 0.35);
    reflectPath.quadraticBezierTo(w * 0.18, h * 0.3, w * 0.18, h * 0.08);
    canvas.save();
    canvas.clipPath(shieldPath);
    canvas.drawPath(reflectPath, reflectPaint);
    canvas.restore();

    // ── 3. Bordure / contour léger du bouclier ───────────────────────────
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.025;

    canvas.drawPath(shieldPath, borderPaint);

    // ── 4. Éclair orange — forme principale ──────────────────────────────
    final boltPath = _buildLightningPath(w, h);

    // Dégradé orange → ambre chaud
    const boltGradient = LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [
        Color(0xFFFFA040), // orange vif en haut
        TechSosColors.accent, // orange technique
        Color(0xFFD9A441), // ambre en bas
      ],
    );

    final boltPaint = Paint()
      ..shader = boltGradient.createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    canvas.drawPath(boltPath, boltPaint);

    // ── 5. Reflet blanc sur l'éclair pour effet 3D ───────────────────────
    final boltHighlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    final boltHighlightPath = _buildLightningHighlightPath(w, h);
    canvas.drawPath(boltHighlightPath, boltHighlightPaint);

    // ── 6. Microtexture circuit imprimé dans l'éclair ────────────────────
    _drawCircuitTexture(canvas, w, h, boltPath);

    // ── 7. Indicateur SOS — 3 petits traits en bas du bouclier ──────────
    _drawSosDots(canvas, w, h);
  }

  /// Forme du bouclier TechSOS (haut arrondi, pointe en bas)
  Path _buildShieldPath(double w, double h) {
    final path = Path();
    final r = w * 0.18; // rayon de coin

    // Départ : coin haut-gauche
    path.moveTo(w * 0.12 + r, h * 0.07);
    // Bord supérieur
    path.lineTo(w * 0.88 - r, h * 0.07);
    // Coin haut-droit arrondi
    path.quadraticBezierTo(w * 0.88, h * 0.07, w * 0.88, h * 0.07 + r);
    // Bord droit (vertical)
    path.lineTo(w * 0.88, h * 0.55);
    // Courbe de transition vers la pointe
    path.cubicTo(
      w * 0.88, h * 0.75,
      w * 0.65, h * 0.87,
      w * 0.50, h * 0.94,
    );
    // Pointe gauche
    path.cubicTo(
      w * 0.35, h * 0.87,
      w * 0.12, h * 0.75,
      w * 0.12, h * 0.55,
    );
    // Bord gauche (remonte vers haut-gauche)
    path.lineTo(w * 0.12, h * 0.07 + r);
    // Coin haut-gauche arrondi
    path.quadraticBezierTo(w * 0.12, h * 0.07, w * 0.12 + r, h * 0.07);
    path.close();
    return path;
  }

  /// Forme de l'éclair — diagonale descendante droite→gauche
  Path _buildLightningPath(double w, double h) {
    final path = Path();
    // L'éclair descend du tiers supérieur droit vers le tiers inférieur gauche
    // Forme classique en Z/zigzag avec épaisseur variable (plus épais au centre)
    path.moveTo(w * 0.62, h * 0.11); // pointe haute droite
    path.lineTo(w * 0.36, h * 0.49); // milieu gauche (coude)
    path.lineTo(w * 0.50, h * 0.49); // rentrer vers le centre
    path.lineTo(w * 0.30, h * 0.89); // pointe basse gauche
    path.lineTo(w * 0.60, h * 0.52); // milieu droit (coude)
    path.lineTo(w * 0.46, h * 0.52); // remontée légère droite
    path.close();
    return path;
  }

  /// Reflet partiel (quart supérieur de l'éclair)
  Path _buildLightningHighlightPath(double w, double h) {
    final path = Path();
    path.moveTo(w * 0.62, h * 0.11);
    path.lineTo(w * 0.43, h * 0.35);
    path.lineTo(w * 0.52, h * 0.35);
    path.lineTo(w * 0.67, h * 0.11);
    path.close();
    return path;
  }

  /// Lignes fines de circuit imprimé dans la zone de l'éclair
  void _drawCircuitTexture(Canvas canvas, double w, double h, Path clipPath) {
    canvas.save();
    canvas.clipPath(clipPath);

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..strokeWidth = w * 0.012
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Branche horizontale courte en haut de l'éclair
    canvas.drawLine(
      Offset(w * 0.55, h * 0.21),
      Offset(w * 0.64, h * 0.21),
      linePaint,
    );
    // Nœud (petite pastille)
    canvas.drawCircle(
      Offset(w * 0.64, h * 0.21),
      w * 0.018,
      Paint()..color = Colors.white.withValues(alpha: 0.30),
    );

    // Branche horizontale au niveau du coude
    canvas.drawLine(
      Offset(w * 0.38, h * 0.43),
      Offset(w * 0.48, h * 0.43),
      linePaint,
    );
    canvas.drawCircle(
      Offset(w * 0.38, h * 0.43),
      w * 0.016,
      Paint()..color = Colors.white.withValues(alpha: 0.30),
    );

    // Petite verticale
    canvas.drawLine(
      Offset(w * 0.54, h * 0.60),
      Offset(w * 0.54, h * 0.72),
      linePaint,
    );
    canvas.drawCircle(
      Offset(w * 0.54, h * 0.72),
      w * 0.015,
      Paint()..color = Colors.white.withValues(alpha: 0.30),
    );

    canvas.restore();
  }

  /// 3 barres morse "SOS" (··· ---  ···) en bas du bouclier
  void _drawSosDots(Canvas canvas, double w, double h) {
    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;

    final double y = h * 0.845;
    final double dotR = w * 0.022;
    final double dashW = w * 0.055;
    final double dashH = w * 0.028;
    final double gap = w * 0.032;

    // S = · · ·  (3 cercles)
    double x = w * 0.26;
    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(Offset(x, y), dotR, dotPaint);
      x += dotR * 2 + gap;
    }
    x += gap * 0.6; // espace entre S et O

    // O = — — —  (3 tirets)
    for (int i = 0; i < 3; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(x + dashW / 2, y),
            width: dashW,
            height: dashH,
          ),
          Radius.circular(dashH / 2),
        ),
        dotPaint,
      );
      x += dashW + gap;
    }
    x += gap * 0.6;

    // S = · · ·  (3 cercles)
    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(Offset(x, y), dotR, dotPaint);
      x += dotR * 2 + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Variante horizontale pour les AppBar avec texte intégré
class TechSosLogoHorizontal extends StatelessWidget {
  final double height;

  const TechSosLogoHorizontal({super.key, this.height = 40});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: height,
          height: height,
          child: CustomPaint(painter: _TechSosLogoPainter()),
        ),
        const SizedBox(width: 10),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Tech',
                  style: TextStyle(
                    fontSize: height * 0.40,
                    fontWeight: FontWeight.w700,
                    color: TechSosColors.primary,
                    letterSpacing: -0.3,
                    height: 1,
                  ),
                ),
                Text(
                  'SOS',
                  style: TextStyle(
                    fontSize: height * 0.40,
                    fontWeight: FontWeight.w900,
                    color: TechSosColors.accent,
                    letterSpacing: -0.3,
                    height: 1,
                  ),
                ),
              ],
            ),
            Text(
              'Réparations · Bamako',
              style: TextStyle(
                fontSize: height * 0.20,
                fontWeight: FontWeight.w500,
                color: TechSosColors.textSecondary,
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
