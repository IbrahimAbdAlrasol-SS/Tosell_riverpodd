import 'package:Tosell/Features/orders/models/OrderFilter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:Tosell/core/constants/spaces.dart';
import 'package:Tosell/core/widgets/CustomAppBar.dart';
import 'package:Tosell/Features/shipments/screens/orders_screen.dart' as shipments;
import 'package:Tosell/Features/shipments/screens/shipments_screen.dart';

class OrdersAndShipmentsScreen extends ConsumerStatefulWidget {
  final OrderFilter? filter;
  const OrdersAndShipmentsScreen({super.key, this.filter});

  @override
  ConsumerState<OrdersAndShipmentsScreen> createState() => _OrdersAndShipmentsScreenState();
}

class _OrdersAndShipmentsScreenState extends ConsumerState<OrdersAndShipmentsScreen>
    with SingleTickerProviderStateMixin {
  
  late TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppBar
            const CustomAppBar(
              title: "إدارة الطلبات والشحنات",
              showBackButton: true,
            ),
            
            // Custom TabBar
            _buildCustomTabBar(),
            
            const Gap(10), // 10px spacing as requested
            
            // TabBarView
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  shipments.OrdersScreen(filter: widget.filter),
                  ShipmentsScreen(filter: widget.filter),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpaces.medium),
      child: Column(
        children: [
          Row(
            children: [
              _buildTabItem("الطلبات", 0),
              _buildTabItem("الشحنات", 1),
            ],
          ),
          const Gap(5),
          // Tab indicator line
          Row(
            children: [
              _buildTabIndicator(0),
              _buildTabIndicator(1),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, int index) {
    final isActive = _currentTabIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _tabController.animateTo(index);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isActive 
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabIndicator(int index) {
    final isActive = _currentTabIndex == index;
    
    return Expanded(
      child: Container(
        height: 3,
        decoration: BoxDecoration(
          color: isActive 
            ? Theme.of(context).colorScheme.primary
            : Colors.transparent,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}