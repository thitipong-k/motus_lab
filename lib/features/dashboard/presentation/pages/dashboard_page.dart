import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motus_lab/core/services/service_locator.dart';
import 'package:motus_lab/core/widgets/adaptive_scaffold.dart';
import 'package:motus_lab/features/scan/presentation/bloc/scan_bloc.dart';
import 'package:motus_lab/features/scan/presentation/bloc/live_data/live_data_bloc.dart';
import 'package:motus_lab/features/scan/presentation/bloc/dtc/dtc_bloc.dart';
import 'package:motus_lab/features/scan/presentation/pages/connection_page.dart';
import 'package:motus_lab/features/scan/presentation/pages/live_data/live_data_page.dart';
import 'package:motus_lab/features/scan/presentation/pages/topology/topology_page.dart';
import 'package:motus_lab/features/maintenance/presentation/pages/maintenance_page.dart';
import 'package:motus_lab/features/dashboard/presentation/pages/more_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // รายการหน้าหลัก (Main Tabs) ที่ถูกจัดกลุ่มใหม่เหลือ 5 หน้า เพื่อความสะอาดตา
    // และให้แสดงผลเหมือนกันทั้งบน Mobile และ Desktop (Unified UX)
    final List<Widget> pages = [
      const ConnectionPage(), // Tab 0: Connect (เชื่อมต่ออุปกรณ์)
      const LiveDataPage(), // Tab 1: Dashboard (หน้าปัดวัดค่าสด)
      const TopologyPage(), // Tab 2: Map (แผนผังโครงสร้าง)
      const MaintenancePage(), // Tab 3: Service (บริการและซ่อมบำรุง)
      const MorePage(), // Tab 4: Menu (รวมฟีเจอร์ย่อยอื่นๆ ไว้ในหน้านี้ เช่น Settings, CRM)
    ];

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: locator<ScanBloc>(),
        ),
        BlocProvider.value(
          value: locator<LiveDataBloc>(),
        ),
        BlocProvider.value(
          value: locator<DtcBloc>(),
        ),
      ],
      child: BlocListener<ScanBloc, ScanState>(
        listener: (context, state) {
          if (state.status == ScanStatus.connected) {
            // Trigger Live Data discovery/streaming immediately after connection
            context.read<LiveDataBloc>().add(const StartStreaming([]));

            setState(() {
              _currentIndex = 1; // Switch to Live Data tab
            });

            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Connection Successful! Starting Live Data...")));
          }
        },
        child: AdaptiveScaffold(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.bluetooth_searching), label: 'Connect'),
            NavigationDestination(icon: Icon(Icons.speed), label: 'Dash'),
            NavigationDestination(icon: Icon(Icons.account_tree), label: 'Map'),
            NavigationDestination(icon: Icon(Icons.build), label: 'Service'),
            NavigationDestination(icon: Icon(Icons.grid_view), label: 'Menu'),
          ],
          // ใช้ IndexedStack เพื่อเก็บ State ของแต่ละหน้าไว้ ไม่ให้หายเมื่อเปลี่ยน Tab
          // (ช่วยแก้ปัญหา Rebuild บ่อย และอาการกระตุก)
          body: IndexedStack(
            index: _currentIndex,
            children: pages,
          ),
        ),
      ),
    );
  }
}
