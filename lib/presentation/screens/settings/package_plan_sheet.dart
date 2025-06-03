import 'package:carousel_slider/carousel_slider.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/application/subscription_provider.dart';
import 'package:seekr_app/presentation/screens/settings/plan_card.dart';

class ModalPage<T> extends Page<T> {
  const ModalPage({super.key, required this.child});

  final Widget child;

  @override
  Route<T> createRoute(BuildContext context) => ModalBottomSheetRoute<T>(
        settings: this,
        // backgroundColor: const Color.fromRGBO(17, 56, 75, 1),
        builder: (context) => child,
        isScrollControlled: true,
      );
}

class PackagePlansSheet extends HookConsumerWidget {
  static const String routeName = 'package-plans';
  static const String routePath = '/package-plans';
  const PackagePlansSheet({
    super.key,
  });

  @override
  Widget build(BuildContext context, ref) {
    final plans = ref.watch(subscriptionPlansProvider);

    final currentIndex = useState(0);
    return Container(
      margin: MediaQuery.of(context).viewInsets,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: SizedBox(
        width: double.infinity,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          children: [
            Center(
              child: Image.asset(
                'assets/icons/seekrLogo.png',
                height: 50,
              ),
            ),
            const SizedBox(height: 20),
            plans.when(
                data: (data) => CarouselSlider(
                      items: data
                          .mapIndexed((i, p) => PlanCard(
                                plan: p,
                                currentFocus: currentIndex.value == i,
                              ))
                          .toList(),
                      options: CarouselOptions(
                        viewportFraction: 0.3,
                        autoPlayAnimationDuration: const Duration(seconds: 2),
                        autoPlayInterval: const Duration(seconds: 10),
                        aspectRatio: 16 / 10,
                        height: MediaQuery.of(context).size.width *
                            0.35, // Customize the height of the carousel
                        autoPlay: true, // Enable auto-play
                        enlargeCenterPage:
                            true, // Increase the size of the center item
                        enableInfiniteScroll: true, // Enable infinite scroll
                        onPageChanged: (index, reason) =>
                            currentIndex.value = index,
                      ),
                    ),
                error: (e, s) => Center(
                      child: Text('Error: $e',
                          style: const TextStyle(color: Colors.red)),
                    ),
                loading: () => const SizedBox.shrink()),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white10,
                  border: Border.all(color: Colors.white10, width: 2)),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.blue,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text('Real-time Scene Recognition')
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.blue,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text('Native Language Support')
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.blue,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text('Real life experience')
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.blue,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text('24/7 support')
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
