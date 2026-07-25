import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_line_victim/styles/styles.dart';
import 'package:life_line_victim/providers/sos_alt_provider.dart';
import 'package:life_line_victim/utils/responsive_helper.dart';
import 'package:life_line_victim/widgets/global/internet_connection.dart';
import 'package:life_line_victim/widgets/global/ngo_chat_screen.dart';
import 'package:life_line_victim/widgets/global/page_loading.dart';
import 'package:life_line_victim/widgets/global/page_message.dart';
import 'package:life_line_victim/widgets/global/page_navigation.dart';

class SosAlternative extends ConsumerStatefulWidget {
  const SosAlternative({super.key});

  @override
  ConsumerState<SosAlternative> createState() => _SosAlternativeState();
}

class _SosAlternativeState extends ConsumerState<SosAlternative> {
  FirebaseFirestore? _ngoFirestore;

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
    super.dispose();
  }

  Future<void> _initSecondaryFirebase() async {
    // Initialize life-line-ngo Firebase
    if (mounted) {
      ref.read(loadingProvider.notifier).state = true;
    }
    try {
      FirebaseApp ngoApp;

      // NGO Firebase
      try {
        ngoApp = Firebase.app('life-line-ngo');
      } catch (_) {
        ngoApp = await Firebase.initializeApp(
          name: 'life-line-ngo',
          options: _ngoFirebaseOptions,
        );
      }

      _ngoFirestore = FirebaseFirestore.instanceFor(app: ngoApp);

      // Fetch approved NGOs once
      await _fetchApprovedNgos();
      if (mounted) {
        ref.read(loadingProvider.notifier).state = false;
      }
    } catch (e) {
      if (mounted) {
        ref.read(loadingProvider.notifier).state = false;
        pageMessage(
          'An unexpected error occurred please retry',
          context,
          AppColors.error,
        );
      }
    }
  }

  Future<void> _fetchApprovedNgos() async {
    if (_ngoFirestore == null) return;

    try {
      if (mounted) {
        ref.read(approvedNgosProvider.notifier).state = [];
      }

      // Get the data once
      final snapshot =
          await _ngoFirestore!
              .collection('ngo-info-database')
              .where('approved', isEqualTo: true)
              .get();

      final ngos =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'docId': doc.id,
              'ngoName': data['ngoName'] ?? 'Unknown NGO',
              'registrationNumber': data['registrationNumber'] ?? 'N/A',
              'selectedProgram': data['selectedProgram'] ?? 'N/A',
              'phone': data['phone'] ?? 'N/A',
              'email': data['email'] ?? 'N/A',
              'address': data['address'] ?? 'N/A',
              'geographicalCoverage': data['geographicalCoverage'] ?? 'N/A',
              'branchName': data['branchName'] ?? 'N/A',
              'approved': data['approved'] ?? false,
            };
          }).toList();

      if (mounted) {
        ref.read(approvedNgosProvider.notifier).state = ngos;
      }
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
        iconTheme: IconThemeData(
          size: ResponsiveHelper.iconSize(context),
          color: AppColors.textPrimary,
        ),
        title: Text(
          'Approved NGOs',
          style: AppText.appHeader.copyWith(
            fontSize: ResponsiveHelper.isTablet(context) ? 24 : 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: ResponsiveHelper.contentWidth(context),
            child: Consumer(
              builder: (context, ref, child) {
                return _buildBody(ref);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(WidgetRef ref) {
    final isLoading = ref.watch(loadingProvider);
    final approvedNgos = ref.watch(approvedNgosProvider);

    if (isLoading) {
      return pageLoading(context);
    }

    if (approvedNgos.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(ResponsiveHelper.isTablet(context) ? 48 : 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_outlined,
                color: AppColors.textSecondary.withOpacity(0.5),
                size: ResponsiveHelper.isTablet(context) ? 96 : 64,
              ),
              SizedBox(height: ResponsiveHelper.isTablet(context) ? 24 : 16),
              Text(
                'No NGOs available',
                style: AppText.subtitle.copyWith(
                  fontSize: ResponsiveHelper.titleFont(context),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(ResponsiveHelper.isTablet(context) ? 32 : 16),
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
    final geographicalCoverage = ngo['geographicalCoverage'] ?? '';

    return Consumer(
      builder: (context, ref, child) {
        final isExpanded = ref.watch(ngoCardExpandedProvider(ngoId));

        return Container(
          margin: EdgeInsets.only(
            bottom: ResponsiveHelper.isTablet(context) ? 24 : 16,
          ),
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
                    if (mounted) {
                      ref.read(ngoCardExpandedProvider(ngoId).notifier).state =
                          !isExpanded;
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(
                      ResponsiveHelper.isTablet(context) ? 32 : 24,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        // NGO Logo
                        _buildNgoLogo(ngoName),
                        SizedBox(
                          width: ResponsiveHelper.isTablet(context) ? 24 : 12,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ngoName,
                                style: AppText.fieldLabel.copyWith(
                                  fontSize:
                                      ResponsiveHelper.isTablet(context)
                                          ? 20
                                          : 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.darkCharcoal,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                geographicalCoverage,
                                style: AppText.small.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: ResponsiveHelper.bodyFont(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.chat_bubble_outline,
                            color: AppColors.primaryMaroon,
                            size: ResponsiveHelper.iconSize(context),
                          ),
                          onPressed: () {
                            if (mounted) {
                              pageNavigation(
                                InternetConnection(
                                  child: NgoChatScreen(
                                    ngoId: ngoId,
                                    ngoName: ngoName,
                                    isSosAlternative: true,
                                  ),
                                ),
                                context,
                              );
                            }
                          },
                        ),
                        const SizedBox(width: 4),
                        AnimatedRotation(
                          turns: isExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.textSecondary,
                            size: ResponsiveHelper.isTablet(context) ? 32 : 24,
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
                            padding: EdgeInsets.fromLTRB(
                              ResponsiveHelper.isTablet(context) ? 32 : 24,
                              0,
                              ResponsiveHelper.isTablet(context) ? 32 : 24,
                              ResponsiveHelper.isTablet(context) ? 32 : 24,
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
      padding: EdgeInsets.only(
        top: ResponsiveHelper.isTablet(context) ? 24 : 16,
      ),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.borderColor, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Contact Information'),
          SizedBox(height: ResponsiveHelper.isTablet(context) ? 16 : 12),
          _buildDetailRow('Phone', ngo['phone'], Icons.phone_outlined),
          _buildDetailRow('Email', ngo['email'], Icons.email_outlined),
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

  Widget _buildNgoLogo(String ngoName) {
    return Container(
      width: ResponsiveHelper.isTablet(context) ? 72 : 48,
      height: ResponsiveHelper.isTablet(context) ? 72 : 48,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderColor, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          'assets/offline_logos/$ngoName.webp',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppColors.primaryMaroon.withOpacity(0.1),
              child: Icon(
                Icons.business,
                color: AppColors.primaryMaroon,
                size: ResponsiveHelper.isTablet(context) ? 36 : 24,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppText.fieldLabel.copyWith(
        fontSize: ResponsiveHelper.isTablet(context) ? 18 : 14,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryMaroon,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: ResponsiveHelper.isTablet(context) ? 16 : 12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: ResponsiveHelper.isTablet(context) ? 24 : 18,
            color: AppColors.textSecondary,
          ),
          SizedBox(width: ResponsiveHelper.isTablet(context) ? 12 : 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppText.small.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: ResponsiveHelper.isTablet(context) ? 14 : 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isNotEmpty ? value : 'N/A',
                  style: AppText.small.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: ResponsiveHelper.bodyFont(context),
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
