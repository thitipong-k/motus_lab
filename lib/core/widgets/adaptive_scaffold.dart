import 'package:flutter/material.dart';
import 'package:motus_lab/core/theme/app_colors.dart';

class AdaptiveScaffold extends StatelessWidget {
  final int selectedIndex;
  final Widget body;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationDestination> destinations;

  const AdaptiveScaffold({
    super.key,
    required this.selectedIndex,
    required this.body,
    required this.onDestinationSelected,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // หากหน้าจอกว้างกว่า 600px ให้ใช้ NavigationRail (Tablet/Desktop)
        if (constraints.maxWidth >= 600) {
          return Scaffold(
            body: Row(
              children: [
                SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: NavigationRail(
                        selectedIndex: selectedIndex,
                        onDestinationSelected: onDestinationSelected,
                        labelType: NavigationRailLabelType.all,
                        backgroundColor: AppColors.background,
                        indicatorColor: AppColors.primary.withOpacity(0.2),
                        unselectedIconTheme:
                            const IconThemeData(color: Colors.white54),
                        selectedIconTheme:
                            const IconThemeData(color: AppColors.primary),
                        selectedLabelTextStyle:
                            const TextStyle(color: AppColors.primary),
                        unselectedLabelTextStyle:
                            const TextStyle(color: Colors.white54),
                        destinations: destinations
                            .map((d) => NavigationRailDestination(
                                  icon: d.icon,
                                  selectedIcon: d.selectedIcon ?? d.icon,
                                  label: Text(d.label),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: body),
              ],
            ),
          );
        }

        // หากหน้าจอแคบ (Mobile) ให้ใช้ NavigationBar แบบเดิม
        return Scaffold(
          body: body,
          bottomNavigationBar: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            backgroundColor: AppColors.background,
            indicatorColor: AppColors.primary.withOpacity(0.2),
            destinations: destinations,
          ),
        );
      },
    );
  }
}
