import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:movies_info/getControllers/ApiController.dart';
import 'package:movies_info/hiveModels/movie_model.dart';
import 'package:movies_info/views/DetailsPage.dart';

class FavoritesPage extends StatelessWidget {
  final apiController = Get.find<ApiController>();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'My Favorites',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
              onPressed: () {},
              icon: Icon(Icons.search, size: 26, color: Colors.white)),
          IconButton(
              onPressed: () {},
              icon: Icon(Icons.filter_list, size: 26, color: Colors.white))
        ],
      ),
      body: Obx(() {
        if (apiController.favoritesList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bookmark_outline, size: 110, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "No favorites yet",
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
                SizedBox(height: 8),
                Text(
                  "Add movies & shows to see them here",
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ],
            ),
          );
        }

        final movies = apiController.favoritesList;

        return GridView.builder(
          padding: EdgeInsets.all(12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.65,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: movies.length,
          itemBuilder: (context, index) {
            final MovieModel movie = movies[index];

            final posterUrl = movie.posterUrl.isNotEmpty
                ? movie.posterUrl
                : "https://via.placeholder.com/300x450";

            return GestureDetector(
              onTap: () async {
                // fetch full details (for runtime, genres, cast etc.)
                final details = await apiController.getMovieDetails(movie.id);
                if (details != null) {
                  Get.to(() => DetailsPage(details: details, movie: movie));
                }
              },
              onLongPress: () {
                apiController.removeFromFavorites(movie.id);
                Get.snackbar(
                  "Removed",
                  "${movie.title} removed from favorites",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.black87,
                  colorText: Colors.white,
                  margin: EdgeInsets.all(12),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    // Poster
                    Positioned.fill(
                      child: Image.network(
                        posterUrl,
                        fit: BoxFit.cover,
                      ),
                    ),

                    // Gradient overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.black87, Colors.transparent],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              movie.title,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.star,
                                    color: Colors.amber, size: 14),
                                SizedBox(width: 4),
                                Text(
                                  movie.rating,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  movie.releaseYear,
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Bookmark toggle
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Obx(() {
                         final isFav = apiController.favoritesList.any((fav) => fav.id == movie.id);
                        return GestureDetector(
                          onTap: () {
                            if (isFav) {
                              apiController.removeFromFavorites(movie.id);
                              Get.snackbar(
                                "Removed",
                                "${movie.title} removed from favorites",
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.black87,
                                colorText: Colors.white,
                                margin: EdgeInsets.all(12),
                              );
                            } else {
                              apiController.addToFavorites(movie);
                              Get.snackbar(
                                "Added",
                                "${movie.title} added to favorites",
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.black87,
                                colorText: Colors.white,
                                margin: EdgeInsets.all(12),
                              );
                            }
                          },
                          child: Icon(
                            Icons.bookmark,
                            color: isFav ? Colors.red : Colors.white,
                            size: 26,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
