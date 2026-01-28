import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motus_lab/core/connection/bluetooth_service.dart';
import 'package:motus_lab/core/connection/connection_interface.dart';
import 'package:motus_lab/core/services/service_locator.dart';
import 'package:motus_lab/core/theme/app_colors.dart';
import 'package:motus_lab/core/protocol/protocol_engine.dart';
import 'package:motus_lab/core/widgets/adaptive_scaffold.dart';
import 'package:motus_lab/features/scan/presentation/bloc/scan_bloc.dart';
import 'package:motus_lab/features/scan/presentation/bloc/live_data/live_data_bloc.dart';
import 'package:motus_lab/features/scan/presentation/bloc/dtc/dtc_bloc.dart';
import 'package:motus_lab/features/scan/presentation/pages/connection_page.dart';
import 'package:motus_lab/features/scan/presentation/pages/live_data/live_data_page.dart';
import 'package:motus_lab/features/scan/presentation/pages/topology/topology_page.dart';
import 'package:motus_lab/features/scan/presentation/pages/graph_analysis_page.dart';
import 'package:motus_lab/features/reports/presentation/pages/settings_page.dart';
import 'package:motus_lab/features/coding/presentation/pages/adaptation_page.dart';
import 'package:motus_lab/features/sniffer/presentation/pages/sniffer_page.dart';
import 'package:motus_lab/features/service/presentation/pages/service_catalog_page.dart';
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

  final List<Widget> _pages = [
    const ConnectionPage(), // Tab 0: Connect
    const LiveDataPage(), // Tab 1: Dashboard
    const TopologyPage(), // Tab 2: Topology
    const GraphAnalysisPage(), // Tab 3: Graphs
    const ServiceCatalogPage(), // Tab 4: Service
    const CustomerListPage(), // Tab 5: CRM
    const RemoteExpertPage(), // Tab 6: Remote (Phase 5)
    const WalletPage(), // Tab 7: Wallet (Phase 5)
    const AdaptationPage(), // Tab 8: Coding
    const SnifferPage(), // Tab 9: Sniffer
    const SettingsPage(), // Tab 10: Settings
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ScanBloc(
            bluetoothService: locator<BluetoothService>(),
            connection: locator<ConnectionInterface>(),
          ),
        ),
        BlocProvider(
          create: (context) => LiveDataBloc(
            engine: locator<ProtocolEngine>(),
            connection: locator<ConnectionInterface>(),
          ),
        ),
        BlocProvider(
          create: (context) => DtcBloc(
            engine: locator<ProtocolEngine>(),
            connection: locator<ConnectionInterface>(),
          ),
        ),
      ],
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
          NavigationDestination(icon: Icon(Icons.show_chart), label: 'Graph'),
          NavigationDestination(icon: Icon(Icons.build), label: 'Service'),
          NavigationDestination(icon: Icon(Icons.people), label: 'CRM'),
          NavigationDestination(icon: Icon(Icons.hub), label: 'Remote'),
          NavigationDestination(
              icon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
          NavigationDestination(icon: Icon(Icons.edit_note), label: 'Coding'),
          NavigationDestination(icon: Icon(Icons.terminal), label: 'Sniff'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Set'),
        ],
        body: _pages[_currentIndex],
      ),
    );
  }
}
