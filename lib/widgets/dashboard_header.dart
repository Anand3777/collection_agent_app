import 'package:flutter/material.dart';

class DashboardTopHeader extends StatelessWidget {
  const DashboardTopHeader({
    super.key,
    required this.title,
    required this.tabs,
    required this.activeIndex,
    required this.onTabSelected,
    required this.background,
    required this.border,
    required this.titleColor,
    required this.tabColor,
    required this.activeTabColor,
  });

  final String title;
  final List<String> tabs;
  final int activeIndex;
  final ValueChanged<int> onTabSelected;
  final Color background;
  final Color border;
  final Color titleColor;
  final Color tabColor;
  final Color activeTabColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [Color(0xFFE8FBF5), Color(0xFFEAF4FF)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              border: Border.all(color: const Color(0xFFD9E7F5)),
            ),
            child: Text(
              title,
              style: TextStyle(
                color: titleColor,
                fontWeight: FontWeight.w900,
                fontSize: 22,
                letterSpacing: 0.3,
                height: 1.0,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (int i = 0; i < tabs.length; i++)
                    Padding(
                      padding: EdgeInsets.only(right: i == tabs.length - 1 ? 0 : 14),
                      child: _HeaderTab(
                        label: tabs[i],
                        active: i == activeIndex,
                        activeColor: activeTabColor,
                        inactiveColor: tabColor,
                        border: border,
                        onTap: () => onTabSelected(i),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          _HeaderIconButton(
            tooltip: 'Notifications',
            icon: Icons.notifications_none_rounded,
            border: border,
          ),
          const SizedBox(width: 8),
          _HeaderIconButton(
            tooltip: 'Help',
            icon: Icons.help_outline_rounded,
            border: border,
          ),
          const SizedBox(width: 8),
          _Avatar(border: border),
        ],
      ),
    );
  }
}

class DashboardLeftMenuRail extends StatelessWidget {
  const DashboardLeftMenuRail({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelect,
    required this.background,
    required this.border,
    required this.selectedColor,
    required this.labelColor,
  });

  final List<DashboardMenuItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final Color background;
  final Color border;
  final Color selectedColor;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      child: Column(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE9F8F2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.apps_rounded, color: Color(0xFF0EA37A)),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = items[index];
                final selected = index == selectedIndex;
                return _MenuTile(
                  label: item.label,
                  icon: item.icon,
                  selected: selected,
                  selectedColor: selectedColor,
                  labelColor: labelColor,
                  onTap: () => onSelect(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardMenuItem {
  const DashboardMenuItem({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

class _HeaderTab extends StatelessWidget {
  const _HeaderTab({
    required this.label,
    required this.active,
    required this.activeColor,
    required this.inactiveColor,
    required this.border,
    required this.onTap,
  });

  final String label;
  final bool active;
  final Color activeColor;
  final Color inactiveColor;
  final Color border;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFF3F4F6) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: active ? border : Colors.transparent),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? activeColor : inactiveColor,
            fontWeight: active ? FontWeight.w700 : FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.tooltip,
    required this.icon,
    required this.border,
  });

  final String tooltip;
  final IconData icon;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF374151)),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.border});

  final Color border;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
        gradient: const LinearGradient(
          colors: [Color(0xFF0EA37A), Color(0xFF1FB7FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Text(
          'A',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.selectedColor,
    required this.labelColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final Color selectedColor;
  final Color labelColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? const Color(0xFFE9F8F2) : Colors.transparent;
    final fg = selected ? selectedColor : const Color(0xFF4B5563);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: fg, size: 20),
            const SizedBox(height: 6),
            Text(
              label.toUpperCase(),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9,
                height: 1.15,
                color: selected ? fg : labelColor,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

