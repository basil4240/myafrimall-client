import 'package:dio/dio.dart';
import '../../../../core/models/pagination_meta.dart';
import '../../../../core/network/network.dart';
import '../models/shipment_model.dart';

class ShipmentsRepository {
  final Dio _dio = DioClient.instance.dio;

  Future<({List<Shipment> items, PaginationMeta meta})> getShipments({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/shipments',
        queryParameters: {'page': page, 'limit': limit},
      );
      final items = (response.data['data'] as List)
          .map((e) => Shipment.fromJson(e as Map<String, dynamic>))
          .toList();
      final meta = PaginationMeta.fromJson(
        response.data['pagination'] as Map<String, dynamic>,
      );
      return (items: items, meta: meta);
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  Future<Shipment> createShipment({
    required String senderName,
    required String pickupAddress,
    required String receiverName,
    required String deliveryAddress,
    required double weight,
    required String description,
    required String serviceType,
  }) async {
    try {
      final response = await _dio.post('/shipments', data: {
        'senderName': senderName,
        'pickupAddress': pickupAddress,
        'receiverName': receiverName,
        'deliveryAddress': deliveryAddress,
        'weight': weight,
        'description': description,
        'serviceType': serviceType.toLowerCase(),
      });
      return Shipment.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  Future<Shipment> updateShipment({
    required String id,
    required String senderName,
    required String pickupAddress,
    required String receiverName,
    required String deliveryAddress,
    required double weight,
    required String description,
    required String serviceType,
  }) async {
    try {
      final response = await _dio.patch('/shipments/$id', data: {
        'senderName': senderName,
        'pickupAddress': pickupAddress,
        'receiverName': receiverName,
        'deliveryAddress': deliveryAddress,
        'weight': weight,
        'description': description,
        'serviceType': serviceType.toLowerCase(),
      });
      return Shipment.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  Future<void> deleteShipment(String id) async {
    try {
      await _dio.delete('/shipments/$id');
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  Exception _wrap(DioException e) => e.error is AppException
      ? e.error as AppException
      : AppException.fromDioException(e);
}
