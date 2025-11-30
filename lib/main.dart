import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unbound/screens/app_drawer_screen.dart';
import 'package:unbound/screens/settings_screen.dart';
import 'package:unbound/services/apps_service.dart';
import 'package:unbound/services/wallpaper_service.dart';
import 'package:unbound/utils/method_channel_helper.dart';
import 'package:unbound/widgets/dashboard.dart';
import 'package:unbound/widgets/favorites_dock.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style for edge-to-edge experience
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Enable edge-to-edge mode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(const UnboundApp());

  // Preload apps in background
  AppsService().getAllApps();
}

class UnboundApp extends StatelessWidget {
  const UnboundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unbound',
      theme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
      debugShowCheckedModeBanner: false,
      home: const LauncherHome(),
    );
  }
}

class LauncherHome extends StatefulWidget {
  const LauncherHome({super.key});

  @override
  State<LauncherHome> createState() => _LauncherHomeState();
}

class _LauncherHomeState extends State<LauncherHome> {
  String? _wallpaperPath;

  @override
  void initState() {
    super.initState();
    _loadWallpaper();
  }

  Future<void> _loadWallpaper() async {
    final wallpaperService = WallpaperService();
    final path = await wallpaperService.getCurrentWallpaperPath();
    if (mounted) {
      setState(() {
        _wallpaperPath = path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Wallpaper background
          if (_wallpaperPath != null)
            Image.file(
              File(_wallpaperPath!),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: Colors.black);
              },
            )
          else
            Container(color: Colors.black),

          // Launcher content
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            // Long press to open settings
            onLongPress: () {
              Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  )
                  .then((_) => _loadWallpaper());
            },
            // Swipe up to open app drawer
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity != null &&
                  details.primaryVelocity! < -500) {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const AppDrawerScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                          const begin = Offset(0.0, 1.0);
                          const end = Offset.zero;
                          const curve = Curves.easeOut;
                          var tween = Tween(
                            begin: begin,
                            end: end,
                          ).chain(CurveTween(curve: curve));
                          return SlideTransition(
                            position: animation.drive(tween),
                            child: child,
                          );
                        },
                  ),
                );
              } else if (details.primaryVelocity != null &&
                  details.primaryVelocity! > 500) {
                MethodChannelHelper.expandNotificationsPanel();
              }
            },
            child: Stack(
              children: [
                // Dashboard (Weather & Calendar)
                Positioned(top: 0, left: 0, right: 0, child: const Dashboard()),

                // Center Content (optional, maybe just keep clean or add clock)
                // For now, we'll remove the big text to let the dashboard shine
                // and keep the bottom hint.
                // Favorites Dock
                Positioned(
                  bottom: 100,
                  left: 0,
                  right: 0,
                  child: Center(child: const FavoritesDock()),
                ),
                // Hint indicator at bottom
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Icon(
                      Icons.keyboard_arrow_up_rounded,
                      color: Colors.white.withOpacity(0.4),
                      size: 32,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
