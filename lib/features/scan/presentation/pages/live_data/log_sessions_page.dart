import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:motus_lab/core/theme/app_colors.dart';
import 'package:motus_lab/features/scan/domain/entities/log_session.dart';
import 'package:motus_lab/features/scan/domain/repositories/log_repository.dart';
import 'package:motus_lab/features/scan/data/repositories/log_repository_impl.dart';
import 'package:motus_lab/shared/widgets/motus_card.dart';
import 'package:motus_lab/features/scan/presentation/pages/live_data/log_playback_page.dart';

class LogSessionsPage extends StatefulWidget {
  const LogSessionsPage({super.key});

  @override
  State<LogSessionsPage> createState() => _LogSessionsPageState();
}

class _LogSessionsPageState extends State<LogSessionsPage> {
  final LogRepository _repository = LogRepositoryImpl();
  List<LogSession> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() => _isLoading = true);
    final sessions = await _repository.getSessions();
    setState(() {
      _sessions = sessions.reversed.toList(); // Newest first
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("DATA LOGS"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSessions,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sessions.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _sessions.length,
                  itemBuilder: (context, index) {
                    final session = _sessions[index];
                    return _buildSessionCard(session);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text("No log sessions found",
              style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          const Text("Start logging in the Live Data page",
              style: TextStyle(color: Colors.white38, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSessionCard(LogSession session) {
    final dateStr =
        DateFormat('MMM dd, yyyy - HH:mm').format(session.startTime);

    return MotusCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.analytics, color: AppColors.primary),
        ),
        title: Text(
          "Session #${session.id} - ${session.vin}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(dateStr, style: const TextStyle(fontSize: 12)),
            Text("${session.recordCount} records",
                style: TextStyle(
                    color: AppColors.primary.withOpacity(0.7), fontSize: 11)),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LogPlaybackPage(session: session),
            ),
          );
        },
      ),
    );
  }
}
