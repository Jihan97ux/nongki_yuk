import 'package:flutter/material.dart';
import '../widgets/home_header.dart';
import '../widgets/home_content.dart';
import '../widgets/home_footer.dart';
import '../constants/app_constants.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: const [
            HomeHeader(),
            Expanded(child: HomeContent()),
          ],
        ),
      ),
      bottomNavigationBar: const HomeFooter(), // Updated to use improved version
    );
  }
}