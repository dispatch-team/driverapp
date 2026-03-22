import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to Driver App',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Obx(() => Text(
                  'Counter: ${controller.count}',
                  style: Theme.of(context).textTheme.bodyLarge,
                )),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.increment,
              icon: const Icon(Icons.add),
              label: const Text('Increment'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.increment,
        backgroundColor: Theme.of(context).extension<AppColors>()!.brand,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
