enum ShipmentStatus { pending, inTransit, delayed, paid, cancelled }

extension ShipmentStatusX on ShipmentStatus {
  String get value => switch (this) {
        ShipmentStatus.pending => 'pending',
        ShipmentStatus.inTransit => 'in_transit',
        ShipmentStatus.delayed => 'delayed',
        ShipmentStatus.paid => 'paid',
        ShipmentStatus.cancelled => 'cancelled',
      };

  static ShipmentStatus fromString(String s) => switch (s) {
        'in_transit' => ShipmentStatus.inTransit,
        'delayed' => ShipmentStatus.delayed,
        'paid' => ShipmentStatus.paid,
        'cancelled' => ShipmentStatus.cancelled,
        _ => ShipmentStatus.pending,
      };
}

class Shipment {
  final String id;
  final String trackingId;
  final String senderName;
  final String senderLocation;
  final String receiverName;
  final String receiverLocation;
  final double amount;
  final String currency;
  final ShipmentStatus status;
  final String processingTime;
  final bool isPaid;
  final String serviceType;
  final double weight;
  final String description;
  final DateTime createdAt;

  const Shipment({
    required this.id,
    required this.trackingId,
    required this.senderName,
    required this.senderLocation,
    required this.receiverName,
    required this.receiverLocation,
    required this.amount,
    required this.currency,
    required this.status,
    required this.processingTime,
    required this.isPaid,
    required this.serviceType,
    required this.weight,
    required this.description,
    required this.createdAt,
  });

  factory Shipment.fromJson(Map<String, dynamic> json) {
    final sender = json['sender'] as Map<String, dynamic>? ?? {};
    final receiver = json['receiver'] as Map<String, dynamic>? ?? {};
    return Shipment(
      id: json['id'] as String,
      trackingId: json['trackingId'] as String,
      senderName: sender['name'] as String? ?? '',
      senderLocation: sender['location'] as String? ?? '',
      receiverName: receiver['name'] as String? ?? '',
      receiverLocation: receiver['location'] as String? ?? '',
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'NGN',
      status: ShipmentStatusX.fromString(
        json['status'] as String? ?? 'pending',
      ),
      processingTime: json['processingTime'] as String? ?? '',
      isPaid: json['isPaid'] as bool? ?? false,
      serviceType: json['serviceType'] as String? ?? 'Standard',
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

final kSampleShipmentsList = [
  Shipment(
    id: '1',
    trackingId: 'MAF-100-234-291',
    senderName: 'Bunmi Tanny',
    senderLocation: 'Lagos, Nigeria',
    receiverName: 'Mercy',
    receiverLocation: 'Oyo, Nigeria',
    amount: 3000,
    currency: 'NGN',
    status: ShipmentStatus.inTransit,
    processingTime: '10 hours',
    isPaid: true,
    serviceType: 'Standard',
    weight: 2.5,
    description: 'Electronics',
    createdAt: DateTime(2025, 1, 5),
  ),
  Shipment(
    id: '2',
    trackingId: 'MAF-100-234-292',
    senderName: 'Chidi Okafor',
    senderLocation: 'Abuja, Nigeria',
    receiverName: 'Sandra K.',
    receiverLocation: 'Port Harcourt, Nigeria',
    amount: 5500,
    currency: 'NGN',
    status: ShipmentStatus.delayed,
    processingTime: '24 hours',
    isPaid: false,
    serviceType: 'Express',
    weight: 5.0,
    description: 'Clothing',
    createdAt: DateTime(2025, 1, 8),
  ),
  Shipment(
    id: '3',
    trackingId: 'MAF-100-234-293',
    senderName: 'Adaeze Nwosu',
    senderLocation: 'Enugu, Nigeria',
    receiverName: 'Emeka',
    receiverLocation: 'London, UK',
    amount: 18000,
    currency: 'NGN',
    status: ShipmentStatus.paid,
    processingTime: '5-7 days',
    isPaid: true,
    serviceType: 'Express',
    weight: 1.2,
    description: 'Documents',
    createdAt: DateTime(2025, 1, 10),
  ),
];
