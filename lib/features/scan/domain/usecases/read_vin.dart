import 'package:motus_lab/core/connection/connection_interface.dart';
import 'package:motus_lab/core/protocol/protocol_engine.dart';
import 'package:motus_lab/core/usecase/usecase.dart';
import 'package:motus_lab/features/scan/data/repositories/protocol_repository.dart';

class ReadVinUseCase implements UseCase<String?, void> {
  final ProtocolEngine engine;
  final ConnectionInterface connection;
  final ProtocolRepository repository;

  ReadVinUseCase(this.engine, this.connection, this.repository);

  @override
  Future<String?> call(void params) async {
    try {
      // 1. Get VIN Command (Mode 09 PID 02)
      final vinCmd = repository.getCommandByCode("0902");
      if (vinCmd == null) {
        print("ReadVinUseCase: VIN Command (0902) not found.");
        return null;
      }

      // 2. Build Request
      final request = engine.buildRequest(vinCmd);

      // 3. Send Request
      final response = await connection.send(request);

      if (response.isEmpty) return null;

      // 4. Parse Response (Mock for now)
      // In real scenario: engine.parseVin(response)
      return "JHMGD38TEST";
    } catch (e) {
      print("ReadVinUseCase Error: $e");
      return null;
    }
  }
}
