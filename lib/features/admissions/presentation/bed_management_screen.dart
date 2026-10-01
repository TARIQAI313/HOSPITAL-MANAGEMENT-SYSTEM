import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../domain/bed_management_model.dart';

final selectedWardFilterProvider = StateProvider<String>((ref) => 'All');

class BedManagementScreen extends ConsumerWidget {
  const BedManagementScreen({super.key});

  final List<HospitalBedModel> _beds = const [
    HospitalBedModel(
      id: 'b-1',
      roomNumber: 'Room 301',
      bedNumber: 'Bed A',
      wardType: 'General Ward',
      floor: 3,
      status: 'occupied',
      patientName: 'Emma Stonehurst',
      admissionReason: 'Cardiac post-observation',
    ),
    HospitalBedModel(
      id: 'b-2',
      roomNumber: 'Room 301',
      bedNumber: 'Bed B',
      wardType: 'General Ward',
      floor: 3,
      status: 'available',
    ),
    HospitalBedModel(
      id: 'b-3',
      roomNumber: 'Room 302',
      bedNumber: 'Bed A',
      wardType: 'General Ward',
      floor: 3,
      status: 'cleaning',
    ),
    HospitalBedModel(
      id: 'b-4',
      roomNumber: 'ICU-1',
      bedNumber: 'Bed 01',
      wardType: 'ICU',
      floor: 4,
      status: 'occupied',
      patientName: 'Noah Sinclair',
      admissionReason: 'Severe respiratory distress',
      dailyRate: 450.0,
    ),
    HospitalBedModel(
      id: 'b-5',
      roomNumber: 'ICU-2',
      bedNumber: 'Bed 02',
      wardType: 'ICU',
      floor: 4,
      status: 'available',
      dailyRate: 450.0,
    ),
    HospitalBedModel(
      id: 'b-6',
      roomNumber: 'Suite 501',
      bedNumber: 'Private Bed',
      wardType: 'Private Suite',
      floor: 5,
      status: 'available',
      dailyRate: 280.0,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFilter = ref.watch(selectedWardFilterProvider);
    final wards = ['All', 'General Ward', 'ICU', 'Private Suite'];

    final filtered = _beds.where((b) {
      if (activeFilter == 'All') return true;
      return b.wardType == activeFilter;
    }).toList();

    final totalOccupied = _beds.where((b) => b.status == 'occupied').length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Hospital Wards & Bed Allocation'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Capacity Summary Banner
          Container(
            margin: const EdgeInsets.all(AppSpacing.lg),
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: AppColors.cardHeaderGradient,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('TOTAL BEDS', '${_beds.length}'),
                _buildStatItem('OCCUPIED', '$totalOccupied'),
                _buildStatItem('AVAILABLE', '${_beds.length - totalOccupied}'),
              ],
            ),
          ),

          // Ward Filters
          SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              scrollDirection: Axis.horizontal,
              itemCount: wards.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final w = wards[idx];
                final isSelected = activeFilter == w;
                return ChoiceChip(
                  label: Text(w),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.text,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                  onSelected: (_) => ref.read(selectedWardFilterProvider.notifier).state = w,
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(AppSpacing.lg),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.95,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, idx) {
                final bed = filtered[idx];

                return AppCard(
                  hasShadow: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.hotel_rounded,
                            color: bed.isAvailable ? AppColors.success : AppColors.primaryDark,
                            size: 24,
                          ),
                          StatusBadge.fromStatus(bed.status),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${bed.roomNumber} - ${bed.bedNumber}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            '${bed.wardType} • Floor ${bed.floor}',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                          ),
                          if (bed.patientName != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Patient: ${bed.patientName}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryDark),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        '\$${bed.dailyRate.toStringAsFixed(0)} / day',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
