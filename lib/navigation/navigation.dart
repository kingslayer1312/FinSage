import 'package:finsage/presentation/home_page.dart';
import 'package:finsage/presentation/investments_page.dart';
import 'package:finsage/presentation/chatbot_page.dart';
import 'package:finsage/presentation/watchlist_page.dart';
import 'package:finsage/theme/custom_theme.dart';
import 'package:flutter/material.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});
  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        backgroundColor: CustomTheme.maastrichtBlue,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: CustomTheme.gold,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home, color: CustomTheme.richBlack),
            icon: Icon(Icons.home_outlined, color: CustomTheme.neutralWhite),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.attach_money, color: CustomTheme.richBlack),
            icon: Icon(Icons.attach_money_outlined, color: CustomTheme.neutralWhite),
            label: 'Investments',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.list, color: CustomTheme.richBlack),
            icon: Icon(Icons.list_outlined, color: CustomTheme.neutralWhite),
            label: 'Watchlist',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.lightbulb, color: CustomTheme.richBlack),
            icon: Icon(Icons.lightbulb_outline, color: CustomTheme.neutralWhite),
            label: 'Home',
          ),
        ],
      ),
      body: <Widget>[
        HomePage(),
        InvestmentsPage(),
        WatchlistPage(),
        ChatBotPage()
      ][currentPageIndex],
    );
  }
}
