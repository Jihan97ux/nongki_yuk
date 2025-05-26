import 'package:flutter/material.dart';
import '../widgets/home_header.dart';
import '../widgets/home_content.dart';
import '../widgets/home_footer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBEAFF),
      body: SafeArea(
        child: Column(
          children: const [
            HomeHeader(),
            Expanded(child: HomeContent()),
          ],
        ),
      ),
      bottomNavigationBar: const HomeFooter(),
    );
  }
}
