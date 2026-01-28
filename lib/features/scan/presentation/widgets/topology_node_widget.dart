import 'package:flutter/material.dart';
import 'package:motus_lab/core/theme/app_colors.dart';
import 'package:motus_lab/domain/entities/vehicle_module.dart';

class TopologyNodeWidget extends StatelessWidget {
  final VehicleModule module;
  final VoidCallback? onTap;

  const TopologyNodeWidget({
    super.key,
    required this.module,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;

    switch (module.status) {
      case ModuleStatus.ok:
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        break;
      case ModuleStatus.fault:
        statusColor = AppColors.error;
        statusIcon = Icons.warning;
        break;
      case ModuleStatus.offline:
        statusColor = Colors.grey;
        statusIcon = Icons.power_off;
        break;
      case ModuleStatus.scanning:
        statusColor = AppColors.primary;
        statusIcon = Icons.radar;
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: statusColor.withOpacity(0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: statusColor.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  module.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                Icon(statusIcon, color: statusColor, size: 20),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              module.bus,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
            const Spacer(),
            if (module.status == ModuleStatus.fault)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "${module.dtcCount} DTCs",
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              )
            else if (module.status == ModuleStatus.ok)
              const Text(
                "System OK",
                style: TextStyle(fontSize: 12, color: AppColors.success),
              )
            else
              Text(
                module.status.name.toUpperCase(),
                style: TextStyle(fontSize: 12, color: statusColor),
              ),
          ],
        ),
      ),
    );
  }
}
