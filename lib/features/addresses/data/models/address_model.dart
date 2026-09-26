class Address {
  final String id;
  final String label;
  final String fullAddress;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final bool isDefault;
  final DateTime createdAt;

  const Address({
    required this.id,
    required this.label,
    required this.fullAddress,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    required this.isDefault,
    required this.createdAt,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        id: json['id'] as String,
        label: json['label'] as String,
        fullAddress: json['fullAddress'] as String,
        city: json['city'] as String,
        state: json['state'] as String,
        country: json['country'] as String,
        postalCode: json['postalCode'] as String? ?? '',
        isDefault: json['isDefault'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'label': label,
        'fullAddress': fullAddress,
        'city': city,
        'state': state,
        'country': country,
        'postalCode': postalCode,
        'isDefault': isDefault,
      };

  Address copyWith({
    String? id,
    String? label,
    String? fullAddress,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return Address(
      id: id ?? this.id,
      label: label ?? this.label,
      fullAddress: fullAddress ?? this.fullAddress,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

final kSampleAddresses = [
  Address(
    id: '1',
    label: 'Home',
    fullAddress: '14 Allen Avenue, Ikeja',
    city: 'Lagos',
    state: 'Lagos',
    country: 'Nigeria',
    postalCode: '100001',
    isDefault: true,
    createdAt: DateTime(2025, 1, 1),
  ),
  Address(
    id: '2',
    label: 'Office',
    fullAddress: '23 Wuse Zone 4, Central Business District',
    city: 'Abuja',
    state: 'FCT',
    country: 'Nigeria',
    postalCode: '900001',
    isDefault: false,
    createdAt: DateTime(2025, 1, 10),
  ),
];
