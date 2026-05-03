import 'package:flutter_riverpod/legacy.dart';

// Provider for loading state
final sosLoadingProvider = StateProvider<bool>((ref) => true);

// Family provider to track each NGO card's expanded state independently
final ngoCardExpandedProvider = StateProvider.family<bool, String>(
  (ref, ngoId) => false,
);

// Provider for approved NGOs list
final approvedNgosProvider = StateProvider<List<Map<String, dynamic>>>(
  (ref) => [],
);
