import 'package:equatable/equatable.dart';

class ShopProfile extends Equatable {
  final int? id;
  final String name;
  final String? address;
  final String? phone;
  final String? email;
  final String? taxId;
  final String? logoPath;

  const ShopProfile({
    this.id,
    required this.name,
    this.address,
    this.phone,
    this.email,
    this.taxId,
    this.logoPath,
  });

  @override
  List<Object?> get props => [id, name, address, phone, email, taxId, logoPath];
}
