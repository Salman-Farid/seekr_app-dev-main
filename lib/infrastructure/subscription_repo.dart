import 'package:dio/dio.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:seekr_app/domain/subscription/i_subscription_repo.dart';
import 'package:seekr_app/domain/subscription/package_plan.dart';

class SubscriptionRepo extends ISubscriptionRepo {
  final Dio dio;
  SubscriptionRepo({required this.dio});
  @override
  Future<IList<PackagePlan>> getSubscriptionPlans() async {
    final response = await dio.get('/subscription/list');
    final plans = response.data['data'] as List;
    return IList(plans.map((e) => PackagePlan.fromMap(e)).toList());
  }

  @override
  Future<String> getHostUrl(String planId) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    Logger.i({'plan_id': planId, 'customer_id': uid});
    final response = await dio.post('/subscription/checkout',
        data: {'plan_id': planId, 'customer_id': uid});
    Logger.i(response.data);
    final url = response.data['data'] as String;
    return url;
  }
}
