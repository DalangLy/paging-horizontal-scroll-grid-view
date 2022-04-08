import 'package:best_grid_responsive/widgets/responsive_grid_view.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: 600,
            height: 400,
            child: ResponsiveGridView(),
          ),
        ),
      ),
    );
  }
}
