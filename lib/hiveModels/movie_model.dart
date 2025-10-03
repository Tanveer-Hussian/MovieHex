import 'package:hive/hive.dart';
part 'movie_model.g.dart';

@HiveType(typeId: 0)
class MovieModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String posterUrl;

  @HiveField(3)
  final String rating;

  @HiveField(4)
  final String releaseYear;

  MovieModel({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.rating,
    required this.releaseYear,
  });

  /// ✅ Map API response to MovieModel
  factory MovieModel.fromMap(Map<String, dynamic> map) {
    return MovieModel(
      id: map['id'],
      title: map['title'] ?? "",
      posterUrl: map['poster_path'] != null
          ? "https://image.tmdb.org/t/p/w500${map['poster_path']}"
          : "",
      rating: (map['vote_average'] != null) ? (map['vote_average'] as num).toDouble().toStringAsFixed(1) : "0.0",
      releaseYear: (map['release_date'] != null && map['release_date'] != "")
          ? map['release_date'].toString().split("-")[0]
          : "Unknown",
    );
  }

  /// (Optional) Convert back to Map
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "posterUrl": posterUrl,
      "rating": rating,
      "releaseYear": releaseYear,
    };
  }
}
