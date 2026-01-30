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
import 'package:motus_lab/features/scan/presentation/pages/freeze_frame_page.dart';
import 'package:motus_lab/features/settings/presentation/pages/settings_page.dart';
import 'package:motus_lab/features/coding/presentation/pages/adaptation_page.dart';
import 'package:motus_lab/features/sniffer/presentation/pages/sniffer_page.dart';
import 'package:motus_lab/features/maintenance/presentation/pages/maintenance_page.dart';
import 'package:motus_lab/features/crm/presentation/pages/customer_list_page.dart';
import 'package:motus_lab/features/remote/presentation/pages/remote_expert_page.dart';
import 'package:motus_lab/features/profile/presentation/pages/wallet_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const ConnectionPage(), // Tab 0: Connect
      const LiveDataPage(), // Tab 1: Dashboard
      const TopologyPage(), // Tab 2: Topology
      const FreezeFramePage(), // Tab 3: Freeze Frame
      const MaintenancePage(), // Tab 4: Service (Maintenance)
      const CustomerListPage(), // Tab 5: CRM
      const RemoteExpertPage(), // Tab 6: Remote (Phase 5)
      const WalletPage(), // Tab 7: Wallet (Phase 5)
      const AdaptationPage(), // Tab 8: Coding
      const SnifferPage(), // Tab 9: Sniffer
      const SettingsPage(), // Tab 10: Settings
    ];

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => locator<ScanBloc>(),
        ),
        BlocProvider(
          create: (context) => locator<LiveDataBloc>(),
        ),
        BlocProvider(
          create: (context) => locator<DtcBloc>(),
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
            NavigationDestination(
                icon: Icon(Icons.backup_table), label: 'Freeze Frame'),
            NavigationDestination(icon: Icon(Icons.build), label: 'Service'),
            NavigationDestination(icon: Icon(Icons.people), label: 'CRM'),
            NavigationDestination(icon: Icon(Icons.hub), label: 'Remote'),
            NavigationDestination(
                icon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
            NavigationDestination(icon: Icon(Icons.edit_note), label: 'Coding'),
            NavigationDestination(icon: Icon(Icons.terminal), label: 'Sniff'),
            NavigationDestination(icon: Icon(Icons.settings), label: 'Set'),
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
