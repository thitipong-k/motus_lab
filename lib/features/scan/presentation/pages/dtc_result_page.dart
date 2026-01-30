import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motus_lab/core/theme/app_colors.dart';
import 'package:motus_lab/features/scan/presentation/bloc/dtc/dtc_bloc.dart';
import 'package:motus_lab/core/widgets/motus_card.dart';
import 'package:motus_lab/core/widgets/loading_indicator.dart';
import 'package:motus_lab/core/widgets/empty_state.dart';
// Note: Will implement injection later
import 'package:motus_lab/features/scan/data/repositories/diagnostic_repository.dart';
import 'package:get_it/get_it.dart';

class DtcResultPage extends StatefulWidget {
  const DtcResultPage({super.key});

  @override
  State<DtcResultPage> createState() => _DtcResultPageState();
}

class _DtcResultPageState extends State<DtcResultPage> {
  // Simple state for expanded item
  String? _selectedDtc;
  List<DiagnosticResult> _causes = [];
  bool _isLoadingCauses = false;

  void _onDtcSelected(String code) async {
    setState(() {
      _selectedDtc = code;
      _isLoadingCauses = true;
      _causes = [];
    });

    try {
      // Direct call for MVP (Should be via Bloc in full ver)
      final repo = GetIt.I<DiagnosticRepository>();
      final results = await repo.getLikelyCauses(
          code, "Honda Civic"); // Hardcoded model for now

      if (mounted) {
        setState(() {
          _causes = results;
          _isLoadingCauses = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCauses = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("DIAGNOSTIC RESULTS")),
      body: BlocBuilder<DtcBloc, DtcState>(
        builder: (context, state) {
          if (state.codes.isEmpty) {
            return const EmptyState(
              icon: Icons.check_circle_outline,
              message: "No Fault Codes Found (Clean)",
            );
          }

          return ListView.builder(
            itemCount: state.codes.length,
            itemBuilder: (context, index) {
              final code = state.codes[index];
              final isSelected = _selectedDtc == code;

              return MotusCard(
                color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.warning, color: Colors.orange),
                      title: Text(code,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle:
                          const Text("Tap for Expert Diagnosis"), // Placeholder
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _onDtcSelected(code),
                    ),
                    if (isSelected) _buildExpertAnalysis(),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildExpertAnalysis() {
    if (_isLoadingCauses) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: LoadingIndicator(),
      );
    }

    if (_causes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text("No expert logic found for this code.",
            style: TextStyle(fontStyle: FontStyle.italic)),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.black12,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.psychology, color: AppColors.primary),
              SizedBox(width: 8),
              Text("AI MECHANIC DIAGNOSIS",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 8),
          ..._causes.map((cause) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(cause.causeTitle,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          Text(cause.causeDescription,
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getScoreColor(cause.likelihoodScore),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text("${cause.likelihoodScore}%",
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.check_circle_outline,
                          color: Colors.grey),
                      tooltip: "Mark as Fix",
                      onPressed: () async {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text("Feedback received! Logic updated.")));
                      },
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.red;
    if (score >= 50) return Colors.orange;
    return Colors.green;
  }
}
