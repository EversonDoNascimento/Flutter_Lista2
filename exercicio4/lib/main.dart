import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => FavoriteMoviesList(),
      child: MyApp(),
    ),
  );
}

class Movie {
  final String title;

  Movie(this.title);
}

class FavoriteMoviesList with ChangeNotifier {
  List<Movie> _favoriteMovies = [];
  SharedPreferences? _prefs;

  FavoriteMoviesList() {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favoriteList = _prefs?.getStringList('favorites') ?? [];
    _favoriteMovies = favoriteList.map((title) => Movie(title)).toList();
  }

  Future<void> _saveFavorites() async {
    final favoriteList = _favoriteMovies.map((movie) => movie.title).toList();
    await _prefs?.setStringList('favorites', favoriteList);
  }

  List<Movie> get favoriteMovies => _favoriteMovies;

  void addMovie(String title) {
    _favoriteMovies.add(Movie(title));
    _saveFavorites();
    notifyListeners();
  }

  void removeMovie(Movie movie) {
    _favoriteMovies.remove(movie);
    _saveFavorites();
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Lista de Filmes Favoritos'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(),
                      decoration: InputDecoration(
                        labelText: 'Novo Filme',
                      ),
                      onSubmitted: (text) {
                        if (text.isNotEmpty) {
                          Provider.of<FavoriteMoviesList>(context,
                                  listen: false)
                              .addMovie(text);
                        }
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      final textController = context.read<FavoriteMoviesList>();
                      if (textController.favoriteMovies.isNotEmpty) {
                        textController
                            .addMovie(textController.favoriteMovies.last.title);
                      }
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<FavoriteMoviesList>(
                builder: (context, moviesList, child) {
                  // Chame o método notifyListeners() aqui
                  moviesList.notifyListeners();

                  return ListView.builder(
                    itemCount: moviesList.favoriteMovies.length,
                    itemBuilder: (context, index) {
                      final movie = moviesList.favoriteMovies[index];
                      return ListTile(
                        title: Text(movie.title),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            moviesList.removeMovie(movie);
                          },
                        ),
                      );
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
