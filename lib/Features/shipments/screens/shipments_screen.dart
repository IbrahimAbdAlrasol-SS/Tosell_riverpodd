import 'package:Tosell/Features/orders/models/OrderFilter.dart';
import 'package:Tosell/Features/shipments/models/Shipment.dart';
import 'package:Tosell/Features/shipments/providers/shipments_provider.dart';
import 'package:Tosell/Features/shipments/widgets/shipment_card_item.dart';
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

class ShipmentsScreen extends ConsumerStatefulWidget {
  final OrderFilter? filter;
  const ShipmentsScreen({super.key, this.filter});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ShipmentsScreenState();
}

class _ShipmentsScreenState extends ConsumerState<ShipmentsScreen> {
  late OrderFilter? _currentFilter;
  List<Shipment> _currentShipments = [];

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.filter;
    _fetchInitialShipments();
  }

  void _fetchInitialShipments() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(shipmentsNotifierProvider.notifier).getAll(
            page: 1,
            queryParams: _currentFilter?.toJson(),
          );
    });
  }

  @override
  void didUpdateWidget(covariant ShipmentsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filter != oldWidget.filter) {
      _currentFilter = widget.filter ?? OrderFilter();
      _fetchInitialShipments();
    }
  }

  @override
  Widget build(BuildContext context) {
    final shipmentsState = ref.watch(shipmentsNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: AppSpaces.large),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar
              Row(
                children: [
                  const Gap(10),
                  Expanded(
                    child: CustomTextFormField(
                      label: '',
                      showLabel: false,
                      hint: 'رقم الشحنة',
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
                ],
              ),
              
              const Gap(5),
              
              // Title
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'جميع الشحنات',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              
              // Shipments list
              shipmentsState.when(
                data: (data) {
                  _currentShipments = data;
                  return _buildUi(data);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text(err.toString())),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Expanded _buildUi(List<Shipment> data) {
    return Expanded(
      child: GenericPagedListView(
        key: ValueKey(widget.filter?.toJson()),
        noItemsFoundIndicatorBuilder: _buildNoItemsFound(),
        fetchPage: (pageKey, _) async {
          return await ref.read(shipmentsNotifierProvider.notifier).getAll(
                page: pageKey,
                queryParams: _currentFilter?.toJson(),
              );
        },
        itemBuilder: (context, shipment, index) => ShipmentCardItem(
          shipment: shipment,
          onTap: () {
            // Navigate to shipment details
            context.push('/shipment-details', extra: shipment.id);
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
          'لا توجد شحنات',
          style: context.textTheme.bodyLarge!.copyWith(
            fontWeight: FontWeight.w700,
            color: context.colorScheme.primary,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'سيتم عرض الشحنات التي تم إنشاؤها هنا',
          style: context.textTheme.bodySmall!.copyWith(
            fontWeight: FontWeight.w500,
            color: const Color(0xff698596),
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}