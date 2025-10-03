import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:http/http.dart' as http;

typedef MapTapCallback = void Function(Offset position);

// custom behavior to capture tap pixel
class _CustomMapZoomPanBehavior extends MapZoomPanBehavior {
  late MapTapCallback onTap;

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerUpEvent) {
      onTap(event.localPosition);
    }
    super.handleEvent(event);
  }
}

class TrendMap extends StatefulWidget {
  @override
  State<TrendMap> createState() => _TrendMapState();
}

class _TrendMapState extends State<TrendMap> {
  late MapShapeSource _mapShapeSource;
  late _CustomMapZoomPanBehavior _zoomPanBehavior;
  late MapShapeLayerController _controller;

  // marker position (where the tooltip-like widget will be shown)
  MapLatLng? _markerPosition;

  // which shape was tapped (index into `countries`)
  int _tappedShapeIndex = -1;

  // cache top movie titles by country name
  final Map<String, String> topMoviesMap = {};

  // 50 countries you prepared (use your list)
  final List<String> countries = [
    "United States", "United Kingdom", "Canada", "Australia", "India",
    "Pakistan", "Germany", "France", "Italy", "Spain",
    "Brazil", "Mexico", "Argentina", "Chile", "Colombia",
    "Russia", "Ukraine", "Poland", "Netherlands", "Belgium",
    "Sweden", "Norway", "Denmark", "Finland", "Switzerland",
    "Austria", "Portugal", "Greece", "Turkey", "Saudi Arabia",
    "United Arab Emirates", "South Africa", "Nigeria", "Egypt", "Morocco",
    "Kenya", "Ethiopia", "Japan", "South Korea", "China",
    "Hong Kong", "Taiwan", "Thailand", "Vietnam", "Indonesia",
    "Philippines", "Malaysia", "Singapore", "New Zealand", "Bangladesh",
  ];

  final Map<String, String> countryToCode = {
    "United States": "US", "United Kingdom": "GB", "Canada": "CA", "Australia": "AU", "India": "IN",
    "Pakistan": "PK", "Germany": "DE", "France": "FR", "Italy": "IT", "Spain": "ES",
    "Brazil": "BR", "Mexico": "MX", "Argentina": "AR", "Chile": "CL", "Colombia": "CO",
    "Russia": "RU", "Ukraine": "UA", "Poland": "PL", "Netherlands": "NL", "Belgium": "BE",
    "Sweden": "SE", "Norway": "NO", "Denmark": "DK", "Finland": "FI", "Switzerland": "CH",
    "Austria": "AT", "Portugal": "PT", "Greece": "GR", "Turkey": "TR", "Saudi Arabia": "SA",
    "United Arab Emirates": "AE", "South Africa": "ZA", "Nigeria": "NG", "Egypt": "EG", "Morocco": "MA",
    "Kenya": "KE", "Ethiopia": "ET", "Japan": "JP", "South Korea": "KR", "China": "CN",
    "Hong Kong": "HK", "Taiwan": "TW", "Thailand": "TH", "Vietnam": "VN", "Indonesia": "ID",
    "Philippines": "PH", "Malaysia": "MY", "Singapore": "SG", "New Zealand": "NZ", "Bangladesh": "BD",
  };

  final Map<String, String> countryToLanguage = {
      "United States": "en",
      "United Kingdom": "en",
      "Canada": "en", // (could also be fr for Quebec)
      "Australia": "en",
      "India": "hi", // Hindi (could extend with multiple langs)
      "Pakistan": "ur", "Germany": "de",
      "France": "fr","Italy": "it",
      "Spain": "es","Brazil": "pt","Mexico": "es","Argentina": "es",
      "Chile": "es","Colombia": "es","Russia": "ru",
      "Ukraine": "uk","Poland": "pl","Netherlands": "nl",
      "Belgium": "fr", // (could also be nl for Flanders)
      "Sweden": "sv","Norway": "no","Denmark": "da","Finland": "fi",
      "Switzerland": "de", // (could also be fr/it)
      "Austria": "de","Portugal": "pt","Greece": "el",
      "Turkey": "tr","Saudi Arabia": "ar","United Arab Emirates": "ar",
      "South Africa": "en", // (multi-lang, but English dominant)
      "Nigeria": "en", // (Nollywood often in English)
      "Egypt": "ar","Morocco": "ar",
      "Kenya": "en", // (English + Swahili)
      "Ethiopia": "am","Japan": "ja","South Korea": "ko",
      "China": "zh",
      "Hong Kong": "zh",
      "Taiwan": "zh",
      "Thailand": "th",
      "Vietnam": "vi",
      "Indonesia": "id",
      "Philippines": "tl",
      "Malaysia": "ms",
      "Singapore": "en", // (multi-lingual, English main)
      "New Zealand": "en",
      "Bangladesh": "bn",
    };



  @override
  void initState() {
    super.initState();

    _controller = MapShapeLayerController();

    _zoomPanBehavior = _CustomMapZoomPanBehavior()
      ..onTap = (Offset pos) {
        // convert tapped pixel to lat/lng and store for markerBuilder
        final latlng = _controller.pixelToLatLng(pos);
        setState(() {
          _markerPosition = latlng;
        });
      };

    _mapShapeSource = MapShapeSource.asset(
      'assets/worldMap.json',
      shapeDataField: 'name',
      dataCount: countries.length,
      primaryValueMapper: (int index) => countries[index],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🌍 Explore Trending Movies'), centerTitle: true),
      body: SfMaps(
        layers: [
          MapShapeLayer(
            source: _mapShapeSource,
            controller: _controller,
            zoomPanBehavior: _zoomPanBehavior,
            color: Colors.blueGrey[400]!,
            strokeColor: Colors.white,
            strokeWidth: 0.5,
            // we will not use the built-in shape tooltip: insert a marker that acts like a tooltip
            shapeTooltipBuilder: (BuildContext context, int index) {
              // called when shape tapped — set tapped index and insert a marker slot
              _tappedShapeIndex = index;

              // clear any previous marker and insert a single one at index 0
              if (_controller.markersCount > 0) {
                _controller.clearMarkers();
              }
              // this causes markerBuilder to be called for index 0
              _controller.insertMarker(0);

              // kick off the network fetch (if needed) so marker shows loading->result
              final country = countries[index];
              final region = countryToCode[country];
              final lang = countryToLanguage[country] ?? "en";

              if (region == null) {
                setState(() => topMoviesMap[country] = 'N/A');
              } else if (!topMoviesMap.containsKey(country)) {
                // mark loading (empty string) so marker shows "Loading..."
                setState(() => topMoviesMap[country] = '');
                fetchTopMovie(region,lang).then((title) {
                  setState(() => topMoviesMap[country] = title);
                  // refresh marker widget at index 0 to show the fetched title
                  _controller.updateMarkers(<int>[0]);
                }).catchError((e) {
                  setState(() => topMoviesMap[country] = 'Error');
                  _controller.updateMarkers(<int>[0]);
                });
              } else {
                // already cached — trigger marker refresh so it shows cached value immediately
                _controller.updateMarkers(<int>[0]);
              }

              Future.delayed(const Duration(seconds: 20),(){
                  if(mounted){
                    _controller.clearMarkers();
                    setState(() {
                       _tappedShapeIndex =-1;
                       _markerPosition = null;
                    });
                  }
              });

              // return empty because we don't want the shape's default tooltip
              return const SizedBox.shrink();
            },

            // markerBuilder is called for marker indexes (we only insert one at index 0)
            markerBuilder: (BuildContext context, int markerIndex) {
              // markerIndex is the index among markers (0 ... markersCount-1)
              // our tapped country index is _tappedShapeIndex
              if (_tappedShapeIndex < 0 || _markerPosition == null) {
                // fallback: tiny invisible marker so nothing breaks
                return MapMarker(
                  latitude: 0,
                  longitude: 0,
                  child: const SizedBox.shrink(),
                );
              }

              final country = countries[_tappedShapeIndex];
              final region = countryToCode[country] ?? '';
              final title = topMoviesMap[country];

              // build the flag + title "tooltip-like" widget
              return MapMarker(
                latitude: _markerPosition!.latitude,
                longitude: _markerPosition!.longitude,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (region.isNotEmpty)
                        Image.network(
                          'https://flagsapi.com/$region/flat/24.png',
                          width: 24,
                          height: 16,
                          errorBuilder: (_, __, ___) => const Icon(Icons.flag, size: 16, color: Colors.white),
                        ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 180,
                        child: Text(
                          (title == null || title.isEmpty) ? 'Loading…' : title,
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },

            selectionSettings: const MapSelectionSettings(
              color: Colors.redAccent,
              strokeColor: Colors.black,
              strokeWidth: 1.2,
            ),


          ),
        ],
      ),
    );
  }

  
  Future<String> fetchTopMovie(String regionCode, String languageCode) async {

    try{
       final response = await http.get(Uri.parse(
         "https://api.themoviedb.org/3/discover/movie?api_key=adce8a7be36ac28fad977e0a16d42061&region=$regionCode&with_original_language=$languageCode&sort_by=popularity.desc&with_release_type=3|2&include_adult=false&page=1",
       ));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List results = data['results'] ?? [];
        if (results.isNotEmpty){
          return results[0]['title'].toString();
        }else{
          return "No movies";
        }

      }else if (response.statusCode == 429) {
        // Handle rate limit
        await Future.delayed(const Duration(seconds: 1));
        return await fetchTopMovie(regionCode,languageCode); // Retry once
      } else {
        throw Exception('Failed to load movies for $regionCode (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }


}
