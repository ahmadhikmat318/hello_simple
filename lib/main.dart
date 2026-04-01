import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import 'gallery_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = await GalleryStore.create();
  runApp(HelloApp(store: store));
}

class HelloApp extends StatelessWidget {
  const HelloApp({super.key, required this.store});

  final GalleryStore store;

  static const _seed = Color(0xFF0D9488);

  @override
  Widget build(BuildContext context) {
    final baseLight = ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.light);
    final baseDark = ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.dark);

    return MaterialApp(
      title: 'hello_simple',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: baseLight,
        useMaterial3: true,
        textTheme: GoogleFonts.tajawalTextTheme(),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          backgroundColor: baseLight.surfaceContainerHighest,
          foregroundColor: baseLight.onSurface,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: baseLight.surfaceContainerLow,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: baseLight.primary,
          foregroundColor: baseLight.onPrimary,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: baseDark,
        useMaterial3: true,
        textTheme: GoogleFonts.tajawalTextTheme(ThemeData(brightness: Brightness.dark).textTheme),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          backgroundColor: baseDark.surfaceContainerHighest,
          foregroundColor: baseDark.onSurface,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: baseDark.surfaceContainerLow,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: baseDark.primary,
          foregroundColor: baseDark.onPrimary,
        ),
      ),
      themeMode: ThemeMode.system,
      home: HomePage(store: store),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.store});

  final GalleryStore store;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _reload() => setState(() {});

  Future<void> _showAddDialog() async {
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة صورة'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            hintText: 'https://...',
            border: OutlineInputBorder(),
            labelText: 'رابط الصورة',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حفظ')),
        ],
      ),
    );
    if (ok == true && mounted) {
      await widget.store.add(controller.text);
      if (mounted) {
        _reload();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت الإضافة')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final urls = widget.store.urls;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('معرض الصور'),
            flexibleSpace: FlexibleSpaceBar(
              background: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [scheme.primaryContainer, scheme.surface],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
                child: Align(
                  alignment: const Alignment(0, 0.35),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.flutter_dash, size: 40, color: scheme.primary),
                      const SizedBox(width: 12),
                      Text(
                        'Flutter + تخزين محلي',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: scheme.onPrimaryContainer,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: SliverToBoxAdapter(
              child: Text(
                'الصور تُحمَّل من الإنترنت وتُحفظ روابطها على الجهاز. اضغط مطولاً لحذف صورة.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.outline),
              ),
            ),
          ),
          if (urls.isEmpty)
            const SliverFillRemaining(
              child: Center(child: Text('لا توجد صور. أضف رابطاً من الزر +')),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final url = urls[index];
                    return _ImageTile(
                      url: url,
                      onLongPress: () async {
                        await widget.store.removeAt(index);
                        if (mounted) {
                          _reload();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تم الحذف')),
                          );
                        }
                      },
                    );
                  },
                  childCount: urls.length,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add_photo_alternate_outlined),
        label: const Text('صورة'),
      ),
    );
  }
}

class _ImageTile extends StatelessWidget {
  const _ImageTile({required this.url, required this.onLongPress});

  final String url;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onLongPress: onLongPress,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                errorWidget: (_, __, ___) => ColoredBox(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Icon(Icons.broken_image_outlined, color: Theme.of(context).colorScheme.onErrorContainer),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                url,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
