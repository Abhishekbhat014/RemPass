import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rem_pass/models/users.dart';
import 'package:rem_pass/screens/home_screen.dart';
import 'package:rem_pass/screens/item_screen.dart';
import 'package:rem_pass/screens/pass_generate.dart';
import 'package:rem_pass/screens/profile_screen.dart';

class ParentHome extends StatefulWidget {
  const ParentHome({super.key});

  @override
  State<ParentHome> createState() => _ParentHomeState();
}

class _ParentHomeState extends State<ParentHome> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  late PageController _pageController;
  String firstName = "";

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadUser();
    WidgetsBinding.instance.addObserver(this);
  }

  void _loadUser() {
    var userBox = Hive.box<User>('userBox');
    User? storedUser = userBox.get('user');

    setState(() {
      firstName = storedUser?.firstName ?? "User";
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  List<Widget> get _screens => [
    HomeScreen(firstName: firstName),
    Builder(builder: (context) => ItemScreen()),
    const PassGenerate(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final navColor = Colors.white;

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _screens,
      ),
      bottomNavigationBar: BottomAppBar(
        color: navColor,
        elevation: 4,
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: CustomNavBarWidget(
              items: _navBarsItems(),
              selectedIndex: _selectedIndex,
              onItemSelected: (index) {
                setState(() => _selectedIndex = index);
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  List<NavBarItemData> _navBarsItems() {
    return [
      NavBarItemData(
        icon: const Icon(Icons.home_rounded),
        activeColor: Colors.deepPurple,
        inactiveColor: Colors.grey,
      ),
      NavBarItemData(
        icon: const Icon(Icons.view_list_rounded),
        activeColor: Colors.deepPurple,
        inactiveColor: Colors.grey,
      ),
      NavBarItemData(
        icon: const Icon(Icons.key_rounded),
        activeColor: Colors.deepPurple,
        inactiveColor: Colors.grey,
      ),
      NavBarItemData(
        icon: const Icon(Icons.account_circle_rounded),
        activeColor: Colors.deepPurple,
        inactiveColor: Colors.grey,
      ),
    ];
  }
}

class CustomNavBarWidget extends StatelessWidget {
  final List<NavBarItemData> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const CustomNavBarWidget({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children:
            items.map((item) {
              int index = items.indexOf(item);
              bool isSelected = selectedIndex == index;

              return GestureDetector(
                onTap: () => onItemSelected(index),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconTheme(
                      data: IconThemeData(
                        color:
                            isSelected ? item.activeColor : item.inactiveColor,
                        size: 30,
                      ),
                      child: item.icon,
                    ),
                    if (item.title != null)
                      Text(
                        item.title!,
                        style: TextStyle(
                          color:
                              isSelected
                                  ? item.activeColor
                                  : item.inactiveColor,
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }
}

class NavBarItemData {
  final Icon icon;
  final String? title;
  final Color activeColor;
  final Color inactiveColor;

  NavBarItemData({
    required this.icon,
    this.title,
    required this.activeColor,
    required this.inactiveColor,
  });
}
