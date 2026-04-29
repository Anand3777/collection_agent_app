import 'package:flutter/material.dart';
import 'screens/users_list_screen.dart';
import 'widgets/dashboard_header.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  int? _activeTopTabIndex = 0;
  String _contentTitle = 'Dashboard';
  final GlobalKey<NavigatorState> _contentNavigatorKey = GlobalKey<NavigatorState>();

  static const _menuItems = <DashboardMenuItem>[
    DashboardMenuItem(label: 'Dashboard', icon: Icons.dashboard_rounded),
    DashboardMenuItem(label: 'AI Voice', icon: Icons.record_voice_over_rounded),
  ];

  static const _topTabs = <String>[
    // 'Billing',
    // 'Inventory',
    // 'Purchase',
    // 'Customers',
    // 'Reports',
    // 'Settings',
  ];

  static const _dashboardCards = <_DashboardCardItem>[
    _DashboardCardItem(title: 'Total Contacts', count: 0, actionLabel: 'Manage Contacts', icon: Icons.person, accent: Color(0xFF17A2B8)),
    _DashboardCardItem(title: 'Total Groups', count: 0, actionLabel: 'Manage Groups', icon: Icons.group, accent: Color(0xFF1ABC9C)),
    _DashboardCardItem(title: 'Total Campaigns', count: 0, actionLabel: 'Manage Campaigns', icon: Icons.campaign, accent: Color(0xFFE91E63)),
    _DashboardCardItem(title: 'Total Templates', count: 0, actionLabel: 'Manage Templates', icon: Icons.layers, accent: Color(0xFF16C79A)),
    _DashboardCardItem(title: 'Total Bot Replies', count: 0, actionLabel: 'Manage Bot Replies', icon: Icons.smart_toy, accent: Color(0xFF16C79A)),
    _DashboardCardItem(title: 'Active Team Members', count: 0, actionLabel: 'Manage Team Members', icon: Icons.support_agent, accent: Color(0xFFFF7043)),
    _DashboardCardItem(title: 'Messages in Queue', count: 0, actionLabel: 'Manage Queue', icon: Icons.segment, accent: Color(0xFF13B5A6)),
    _DashboardCardItem(title: 'Messages Processed', count: 0, actionLabel: 'View Processed', icon: Icons.checklist, accent: Color(0xFF13B5A6)),
  ];

  @override
  Widget build(BuildContext context) {
    const surface = Color(0xFFF6F7F9);
    const panel = Colors.white;
    const border = Color(0xFFE6E9EF);
    const text = Color(0xFF1E2430);
    const muted = Color(0xFF6B7280);
    const brand = Color(0xFF0EA37A);
    final hasTopTabs = _topTabs.isNotEmpty;
    final activeIndex = hasTopTabs ? ((_activeTopTabIndex ?? 0).clamp(0, _topTabs.length - 1)).toInt() : 0;
    final displayTitle = _contentTitle.isNotEmpty
        ? _contentTitle
        : (hasTopTabs ? _topTabs[activeIndex] : 'Dashboard');
    return Scaffold(
      backgroundColor: surface,
      body: SafeArea(
        child: Row(
          children: [
            DashboardLeftMenuRail(
              items: _menuItems,
              selectedIndex: _selectedIndex,
              onSelect: (idx) {
                final title = _menuItems[idx].label;
                setState(() {
                  _selectedIndex = idx;
                  _contentTitle = title;
                });

                if (title == 'Dashboard') {
                  // Already on Dashboard; keep this for future consistency.
                  return;
                }

                ScaffoldMessenger.of(context)
                  ..clearSnackBars()
                  ..showSnackBar(
                    SnackBar(
                      content: Text('$title — coming soon'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
              },
              background: panel,
              border: border,
              selectedColor: brand,
              labelColor: muted,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  DashboardTopHeader(
                    title: 'IVA AI Voice',
                    tabs: _topTabs,
                    activeIndex: activeIndex,
                    onTabSelected: (idx) {
                      if (!hasTopTabs) return;
                      final title = _topTabs[idx];
                      setState(() {
                        _activeTopTabIndex = idx;
                        _contentTitle = title;
                      });
                      ScaffoldMessenger.of(context)
                        ..clearSnackBars()
                        ..showSnackBar(
                          SnackBar(
                            content: Text('$title — coming soon'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                    },
                    background: panel,
                    border: border,
                    titleColor: text,
                    tabColor: muted,
                    activeTabColor: text,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: panel,
                        border: Border.all(color: border),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: _buildContentView(context, displayTitle),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildContentView(BuildContext context, String displayTitle) {
    if (displayTitle == 'Dashboard') {
      return _buildDashboardCards();
    }

    if (displayTitle == 'AI Voice') {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Navigator(
          key: _contentNavigatorKey,
          onGenerateRoute: (settings) {
            if (settings.name == '/users') {
              return MaterialPageRoute(
                settings: settings,
                builder: (_) => const UsersListScreen(),
              );
            }

            return MaterialPageRoute(
              settings: settings,
              builder: (_) => _AiVoiceLanding(
                onOpenUsers: () => _contentNavigatorKey.currentState?.pushNamed('/users'),
              ),
            );
          },
        ),
      );
    }

    return Align(
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            displayTitle,
            style: const TextStyle(
              color: Color(0xFF1E2430),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Coming soon',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hi ANNAMALAI RAJA,',
          style: TextStyle(
            color: Color(0xFF10A088),
            fontSize: 36,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 18),
        Expanded(
          child: GridView.builder(
            itemCount: _dashboardCards.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.7,
            ),
            itemBuilder: (context, index) {
              final item = _dashboardCards[index];
              return _DashboardStatCard(item: item);
            },
          ),
        ),
      ],
    );
  }
}

class _AiVoiceLanding extends StatelessWidget {
  const _AiVoiceLanding({required this.onOpenUsers});

  final VoidCallback onOpenUsers;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.phone_in_talk, size: 84, color: Colors.green),
          const SizedBox(height: 20),
          const Text(
            'AI Voice',
            style: TextStyle(
              color: Color(0xFF1E2430),
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Coming soon',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onOpenUsers,
            child: const Text('View Chit Details'),
          ),
        ],
      ),
    );
  }
}

class _DashboardStatCard extends StatelessWidget {
  const _DashboardStatCard({required this.item});

  final _DashboardCardItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE6E9EF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.title.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  color: item.accent,
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, size: 20, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${item.count}',
            style: const TextStyle(
              color: Color(0xFF1F2140),
              fontSize: 40,
              fontWeight: FontWeight.w700,
              height: 1.0,
            ),
          ),
          const Spacer(),
          Text(
            item.actionLabel,
            style: const TextStyle(
              color: Color(0xFF1AA698),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardCardItem {
  const _DashboardCardItem({
    required this.title,
    required this.count,
    required this.actionLabel,
    required this.icon,
    required this.accent,
  });

  final String title;
  final int count;
  final String actionLabel;
  final IconData icon;
  final Color accent;
}

