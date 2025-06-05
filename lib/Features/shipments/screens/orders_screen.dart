import 'package:Tosell/Features/orders/models/Order.dart';
import 'package:Tosell/Features/orders/models/OrderFilter.dart';
import 'package:Tosell/Features/orders/providers/orders_provider.dart';
import 'package:Tosell/Features/orders/screens/orders_filter_bottom_sheet.dart';

import 'package:Tosell/Features/shipments/providers/orders_selection_provider.dart';
import 'package:Tosell/Features/shipments/widgets/order_card_item.dart';
import 'package:gap/gap.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:Tosell/core/constants/spaces.dart';
import 'package:Tosell/core/utils/extensions.dart';
import 'package:Tosell/core/router/app_router.dart';
import 'package:Tosell/core/widgets/FillButton.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Tosell/paging/generic_paged_list_view.dart';
import 'package:Tosell/core/widgets/CustomTextFormField.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  final OrderFilter? filter;
  const OrdersScreen({super.key, this.filter});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  late OrderFilter? _currentFilter;
  List<Order> _currentOrders = [];

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.filter;
    _fetchInitialOrders();
  }

  void _fetchInitialOrders() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ordersNotifierProvider.notifier).getAll(
            page: 1,
            queryParams: _currentFilter?.toJson(),
          );
    });
  }

  @override
  void didUpdateWidget(covariant OrdersScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filter != oldWidget.filter) {
      _currentFilter = widget.filter ?? OrderFilter();
      _fetchInitialOrders();
    }
  }

  void _toggleSelectionMode() {
    final isSelectionMode = ref.read(selectionModeProvider);
    ref.read(selectionModeProvider.notifier).state = !isSelectionMode;
    
    // Clear selection when exiting selection mode
    if (isSelectionMode) {
      ref.read(selectedOrdersProvider.notifier).clearSelection();
    }
  }

  void _selectAll() {
    ref.read(selectedOrdersProvider.notifier).selectAll(_currentOrders);
  }

  void _clearSelection() {
    ref.read(selectedOrdersProvider.notifier).clearSelection();
  }

  void _createShipment() {
    final selectedOrderIds = ref.read(selectedOrdersProvider);
    ref.read(createShipmentProvider.notifier).createShipment(selectedOrderIds);
    
    // Exit selection mode and clear selection after creating shipment
    Future.delayed(const Duration(milliseconds: 500), () {
      ref.read(selectionModeProvider.notifier).state = false;
      ref.read(selectedOrdersProvider.notifier).clearSelection();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ordersState = ref.watch(ordersNotifierProvider);
    final isSelectionMode = ref.watch(selectionModeProvider);
    final selectedOrders = ref.watch(selectedOrdersProvider);
    final createShipmentState = ref.watch(createShipmentProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: AppSpaces.large),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search and filter row
              Row(
                children: [
                  const Gap(10),
                  Expanded(
                    child: CustomTextFormField(
                      label: '',
                      showLabel: false,
                      hint: 'رقم الطلب',
                      prefixInner: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SvgPicture.asset(
                          'assets/svg/search.svg',
                          color: Theme.of(context).colorScheme.primary,
                          width: 3,
                          height: 3,
                        ),
                      ),
                    ),
                  ),
                  const Gap(AppSpaces.medium),
                  
                  // Filter button
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        builder: (_) => const OrdersFilterBottomSheet(),
                      );
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: widget.filter?.status == null
                                    ? Theme.of(context).colorScheme.outline
                                    : Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SvgPicture.asset(
                                'assets/svg/Funnel.svg',
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        if (widget.filter != null)
                          Positioned(
                            top: 6,
                            right: 10,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // Selection mode toggle button
                  GestureDetector(
                    onTap: _toggleSelectionMode,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isSelectionMode 
                            ? Theme.of(context).colorScheme.primary
                            : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            isSelectionMode ? Icons.close : Icons.checklist,
                            color: isSelectionMode 
                              ? Colors.white
                              : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const Gap(5),
              
              // Title and selection info
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.filter == null
                          ? 'جميع الطلبات'
                          : 'جميع الطلبات "${widget.filter?.shipmentCode}"',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    
                    // Selection counter and menu
                    if (isSelectionMode) ...[
                      Row(
                        children: [
                          if (selectedOrders.isNotEmpty)
                            Text(
                              "تم تحديد ${selectedOrders.length} طلب",
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          
                          const Gap(AppSpaces.small),
                          
                          // Selection menu
                          PopupMenuButton<String>(
                            icon: Icon(
                              Icons.more_vert,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            onSelected: (value) {
                              switch (value) {
                                case 'select_all':
                                  _selectAll();
                                  break;
                                case 'clear_all':
                                  _clearSelection();
                                  break;
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'select_all',
                                child: Row(
                                  children: [
                                    Icon(Icons.select_all),
                                    Gap(AppSpaces.small),
                                    Text('تحديد الكل'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'clear_all',
                                child: Row(
                                  children: [
                                    Icon(Icons.clear_all),
                                    Gap(AppSpaces.small),
                                    Text('إلغاء التحديد'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              
              // Orders list
              ordersState.when(
                data: (data) {
                  _currentOrders = data;
                  return _buildUi(data);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text(err.toString())),
              ),
              
              // Create shipment button
              if (isSelectionMode && selectedOrders.isNotEmpty)
                Container(
                  padding: AppSpaces.allMedium,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  child: FillButton(
                    label: "إنشاء شحنة (${selectedOrders.length})",
                    isLoading: createShipmentState.isLoading,
                    onPressed: _createShipment,
                    icon: const Icon(Icons.local_shipping, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Expanded _buildUi(List<Order> data) {
    final isSelectionMode = ref.watch(selectionModeProvider);
    
    return Expanded(
      child: GenericPagedListView(
        key: ValueKey(widget.filter?.toJson()),
        noItemsFoundIndicatorBuilder: _buildNoItemsFound(),
        fetchPage: (pageKey, _) async {
          return await ref.read(ordersNotifierProvider.notifier).getAll(
                page: pageKey,
                queryParams: _currentFilter?.toJson(),
              );
        },
        itemBuilder: (context, order, index) => OrderCardItem(
          order: order,
          isSelectionMode: isSelectionMode,
          onTap: () {
            if (!isSelectionMode) {
              context.push(AppRoutes.orderDetails, extra: order.id);
            }
          },
        ),
      ),
    );
  }

  Widget _buildNoItemsFound() {
    return Column(
      children: [
        Image.asset('assets/svg/NoItemsFound.gif', width: 240, height: 240),
        Text(
          'لا توجد طلبات',
          style: context.textTheme.bodyLarge!.copyWith(
            fontWeight: FontWeight.w700,
            color: context.colorScheme.primary,
            fontSize: 24,
          ),
        ),
      ],
    );
  }
}