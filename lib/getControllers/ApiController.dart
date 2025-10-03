// import 'dart:async';
// import 'dart:convert';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;

// class ApiController extends GetxController{

//    RxInt popularMoviesPage = 1.obs;
//    RxInt topRatedMoviesPage = 1.obs;
//    RxInt upcomingMoviesPage = 1.obs;
//    RxInt nowPlayingMoviesPage = 1.obs;

//    RxBool isPopularLoading = false.obs;
//    RxBool isTopRatedLoading = false.obs; 
//    RxBool isUpcomingLoading = false.obs;
//    RxBool isNowPlayingLoading = false.obs;
//    RxBool isSearchMoviesLoading = false.obs;

//    RxBool hasMorePopularMovies = true.obs;
//    RxBool hasMoreTopRatedMovies = true.obs;
//    RxBool hasMoreUpcomingMovies = true.obs;
//    RxBool hasMoreNowPlayingMovies = true.obs;


//    RxList<Map<String,dynamic>> popularMoviesList = <Map<String,dynamic>>[].obs; 
//    RxList<Map<String,dynamic>> topRatedMoviesList = <Map<String,dynamic>>[].obs; 
//    RxList<Map<String,dynamic>> upcomingMoviesList = <Map<String,dynamic>>[].obs; 
//    RxList<Map<String,dynamic>> nowPlayingMoviesList = <Map<String,dynamic>>[].obs; 

//    RxList<Map<String,dynamic>> searchMoviesList = <Map<String,dynamic>>[].obs;

//     static const baseUrl = 'https://api.themoviedb.org/3';
//     static const apikey = 'adce8a7be36ac28fad977e0a16d42061';

//     @override
//   void onInit() {
//      super.onInit();
//      getPopularMovies(popularMoviesPage.value);
//      getNowPlayingMovies(nowPlayingMoviesPage.value);
//      getUpcomingMovies(upcomingMoviesPage.value);
//      getTopRatedMovies(topRatedMoviesPage.value);
//   }
  

// // Future<bool> hasNetwork() async {
// //     try {
// //      // Check connectivity_plus status
// //       var connectivityResult = await Connectivity().checkConnectivity();
// //       var connectivityStatus = [
// //        ConnectivityResult.mobile,
// //        ConnectivityResult.wifi,
// //        ConnectivityResult.ethernet,
// //      ].contains(connectivityResult);
// //
// //     if (!connectivityStatus) {
// //       print('connectivity_plus reports no connection: $connectivityResult');
// //       return false;
// //     }
// //
// //     // Verify actual connectivity with a lightweight request
// //     final result = await InternetAddress.lookup('google.com').timeout(Duration(seconds: 5), onTimeout: () {
// //       print('DNS lookup timed out');
// //       return [];
// //     });
// //     if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
// //       print('Network is reachable (DNS lookup succeeded)');
// //       return true;
// //      }
// //     print('Network is not reachable (DNS lookup failed)');
// //       return false;
// //   } catch (e) {
// //     print('Error checking network: $e');
// //     return false;
// //   }
// //  }


//   Future<Map<String, dynamic>?> getMovieDetails(int movieId) async {
//     try {
//       final url = Uri.parse(
//         "$baseUrl/movie/$movieId?api_key=$apikey&language=en-US&append_to_response=credits"
//        );

//       final response = await http.get(url).timeout(
//         const Duration(seconds: 20),
//         onTimeout: () {
//           throw TimeoutException('API request timed out');
//         },
//       );

//       if (response.statusCode == 200) {
//          final data = jsonDecode(response.body);
//          return data; 
//       } else {
//          Get.snackbar("Error", "Failed to load movie details");
//          return null;
//       }
//     } catch (e) {
//        Get.snackbar("Error", "An error occurred while fetching movie details");
//        return null;
//     } 
//   }


//   Future<void> getPopularMovies(int page) async{
//      if(isPopularLoading.value || !hasMorePopularMovies.value) return; // This prevents duplicate or unneeded api calls
//       try{
//          isPopularLoading.value = true;
//          final url =  Uri.parse("$baseUrl/movie/popular?api_key=$apikey&language=en-US&page=$page");
//          final response = await http.get(url).timeout(Duration(seconds: 20), onTimeout: (){
//             throw TimeoutException('API request timed out');
//           });

//          if(response.statusCode==200){
//              final data = jsonDecode(response.body);
//              if (page >= data['total_pages']) {
//                 hasMorePopularMovies.value = false;
//               }
//              List movies = data['results'] ?? [];
//              if(movies.isEmpty){
//                 return;
//              }

//              // Filter out duplicates by ID
//            final newMovies = movies
//               .map((e) => Map<String, dynamic>.from(e))
//                 .where((movie) => !popularMoviesList.any((existing) => existing['id'] == movie['id']))
//               .toList();

//            popularMoviesList.addAll(newMovies);
//            popularMoviesPage.value++;

//              print('After adding, new list length: ${popularMoviesList.length}');
//           }else{
//             print('Failed to load Popular Movies: Status ${response.statusCode},Response: ${response.body}');
//       // Optionally, show a snackbar or update UI to indicate failure
//             Get.snackbar('Error', 'Failed to load popular movies');
//           }
//       }catch (e){
//          print('Exception: $e');
//          Get.snackbar('Error', 'An error occured while fetching the popular movies');
//       }finally{
//          isPopularLoading.value = false;
//       }
//     }


//   Future<void> searchMovies(String query) async{
//       try{
//         isSearchMoviesLoading.value = true;
//         final response = await http.get(
//             Uri.parse(
//                '$baseUrl/search/movie?api_key=$apikey&language=en-US&query=$query&&append_to_response=credits'
//             ),
//          );
          
//         if(response.statusCode==200){
//             final data = jsonDecode(response.body.toString());
//             final List result = data['results'] ?? [];

//             searchMoviesList.assignAll(
//               result.map((e)=> Map<String,dynamic>.from(e)).toList(),
//             );

//            isSearchMoviesLoading.value = false; 
           
//         }else{
//            isSearchMoviesLoading.value=false;
//            throw Exception('No Result found!');
//         }
//       }
//       catch(e){
//          isSearchMoviesLoading.value = false;
//          Get.snackbar('error', 'An error occurred while searching movies');
//       } 
//    } 
  

//    Future<void> getTopRatedMovies(int page) async{
//        if(isTopRatedLoading.value || !hasMoreTopRatedMovies.value) return;
//        try{
//         isTopRatedLoading.value=true;
//         final url = Uri.parse("$baseUrl/movie/top_rated?api_key=$apikey&language=en-US&page=$page");
//          final response = await http.get(url).timeout(Duration(seconds: 20), onTimeout: (){
//             throw TimeoutException('API request timed out');
//           });
//         if(response.statusCode==200){
//            final data = jsonDecode(response.body.toString());
//            if (page >= data['total_pages']) {
//              hasMoreTopRatedMovies.value = false;
//            }
//            List movies = data['results'] ?? [];
//            print('Top Rated Movies - Page $page: Fetched ${movies.length} movies, Total pages: ${data['total_pages']}, Current list length: ${topRatedMoviesList.length}');
//             if(movies.isEmpty){
//                 print('No more movies to fetch on page $page');
//                return;
//              }

//          // Filter out duplicates by ID
//           final newMovies = movies
//              .map((e) => Map<String, dynamic>.from(e))
//              .where((movie) => !topRatedMoviesList.any((existing) => existing['id'] == movie['id']))
//              .toList();

//            topRatedMoviesList.addAll(newMovies);
//            topRatedMoviesPage.value++;
          
//             print('After adding, new list length: ${topRatedMoviesList.length}');
//         }
//         else{
//            print('Failed to load Top Rated Movies: Status ${response.statusCode}, Response: ${response.body}');
//       // Optionally, show a snackbar or update UI to indicate failure
//            Get.snackbar('Error', 'Failed to load Top Rated Movies');
//         }
//        }catch(e){
//          print('Exception: $e');
//          Get.snackbar('Error', 'An error occurred while fetching Top Rated Movies');
//        }finally{
//          isTopRatedLoading.value=false;
//       }  
//     }


//    Future<void> getUpcomingMovies(int page) async{
//       if(isUpcomingLoading.value || !hasMoreUpcomingMovies.value) return;
//       try{
//          isUpcomingLoading.value = true;
//          final url = Uri.parse('$baseUrl/movie/upcoming?api_key=$apikey&language=en-US&page=$page');
//          final response = await http.get(url).timeout(Duration(seconds: 20), onTimeout: (){
//             throw TimeoutException('API request timed out');
//           });
//          if(response.statusCode==200){
//             final data = jsonDecode(response.body.toString());

//             if (page >= data['total_pages']) {
//                hasMoreUpcomingMovies.value = false;
//             }

//             List movies = data['results'] ?? [];
//             print('Upcoming Movies - Page $page: Fetched ${movies.length} movies, Total pages: ${data['total_pages']}, Current list length: ${upcomingMoviesList.length}');
//             if(movies.isEmpty){
//                 print('No more movies to fetch on page $page');
//                return;
//              }
           
//           // Filter out duplicates by ID
//             final newMovies = movies
//               .map((e) => Map<String, dynamic>.from(e))
//               .where((movie) => !upcomingMoviesList.any((existing) => existing['id'] == movie['id']))
//               .toList();

//             upcomingMoviesList.addAll(newMovies);
//             upcomingMoviesPage.value++;
          
//             print('After adding, new list length: ${upcomingMoviesList.length}');
//          }else{
//            print('Failed to load Upcoming Movies: Status ${response.statusCode}, Response: ${response.body}');
//            Get.snackbar('Error', 'Failed to load Upcoming Movies');  
//          }
//       }catch(e){
//         print('Exception $e');
//         Get.snackbar('Error', 'An error occurred while fetching popular movies');
//       }finally{
//          isUpcomingLoading.value=false;
//       }
//     }


//    Future<void> getNowPlayingMovies(int page) async{
//      if(isNowPlayingLoading.value || !hasMoreNowPlayingMovies.value) return; 
//       try{ 
//          isNowPlayingLoading.value = true;
//          final url = Uri.parse('$baseUrl/movie/now_playing?api_key=$apikey&language=en-US&page=$page');
//          final response = await http.get(url).timeout(Duration(seconds: 20), onTimeout: (){
//             throw TimeoutException('API request timed out');
//           });
//          if(response.statusCode==200){
//             final data = jsonDecode(response.body.toString());
//              if (page >= data['total_pages']) {
//                 hasMoreNowPlayingMovies.value = false;
//              }
//             List movies = data['results'] ?? [];
//             print('Now Playing Movies - Page $page: Fetched ${movies.length} movies, Total pages: ${data['total_pages']}, Current list length: ${nowPlayingMoviesList.length}');
//             if(movies.isEmpty){
//                 print('No more movies to fetch on page $page');
//                return;
//              }
                       
//            // Filter out duplicates by ID
//              final newMovies = movies
//                .map((e) => Map<String, dynamic>.from(e))
//                .where((movie) => !nowPlayingMoviesList.any((existing) => existing['id'] == movie['id']))
//                .toList();
             
//              nowPlayingMoviesList.addAll(newMovies);
//              nowPlayingMoviesPage.value++;
          
//             print('After adding, new list length: ${nowPlayingMoviesList.length}');
//          }else{
//            print('Failed to load Popular Movies: Status ${response.statusCode}, Response: ${response.body}');
//            Get.snackbar('Error', 'Failed to load Now Playing movies');
//          }
//       }catch(e){
//          print('Exception $e');
//          Get.snackbar('Error', 'An error occurred while fetching Now Playing movies');
//       }finally{
//          isNowPlayingLoading.value = false;
//       }
//     }

  
//  }








import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:movies_info/hiveModels/movie_model.dart';


class ApiController extends GetxController {
  // ===== Page trackers =====
  RxInt popularMoviesPage = 1.obs;
  RxInt topRatedMoviesPage = 1.obs;
  RxInt upcomingMoviesPage = 1.obs;
  RxInt nowPlayingMoviesPage = 1.obs;

  // ===== Loading flags =====
  RxBool isPopularLoading = false.obs;
  RxBool isTopRatedLoading = false.obs;
  RxBool isUpcomingLoading = false.obs;
  RxBool isNowPlayingLoading = false.obs;
  RxBool isSearchMoviesLoading = false.obs;

  // ===== Pagination flags =====
  RxBool hasMorePopularMovies = true.obs;
  RxBool hasMoreTopRatedMovies = true.obs;
  RxBool hasMoreUpcomingMovies = true.obs;
  RxBool hasMoreNowPlayingMovies = true.obs;

  // ===== Movie Lists (Now Typed) =====
  RxList<MovieModel> popularMoviesList = <MovieModel>[].obs;
  RxList<MovieModel> topRatedMoviesList = <MovieModel>[].obs;
  RxList<MovieModel> upcomingMoviesList = <MovieModel>[].obs;
  RxList<MovieModel> nowPlayingMoviesList = <MovieModel>[].obs;
  RxList<MovieModel> searchMoviesList = <MovieModel>[].obs;

  static const baseUrl = 'https://api.themoviedb.org/3';
  static const apikey = 'adce8a7be36ac28fad977e0a16d42061';

  // ===== Hive Favorites =====
  late Box<MovieModel> _favoritesBox;
  RxList<MovieModel> favoritesList = <MovieModel>[].obs;

  @override
  void onInit() {
    super.onInit();

    // Hive favorites init
    _favoritesBox = Hive.box<MovieModel>('favorites');
    favoritesList.value = _favoritesBox.values.toList();

    // Load initial movies
    getPopularMovies(popularMoviesPage.value);
    getNowPlayingMovies(nowPlayingMoviesPage.value);
    getUpcomingMovies(upcomingMoviesPage.value);
    getTopRatedMovies(topRatedMoviesPage.value);
  }

  // ===== Favorite Methods =====
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

  // ===== API Calls =====

  Future<void> getPopularMovies(int page) async {
    if (isPopularLoading.value || !hasMorePopularMovies.value) return;
    try {
      isPopularLoading.value = true;
      final url = Uri.parse("$baseUrl/movie/popular?api_key=$apikey&language=en-US&page=$page");
      final response = await http.get(url).timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (page >= data['total_pages']) hasMorePopularMovies.value = false;

        final List results = data['results'] ?? [];
        final newMovies = results.map((json) => MovieModel.fromMap(json)).where(
          (movie) => !popularMoviesList.any((m) => m.id == movie.id),
        ).toList();

        popularMoviesList.addAll(newMovies);
        popularMoviesPage.value++;
      } else {
        Get.snackbar('Error', 'Failed to load popular movies');
      }
    } catch (e) {
      Get.snackbar('Error', 'Exception: $e');
    } finally {
      isPopularLoading.value = false;
    }
  }

  Future<void> getTopRatedMovies(int page) async {
    if (isTopRatedLoading.value || !hasMoreTopRatedMovies.value) return;
    try {
      isTopRatedLoading.value = true;
      final url = Uri.parse("$baseUrl/movie/top_rated?api_key=$apikey&language=en-US&page=$page");
      final response = await http.get(url).timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (page >= data['total_pages']) hasMoreTopRatedMovies.value = false;

        final List results = data['results'] ?? [];
        final newMovies = results.map((json) => MovieModel.fromMap(json)).where(
          (movie) => !topRatedMoviesList.any((m) => m.id == movie.id),
        ).toList();

        topRatedMoviesList.addAll(newMovies);
        topRatedMoviesPage.value++;
      } else {
        Get.snackbar('Error', 'Failed to load top rated movies');
      }
    } catch (e) {
      Get.snackbar('Error', 'Exception: $e');
    } finally {
      isTopRatedLoading.value = false;
    }
  }

  Future<void> getUpcomingMovies(int page) async {
    if (isUpcomingLoading.value || !hasMoreUpcomingMovies.value) return;
    try {
      isUpcomingLoading.value = true;
      final url = Uri.parse("$baseUrl/movie/upcoming?api_key=$apikey&language=en-US&page=$page");
      final response = await http.get(url).timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (page >= data['total_pages']) hasMoreUpcomingMovies.value = false;

        final List results = data['results'] ?? [];
        final newMovies = results.map((json) => MovieModel.fromMap(json)).where(
          (movie) => !upcomingMoviesList.any((m) => m.id == movie.id),
        ).toList();

        upcomingMoviesList.addAll(newMovies);
        upcomingMoviesPage.value++;
      } else {
        Get.snackbar('Error', 'Failed to load upcoming movies');
      }
    } catch (e) {
      Get.snackbar('Error', 'Exception: $e');
    } finally {
      isUpcomingLoading.value = false;
    }
  }

  Future<void> getNowPlayingMovies(int page) async {
    if (isNowPlayingLoading.value || !hasMoreNowPlayingMovies.value) return;
    try {
      isNowPlayingLoading.value = true;
      final url = Uri.parse("$baseUrl/movie/now_playing?api_key=$apikey&language=en-US&page=$page");
      final response = await http.get(url).timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (page >= data['total_pages']) hasMoreNowPlayingMovies.value = false;

        final List results = data['results'] ?? [];
        final newMovies = results.map((json) => MovieModel.fromMap(json)).where(
          (movie) => !nowPlayingMoviesList.any((m) => m.id == movie.id),
        ).toList();

        nowPlayingMoviesList.addAll(newMovies);
        nowPlayingMoviesPage.value++;
      } else {
        Get.snackbar('Error', 'Failed to load now playing movies');
      }
    } catch (e) {
      Get.snackbar('Error', 'Exception: $e');
    } finally {
      isNowPlayingLoading.value = false;
    }
  }

  Future<void> searchMovies(String query) async {
    try {
      isSearchMoviesLoading.value = true;
      final url = Uri.parse('$baseUrl/search/movie?api_key=$apikey&language=en-US&query=$query');
      final response = await http.get(url).timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List results = data['results'] ?? [];
        searchMoviesList.assignAll(results.map((json) => MovieModel.fromMap(json)).toList());
      } else {
        Get.snackbar('Error', 'Failed to search movies');
      }
    } catch (e) {
      Get.snackbar('Error', 'Exception: $e');
    } finally {
      isSearchMoviesLoading.value = false;
    }
  }

  Future<Map<String, dynamic>?> getMovieDetails(int movieId) async {
    try {
      final url = Uri.parse(
        "$baseUrl/movie/$movieId?api_key=$apikey&language=en-US&append_to_response=credits"
      );
      final response = await http.get(url).timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        Get.snackbar("Error", "Failed to load movie details");
        return null;
      }
    } catch (e) {
      Get.snackbar("Error", "Exception: $e");
      return null;
    }
  }
}

