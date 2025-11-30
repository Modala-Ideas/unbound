import 'package:flutter/material.dart';
import 'package:flutter_device_apps/flutter_device_apps.dart';
import 'package:unbound/services/apps_service.dart';

/// Full-screen app drawer showing all installed apps
class AppDrawerScreen extends StatefulWidget {
  const AppDrawerScreen({super.key});

  @override
  State<AppDrawerScreen> createState() => _AppDrawerScreenState();
}

class _AppDrawerScreenState extends State<AppDrawerScreen> {
  final AppsService _appsService = AppsService();
  List<AppInfo> _apps = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (AppsService.cachedApps != null) {
      _apps = AppsService.cachedApps!;
      _isLoading = false;
    }
    _loadApps();
  }

  Future<void> _loadApps() async {
    final apps = await _appsService.getAllApps();
    debugPrint('AppDrawer: Loaded ${apps.length} apps');
    setState(() {
      _apps = apps;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.8),
      body: SafeArea(
        child: Column(
          children: [
            // Header with close button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Apps',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Apps grid
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemCount: _apps.length,
                      itemBuilder: (context, index) {
                        final app = _apps[index];
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
            ),
          ],
        ),
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
        // Handle long press (e.g., show app info or uninstall option)
        debugPrint('Long press on ${app.appName}');
      },
      onSecondaryTap: () {
        // Handle right click (desktop)
        debugPrint('Right click on ${app.appName}');
      },
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
