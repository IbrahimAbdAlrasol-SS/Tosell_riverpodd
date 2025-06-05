import 'dart:async';
import 'package:Tosell/core/Client/ApiResponse.dart';
import 'package:Tosell/Features/shipments/models/Shipment.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Tosell/Features/shipments/services/services/shipments_service.dart';

// Shipments Provider using traditional Riverpod
final shipmentsNotifierProvider = 
    AsyncNotifierProvider<ShipmentsNotifier, List<Shipment>>(() {
  return ShipmentsNotifier();
});

class ShipmentsNotifier extends AsyncNotifier<List<Shipment>> {
  final ShipmentsService _service = ShipmentsService();

  Future<ApiResponse<Shipment>> getAll(
      {int page = 1, Map<String, dynamic>? queryParams}) async {
    return (await _service.getAll(queryParams: queryParams, page: page));
  }

  Future<Shipment?>? getShipmentById({required String id}) async {
    try {
      // This would need to be implemented in the service
      // return (await _service.getShipmentById(id: id));
      return null; // Placeholder
    } catch (e) {
      rethrow;
    }
  }

  @override
  FutureOr<List<Shipment>> build() async {
    var result = await getAll();
    return result.data ?? [];
  }

  // Additional methods for refreshing data
  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final result = await getAll();
      state = AsyncData(result.data ?? []);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> loadMore({int page = 1, Map<String, dynamic>? queryParams}) async {
    try {
      final result = await getAll(page: page, queryParams: queryParams);
      final currentData = state.value ?? [];
      final newData = result.data ?? [];
      state = AsyncData([...currentData, ...newData]);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}