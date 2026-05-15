import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';
import 'home_page.dart';
import 'location_page.dart';
import 'explore_page.dart';
import 'trips_page.dart';
import 'likes_page.dart';
import 'profile_page.dart';

class MainNav extends StatefulWidget {
  const MainNav({super.key});

  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  int _currentIndex = 0;
  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      const _HomeTabPlaceholder(),
      const LocationPage(
          onCitySelected: _onCitySelectedDummy,
          currentCity: 'Karachi, Pakistan'),
      const ExplorePage(lat: 24.8607, lon: 67.0011),
      const TripsPage(),
      const LikesPage(),
    ];
  }

  static void _onCitySelectedDummy(String city, double lat, double lon) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: _CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

// ─── Nav bar ────────────────────────────────────────────────────────────────

class _CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _CustomBottomNav({required this.currentIndex, required this.onTap});

  static const _tabs = [
    _TabData('Home', Icons.home_rounded),
    _TabData('Location', Icons.location_on_rounded),
    _TabData('Explore', Icons.explore_rounded),
    _TabData('Trips', Icons.luggage_rounded),
    _TabData('Likes', Icons.favorite_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              _tabs.length,
              (i) => _NavItem(
                tab: _tabs[i],
                isSelected: i == currentIndex,
                onTap: () => onTap(i),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabData {
  final String label;
  final IconData icon;
  const _TabData(this.label, this.icon);
}

// ─── Each nav item ───────────────────────────────────────────────────────────

class _NavItem extends StatefulWidget {
  final _TabData tab;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _bounce = Tween(begin: 1.0, end: 1.0).animate(_ctrl);
  }

  @override
  void didUpdateWidget(_NavItem old) {
    super.didUpdateWidget(old);
    if (widget.isSelected && !old.isSelected) {
      // pop up then settle
      _bounce = TweenSequence([
        TweenSequenceItem(
            tween: Tween(begin: 1.0, end: 1.18)
                .chain(CurveTween(curve: Curves.easeOut)),
            weight: 40),
        TweenSequenceItem(
            tween: Tween(begin: 1.18, end: 0.92)
                .chain(CurveTween(curve: Curves.easeIn)),
            weight: 30),
        TweenSequenceItem(
            tween: Tween(begin: 0.92, end: 1.0)
                .chain(CurveTween(curve: Curves.elasticOut)),
            weight: 30),
      ]).animate(_ctrl);
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _bounce,
        builder: (_, child) =>
            Transform.scale(scale: _bounce.value, child: child),
        child: widget.isSelected
            ? _SelectedTab(tab: widget.tab)
            : _UnselectedTab(tab: widget.tab),
      ),
    );
  }
}

// Selected: white pill with icon + label side by side
class _SelectedTab extends StatelessWidget {
  final _TabData tab;
  const _SelectedTab({required this.tab});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(tab.icon, color: AppTheme.primary, size: 20),
          const SizedBox(width: 6),
          Text(
            tab.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// Unselected: icon only, white 55% opacity
class _UnselectedTab extends StatelessWidget {
  final _TabData tab;
  const _UnselectedTab({required this.tab});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
      child: Icon(
        tab.icon,
        color: Colors.white.withOpacity(0.55),
        size: 24,
      ),
    );
  }
}

// ─── Home tab wrapper (unchanged logic) ─────────────────────────────────────

class _HomeTabPlaceholder extends StatefulWidget {
  const _HomeTabPlaceholder();

  @override
  State<_HomeTabPlaceholder> createState() => _HomeTabPlaceholderState();
}

class _HomeTabPlaceholderState extends State<_HomeTabPlaceholder> {
  @override
  Widget build(BuildContext context) {
    return const _HomeTab(
      username: 'User',
      city: 'Karachi, Pakistan',
      lat: 24.8607,
      lon: 67.0011,
    );
  }
}

class _HomeTab extends StatefulWidget {
  final String username;
  final String city;
  final double? lat;
  final double? lon;
  const _HomeTab(
      {required this.username, required this.city, this.lat, this.lon});

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  String _username = 'User';

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'User';
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Your Location',
                          style:
                              TextStyle(fontSize: 11, color: AppTheme.textMid)),
                      Row(children: [
                        const Icon(Icons.location_on,
                            size: 14, color: AppTheme.primary),
                        const SizedBox(width: 2),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 160),
                          child: Text(widget.city,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textDark)),
                        ),
                      ]),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfilePage(username: _username),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: AppTheme.primary,
                    child: Text(
                      _username.isNotEmpty ? _username[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hello, ${widget.username}! 👋',
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark)),
                    const SizedBox(height: 4),
                    const Text('Where would you like to go today?',
                        style: TextStyle(
                            fontSize: 14, color: AppTheme.textMid)),
                  ]),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 8),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10)
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(Icons.explore,
                        size: 48, color: AppTheme.primary),
                    const SizedBox(height: 12),
                    const Text('Explore Destinations',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark)),
                    const SizedBox(height: 8),
                    const Text('Discover amazing places around the world',
                        style: TextStyle(
                            fontSize: 12, color: AppTheme.textMid)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                        onPressed: () {},
                        child: const Text('Start Exploring')),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}