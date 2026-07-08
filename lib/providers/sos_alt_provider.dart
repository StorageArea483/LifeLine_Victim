import 'package:flutter_riverpod/legacy.dart';

// Provider for loading state
final loadingProvider = StateProvider.autoDispose<bool>((ref) => true);

// Family provider to track each NGO card's expanded state independently
final ngoCardExpandedProvider = StateProvider.family.autoDispose<bool, String>(
  (ref, ngoId) => false,
);

// Provider for approved NGOs list
final approvedNgosProvider =
    StateProvider.autoDispose<List<Map<String, dynamic>>>((ref) => []);

// Family provider to track each NGO's alert state independently
final alertNgoProvider = StateProvider.family.autoDispose<bool, String>(
  (ref, ngoId) => false,
);
