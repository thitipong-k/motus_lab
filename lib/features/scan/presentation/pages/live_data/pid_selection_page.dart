import 'package:flutter/material.dart';
import 'package:motus_lab/core/theme/app_colors.dart';
import 'package:motus_lab/domain/entities/command.dart';
import 'package:motus_lab/core/protocol/standard_pids.dart';

class PidSelectionPage extends StatefulWidget {
  final List<Command> currentSelection;

  const PidSelectionPage({super.key, required this.currentSelection});

  @override
  State<PidSelectionPage> createState() => _PidSelectionPageState();
}

class _PidSelectionPageState extends State<PidSelectionPage> {
  // ใช้ Set เพื่อความง่ายในการเช็คว่าเลือกแล้วหรือยัง
  late Set<Command> _selectedCommands;

  @override
  void initState() {
    super.initState();
    _selectedCommands = widget.currentSelection.toSet();
  }

  void _toggleSelection(Command command) {
    setState(() {
      if (_selectedCommands.contains(command)) {
        _selectedCommands.remove(command);
      } else {
        _selectedCommands.add(command);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // กรองเอาเฉพาะ PIDs ที่ไม่ใช่ Command พิเศษดึง Supported PIDs
    final allPids = StandardPids.all
        .where((cmd) => !cmd.name.startsWith("Supported"))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select PIDs"),
        actions: [
          TextButton(
            onPressed: () {
              // ส่งค่ากลับไปหน้าเดิม
              Navigator.pop(context, _selectedCommands.toList());
            },
            child: const Text("SAVE",
                style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: ListView.builder(
        itemCount: allPids.length,
        itemBuilder: (context, index) {
          final command = allPids[index];
          final isSelected = _selectedCommands.contains(command);

          return CheckboxListTile(
            activeColor: AppColors.primary,
            title: Text(command.name,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text("${command.code} - ${command.description}"),
            secondary:
                Text(command.unit, style: const TextStyle(color: Colors.grey)),
            value: isSelected,
            onChanged: (bool? value) {
              _toggleSelection(command);
            },
          );
        },
      ),
    );
  }
}
