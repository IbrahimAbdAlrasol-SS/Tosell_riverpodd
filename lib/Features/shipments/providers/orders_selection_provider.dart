import 'package:Tosell/Features/orders/services/orders_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Tosell/Features/shipments/models/Order.dart';
import 'package:Tosell/Features/shipments/services/orders_service.dart';
import 'package:Tosell/core/utils/GlobalToast.dart';
import 'package:flutter/material.dart';

// Provider for managing selected orders
final selectedOrdersProvider = StateNotifierProvider<SelectedOrdersNotifier, List<String>>((ref) {
  return SelectedOrdersNotifier();
});

// Provider for selection mode state
final selectionModeProvider = StateProvider<bool>((ref) => false);

class SelectedOrdersNotifier extends StateNotifier<List<String>> {
  SelectedOrdersNotifier() : super([]);

  void toggleOrder(String orderId) {
    if (state.contains(orderId)) {
      state = state.where((id) => id != orderId).toList();
    } else {
      state = [...state, orderId];
    }
  }

  void selectAll(List<Order> orders) {
    state = orders.map((order) => order.id ?? '').where((id) => id.isNotEmpty).toList();
  }

  void clearSelection() {
    state = [];
  }

  bool isSelected(String orderId) {
    return state.contains(orderId);
  }

  int get selectedCount => state.length;

  List<String> get selectedOrderIds => state;
}

// Provider for creating shipment
final createShipmentProvider = StateNotifierProvider<CreateShipmentNotifier, AsyncValue<void>>((ref) {
  return CreateShipmentNotifier();
});

class CreateShipmentNotifier extends StateNotifier<AsyncValue<void>> {
  CreateShipmentNotifier() : super(const AsyncValue.data(null));

  Future<void> createShipment(List<String> orderIds) async {
    if (orderIds.isEmpty) {
      GlobalToast.show(
        message: "يجب تحديد طلب واحد على الأقل",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    state = const AsyncValue.loading();
    
    try {
      final service = OrdersService();
      
      // Prepare the request data
      final requestData = {
        "orders": orderIds.map((id) => {"orderId": id}).toList()
      };

      // Call the API
      final result = await service.createShipment(requestData);
      
      state = const AsyncValue.data(null);
      
      GlobalToast.showSuccess(
        message: "تم إنشاء الشحنة بنجاح",
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      
      GlobalToast.show(
        message: "حدث خطأ أثناء إنشاء الشحنة: ${e.toString()}",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }
}