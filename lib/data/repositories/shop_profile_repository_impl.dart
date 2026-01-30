import 'package:drift/drift.dart';
import 'package:motus_lab/core/database/app_database.dart';
import 'package:motus_lab/domain/entities/shop_profile.dart' as entity;
import 'package:motus_lab/domain/repositories/shop_profile_repository.dart';

class ShopProfileRepositoryImpl implements ShopProfileRepository {
  final AppDatabase _db;

  ShopProfileRepositoryImpl(this._db);

  @override
  Future<entity.ShopProfile> getShopProfile() async {
    // Get all records and take the last one to be safe (should only be 1)
    final profiles = await _db.select(_db.shopProfiles).get();

    if (profiles.isEmpty) {
      // Return default if empty
      return const entity.ShopProfile(name: 'My Workshop');
    }

    final profile = profiles.last;

    return entity.ShopProfile(
      id: profile.id,
      name: profile.name,
      address: profile.address,
      phone: profile.phone,
      email: profile.email,
      taxId: profile.taxId,
      logoPath: profile.logoPath,
    );
  }

  @override
  Future<void> updateShopProfile(entity.ShopProfile profile) async {
    final companion = ShopProfilesCompanion(
      name: Value(profile.name),
      address: Value(profile.address),
      phone: Value(profile.phone),
      email: Value(profile.email),
      taxId: Value(profile.taxId),
      logoPath: Value(profile.logoPath),
    );

    // Try to update by ID first
    if (profile.id != null) {
      await (_db.update(_db.shopProfiles)
            ..where((t) => t.id.equals(profile.id!)))
          .write(companion);
    } else {
      // If ID is null, check if any record exists to prevent duplicates
      final existing = await _db.select(_db.shopProfiles).get();
      if (existing.isNotEmpty) {
        // Update the first found record
        await (_db.update(_db.shopProfiles)
              ..where((t) => t.id.equals(existing.first.id)))
            .write(companion);
      } else {
        // Insert new
        await _db.into(_db.shopProfiles).insert(companion);
      }
    }
  }
}
