import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/application/subscription_provider.dart';
import 'package:seekr_app/domain/subscription/package_plan.dart';
import 'package:url_launcher/url_launcher.dart';

class PlanCard extends ConsumerWidget {
  final PackagePlan plan;
  final bool currentFocus;

  const PlanCard({
    super.key,
    required this.plan,
    required this.currentFocus,
  });

  @override
  Widget build(BuildContext context, ref) {
    return AspectRatio(
      aspectRatio: 16 / 10,
      child: InkWell(
        onTap: () async {
          final urlStrng =
              await ref.read(subscriptionRepoProvider).getHostUrl(plan.id);
          final url = Uri.parse(urlStrng);

          await launchUrl(url);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
              border: Border.all(
                  color: currentFocus
                      ? Colors.blue
                      : Colors.blue.withValues(alpha: 0.2),
                  width: 2),
              borderRadius: BorderRadius.circular(10),
              color: Colors.blue.withValues(alpha: 0.1)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Center(
                child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                        text: "${plan.period}",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color:
                                currentFocus ? Colors.black : Colors.black45),
                        children: [
                          TextSpan(
                              text: plan.periodUnit,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                      color: currentFocus
                                          ? Colors.black
                                          : Colors.black45))
                        ])),
              ),
              RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                      text: '${plan.price} ',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: currentFocus ? Colors.black : Colors.black38),
                      children: [
                        TextSpan(
                          text: plan.currency,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.black),
                        )
                      ])),

              const SizedBox(
                height: 5,
              ),
              Flexible(
                child: Text(
                  plan.name,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: currentFocus ? Colors.black : Colors.black38,
                      ),
                ),
              ),
              // Row(
              //   children: [
              //     Text(
              //       plan.title,
              //       style: context.textTheme.headlineSmall
              //           ?.copyWith(color: Colors.white),
              //     ),
              //   ],
              // )
            ],
          ),
        ),
      ),
    );
  }
}
