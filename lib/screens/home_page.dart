import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/place_model.dart';
import '../models/trip_model.dart';
import '../services/opentripmap_service.dart';
import '../services/storage_service.dart';
import '../widgets/carousel_card.dart';
import '../widgets/place_card.dart';
import 'profile_page.dart';
import 'explore_page.dart';
import 'trips_page.dart';

class HomePage extends StatefulWidget {
  final String username;
  final String city;
  final double? lat;
  final double? lon;
  const HomePage({super.key, required this.username, required this.city, required this.lat, required this.lon});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return _HomeTab(username: widget.username, city: widget.city, lat: widget.lat, lon: widget.lon);
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

  List<Trip> _getRecentTrips() {
    final trips = StorageService.getAllTrips();
    trips.sort((a, b) => b.startDate.compareTo(a.startDate));
    return trips;
  }

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
            // ── QUICK ACTIONS ROW ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: Row(
                  children: [
                    // Plan a Trip Card
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TripsPage(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.luggage_rounded,
                                  size: 32, color: AppTheme.primary),
                              const SizedBox(height: 8),
                              const Text('Plan a Trip',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textDark)),
                              const SizedBox(height: 4),
                              const Text('Create your itinerary',
                                  style: TextStyle(
                                      fontSize: 11, color: AppTheme.textMid)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Explore Nearby Card
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => Scaffold(
                                appBar: AppBar(
                                  title: const Text('Explore'),
                                  backgroundColor: AppTheme.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                ),
                                body: ExplorePage(lat: widget.lat, lon: widget.lon),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.explore_rounded,
                                  size: 32, color: Colors.orange),
                              const SizedBox(height: 8),
                              const Text('Explore Nearby',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textDark)),
                              const SizedBox(height: 4),
                              const Text('Discover places',
                                  style: TextStyle(
                                      fontSize: 11, color: AppTheme.textMid)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── RECENT TRIPS SECTION ──
            if (_getRecentTrips().isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Recent Trips',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark)),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount:
                              _getRecentTrips().length > 2 ? 2 : _getRecentTrips().length,
                          itemBuilder: (_, i) {
                            final trip = _getRecentTrips()[i];
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Container(
                                width: 150,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(trip.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textDark)),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on,
                                            size: 12, color: AppTheme.primary),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(trip.destination,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  color: AppTheme.textMid)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 28, 16, 12),
                child: Text('Popular Destinations',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark)),
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