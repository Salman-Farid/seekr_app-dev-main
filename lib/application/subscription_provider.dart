import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/application/dio_provider.dart';
import 'package:seekr_app/domain/subscription/i_subscription_repo.dart';
import 'package:seekr_app/domain/subscription/package_plan.dart';
import 'package:seekr_app/infrastructure/subscription_repo.dart';

final subscriptionRepoProvider = Provider<ISubscriptionRepo>((ref) {
  return SubscriptionRepo(dio: ref.watch(dioProvider));
});

final subscriptionPlansProvider =
    FutureProvider<IList<PackagePlan>>((ref) async {
  return ref.read(subscriptionRepoProvider).getSubscriptionPlans();
});
