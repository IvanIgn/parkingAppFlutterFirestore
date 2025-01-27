import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int selectedIndex;
  // final Function(int) onItemTapped;

  const CustomBottomNav({
    super.key,
    required this.selectedIndex,
    /*required this.onItemTapped*/
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.login),
          label: 'Inloggning',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.directions_car),
          label: 'Fordon',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_parking),
          label: 'Parkeringsplats',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'Aktiva Parkeringar',
        ),
      ],
      currentIndex: selectedIndex,
      selectedItemColor: Colors.blue,
      // onTap: onItemTapped,
    );
  }
}
