import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:movies_info/MainScreen.dart';
import 'package:movies_info/hiveModels/movie_model.dart';
import 'package:get/get.dart';

void main() async{
     WidgetsFlutterBinding.ensureInitialized();

     await Hive.initFlutter();
     Hive.registerAdapter(MovieModelAdapter());
     await Hive.openBox<MovieModel>('favorites');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Movies Information App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark, primaryColor: Colors.green,),
      home: MainScreen(),
    );
  }
}
