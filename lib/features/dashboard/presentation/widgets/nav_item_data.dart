import 'package:flutter/material.dart';
import '../../../../../router/route_names.dart';

class NavItemData {
  final String label;
  final IconData icon;
  final String route;

  const NavItemData({
    required this.label,
    required this.icon,
    required this.route,
  });
}

const List<NavItemData> kNavItems = [
  NavItemData(
    label: 'Dashboard',
    icon: Icons.grid_view_outlined,
    route: RouteNames.dashboard,
  ),
  NavItemData(
    label: 'Shipments',
    icon: Icons.local_shipping_outlined,
    route: RouteNames.shipments,
  ),
  NavItemData(
    label: 'Our Services',
    icon: Icons.language_outlined,
    route: RouteNames.services,
  ),
  NavItemData(
    label: 'Notifications',
    icon: Icons.notifications_outlined,
    route: RouteNames.notifications,
  ),
  NavItemData(
    label: 'Wallet',
    icon: Icons.account_balance_wallet_outlined,
    route: RouteNames.wallet,
  ),
  NavItemData(
    label: 'My Addresses',
    icon: Icons.location_on_outlined,
    route: RouteNames.addresses,
  ),
  NavItemData(
    label: 'Invite & Earn',
    icon: Icons.card_giftcard_outlined,
    route: RouteNames.invite,
  ),
  NavItemData(
    label: 'Help Center',
    icon: Icons.help_outline_rounded,
    route: RouteNames.help,
  ),
];