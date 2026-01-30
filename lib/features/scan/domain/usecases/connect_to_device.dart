import 'package:motus_lab/core/connection/connection_interface.dart';
import 'package:motus_lab/core/usecase/usecase.dart';

class ConnectToDeviceUseCase implements UseCase<void, String> {
  final ConnectionInterface connection;

  ConnectToDeviceUseCase(this.connection);

  @override
  Future<void> call(String deviceId) async {
    return await connection.connect(deviceId);
  }
}
