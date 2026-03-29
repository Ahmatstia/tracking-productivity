import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider ini akan menyimpan angka index halaman (0, 1, 2, atau 3)
final navIndexProvider = StateProvider<int>((ref) => 0);
