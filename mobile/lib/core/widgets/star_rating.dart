import 'package:flutter/material.dart';
import '../constants/colors.dart';

/// TechSOS Star Rating Widget
class StarRating extends StatelessWidget {
  final double rating;
  final int maxStars;
  final double size;
  final bool isInteractive;
  final ValueChanged<int>? onRatingChanged;

  const StarRating({
    super.key,
    required this.rating,
    this.maxStars = 5,
    this.size = 20,
    this.isInteractive = false,
    this.onRatingChanged,
  });

  Widget _buildStar(BuildContext context, int index) {
    IconData icon;
    final starIndex = index + 1;

    if (rating >= starIndex) {
      icon = Icons.star;
    } else if (rating >= starIndex - 0.5) {
      icon = Icons.star_half;
    } else {
      icon = Icons.star_border;
    }

    final starWidget = Icon(
      icon,
      size: size,
      color: TechSosColors.alert,
    );

    if (isInteractive) {
      return GestureDetector(
        key: ValueKey('star_$index'),
        onTap: () {
          if (onRatingChanged != null) {
            onRatingChanged!(starIndex);
          }
        },
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.0),
          child: starWidget,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1.0),
      child: starWidget,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        maxStars,
        (index) => _buildStar(context, index),
      ),
    );
  }
}
