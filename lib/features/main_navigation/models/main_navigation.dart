import 'package:flutter/material.dart';

/// Model for navigation items
class NavItem {
  final IconData icon;
  final String label;

  const NavItem({required this.icon, required this.label});

  NavItem copyWith({IconData? icon, String? label}) {
    return NavItem(icon: icon ?? this.icon, label: label ?? this.label);
  }
}
