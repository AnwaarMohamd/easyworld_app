import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

abstract class CharacterStatusHelper {
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'alive':
        return AppColors.alive;
      case 'dead':
        return AppColors.dead;
      default:
        return AppColors.unknown;
    }
  }
}