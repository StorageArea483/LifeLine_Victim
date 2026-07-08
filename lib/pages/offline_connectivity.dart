import 'package:direct_dialer/direct_dialer.dart';
import 'package:flutter/material.dart';
import 'package:life_line_victim/models/phone_entry.dart';
import 'package:life_line_victim/models/organization.dart';
import 'package:life_line_victim/styles/styles.dart';
import 'package:life_line_victim/utils/responsive_helper.dart';
import 'package:life_line_victim/widgets/global/page_message.dart';

const List<Organization> _orgs = [
  // Rescue & Emergency
  Organization(
    name: 'Rescue 1122 KPK Abbottabad',
    type: 'Government Emergency Service',
    description:
        '24/7 emergency rescue, ambulance, and fire service across all KPK districts including Abbottabad.',
    initials: 'assets/offline_logos/Rescue 1122 KPK Abbottabad.webp',
    phones: [PhoneEntry('District Landline', '0992331564')],
  ),

  // Government Disaster Management
  Organization(
    name: 'PDMA KPK',
    type: 'Provincial Government Authority',
    description:
        'Apex disaster management body for KPK. Coordinates flood, earthquake, and relief operations.',
    initials: 'assets/offline_logos/PDMA KPK.webp',
    phones: [PhoneEntry('Main Office', '0919219635')],
  ),

  // Hospitals
  Organization(
    name: 'Ayub Teaching Hospital (ATH)',
    type: 'Government Tertiary Hospital',
    description:
        'Largest hospital in Northern Pakistan (1,500 beds). 24/7 emergency, trauma, and ICU.',
    initials: 'assets/offline_logos/Ayub Teaching Hospital (ATH).webp',
    phones: [
      PhoneEntry('Main Line', '09929311154'),
      PhoneEntry('Alt. Line', '09929311155'),
    ],
  ),
  Organization(
    name: 'Benazir Hospital (DHQ Abbottabad)',
    type: 'Government District Hospital',
    description:
        'District HQ Hospital with 24/7 emergency and OPD services for Abbottabad district.',
    initials: 'assets/offline_logos/Benazir Hospital (DHQ Abbottabad).webp',
    phones: [
      PhoneEntry('Main', '0992333739'),
      PhoneEntry('Alt. 1', '09929310198'),
      PhoneEntry('Alt. 2', '09929310199'),
    ],
  ),
  Organization(
    name: 'INOR Nuclear Medicine & Oncology',
    type: 'Specialized Government Hospital',
    description:
        'Located within Ayub Medical Complex. Advanced oncology and diagnostics for the Hazara region.',
    initials: 'assets/offline_logos/INOR Nuclear Medicine & Oncology.webp',
    phones: [
      PhoneEntry('Main', '0992383149'),
      PhoneEntry('Alt.', '0992385462'),
    ],
  ),
  // NGOs
  Organization(
    name: 'Alkhidmat Foundation',
    type: 'NGO / Humanitarian',
    description:
        'Active in disaster management, health, and clean water. Deployed in 2005 earthquake and floods.',
    initials: 'assets/offline_logos/Alkhidmat Foundation.webp',
    phones: [
      PhoneEntry('KPK Office', '0912263651'),
      PhoneEntry('KPK Office Alt.', '0912263652'),
    ],
  ),
  Organization(
    name: 'Rural Development Organization',
    type: 'Local NGO',
    description:
        'Abbottabad-based NGO providing community welfare and disaster humanitarian support.',
    initials: 'assets/offline_logos/Rural Development Organization.webp',
    phones: [PhoneEntry('Office', '03319109040')],
  ),
  Organization(
    name: 'Saibaan Development Organization',
    type: 'PCP-Certified NGO',
    description:
        'Certified relief NGO providing shelter, livelihood, and disaster response in the Hazara region.',
    initials: 'assets/offline_logos/Saibaan Development Organization.webp',
    phones: [
      PhoneEntry('Office Line 1', '0997440528'),
      PhoneEntry('Office Line 2', '0997440529'),
    ],
  ),
  Organization(
    name: 'Pak Irish Center',
    type: 'Rehabilitation NGO',
    description:
        'Abbottabad-based NGO for rehabilitation and support for disaster-affected communities.',
    initials: 'assets/offline_logos/Pak Irish Center.webp',
    phones: [PhoneEntry('Tel', '0992414465')],
  ),
];

class OfflineConnectivity extends StatelessWidget {
  const OfflineConnectivity({super.key});

  Future<void> _call(BuildContext context, String number) async {
    try {
      final dialer = await DirectDialer.instance;
      await dialer.dial(number);
    } catch (e) {
      if (context.mounted) {
        pageMessage('Failed to dial: $number', context, AppColors.error);
      }
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
          'Offline Mode',
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
            child: ListView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.horizontalPadding(context),
                vertical: ResponsiveHelper.verticalPadding(context),
              ),
              itemCount: _orgs.length,
              itemBuilder: (context, index) {
                final org = _orgs[index];
                return _buildOrganizationCard(context, org);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrganizationCard(BuildContext context, Organization org) {
    final isTablet = ResponsiveHelper.isTablet(context);

    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 24 : 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
        border: const Border(
          left: BorderSide(color: AppColors.primaryMaroon, width: 4),
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: isTablet ? 80 : 56,
                  height: isTablet ? 80 : 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryMaroon.withOpacity(0.3),
                        blurRadius: isTablet ? 12 : 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                      child: Image.asset(
                        org.initials,
                        width: isTablet ? 80 : 56,
                        height: isTablet ? 80 : 56,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: isTablet ? 20 : 12),
                // Name + Type Badge
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        org.name,
                        style: AppText.fieldLabel.copyWith(
                          fontSize: isTablet ? 22 : 15,
                        ),
                      ),
                      SizedBox(height: isTablet ? 8 : 6),
                      // Type Badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 14 : 10,
                          vertical: isTablet ? 6 : 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryMaroon.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            isTablet ? 16 : 12,
                          ),
                          border: Border.all(
                            color: AppColors.primaryMaroon.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          org.type,
                          style: AppText.small.copyWith(
                            fontSize: isTablet ? 13 : 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryMaroon,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: isTablet ? 20 : 12),

            // Description
            Text(
              org.description,
              style: AppText.small.copyWith(
                height: 1.4,
                color: AppColors.textSecondary,
                fontSize: ResponsiveHelper.bodyFont(context),
              ),
            ),

            // Divider
            Padding(
              padding: EdgeInsets.symmetric(vertical: isTablet ? 20 : 12),
              child: const Divider(
                color: AppColors.borderColor,
                thickness: 1,
                height: 1,
              ),
            ),

            // Phone Numbers Section
            ...org.phones.map((phone) => _buildPhoneRow(context, phone)),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneRow(BuildContext context, PhoneEntry phone) {
    final isTablet = ResponsiveHelper.isTablet(context);

    return Padding(
      padding: EdgeInsets.only(bottom: isTablet ? 12 : 8),
      child: Row(
        children: [
          // Phone icon
          Container(
            padding: EdgeInsets.all(isTablet ? 10 : 6),
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(isTablet ? 8 : 6),
            ),
            child: Icon(
              Icons.phone_outlined,
              size: isTablet ? 20 : 16,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(width: isTablet ? 16 : 10),
          // Label and number
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  phone.label,
                  style: AppText.small.copyWith(
                    fontSize: isTablet ? 14 : 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: isTablet ? 4 : 2),
                Text(
                  phone.number,
                  style: AppText.fieldLabel.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: isTablet ? 18 : 15,
                  ),
                ),
              ],
            ),
          ),
          // Call button
          ElevatedButton.icon(
            onPressed: () => _call(context, phone.number),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryMaroon,
              foregroundColor: AppColors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 24 : 16,
                vertical: isTablet ? 14 : 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
              ),
            ),
            icon: Icon(Icons.call, size: isTablet ? 20 : 16),
            label: Text(
              'Call',
              style: AppText.small.copyWith(
                fontSize: isTablet ? 16 : 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
