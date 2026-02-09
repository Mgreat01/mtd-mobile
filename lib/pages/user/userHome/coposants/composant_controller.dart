import 'package:flutter_riverpod/flutter_riverpod.dart';

final navigationIndexProvider = StateProvider.autoDispose<int>((ref) => 0);
