import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:movies_info/hiveModels/movie_model.dart';

class FavoritesController extends GetxController {
  
  final Box<MovieModel> _favoritesBox = Hive.box<MovieModel>('favorites');
  RxList<MovieModel> favoritesList = <MovieModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    favoritesList.value = _favoritesBox.values.toList();
  }

  void addToFavorites(MovieModel movie) {
    if (!_favoritesBox.containsKey(movie.id)) {
      _favoritesBox.put(movie.id, movie);
      favoritesList.add(movie);
    }
  }

  void removeFromFavorites(int id) {
    _favoritesBox.delete(id);
    favoritesList.removeWhere((m) => m.id == id);
  }

  bool isInFavorites(int id) {
    return _favoritesBox.containsKey(id);
  }
}
