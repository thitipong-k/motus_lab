import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motus_lab/core/services/service_locator.dart';
import 'package:motus_lab/core/theme/app_colors.dart';
import 'package:motus_lab/features/remote/presentation/bloc/remote_bloc.dart';
import 'package:motus_lab/features/remote/presentation/widgets/chat_widget.dart';
import 'package:motus_lab/core/widgets/motus_button.dart';

class RemoteExpertPage extends StatelessWidget {
  const RemoteExpertPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => locator<RemoteBloc>(),
      child: const _RemoteExpertView(),
    );
  }
}

class _RemoteExpertView extends StatefulWidget {
  const _RemoteExpertView();

  @override
  State<_RemoteExpertView> createState() => _RemoteExpertViewState();
}

class _RemoteExpertViewState extends State<_RemoteExpertView> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100, // +100 to be sure
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Uses dashboard background
      body: BlocConsumer<RemoteBloc, RemoteState>(
        listener: (context, state) {
          if (state.messages.isNotEmpty) {
            // Scroll to bottom on new message
            Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
          }
        },
        builder: (context, state) {
          // [WORKFLOW] Remote: ตรวจสอบสถานะการเชื่อมต่อ
          // ถ้ายังไม่เชื่อมต่อ (Initial/Disconnected) ให้แสดงหน้า Connect
          if (state.status == RemoteStatus.initial ||
              state.status == RemoteStatus.disconnected) {
            return _buildConnectView(context);
          }

          // ถ้ากำลังเชื่อมต่อ ให้แสดง Loading
          if (state.status == RemoteStatus.connecting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text("Conneting to Expert...",
                      style: TextStyle(color: Colors.white)),
                ],
              ),
            );
          }

          // ถ้าเชื่อมต่อสำเร็จ ให้แสดงหน้าจอ Chat/Video
          return _buildActiveSessionView(context, state);
        },
      ),
    );
  }

  Widget _buildConnectView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.support_agent, size: 80, color: AppColors.primary),
          const SizedBox(height: 24),
          const Text(
            "Remote Expert Support",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Connect with a certified mechanic for real-time assistance.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          MotusButton(
            label: "Connect to Expert",
            icon: Icons.video_call,
            onPressed: () {
              context.read<RemoteBloc>().add(ConnectToRemote());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSessionView(BuildContext context, RemoteState state) {
    return Column(
      children: [
        // Video Area (Placeholder)
        Container(
          height: 200,
          width: double.infinity,
          color: Colors.black,
          child: Stack(
            children: [
              const Center(
                child: Icon(Icons.person, size: 64, color: Colors.grey),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    state.session?.expertName ?? "Expert",
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.call_end, color: Colors.red),
                  onPressed: () {
                    context.read<RemoteBloc>().add(DisconnectRemote());
                  },
                ),
              ),
            ],
          ),
        ),

        // Chat Area
        Expanded(
          child: ChatWidget(
            messages: state.messages,
            scrollController: _scrollController,
          ),
        ),

        // Input Area
        _buildInputArea(context),
      ],
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.black26,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.camera_alt, color: AppColors.primary),
            onPressed: () {
              // TODO: Send Image
            },
          ),
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: "Type a message...",
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
              ),
              style: const TextStyle(color: Colors.white),
              onSubmitted: (_) => _sendMessage(context),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: AppColors.primary),
            onPressed: () => _sendMessage(context),
          ),
        ],
      ),
    );
  }

  void _sendMessage(BuildContext context) {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      context.read<RemoteBloc>().add(SendMessage(text));
      _textController.clear();
      // Scroll handling is in listener
    }
  }
}
