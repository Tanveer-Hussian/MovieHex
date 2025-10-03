import 'package:get/get.dart';
import 'package:movies_info/views/FavoritesPage.dart';
import 'package:movies_info/views/HomePage.dart';
import 'package:movies_info/views/SearchPage.dart';
import 'package:movies_info/views/TrendMap.dart';

class NavController extends GetxController{

    var currentIndex = 0.obs;

    final pages = [
       HomePage(),
       SearchPage(),
       TrendMap(),
       FavoritesPage(),    
    ];

}
