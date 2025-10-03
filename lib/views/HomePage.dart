import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:iconsax/iconsax.dart';
import 'package:movies_info/getControllers/ApiController.dart';
import 'package:movies_info/hiveModels/movie_model.dart';
import 'package:movies_info/views/DetailsPage.dart';
import 'package:get/get.dart';
import 'package:movies_info/views/SearchPage.dart';

enum MovieCategory {
  popular,
  topRated,
  upcoming,
  nowPlaying,
}

class HomePage extends StatelessWidget {
  final apiController = Get.put(ApiController());

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          '🎬 MovieHex',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Iconsax.search_normal_1, color: Colors.white),
            onPressed: () {
              Get.to(() => SearchPage());
            },
          ),
          SizedBox(width: screenWidth * 0.05),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- TRENDING MOVIES ---
            Text(
              'Trending Movies',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
            SizedBox(height: screenHeight * 0.02),

            SizedBox(
              height: screenHeight * 0.28,
              child: MoviesListClass(
                category: MovieCategory.popular,
                moviesList: apiController.popularMoviesList,
                isLoading: apiController.isPopularLoading,
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                wantedHeight: screenHeight * 0.25,
                wantedWidth: screenWidth * 0.47,
                axis: Axis.horizontal,
              ),
            ),
            SizedBox(height: screenHeight * 0.05, width: screenWidth),

            // --- TAB BAR ---
            Expanded(
              child: DefaultTabController(
                length: 4,
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TabBar(
                        isScrollable: true,
                        labelPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.grey,
                        labelStyle: TextStyle(fontWeight: FontWeight.w600),
                        tabs: const [
                          Tab(text: 'Now playing'),
                          Tab(text: 'Upcoming'),
                          Tab(text: 'Top rated'),
                          Tab(text: 'Popular'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          MoviesListClass(
                              category: MovieCategory.nowPlaying,
                              moviesList: apiController.nowPlayingMoviesList,
                              isLoading: apiController.isNowPlayingLoading,
                              screenWidth: screenWidth,
                              screenHeight: screenHeight,
                              wantedHeight: screenHeight * 0.17,
                              wantedWidth: screenWidth * 0.35,
                              axis: Axis.vertical),
                          MoviesListClass(
                              category: MovieCategory.upcoming,
                              moviesList: apiController.upcomingMoviesList,
                              isLoading: apiController.isUpcomingLoading,
                              screenWidth: screenWidth,
                              screenHeight: screenHeight,
                              wantedHeight: screenHeight * 0.17,
                              wantedWidth: screenWidth * 0.35,
                              axis: Axis.vertical),
                          MoviesListClass(
                              category: MovieCategory.topRated,
                              moviesList: apiController.topRatedMoviesList,
                              isLoading: apiController.isTopRatedLoading,
                              screenWidth: screenWidth,
                              screenHeight: screenHeight,
                              wantedHeight: screenHeight * 0.17,
                              wantedWidth: screenWidth * 0.35,
                              axis: Axis.vertical),
                          MoviesListClass(
                              category: MovieCategory.popular,
                              moviesList: apiController.popularMoviesList,
                              isLoading: apiController.isPopularLoading,
                              screenWidth: screenWidth,
                              screenHeight: screenHeight,
                              wantedHeight: screenHeight * 0.17,
                              wantedWidth: screenWidth * 0.35,
                              axis: Axis.vertical),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================
// MoviesListClass
// ===========================
class MoviesListClass extends StatefulWidget {
  final MovieCategory category;
  final RxList<MovieModel> moviesList; 
  final RxBool isLoading;
  final double screenWidth;
  final double screenHeight;
  final double wantedHeight;
  final double wantedWidth;
  final Axis axis;

  MoviesListClass({
    Key? key,
    required this.category,
    required this.moviesList,
    required this.isLoading,
    required this.screenWidth,
    required this.screenHeight,
    required this.wantedHeight,
    required this.wantedWidth,
    required this.axis,
  }) : super(key: key);

  @override
  State<MoviesListClass> createState() => _MoviesListClassState();
}

class _MoviesListClassState extends State<MoviesListClass> {
  
  final apiController = Get.find<ApiController>();
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        switch (widget.category) {
          case MovieCategory.nowPlaying:
            apiController.getNowPlayingMovies(
                apiController.nowPlayingMoviesPage.value);
            break;
          case MovieCategory.upcoming:
            apiController.getUpcomingMovies(
                apiController.upcomingMoviesPage.value);
            break;
          case MovieCategory.topRated:
            apiController.getTopRatedMovies(
                apiController.topRatedMoviesPage.value);
            break;
          case MovieCategory.popular:
            apiController
                .getPopularMovies(apiController.popularMoviesPage.value);
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (widget.moviesList.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      } else {
        Widget movieListItemBuilder(BuildContext context, int index) {
          final MovieModel movie = widget.moviesList[index]; 

          return Padding(
            padding: EdgeInsets.only(right: widget.wantedWidth * 0.1),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    final details = await apiController.getMovieDetails(movie.id);
                    if (details != null) {
                      Get.to(() => DetailsPage(details: details, movie: movie));
                    }
                  },
                  child: Container(
                    width: widget.wantedWidth,
                    height: widget.wantedHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        movie.posterUrl.isNotEmpty
                            ? movie.posterUrl
                            : "https://via.placeholder.com/200x300",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: widget.screenHeight * 0.005),
                Flexible(
                  child: SizedBox(
                    height: widget.screenHeight * 0.05,
                    width: widget.screenWidth * 0.35,
                    child: Text(
                      movie.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold),
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      textWidthBasis: TextWidthBasis.parent,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (widget.axis == Axis.vertical) {
          return Padding(
            padding: EdgeInsets.only(top: widget.screenHeight * 0.02),
            child: GridView.builder(
              controller: _scrollController,
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.82,
                crossAxisSpacing: widget.screenWidth * 0.015,
                mainAxisSpacing: widget.screenHeight * 0.005,
              ),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: widget.moviesList.length + 1,
              itemBuilder: (context, index) {
                if (index < widget.moviesList.length) {
                  return movieListItemBuilder(context, index);
                } else {
                  return Obx(() {
                    if (widget.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    } else {
                      return SizedBox(height: widget.screenHeight * 0.2);
                    }
                  });
                }
              },
            ),
          );
        } else {
          return ListView.builder(
            controller: _scrollController,
            scrollDirection: widget.axis,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: widget.moviesList.length + 1,
            itemBuilder: (context, index) {
              if (index < widget.moviesList.length) {
                return movieListItemBuilder(context, index);
              } else {
                return Obx(() {
                  if (widget.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    return SizedBox(height: widget.screenHeight * 0.2);
                  }
                });
              }
            },
          );
        }
      }
    });
  }
}
