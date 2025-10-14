// lib/features/plans/data/datasources/plan_local_data_source.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/plan_model.dart';
import '../../../../core/errors/exceptions.dart';

abstract class PlanLocalDataSource {
  Future<List<PlanModel>> getCachedPlans();
  Future<void> cachePlans(List<PlanModel> plans);
  Future<PlanModel> getCachedPlan(int id);  // AGREGADO
  Future<void> cachePlan(PlanModel plan);   // AGREGADO
}

class PlanLocalDataSourceImpl implements PlanLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String CACHED_PLANS = 'CACHED_PLANS';
  static const String CACHED_PLAN_PREFIX = 'CACHED_PLAN_';  // AGREGADO

  PlanLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<PlanModel>> getCachedPlans() async {
    final jsonString = sharedPreferences.getString(CACHED_PLANS);
    if (jsonString != null) {
      final jsonList = json.decode(jsonString) as List;
      return jsonList.map((json) => PlanModel.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw CacheException();
    }
  }

  @override
  Future<void> cachePlans(List<PlanModel> plans) async {
    final jsonString = json.encode(plans.map((plan) => plan.toJson()).toList());
    await sharedPreferences.setString(CACHED_PLANS, jsonString);
  }

  @override
  Future<PlanModel> getCachedPlan(int id) async {
    final jsonString = sharedPreferences.getString('$CACHED_PLAN_PREFIX$id');
    if (jsonString != null) {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return PlanModel.fromJson(json);
    } else {
      throw CacheException();
    }
  }

  @override
  Future<void> cachePlan(PlanModel plan) async {
    final jsonString = json.encode(plan.toJson());
    await sharedPreferences.setString('$CACHED_PLAN_PREFIX${plan.id}', jsonString);
  }
}