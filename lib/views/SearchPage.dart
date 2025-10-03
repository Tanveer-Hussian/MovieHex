import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:movies_info/getControllers/ApiController.dart';
import 'package:movies_info/hiveModels/movie_model.dart';
import 'package:movies_info/views/DetailsPage.dart';
import 'package:shimmer/shimmer.dart';

class SearchPage extends StatelessWidget {
  final apiController = Get.find<ApiController>();
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: TextField(
          controller: searchController,
          autofocus: true,
          style: TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: "Search movies, shows...",
            hintStyle: TextStyle(color: Colors.white54, fontSize: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white70),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white70),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white70, width: 2),
            ),
            suffixIcon: IconButton(
              icon: Icon(Icons.clear, color: Colors.white70),
              onPressed: () {
                searchController.clear();
                apiController.searchMoviesList.clear();
              },
            ),
          ),
          onChanged: (query) {
            if (query.trim().isNotEmpty) {
              apiController.searchMovies(query);
            } else {
              apiController.searchMoviesList.clear();
            }
          },
        ),
      ),

      body: Padding(
        padding: EdgeInsets.all(8),
        child: Obx(() {
          if (apiController.isSearchMoviesLoading.value) {
            // 🔹 SHIMMER PLACEHOLDER
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 4 / 6,
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                return Shimmer.fromColors(
                  baseColor: Colors.grey[800]!,
                  highlightColor: Colors.grey[600]!,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
            );
          }

          if (apiController.searchMoviesList.isEmpty) {
            // 🔹 EMPTY STATE
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 100, color: Colors.white24),
                  SizedBox(height: 16),
                  Text(
                    "Search for your favorite movies & shows",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // 🔹 RESULTS GRID
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 4 / 6,
            ),
            itemCount: apiController.searchMoviesList.length,
            itemBuilder: (context, index) {
              final MovieModel movie = apiController.searchMoviesList[index];

              return GestureDetector(
                onTap: () async {
                  final details = await apiController.getMovieDetails(movie.id);
                  if (details != null) {
                    Get.to(() => DetailsPage(details: details, movie: movie));
                  }
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    children: [
                      // Poster
                      Positioned.fill(
                        child: movie.posterUrl.isNotEmpty
                            ? Image.network(
                                movie.posterUrl,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: Colors.grey[800],
                                child: Icon(Icons.movie,
                                    color: Colors.white70, size: 40),
                              ),
                      ),

                      // Gradient Overlay
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black87,
                                Colors.transparent,
                              ],
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
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(Icons.star,
                                      color: Colors.amber, size: 12),
                                  SizedBox(width: 2),
                                  Text(
                                    movie.rating,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 11),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
