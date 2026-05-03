import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_line/styles/styles.dart';
import 'package:life_line/providers/sos_alt_provider.dart';

class SosAlternative extends ConsumerStatefulWidget {
  const SosAlternative({super.key});

  @override
  ConsumerState<SosAlternative> createState() => _SosAlternativeState();
}

class _SosAlternativeState extends ConsumerState<SosAlternative> {
  FirebaseFirestore? _ngoFirestore;
  StreamSubscription? _ngoSubscription;

  // Firebase configuration for life-line-ngo
  static const FirebaseOptions _ngoFirebaseOptions = FirebaseOptions(
    apiKey: 'AIzaSyBeieryGaw4bh4dtbrI54qsIc51XkP6SoM',
    appId: '1:169949190544:web:2640453ce5dd2aa55d3b15',
    messagingSenderId: '169949190544',
    projectId: 'life-line-ngo',
    authDomain: 'life-line-ngo.firebaseapp.com',
    storageBucket: 'life-line-ngo.firebasestorage.app',
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initSecondaryFirebase();
    });
  }

  @override
  void dispose() {
    _ngoSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initSecondaryFirebase() async {
    if (mounted) {
      ref.read(sosLoadingProvider.notifier).state = true;
    }
    try {
      // Initialize life-line-ngo Firebase
      final ngoApp = await Firebase.initializeApp(
        name: 'life-line-ngo',
        options: _ngoFirebaseOptions,
      );
      _ngoFirestore = FirebaseFirestore.instanceFor(app: ngoApp);

      // Start listening to approved NGOs
      _listenToApprovedNgos();
      if (mounted) {
        ref.read(sosLoadingProvider.notifier).state = false;
      }
    } catch (e) {
      if (mounted) {
        ref.read(sosLoadingProvider.notifier).state = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An unexpected error occurred please retry'),
          ),
        );
      }
    }
  }

  void _listenToApprovedNgos() {
    if (_ngoFirestore == null) return;

    try {
      _ngoSubscription?.cancel();
      _ngoSubscription = _ngoFirestore!
          .collection('ngo-info-database')
          .where('approved', isEqualTo: true)
          .snapshots()
          .listen((snapshot) {
            if (!mounted) return;

            final ngos =
                snapshot.docs.map((doc) {
                  final data = doc.data();
                  return {
                    'docId': doc.id,
                    'ngoName': data['ngoName'] ?? 'Unknown NGO',
                    'ngoLogo': data['ngoLogo'] ?? '',
                    'directorName': data['directorName'] ?? 'N/A',
                    'projectManager': data['projectManager'] ?? 'N/A',
                    'registrationNumber': data['registrationNumber'] ?? 'N/A',
                    'selectedProgram': data['selectedProgram'] ?? 'N/A',
                    'phone': data['phone'] ?? 'N/A',
                    'email': data['email'] ?? 'N/A',
                    'address': data['address'] ?? 'N/A',
                    'geographicalCoverage':
                        data['geographicalCoverage'] ?? 'N/A',
                    'pastExperience': data['pastExperience'] ?? 'N/A',
                    'branchName': data['branchName'] ?? 'N/A',
                    'approved': data['approved'] ?? false,
                  };
                }).toList();

            if (mounted) {
              ref.read(approvedNgosProvider.notifier).state = ngos;
            }
          });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceLight,
        elevation: 0,
        title: const Text('Approved NGOs', style: AppText.appHeader),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final isLoading = ref.watch(sosLoadingProvider);
    final approvedNgos = ref.watch(approvedNgosProvider);

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryMaroon),
      );
    }

    if (approvedNgos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_outlined,
                color: AppColors.textSecondary.withOpacity(0.5),
                size: 64,
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'No NGOs available',
                style: AppText.subtitle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: approvedNgos.length,
      itemBuilder: (context, index) {
        final ngo = approvedNgos[index];
        return _buildNgoCard(ngo);
      },
    );
  }

  Widget _buildNgoCard(Map<String, dynamic> ngo) {
    final ngoName = ngo['ngoName'] ?? 'Unknown NGO';
    final ngoId = ngo['docId'];
    final branchName = ngo['branchName'] ?? '';

    return Consumer(
      builder: (context, ref, child) {
        final isExpanded = ref.watch(ngoCardExpandedProvider(ngoId));

        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primaryMaroon.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.darkCharcoal.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    ref.read(ngoCardExpandedProvider(ngoId).notifier).state =
                        !isExpanded;
                  },
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ngoName,
                                style: AppText.fieldLabel.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.darkCharcoal,
                                ),
                              ),
                              if (branchName.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  branchName,
                                  style: AppText.small.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.chat_bubble_outline,
                            color: AppColors.primaryMaroon,
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Chat feature coming soon'),
                                backgroundColor: AppColors.info,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 4),
                        AnimatedRotation(
                          turns: isExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: const Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.textSecondary,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: isExpanded ? null : 0,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isExpanded ? 1.0 : 0.0,
                  child:
                      isExpanded
                          ? Container(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.xl,
                              0,
                              AppSpacing.xl,
                              AppSpacing.xl,
                            ),
                            child: _buildExpandedDetails(ngo),
                          )
                          : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExpandedDetails(Map<String, dynamic> ngo) {
    return Container(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.borderColor, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Contact Information'),
          const SizedBox(height: AppSpacing.md),
          _buildDetailRow(
            'Director Name',
            ngo['directorName'],
            Icons.person_outline,
          ),
          _buildDetailRow(
            'Project Manager',
            ngo['projectManager'],
            Icons.manage_accounts_outlined,
          ),
          _buildDetailRow('Phone', ngo['phone'], Icons.phone_outlined),
          _buildDetailRow('Email', ngo['email'], Icons.email_outlined),

          const SizedBox(height: AppSpacing.lg),
          _buildSectionTitle('Organization Details'),
          const SizedBox(height: AppSpacing.md),
          _buildDetailRow(
            'Registration Number',
            ngo['registrationNumber'],
            Icons.badge_outlined,
          ),
          _buildDetailRow(
            'Selected Program',
            ngo['selectedProgram'],
            Icons.category_outlined,
          ),
          _buildDetailRow(
            'Address',
            ngo['address'],
            Icons.location_on_outlined,
          ),
          _buildDetailRow(
            'Geographical Coverage',
            ngo['geographicalCoverage'],
            Icons.map_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppText.fieldLabel.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryMaroon,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppText.small.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isNotEmpty ? value : 'N/A',
                  style: AppText.small.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
