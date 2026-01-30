import 'package:motus_lab/core/usecase/usecase.dart';
import 'package:motus_lab/features/scan/data/repositories/vehicle_profile_repository.dart';

class GetSupportedPidsUseCase implements UseCase<List<String>?, String> {
  final VehicleProfileRepository repository;

  GetSupportedPidsUseCase(this.repository);

  @override
  Future<List<String>?> call(String vin) async {
    return await repository.getSupportedPids(vin);
  }
}
