import 'package:flutter/material.dart';

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
        // [Responsive Design] ฟังก์ชันตรวจสอบความกว้างหน้าจอ
        // กรณีหน้าจอ Tablet/Desktop (ความกว้าง >= 600px)
        // ใช้ NavigationRail ด้านซ้าย เพื่อให้มีพื้นที่เนื้อหามากขึ้นและเหมาะสมกับการใช้งาน Landscape
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
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        indicatorColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.2),
                        unselectedIconTheme: IconThemeData(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6)),
                        selectedIconTheme: IconThemeData(
                            color: Theme.of(context).colorScheme.primary),
                        selectedLabelTextStyle: TextStyle(
                            color: Theme.of(context).colorScheme.primary),
                        unselectedLabelTextStyle: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6)),
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
                VerticalDivider(
                    thickness: 1,
                    width: 1,
                    color: Theme.of(context).dividerColor),
                Expanded(child: body),
              ],
            ),
          );
        }

        // [Mobile Design] กรณีหน้าจอ Mobile (ความกว้าง < 600px)
        // ใช้ NavigationBar ด้านล่าง (Bottom Navigation)
        // เพื่อความสะดวกในการกดด้วยนิ้วโป้ง (Thumb-friendly UX)
        return Scaffold(
          body: body,
          bottomNavigationBar: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            backgroundColor: Theme.of(context).colorScheme.surface,
            indicatorColor:
                Theme.of(context).colorScheme.primary.withOpacity(0.2),
            destinations: destinations,
          ),
        );
      },
    );
  }
}
