import 'package:motus_lab/features/remote/domain/entities/remote_entities.dart';

abstract class RemoteRepository {
  /// Connect to the expert service return session ID
  Future<RemoteSession> connectToSession();

  /// Send a text message
  Future<void> sendMessage(String text);

  /// Disconnect session
  Future<void> disconnect();

  /// Stream of incoming messages
  Stream<ChatMessage> get messageStream;

  /// Stream of session status status (true=active, false=ended)
  Stream<bool> get sessionStatus;
}
