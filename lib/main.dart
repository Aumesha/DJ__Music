import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  runApp(const DJMusicApp());
}

class DJMusicApp extends StatelessWidget {
  const DJMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DJMusic',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primaryColor: const Color(0xFFFFD700),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFD700),
          surface: Colors.black,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Color(0xFFFFD700),
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.black,
          selectedItemColor: Color(0xFFFFD700),
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// ------------------- SPLASH SCREEN -------------------
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  AppOpenAd? _appOpenAd;
  bool _isAdLoaded = false;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _loadAppOpenAd();

    Future.delayed(const Duration(seconds: 5), () {
      if (!_hasNavigated) {
        if (_isAdLoaded && _appOpenAd != null) {
          _appOpenAd!.show();
          _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _navigateToHome();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _navigateToHome();
            },
          );
        } else {
          _navigateToHome();
        }
      }
    });
  }

  void _loadAppOpenAd() {
    AppOpenAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/3419887887',
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _appOpenAd = ad;
              _isAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (error) {
          _isAdLoaded = false;
        },
      ),
    );
  }

  void _navigateToHome() {
    if (mounted && !_hasNavigated) {
      _hasNavigated = true;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.music_note_rounded,
              size: 110,
              color: Color(0xFFFFD700),
            ),
            SizedBox(height: 20),
            Text(
              'DJMusic',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFD700),
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 30),
            CircularProgressIndicator(color: Color(0xFFFFD700)),
          ],
        ),
      ),
    );
  }
}

// ------------------- MAIN NAVIGATION -------------------
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  bool isAdminDevice = true;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SavedScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DJMusic', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (isAdminDevice)
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Color(0xFFFFD700)),
              onPressed: () => _showAddVideoDialog(context),
            ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Save'),
        ],
      ),
    );
  }

  void _showAddVideoDialog(BuildContext context) {
    final TextEditingController idController = TextEditingController();
    final TextEditingController titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Add New Video (Admin Only)', style: TextStyle(color: Color(0xFFFFD700))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: idController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'YouTube Video ID',
                labelStyle: TextStyle(color: Colors.grey),
              ),
            ),
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Song Title',
                labelStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700)),
            onPressed: () {
              if (idController.text.trim().isNotEmpty && titleController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Video Sync Feature Triggered!')),
                );
              }
            },
            child: const Text('Add Video', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}

// ------------------- HOME SCREEN -------------------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BannerAd? topBannerAd;
  BannerAd? bottomBannerAd;
  bool isTopAdLoaded = false;
  bool isBottomAdLoaded = false;

  final TextEditingController searchController = TextEditingController();

  final List<Map<String, String>> allVideos = [
    {'id': 'dQw4w9WgXcQ', 'title': 'Kannada DJ Remix Track 1'},
    {'id': '3JZ_D3ELwOQ', 'title': 'Bass Boosted DJ Song 2'},
    {'id': 'L_jWHffIx5E', 'title': 'Non Stop Folk DJ Beats 3'},
    {'id': 'fJ9rUzIMcZQ', 'title': 'New Kannada Hit Remixed 4'},
    {'id': '2Vv-BfVoq4g', 'title': 'DJ Music Special Mix 5'},
    {'id': 'kJQP7kiw5Fk', 'title': 'Party Dance DJ Track 6'},
  ];

  List<Map<String, String>> filteredVideos = [];

  @override
  void initState() {
    super.initState();
    filteredVideos = List.from(allVideos);
    _loadTopAndBottomAds();
  }

  void _loadTopAndBottomAds() {
    topBannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) setState(() => isTopAdLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();

    bottomBannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) setState(() => isBottomAdLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  void _filterVideos(String query) {
    setState(() {
      filteredVideos = allVideos
          .where((v) => v['title']!.toLowerCase().contains(query.toLowerCase().trim()))
          .toList();
    });
  }

  @override
  void dispose() {
    topBannerAd?.dispose();
    bottomBannerAd?.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isTopAdLoaded && topBannerAd != null)
          SizedBox(
            height: topBannerAd!.size.height.toDouble(),
            width: topBannerAd!.size.width.toDouble(),
            child: AdWidget(ad: topBannerAd!),
          ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: searchController,
            onChanged: _filterVideos,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search song name...',
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.search, color: Color(0xFFFFD700)),
              filled: true,
              fillColor: Colors.grey[900],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: filteredVideos.isEmpty
              ? const Center(child: Text('No videos found', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  itemCount: filteredVideos.length,
                  itemBuilder: (context, index) {
                    final video = filteredVideos[index];
                    final videoId = video['id']!;
                    final title = video['title']!;

                    bool showInListAd = (index > 0 && index % 3 == 0);

                    return Column(
                      children: [
                        if (showInListAd) const InListBannerAdWidget(),
                        Card(
                          color: Colors.grey[900],
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () => _playVideoWithInterstitialAd(videoId),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          'https://img.youtube.com/vi/$videoId/hqdefault.jpg',
                                          width: double.infinity,
                                          height: 200,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(
                                            height: 200,
                                            color: Colors.black,
                                            child: const Icon(Icons.play_circle_fill, size: 60, color: Color(0xFFFFD700)),
                                          ),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.play_circle_fill,
                                        size: 60,
                                        color: Color(0xFFFFD700),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.share, color: Color(0xFFFFD700)),
                                      onPressed: () {
                                        Share.share('https://youtu.be/$videoId');
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.bookmark_add, color: Color(0xFFFFD700)),
                                      onPressed: () => _saveVideoLocally(videoId, title),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
        if (isBottomAdLoaded && bottomBannerAd != null)
          SizedBox(
            height: bottomBannerAd!.size.height.toDouble(),
            width: bottomBannerAd!.size.width.toDouble(),
            child: AdWidget(ad: bottomBannerAd!),
          ),
      ],
    );
  }

  void _playVideoWithInterstitialAd(String videoId) {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _openPlayer(videoId);
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _openPlayer(videoId);
            },
          );
          ad.show();
        },
        onAdFailedToLoad: (err) {
          _openPlayer(videoId);
        },
      ),
    );
  }

  void _openPlayer(String videoId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PlayerScreen(videoId: videoId)),
    );
  }

  void _saveVideoLocally(String id, String title) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> saved = prefs.getStringList('saved_videos') ?? [];
    String videoData = json.encode({'id': id, 'title': title});

    if (!saved.contains(videoData)) {
      saved.add(videoData);
      await prefs.setStringList('saved_videos', saved);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video Saved Locally!')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video already saved.')),
        );
      }
    }
  }
}

// ------------------- IN-LIST BANNER AD -------------------
class InListBannerAdWidget extends StatefulWidget {
  const InListBannerAdWidget({super.key});

  @override
  State<InListBannerAdWidget> createState() => _InListBannerAdWidgetState();
}

class _InListBannerAdWidgetState extends State<InListBannerAdWidget> {
  BannerAd? _bannerAd;
  bool isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) setState(() => isAdLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isAdLoaded && _bannerAd != null
        ? Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            height: _bannerAd!.size.height.toDouble(),
            width: _bannerAd!.size.width.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          )
        : const SizedBox.shrink();
  }
}

// ------------------- EMBED PLAYER -------------------
class PlayerScreen extends StatefulWidget {
  final String videoId;
  const PlayerScreen({super.key, required this.videoId});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Playing DJ Track')),
      body: Center(
        child: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          progressIndicatorColor: const Color(0xFFFFD700),
          progressColors: const ProgressBarColors(
            playedColor: Color(0xFFFFD700),
            handleColor: Color(0xFFFFD700),
          ),
        ),
      ),
    );
  }
}

// ------------------- SAVED SCREEN -------------------
class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  List<Map<String, dynamic>> savedVideos = [];

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  void _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> saved = prefs.getStringList('saved_videos') ?? [];
    List<Map<String, dynamic>> temp = [];

    for (var item in saved) {
      try {
        temp.add(json.decode(item) as Map<String, dynamic>);
      } catch (e) {
        // Skip malformed items
      }
    }

    if (mounted) {
      setState(() {
        savedVideos = temp;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return savedVideos.isEmpty
        ? const Center(
            child: Text('No saved videos yet.', style: TextStyle(color: Colors.grey)),
          )
        : ListView.builder(
            itemCount: savedVideos.length,
            itemBuilder: (context, index) {
              final video = savedVideos[index];
              final videoId = video['id'];
              final title = video['title'];

              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    'https://img.youtube.com/vi/$videoId/hqdefault.jpg',
                    width: 80,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(title, style: const TextStyle(color: Colors.white)),
                trailing: const Icon(Icons.play_arrow, color: Color(0xFFFFD700)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlayerScreen(videoId: videoId),
                    ),
                  );
                },
              );
            },
          );
  }
}
