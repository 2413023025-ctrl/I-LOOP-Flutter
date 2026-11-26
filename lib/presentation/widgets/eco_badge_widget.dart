import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class EcoBadgeWidget extends StatelessWidget {
  final int itemsSaved;

  const EcoBadgeWidget({super.key, required this.itemsSaved});

  @override
  Widget build(BuildContext context) {
    String rankTitle = 'Sahabat Bumi Pemula';
    Color rankColor = AppColors.secondary;
    IconData rankIcon = Icons.eco;

    if (itemsSaved >= 20) {
      rankTitle = 'Pahlawan Sirkular Emas';
      rankColor = const Color(0xFFFFB300);
      rankIcon = Icons.workspace_premium;
    } else if (itemsSaved >= 10) {
      rankTitle = 'Pejuang Sirkular';
      rankColor = const Color(0xFF00897B);
      rankIcon = Icons.military_tech;
    } else if (itemsSaved >= 3) {
      rankTitle = 'Pecinta Daur Ulang';
      rankColor = AppColors.primary;
      rankIcon = Icons.recycling;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.08),
            AppColors.accent.withOpacity(0.12),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: rankColor.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(rankIcon, color: rankColor, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '$itemsSaved Barang',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Diselamatkan',
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  rankTitle,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: rankColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
