import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:motus_lab/features/remote/domain/entities/remote_entities.dart';
import 'package:motus_lab/features/remote/domain/repositories/remote_repository.dart';

// Events
abstract class RemoteEvent extends Equatable {
  const RemoteEvent();
  @override
  List<Object> get props => [];
}

class ConnectToRemote extends RemoteEvent {}

class SendMessage extends RemoteEvent {
  final String text;
  const SendMessage(this.text);
}

class DisconnectRemote extends RemoteEvent {}

class _MessageReceived extends RemoteEvent {
  final ChatMessage message;
  const _MessageReceived(this.message);
}

// States
enum RemoteStatus { initial, connecting, connected, disconnected }

class RemoteState extends Equatable {
  final RemoteStatus status;
  final RemoteSession? session;
  final List<ChatMessage> messages;

  const RemoteState({
    this.status = RemoteStatus.initial,
    this.session,
    this.messages = const [],
  });

  RemoteState copyWith({
    RemoteStatus? status,
    RemoteSession? session,
    List<ChatMessage>? messages,
  }) {
    return RemoteState(
      status: status ?? this.status,
      session: session ?? this.session,
      messages: messages ?? this.messages,
    );
  }

  @override
  List<Object?> get props => [status, session, messages];
}

// Bloc
class RemoteBloc extends Bloc<RemoteEvent, RemoteState> {
  final RemoteRepository repository;
  StreamSubscription? _msgSubscription;

  RemoteBloc(this.repository) : super(const RemoteState()) {
    on<ConnectToRemote>(_onConnect);
    on<SendMessage>(_onSendMessage);
    on<DisconnectRemote>(_onDisconnect);
    on<_MessageReceived>(_onMessageReceived);
  }

  Future<void> _onConnect(
      ConnectToRemote event, Emitter<RemoteState> emit) async {
    emit(state.copyWith(status: RemoteStatus.connecting));
    try {
      // [WORKFLOW] Remote: เรียก Repository เพื่อจำลองการเชื่อมต่อ (Socket/WebRTC)
      final session = await repository.connectToSession();

      // [WORKFLOW] Remote: Subscribe Stream เพื่อรอรับข้อความจากช่าง (Real-time)
      _msgSubscription?.cancel();
      _msgSubscription = repository.messageStream.listen((msg) {
        add(_MessageReceived(msg));
      });

      emit(state.copyWith(
        status: RemoteStatus.connected,
        session: session,
        messages: [],
      ));
    } catch (e) {
      emit(state.copyWith(status: RemoteStatus.disconnected));
    }
  }

  Future<void> _onSendMessage(
      SendMessage event, Emitter<RemoteState> emit) async {
    final myMsg = ChatMessage(
      id: DateTime.now().toString(),
      senderId: 'me',
      content: event.text,
      timestamp: DateTime.now(),
      isMe: true,
    );

    // Optimistic Update
    emit(state.copyWith(messages: List.from(state.messages)..add(myMsg)));

    repository.sendMessage(event.text);
  }

  void _onMessageReceived(_MessageReceived event, Emitter<RemoteState> emit) {
    emit(state.copyWith(
        messages: List.from(state.messages)..add(event.message)));
  }

  Future<void> _onDisconnect(
      DisconnectRemote event, Emitter<RemoteState> emit) async {
    await repository.disconnect();
    _msgSubscription?.cancel();
    emit(state.copyWith(status: RemoteStatus.disconnected));
  }

  @override
  Future<void> close() {
    _msgSubscription?.cancel();
    return super.close();
  }
}
