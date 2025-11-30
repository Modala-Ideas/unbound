import 'package:flutter/material.dart';
import 'package:flutter_device_apps/flutter_device_apps.dart';
import 'package:unbound/services/apps_service.dart';
import 'package:unbound/services/favorites_service.dart';

class FavoritesDock extends StatefulWidget {
  const FavoritesDock({super.key});

  @override
  State<FavoritesDock> createState() => _FavoritesDockState();
}

class _FavoritesDockState extends State<FavoritesDock> {
  final FavoritesService _favoritesService = FavoritesService();
  final AppsService _appsService = AppsService();
  List<AppInfo> _favoriteApps = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);

    final favoritePackages = await _favoritesService.getFavorites();
    final allApps = await _appsService.getAllApps();

    final favoriteApps = <AppInfo>[];
    for (final packageName in favoritePackages) {
      final app = allApps.firstWhere(
        (app) => app.packageName == packageName,
        orElse: () => allApps.first,
      );
      if (app.packageName == packageName) {
        favoriteApps.add(app);
      }
    }

    if (mounted) {
      setState(() {
        _favoriteApps = favoriteApps;
        _isLoading = false;
      });
    }
  }

  Future<void> _showAppSelector() async {
    final allApps = await _appsService.getAllApps();

    if (!mounted) return;

    final selected = await showDialog<AppInfo>(
      context: context,
      builder: (context) => _AppSelectorDialog(apps: allApps),
    );

    if (selected != null && selected.packageName != null) {
      final added = await _favoritesService.addFavorite(selected.packageName!);
      if (added) {
        _loadFavorites();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Favorites full (max 5 apps)'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(FavoritesService.maxFavorites, (index) {
          if (index < _favoriteApps.length) {
            final app = _favoriteApps[index];
            return _FavoriteAppIcon(
              app: app,
              onTap: () async {
                final packageName = app.packageName;
                if (packageName != null) {
                  await _appsService.launchApp(packageName);
                }
              },
              onLongPress: () async {
                final packageName = app.packageName;
                if (packageName != null) {
                  await _favoritesService.removeFavorite(packageName);
                  _loadFavorites();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Removed ${app.appName} from favorites'),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
            );
          } else {
            return _EmptyFavoriteSlot(onTap: _showAppSelector);
          }
        }),
      ),
    );
  }
}

class _FavoriteAppIcon extends StatelessWidget {
  final AppInfo app;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _FavoriteAppIcon({
    required this.app,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: app.iconBytes != null
              ? Image.memory(app.iconBytes!, fit: BoxFit.cover)
              : Container(
                  color: Colors.grey.withOpacity(0.3),
                  child: const Icon(Icons.apps, color: Colors.white, size: 28),
                ),
        ),
      ),
    );
  }
}

class _EmptyFavoriteSlot extends StatelessWidget {
  final VoidCallback onTap;

  const _EmptyFavoriteSlot({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
        ),
        child: Icon(Icons.add, color: Colors.white.withOpacity(0.3), size: 24),
      ),
    );
  }
}

class _AppSelectorDialog extends StatefulWidget {
  final List<AppInfo> apps;

  const _AppSelectorDialog({required this.apps});

  @override
  State<_AppSelectorDialog> createState() => _AppSelectorDialogState();
}

class _AppSelectorDialogState extends State<_AppSelectorDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<AppInfo> _filteredApps = [];

  @override
  void initState() {
    super.initState();
    _filteredApps = widget.apps;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterApps(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredApps = widget.apps;
      } else {
        _filteredApps = widget.apps
            .where(
              (app) => (app.appName ?? '').toLowerCase().contains(
                query.toLowerCase(),
              ),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.grey[900],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Select App',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: _filterApps,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search apps...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // App list
          Expanded(
            child: ListView.builder(
              itemCount: _filteredApps.length,
              itemBuilder: (context, index) {
                final app = _filteredApps[index];
                return ListTile(
                  leading: app.iconBytes != null
                      ? Image.memory(app.iconBytes!, width: 40, height: 40)
                      : const Icon(Icons.apps, color: Colors.white),
                  title: Text(
                    app.appName ?? 'Unknown',
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () => Navigator.pop(context, app),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
