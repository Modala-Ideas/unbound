import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unbound/screens/app_drawer_screen.dart';
import 'package:unbound/utils/method_channel_helper.dart';

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
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );
  
  runApp(const UnboundApp());
}

class UnboundApp extends StatelessWidget {
  const UnboundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unbound',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      debugShowCheckedModeBanner: false,
      home: const LauncherHome(),
    );
  }
}

class LauncherHome extends StatelessWidget {
  const LauncherHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: GestureDetector(
        // Swipe up to open app drawer
        onVerticalDragEnd: (details) {
          // Swipe up (negative velocity)
          if (details.primaryVelocity != null && details.primaryVelocity! < -500) {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const AppDrawerScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(0.0, 1.0);
                  const end = Offset.zero;
                  const curve = Curves.easeOut;
                  var tween = Tween(begin: begin, end: end).chain(
                    CurveTween(curve: curve),
                  );
                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
              ),
            );
          }
          // Swipe down (positive velocity) - expand notifications
          else if (details.primaryVelocity != null && details.primaryVelocity! > 500) {
            MethodChannelHelper.expandNotificationsPanel();
          }
        },
        child: Stack(
          children: [
            // Main launcher content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Unbound',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 32,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Swipe up for apps',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
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
    );
  }
}
