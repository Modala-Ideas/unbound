import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_device_apps/flutter_device_apps.dart';
import 'package:unbound/services/apps_service.dart';

/// Full-screen app drawer showing all installed apps
class AppDrawerScreen extends StatefulWidget {
  const AppDrawerScreen({super.key});

  @override
  State<AppDrawerScreen> createState() => _AppDrawerScreenState();
}

class _AppDrawerScreenState extends State<AppDrawerScreen>
    with SingleTickerProviderStateMixin {
  final AppsService _appsService = AppsService();
  List<AppInfo> _apps = [];
  List<AppInfo> _filteredApps = [];
  List<Map<String, dynamic>> _workApps = [];
  List<Map<String, dynamic>> _filteredWorkApps = [];
  bool _isLoading = true;
  bool _isClosing = false;
  bool _scrollingStartedAtTop = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    if (AppsService.cachedApps != null) {
      _apps = AppsService.cachedApps!;
      _filteredApps = _apps;
      _isLoading = false;
    }
    _loadApps();

    // Auto-focus search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadApps() async {
    final apps = await _appsService.getAllApps();
    final workApps = await _appsService.getWorkApps();

    debugPrint('AppDrawer: Loaded ${apps.length} personal apps');
    debugPrint('AppDrawer: Loaded ${workApps.length} work apps');

    if (mounted) {
      setState(() {
        _apps = apps;
        _filteredApps = apps;
        _workApps = workApps;
        _filteredWorkApps = workApps;
        _isLoading = false;

        // Initialize tab controller if we have work apps
        if (_workApps.isNotEmpty && _tabController == null) {
          _tabController = TabController(length: 2, vsync: this);
        }
      });
    }
  }

  void _filterApps(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredApps = _apps;
        _filteredWorkApps = _workApps;
      } else {
        _filteredApps = _apps
            .where(
              (app) => (app.appName ?? '').toLowerCase().contains(
                query.toLowerCase(),
              ),
            )
            .toList();
        _filteredWorkApps = _workApps
            .where(
              (app) => (app['appName'] as String? ?? '').toLowerCase().contains(
                query.toLowerCase(),
              ),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool hasWorkApps = _workApps.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.8),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: _filterApps,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                decoration: InputDecoration(
                  hintText: 'Search apps...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white),
                          onPressed: () {
                            _searchController.clear();
                            _filterApps('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),

            // TabBar (only if work apps exist)
            if (hasWorkApps && _tabController != null)
              TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withOpacity(0.6),
                indicatorColor: Colors.white,
                tabs: const [
                  Tab(text: 'Personal'),
                  Tab(text: 'Work'),
                ],
              ),

            // Apps grid
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : hasWorkApps && _tabController != null
                  ? TabBarView(
                      controller: _tabController,
                      children: [
                        _buildAppGrid(_filteredApps),
                        _buildWorkAppGrid(_filteredWorkApps),
                      ],
                    )
                  : _buildAppGrid(_filteredApps),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppGrid(List<AppInfo> apps) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollStartNotification) {
          _scrollingStartedAtTop = notification.metrics.pixels <= 0;
        } else if (notification is ScrollUpdateNotification) {
          if (!_isClosing &&
              _scrollingStartedAtTop &&
              notification.metrics.pixels <= 0 &&
              notification.scrollDelta! < -10) {
            _isClosing = true;
            Navigator.of(context).pop();
            return true;
          }
        }
        return false;
      },
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(32),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 8,
        ),
        itemCount: apps.length,
        itemBuilder: (context, index) {
          final app = apps[index];
          return _AppItem(
            app: app,
            onTap: () async {
              final packageName = app.packageName;
              if (packageName != null) {
                await _appsService.launchApp(packageName);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildWorkAppGrid(List<Map<String, dynamic>> apps) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollStartNotification) {
          _scrollingStartedAtTop = notification.metrics.pixels <= 0;
        } else if (notification is ScrollUpdateNotification) {
          if (!_isClosing &&
              _scrollingStartedAtTop &&
              notification.metrics.pixels <= 0 &&
              notification.scrollDelta! < -10) {
            _isClosing = true;
            Navigator.of(context).pop();
            return true;
          }
        }
        return false;
      },
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(32),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 8,
        ),
        itemCount: apps.length,
        itemBuilder: (context, index) {
          final app = apps[index];
          return _WorkAppItem(
            appName: app['appName'] as String? ?? 'Unknown',
            packageName: app['packageName'] as String? ?? '',
            iconBytes: app['icon'] as Uint8List?,
            onTap: () async {
              final packageName = app['packageName'] as String?;
              if (packageName != null && packageName.isNotEmpty) {
                await _appsService.launchApp(packageName);
              }
            },
          );
        },
      ),
    );
  }
}

/// Individual app item widget
class _AppItem extends StatelessWidget {
  final AppInfo app;
  final VoidCallback onTap;

  const _AppItem({required this.app, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: () {
        debugPrint('Long press on ${app.appName}');
      },
      onSecondaryTap: () {
        debugPrint('Right click on ${app.appName}');
      },
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // App icon
          SizedBox(
            width: 56,
            height: 56,
            child: app.iconBytes != null
                ? Image.memory(app.iconBytes!)
                : const Icon(Icons.apps, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 8),

          // App name
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              app.appName ?? 'Unknown App',
              style: const TextStyle(color: Colors.white, fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// Work app item widget
class _WorkAppItem extends StatelessWidget {
  final String appName;
  final String packageName;
  final Uint8List? iconBytes;
  final VoidCallback onTap;

  const _WorkAppItem({
    required this.appName,
    required this.packageName,
    required this.iconBytes,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: () {
        debugPrint('Long press on $appName');
      },
      onSecondaryTap: () {
        debugPrint('Right click on $appName');
      },
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // App icon
          SizedBox(
            width: 56,
            height: 56,
            child: iconBytes != null
                ? Image.memory(iconBytes!)
                : const Icon(Icons.work, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 8),

          // App name
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              appName,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
