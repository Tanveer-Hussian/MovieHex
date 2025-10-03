import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movies_info/getControllers/ApiController.dart';
import 'package:movies_info/hiveModels/movie_model.dart';
import 'package:movies_info/widgets/FullImageClass.dart';

class DetailsPage extends StatelessWidget {

  final Map<String, dynamic> details; // full API details response
  final MovieModel movie;             // strongly typed MovieModel
  final apiController = Get.find<ApiController>();

  DetailsPage({
    required this.details,
    required this.movie,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    const String backDropBaseUrl = "https://image.tmdb.org/t/p/w500";
    const String fallBackUrl = 'https://via.placeholder.com/500x300';

    // Use typed model values
    String title = movie.title;
    String posterPath = movie.posterUrl.isNotEmpty ? movie.posterUrl : fallBackUrl;
    String backDropImagePath =
        (details['backdrop_path'] != null && details['backdrop_path'].toString().isNotEmpty)
            ? "$backDropBaseUrl${details['backdrop_path']}"
            : fallBackUrl;
    String releaseDate = details['release_date']?.toString() ?? 'TBA';
    String movieDuration = (details['runtime'] != null && details['runtime'] > 0)
        ? "${details['runtime']} minutes"
        : 'TBA';
    String movieRating = movie.rating;
    String overView = (details['overview'] != null && details['overview'].toString().isNotEmpty)
        ? details['overview']
        : '---';
    String movieGenre = 'TBA';

    if (details['genres'] != null && (details['genres'] as List).isNotEmpty) {
      try {
        movieGenre =
            (details['genres'] as List).map((g) => g['name'].toString()).join(', ');
      } catch (e) {
        movieGenre = 'TBA';
      }
    }

    List cast = details['credits']?['cast'] ?? [];
    List crew = details['credits']?['crew'] ?? [];

    return Scaffold(
      backgroundColor: Colors.grey[800],
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.035),

            // Backdrop
            Stack(children: [
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.to(() => FullImageClass(imagePath: backDropImagePath));
                    },
                    child: Image.network(
                      backDropImagePath,
                      fit: BoxFit.cover,
                      height: screenHeight * 0.32,
                      width: double.infinity,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.06),
                  Row(
                    children: [
                      SizedBox(width: screenWidth * 0.4),
                      Flexible(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          softWrap: true,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Poster
              Positioned(
                bottom: 2,
                left: 20,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: GestureDetector(
                    onTap: () => Get.to(() => FullImageClass(imagePath: posterPath)),
                    child: Hero(
                      tag: posterPath,
                      child: Image.network(
                        posterPath,
                        height: 135,
                        width: 108,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),

              // Rating
              Positioned(
                bottom: 105,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  width: screenWidth * 0.19,
                  height: screenHeight * 0.038,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.amber[700],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star_border, color: Colors.white, size: 25),
                      SizedBox(width: 2),
                      Text(
                        movieRating,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),

              // Favorite button
              Positioned(
                top: 16,
                right: 10,
                child: Obx(() {
                    final isFavorite = apiController.favoritesList.any((fav) => fav.id == movie.id);
                  return IconButton(
                    onPressed: () {
                      if (isFavorite) {
                        apiController.removeFromFavorites(movie.id);
                      } else {
                        apiController.addToFavorites(movie);
                      }
                    },
                    icon: Icon(Icons.favorite,
                        color: isFavorite ? Colors.red : Colors.white),
                  );
                }),
              ),

              // Back button
              Positioned(
                top: 15,
                left: 10,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
                ),
              ),
            ]),

            SizedBox(height: screenHeight * 0.05),

            // ==== MOVIE INFO SECTION ====
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Release Year
                  Row(
                    children: [
                      Icon(Icons.calendar_month,
                          color: Colors.white70, size: 20),
                      SizedBox(width: 6),
                      Text(
                        movie.releaseYear,
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      SizedBox(width: 2),
                      Text('|',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 19)),
                    ],
                  ),
                  SizedBox(width: 4),

                  // Duration
                  Row(
                    children: [
                      Icon(Icons.timer, color: Colors.white70, size: 20),
                      SizedBox(width: 2),
                      Text(movieDuration,
                          style: TextStyle(color: Colors.white, fontSize: 14)),
                      SizedBox(width: 2),
                      Text('|',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 19)),
                    ],
                  ),
                  SizedBox(width: 4),

                  // Genre
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.movie, color: Colors.white70, size: 20),
                        SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            movieGenre,
                            style: TextStyle(
                                color: Colors.white, fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ==== OVERVIEW SECTION ====
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Overview",
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                  SizedBox(height: 6),
                  Text(overView,
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          height: 1.4)),
                ],
              ),
            ),

            // ==== CAST SECTION ====
            buildPeopleSection("Cast", cast, screenWidth, screenHeight),

            // ==== CREW SECTION ====
            buildPeopleSection("Crew", crew, screenWidth, screenHeight),
          ],
        ),
      ),
    );
  }

  Widget buildPeopleSection(
      String title, List list, double screenWidth, double screenHeight) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.poppins(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          SizedBox(height: 8),
          SizedBox(
            height: screenHeight * 0.26,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: list.length,
              itemBuilder: (context, index) {
                final profilePath = list[index]['profile_path'];
                final imageUrl = profilePath != null
                    ? "https://image.tmdb.org/t/p/w200$profilePath"
                    : "https://via.placeholder.com/150";

                return Container(
                  width: screenWidth * 0.36,
                  margin: EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.network(
                          imageUrl,
                          height: screenHeight * 0.18,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Column(
                          children: [
                            Text(
                              list[index]['name'] ?? "N/A",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              list[index]['character'] ??
                                  list[index]['job'] ??
                                  "",
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
