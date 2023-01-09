import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

///**********film class -start*/

@immutable
class Film {
  final String id;
  final String title;
  final String description;
  final bool isFavorite;

  const Film({
    required this.id,
    required this.title,
    required this.description,
    required this.isFavorite,
  });

  Film copy({required bool isFavorite}) => Film(
        id: id,
        title: title,
        description: description,
        isFavorite: isFavorite,
      );
  @override
  String toString() => 'Film(id:$id, '
      'title:$title, '
      'description:$description,'
      'isFavorite:$isFavorite';

  @override
  bool operator ==(covariant Film other) =>
      id == other.id && isFavorite == other.isFavorite;

  @override
  int get hashCode => Object.hashAll([
        id,
        isFavorite,
      ]);
}

///**********film class -end */

const allFilms = [
  Film(
    id: '1',
    title: 'The Shawshank Redemption',
    description: 'Description for the Shawshank Redemption',
    isFavorite: false,
  ),
  Film(
    id: '2',
    title: 'The Shishir Redemption',
    description: 'Description for the Shishir Redemption',
    isFavorite: false,
  ),
  Film(
    id: '3',
    title: 'The Shoshur Redemption',
    description: 'Description for the Shoshur Redemption',
    isFavorite: false,
  ),
  Film(
    id: '4',
    title: 'The Godfather',
    description: 'Description for the Godfather',
    isFavorite: false,
  ),
  Film(
    id: '5',
    title: 'Theory of evolution',
    description: 'Description for the theory of evolution',
    isFavorite: false,
  ),
];

class FilmsNotifier extends StateNotifier<List<Film>> {
  FilmsNotifier() : super(allFilms);

  void update(Film film, bool isFavorite) {
    state = state
        .map((thisFilm) => thisFilm.id == film.id
            ? thisFilm.copy(isFavorite: isFavorite)
            : thisFilm)
        .toList();
  }
}

enum FavoriteStatus {
  all,
  favorite,
  notFavorite,
}

final favoriteStatusProvider = StateProvider<FavoriteStatus>((ref) {
  return FavoriteStatus.all;
});

final allFilmsProvider =
    StateNotifierProvider<FilmsNotifier, List<Film>>((ref) {
  return FilmsNotifier();
});

final favoriteFilmsProvider = Provider<Iterable<Film>>((ref) {
  return ref.watch(allFilmsProvider).where((film) => film.isFavorite);
});

final notfavoriteFilmsProvider = Provider<Iterable<Film>>((ref) {
  return ref.watch(allFilmsProvider).where((film) => !film.isFavorite);
});

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Films"),
      ),
      body: Column(children: [
        const FilterWidget(),
        Consumer(
          builder: ((context, ref, child) {
            final favoriteStatus = ref.watch(favoriteStatusProvider);
            switch (favoriteStatus) {
              case FavoriteStatus.all:
                return FilmsWidget(provider: allFilmsProvider);
              case FavoriteStatus.favorite:
                return FilmsWidget(provider: favoriteFilmsProvider);
              case FavoriteStatus.notFavorite:
                return FilmsWidget(provider: notfavoriteFilmsProvider);
            }
          }),
        ),
      ]),
    );
  }
}

class FilmsWidget extends ConsumerWidget {
  final AlwaysAliveProviderBase<Iterable<Film>> provider;
  const FilmsWidget({super.key, required this.provider});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final films = ref.watch(provider);
    return Expanded(
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: films.length,
          itemBuilder: ((context, index) {
            final film = films.elementAt(index);
            final favoriteIcon = film.isFavorite
                ? const Icon(Icons.favorite)
                : const Icon(Icons.favorite_border);
            return ListTile(
              title: Text(film.title),
              subtitle: Text(film.description),
              trailing: IconButton(
                icon: favoriteIcon,
                onPressed: () {
                  final isFavorite = !film.isFavorite;
                  ref.read(allFilmsProvider.notifier).update(
                        film,
                        isFavorite,
                      );
                },
              ),
            );
          })),
    );
  }
}

class FilterWidget extends StatelessWidget {
  const FilterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return DropdownButton(
          items: FavoriteStatus.values
              .map((fs) => DropdownMenuItem(
                    value: fs,
                    child: Text(fs.toString().split('.').last),
                  ))
              .toList(),
          value: ref.watch(favoriteStatusProvider),
          onChanged: ((fs) {
            ref.read(favoriteStatusProvider.notifier).state = fs!;
          }),
        );
      },
    );
  }
}
