import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:seekr_app/domain/subscription/package_plan.dart';

abstract class ISubscriptionRepo {
  Future<IList<PackagePlan>> getSubscriptionPlans();
  Future<String> getHostUrl(String planId);
}
