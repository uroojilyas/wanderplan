import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/place_model.dart';
import '../services/opentripmap_service.dart';
import '../services/location_service.dart';
import '../widgets/carousel_card.dart';
import '../widgets/place_card.dart';
import 'location_page.dart';
import 'explore_page.dart';
import 'likes_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  final String username;
  const HomePage({super.key, required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  String _city = 'Detecting...';
  double? _lat;
  double? _lon;

  @override
  void initState() {
    super.initState();
    _detectAndLoad();
  }

  Future<void> _detectAndLoad() async {
    final coords = await LocationService.getCurrentLatLon();
    if (!mounted) return;
    if (coords != null) {
      _lat = coords[0];
      _lon = coords[1];
      final cityName = await LocationService.reverseGeocode(_lat!, _lon!);
      if (!mounted) return;
      setState(() => _city = cityName);
    } else {
      _lat = 24.8607;
      _lon = 67.0011;
      setState(() => _city = 'Karachi, Pakistan');
    }
  }

  void _onCitySelected(String city, double lat, double lon) {
    setState(() {
      _city = city;
      _lat = lat;
      _lon = lon;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _HomeTab(username: widget.username, city: _city, lat: _lat, lon: _lon),
      LocationPage(onCitySelected: _onCitySelected, currentCity: _city),
      ExplorePage(lat: _lat, lon: _lon),
      const LikesPage(),
      ProfilePage(username: widget.username),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, -2))],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          backgroundColor: Colors.white,
          indicatorColor: AppTheme.primary.withOpacity(0.15),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.location_on_outlined), selectedIcon: Icon(Icons.location_on), label: 'Location'),
            NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'Explore'),
            NavigationDestination(icon: Icon(Icons.favorite_outline), selectedIcon: Icon(Icons.favorite), label: 'Likes'),
            NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
class _HomeTab extends StatefulWidget {
  final String username;
  final String city;
  final double? lat;
  final double? lon;
  const _HomeTab({required this.username, required this.city, this.lat, this.lon});

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  List<Place> _carousel = [];
  List<Place> _recommended = [];
  List<Place> _allPlaces = [];
  bool _loading = true;
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(
      () => setState(() => _query = _searchController.text.trim().toLowerCase()),
    );
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_HomeTab old) {
    super.didUpdateWidget(old);
    if (old.lat != widget.lat || old.lon != widget.lon) _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final lat = widget.lat ?? 24.8607;
    final lon = widget.lon ?? 67.0011;
    try {
      final attractions = await OpenTripMapService.fetchAttractions(lat, lon);
      if (!mounted) return;
      setState(() {
        _allPlaces = attractions.isEmpty ? samplePlaces : attractions;
        _carousel = _allPlaces.take(5).toList();
        _recommended = _allPlaces.skip(5).take(4).toList();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _allPlaces = samplePlaces;
        _carousel = samplePlaces.take(3).toList();
        _recommended = samplePlaces.take(4).toList();
        _loading = false;
      });
    }
  }

  List<Place> get _searchResults => _allPlaces
      .where((p) =>
          p.name.toLowerCase().contains(_query) ||
          p.location.toLowerCase().contains(_query) ||
          p.description.toLowerCase().contains(_query))
      .toList();

  bool get _isSearching => _query.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // ── Top Bar ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Your Location', style: TextStyle(fontSize: 11, color: AppTheme.textMid)),
                    Row(children: [
                      const Icon(Icons.location_on, size: 14, color: AppTheme.primary),
                      const SizedBox(width: 2),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 160),
                        child: Text(widget.city,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                      ),
                    ]),
                  ]),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfilePage(username: widget.username),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: AppTheme.primary,
                    child: Text(widget.username.isNotEmpty ? widget.username[0].toUpperCase() : 'U',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                ),
              ]),
            ),
          ),

          // ── Greeting ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Hello, ${widget.username}! 👋',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                const SizedBox(height: 4),
                const Text('Where would you like to go today?',
                    style: TextStyle(fontSize: 14, color: AppTheme.textMid)),
              ]),
            ),
          ),

          // ── Search bar ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)],
                ),
                child: Row(children: [
                  const Icon(Icons.search, color: AppTheme.textMid),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search destinations...',
                        hintStyle: TextStyle(color: AppTheme.textMid, fontSize: 14),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  if (_isSearching)
                    GestureDetector(
                      onTap: () => _searchController.clear(),
                      child: const Icon(Icons.close, color: AppTheme.textMid, size: 18),
                    ),
                ]),
              ),
            ),
          ),

          // ── Search Results (shown when typing) ──
          if (_isSearching) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Text('Results for "$_query"',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
              ),
            ),
            if (_searchResults.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(children: [
                      Icon(Icons.search_off, size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 8),
                      Text('No results for "$_query"', style: const TextStyle(color: AppTheme.textMid)),
                    ]),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => PlaceCard(place: _searchResults[i]),
                  childCount: _searchResults.length,
                ),
              ),
          ],

          // ── Normal content (hidden when searching) ──
          if (!_isSearching) ...[
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 28, 16, 12),
                child: Text('Popular Destinations',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
              ),
            ),

            SliverToBoxAdapter(
              child: _loading
                  ? const SizedBox(height: 280, child: Center(child: CircularProgressIndicator()))
                  : SizedBox(
                      height: 280,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: 16),
                        itemCount: _carousel.length,
                        itemBuilder: (_, i) => CarouselCard(place: _carousel[i]),
                      ),
                    ),
            ),

            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 28, 16, 4),
                child: Text('Recommended for You',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
              ),
            ),

            _loading
                ? const SliverToBoxAdapter(
                    child: SizedBox(height: 100, child: Center(child: CircularProgressIndicator())))
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => PlaceCard(place: _recommended[i]),
                      childCount: _recommended.length,
                    ),
                  ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}