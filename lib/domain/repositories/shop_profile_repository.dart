import 'package:motus_lab/domain/entities/shop_profile.dart';

abstract class ShopProfileRepository {
  Future<ShopProfile> getShopProfile();
  Future<void> updateShopProfile(ShopProfile profile);
}
