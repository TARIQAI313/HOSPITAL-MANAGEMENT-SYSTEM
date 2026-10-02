import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/routing/navigation_helper.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/status_badge.dart';

class AmbulanceDispatchScreen extends StatelessWidget {
  const AmbulanceDispatchScreen({super.key});

  final List<Map<String, dynamic>> _fleet = const [
    {
      'vehicleNumber': 'AMB-01 (ALS Unit)',
      'model': 'Mercedes Sprinter Intensive Care',
      'driver': 'Officer Mike Kowalski',
      'status': 'available',
      'location': 'Hospital Emergency Bay Standby',
    },
    {
      'vehicleNumber': 'AMB-02 (ALS Unit)',
      'model': 'Ford Transit Trauma Response',
      'driver': 'Officer Carlos Gomez',
      'status': 'dispatched',
      'location': 'En Route to 404 West Avenue (Cardiac SOS)',
    },
    {
      'vehicleNumber': 'AMB-03 (BLS Unit)',
      'model': 'Toyota HiAce Patient Transport',
      'driver': 'Officer David Miller',
      'status': 'available',
      'location': 'North Annex Bay Standby',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return AppBackScope(
      fallbackRoute: RoutePaths.home,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Ambulance Fleet & Emergency Dispatch'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.safePop(null, RoutePaths.home),
          ),
        ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dispatch Hero Callout
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: AppColors.cardHeaderGradient,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: Row(
                children: [
                  const Icon(Icons.emergency_rounded, color: Colors.white, size: 36),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Emergency CAD Dispatching', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('GPS telemetry synchronized with local emergency services.', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                  AppButton(
                    text: '+ Dispatch',
                    variant: ButtonVariant.secondary,
                    height: 36,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Dispatched nearest available ALS ambulance unit.')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text('Hospital Ambulance Fleet (GPS Live)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text)),
            const SizedBox(height: 12),

            ..._fleet.map((veh) {
              final isDispatched = veh['status'] == 'dispatched';

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppCard(
                  hasShadow: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.airport_shuttle_rounded, color: isDispatched ? AppColors.error : AppColors.primaryDark),
                              const SizedBox(width: 8),
                              Text(veh['vehicleNumber'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                          StatusBadge.fromStatus(veh['status'] as String),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Vehicle: ${veh['model']}', style: const TextStyle(fontSize: 13, color: AppColors.text)),
                      Text('Driver: ${veh['driver']}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, size: 14, color: AppColors.primaryDark),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                veh['location'] as String,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    ),
  );
}
}
