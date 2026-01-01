import 'package:pawfect_vendor_app/libs.dart';

class Home extends StatelessWidget {
  Home({super.key});

  final HomeController navController = Get.put(HomeController());

  final List<Widget> _pages = [
    HomeScreen(),
    ProductScreen(),
    OrderScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() => _pages[navController.currentIndex.value]),
      bottomNavigationBar: Obx(
        () => Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            currentIndex: navController.currentIndex.value,
            onTap: navController.changeTab,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.grey[100],
            selectedItemColor: primaryColor,
            unselectedItemColor: Colors.black,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            elevation: 8,
            enableFeedback: false, // Disable haptic feedback
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.inventory_2_outlined),
                activeIcon: Icon(Icons.inventory_2),
                label: 'Products',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined),
                activeIcon: Icon(Icons.receipt_long),
                label: 'Orders',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
