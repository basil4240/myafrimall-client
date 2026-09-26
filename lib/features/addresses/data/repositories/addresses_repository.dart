import 'package:dio/dio.dart';
import '../../../../core/network/network.dart';
import '../models/address_model.dart';

class AddressesRepository {
  final Dio _dio = DioClient.instance.dio;

  Future<List<Address>> getAddresses() async {
    try {
      final response = await _dio.get('/addresses');
      return (response.data['data'] as List)
          .map((e) => Address.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  Future<Address> createAddress(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/addresses', data: data);
      return Address.fromJson(
          response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  Future<Address> updateAddress(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.patch('/addresses/$id', data: data);
      return Address.fromJson(
          response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  Future<void> deleteAddress(String id) async {
    try {
      await _dio.delete('/addresses/$id');
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  Future<void> setDefault(String id) async {
    try {
      await _dio.patch('/addresses/$id/default');
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  Exception _wrap(DioException e) => e.error is AppException
      ? e.error as AppException
      : AppException.fromDioException(e);
}
