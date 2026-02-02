import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:motus_lab/core/theme/app_colors.dart';
import 'package:motus_lab/features/scan/domain/entities/log_session.dart';
import 'package:motus_lab/features/scan/data/repositories/log_repository_impl.dart';
import 'package:motus_lab/features/scan/presentation/bloc/log_playback/log_playback_bloc.dart';
import 'package:motus_lab/shared/widgets/motus_card.dart';

class LogPlaybackPage extends StatelessWidget {
  final LogSession session;

  const LogPlaybackPage({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LogPlaybackBloc(repository: LogRepositoryImpl())
        ..add(LoadLogSession(session)),
      child: const LogPlaybackView(),
    );
  }
}

class LogPlaybackView extends StatelessWidget {
  const LogPlaybackView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("LOG PLAYBACK"),
        actions: [
          BlocBuilder<LogPlaybackBloc, LogPlaybackState>(
            builder: (context, state) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text(
                    state.currentTimestamp != null
                        ? DateFormat('HH:mm:ss.S')
                            .format(state.currentTimestamp!)
                        : "--:--:--",
                    style: const TextStyle(fontFamily: 'Courier', fontSize: 12),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<LogPlaybackBloc, LogPlaybackState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.allRecords.isEmpty) {
            return const Center(
                child: Text("No records found in this session"));
          }

          return Column(
            children: [
              // 1. Playback Controls & Timeline
              _buildTimeline(context, state),

              // 2. Data Visualization Grid
              Expanded(
                child: _buildDataGrid(state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTimeline(BuildContext context, LogPlaybackState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.black12,
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(state.isPlaying ? Icons.pause : Icons.play_arrow),
                color: AppColors.primary,
                iconSize: 32,
                onPressed: () {
                  if (state.isPlaying) {
                    context.read<LogPlaybackBloc>().add(PausePlayback());
                  } else {
                    context.read<LogPlaybackBloc>().add(PlayPlayback());
                  }
                },
              ),
              Expanded(
                child: Slider(
                  value: state.playbackPosition,
                  onChanged: (value) {
                    context.read<LogPlaybackBloc>().add(SeekPlayback(value));
                  },
                  activeColor: AppColors.primary,
                ),
              ),
              Text(
                "${(state.playbackPosition * 100).toInt()}%",
                style: const TextStyle(fontSize: 12, color: Colors.white60),
              ),
            ],
          ),
          Text(
            "Session #${state.session?.id} - ${state.session?.vin}",
            style: const TextStyle(fontSize: 10, color: Colors.white38),
          ),
        ],
      ),
    );
  }

  Widget _buildDataGrid(LogPlaybackState state) {
    final entries = state.currentValues.entries.toList();

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return MotusCard(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                entry.key,
                style: TextStyle(
                    fontSize: 12, color: Colors.white.withOpacity(0.34)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                entry.value.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
