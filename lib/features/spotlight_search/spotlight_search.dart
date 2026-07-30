import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/glass_tokens.dart';
import '../../core/utils/squircle_path.dart';
import '../../data/repositories/apps_repository.dart';
import '../../core/platform/launcher_service.dart';

class SpotlightSearch extends StatefulWidget {
  final VoidCallback onDismiss;

  const SpotlightSearch({super.key, required this.onDismiss});

  @override
  State<SpotlightSearch> createState() => _SpotlightSearchState();
}

class _SpotlightSearchState extends State<SpotlightSearch>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  final TextEditingController _searchController = TextEditingController();
  final AppsRepository _appsRepo = AppsRepository();
  List<InstalledApp> _results = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
    _loadApps();
  }

  Future<void> _loadApps() async {
    await _appsRepo.loadApps();
    setState(() {
      _results = _appsRepo.installedApps;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _results = _appsRepo.searchApps(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            // Dimmed background
            Positioned.fill(
              child: GestureDetector(
                onTap: _dismiss,
                child: Container(
                  color: Colors.black.withOpacity(0.50 * _fadeAnimation.value),
                ),
              ),
            ),
            // Search bar and results
            Positioned(
              top: MediaQuery.of(context).size.height * 0.2,
              left: MediaQuery.of(context).size.width * 0.15,
              right: MediaQuery.of(context).size.width * 0.15,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: _buildSearchPanel(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchPanel() {
    return ClipPath(
      clipper: SquircleClipper(radius: 28.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 45.0, sigmaY: 45.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.14),
                Colors.white.withOpacity(0.05),
              ],
            ),
            border: Border.all(
              width: 1.0,
              color: Colors.white.withOpacity(0.20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.50),
                blurRadius: 50.0,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search input
              _buildSearchInput(),
              // Results
              if (_results.isNotEmpty) ...[
                const Divider(color: Colors.white12, height: 1.0),
                _buildResultsList(),
              ],
              if (_results.isEmpty && !_isLoading && _searchController.text.isNotEmpty)
                _buildEmptyState(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Row(
        children: [
          Icon(
            Icons.search,
            size: 22.0,
            color: Colors.white.withOpacity(0.50),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              autofocus: true,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.w300,
              ),
              decoration: InputDecoration(
                hintText: 'Search apps, settings, actions...',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.35),
                  fontSize: 18.0,
                  fontWeight: FontWeight.w300,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 400.0),
      child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        itemCount: _results.length,
        itemBuilder: (context, index) {
          final app = _results[index];
          return _SearchResultItem(
            app: app,
            onTap: () {
              LauncherService.launchApp(app.packageName);
              _dismiss();
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Text(
        'No results found',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white.withOpacity(0.40),
          fontSize: 14.0,
        ),
      ),
    );
  }

  void _dismiss() {
    _controller.reverse().then((_) => widget.onDismiss());
  }
}

class _SearchResultItem extends StatelessWidget {
  final InstalledApp app;
  final VoidCallback onTap;

  const _SearchResultItem({required this.app, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Row(
          children: [
            Container(
              width: 36.0,
              height: 36.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.white.withOpacity(0.08),
                border: Border.all(
                  width: 1.0,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
              child: Center(
                child: Text(
                  app.appName[0].toUpperCase(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.70),
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    app.appName,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.90),
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    app.category,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.40),
                      fontSize: 11.0,
                    ),
                  ),
                ],
              ),
            ),
            if (app.isCodingApp)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6.0,
                  vertical: 2.0,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0),
                  color: const Color(0xFF39FF14).withOpacity(0.15),
                ),
                child: const Text(
                  'DEV',
                  style: TextStyle(
                    color: Color(0xFF39FF14),
                    fontSize: 9.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
