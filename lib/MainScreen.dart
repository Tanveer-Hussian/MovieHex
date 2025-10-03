import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:movies_info/getControllers/NavController.dart';

class MainScreen extends StatelessWidget{

   final controller = Get.put(NavController());

  @override
  Widget build(BuildContext context) {
     return Scaffold(
       body: Obx(()=>
          controller.pages[controller.currentIndex.value]
        ),
       bottomNavigationBar: Obx(()=>
          CurvedNavigationBar(
            backgroundColor: Colors.black,
            color: Colors.grey[900]!,
            buttonBackgroundColor: Colors.redAccent,
            height: 60,
            index: controller.currentIndex.value,
            animationDuration: Duration(milliseconds: 500),
            items: const[
                Icon(Icons.home, size: 30, color: Colors.white,),
                Icon(Icons.search, size: 30, color: Colors.white,),
                Icon(Icons.map, size: 30, color: Colors.white),
                Icon(Icons.bookmark, size: 30, color: Colors.white,),
             ],
            onTap: (index){
              controller.currentIndex.value = index;
            }, 
          )
       ),  
      
     );
  }
}
