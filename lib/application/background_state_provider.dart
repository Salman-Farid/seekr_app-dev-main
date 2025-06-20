import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final appStateProvider =
    StateProvider<AppLifecycleState>((ref) => AppLifecycleState.resumed);
