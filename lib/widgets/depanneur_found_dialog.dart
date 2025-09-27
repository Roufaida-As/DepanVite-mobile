import 'package:flutter/material.dart';
import 'package:depanvite/theme/app_theme.dart';

class DepanneurFoundDialog extends StatelessWidget {
  final String depanneurName;
  final double rating;
  final String vehicleType;
  final String matricule;
  final String phoneNumber;
  final String distanceText;
  final VoidCallback onCall;
  final VoidCallback onClose;

  const DepanneurFoundDialog({
    super.key,
    required this.depanneurName,
    required this.rating,
    required this.vehicleType,
    required this.matricule,
    required this.phoneNumber,
    required this.distanceText,
    required this.onCall,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header avec message de succès et distance
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Dépanneur Trouvé parmi les dépanneurs partenaires de AXA !",
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // Distance badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.yellow,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  distanceText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),

          Divider(color: AppTheme.grey2, height: 2),
          const SizedBox(height: 40),
          // Profile section
          Row(
            children: [
              // Avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.grey2, width: 2),
                ),
                child: ClipOval(
                  child: Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.person,
                      size: 35,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Name and rating
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      depanneurName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: AppTheme.yellow,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          rating.toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),

          // Vehicle information
          Column(
            children: [
              _buildInfoRow("Matricule", matricule),
              const SizedBox(height: 12),
              _buildInfoRow("Type de véhicule", vehicleType),
            ],
          ),

          const SizedBox(height: 24),

          // Call button
          GestureDetector(
            onTap: onCall,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.phone, color: Colors.green, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    "Appeler le : $phoneNumber",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "$label :",
          style: const TextStyle(
            fontSize: 15,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            color: AppTheme.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
