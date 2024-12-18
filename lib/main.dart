import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OMDb API Demo',
      debugShowCheckedModeBanner: false,
      home: MovieListScreen(),
    );
  }
}

class MovieListScreen extends StatefulWidget {
  @override
  _MovieListScreenState createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  TextEditingController _searchController = TextEditingController();
  List<Movie> _movies = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OMDb Movie Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(labelText: 'Search Movies'),
              onSubmitted: (value) {
                _searchMovies(value);
              },
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: _movies.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_movies[index].title),
                    subtitle: Text(_movies[index].year),
                    leading: Image.network(_movies[index].Poster),
                    trailing: Text(_movies[index].Type),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MovieDetailScreen(
                            movieId: _movies[index].imdbID,
                            movieTitle: _movies[index].title,
                          ),
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

  Future<void> _searchMovies(String query) async {
    const apiKey = 'ca1ad2d8';
    final apiUrl = 'http://www.omdbapi.com/?apikey=$apiKey&s=$query';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> movies = data['Search'];

      setState(() {
        _movies = movies.map((movie) => Movie.fromJson(movie)).toList();
      });
    } else {
      throw Exception('Failed to load movies');
    }
  }
}

class Movie {
  final String title;
  final String year;
  final String Type;
  final String Poster;
  final String imdbID;

  Movie({
    required this.title,
    required this.year,
    required this.Type,
    required this.Poster,
    required this.imdbID,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['Title'],
      year: json['Year'],
      Type: json['Type'],
      Poster: json['Poster'],
      imdbID: json['imdbID'],
    );
  }
}

class MovieDetailScreen extends StatefulWidget {
  final String movieId;
  final String movieTitle;

  MovieDetailScreen({required this.movieId, required this.movieTitle});

  @override
  _MovieDetailScreenState createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  Map<String, dynamic>? _movieDetails;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMovieDetails();
  }

  Future<void> _fetchMovieDetails() async {
    const apiKey = 'ca1ad2d8';
    final apiUrl = 'http://www.omdbapi.com/?apikey=$apiKey&i=${widget.movieId}';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      setState(() {
        _movieDetails = json.decode(response.body);
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movieTitle),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _movieDetails == null
              ? Center(child: Text('Erreur de chargement'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Image.network(
                          _movieDetails!['Poster'],
                          height: 300,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.broken_image, size: 100);
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: Text(
                          _movieDetails!['Title'],
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Center(
                        child: Text(
                          'Année de sortie: ${_movieDetails!['Year']}',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      SizedBox(height: 10),
                      Center(
                        child: Text(
                          'Réalisateur: ${_movieDetails!['Director']}',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      SizedBox(height: 10),
                      Center(
                        child: Text(
                          'Genre: ${_movieDetails!['Genre']}',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      SizedBox(height: 30),
                      Text(
                        'Résumé: ${_movieDetails!['Plot']}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
    );
  }
}
