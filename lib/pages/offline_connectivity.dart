import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:life_line/models/phone_entry.dart';
import 'package:life_line/models/organization.dart';
import 'package:life_line/styles/styles.dart';

const List<Organization> _orgs = [
  // Rescue & Emergency
  Organization(
    name: 'Rescue 1122 KPK — Abbottabad',
    type: 'Government Emergency Service',
    description:
        '24/7 emergency rescue, ambulance, and fire service across all KPK districts including Abbottabad.',
    initials: 'R1',
    phones: [
      PhoneEntry('Emergency Hotline', '1122'),
      PhoneEntry('District Landline', '0992331564'),
    ],
  ),
  Organization(
    name: 'Edhi Foundation — Abbottabad',
    type: 'NGO / Ambulance Service',
    description:
        "Pakistan's largest ambulance network providing 24/7 emergency transport and disaster relief.",
    initials: 'EF',
    phones: [PhoneEntry('Ambulance Hotline', '115')],
  ),

  // Government Disaster Management
  Organization(
    name: 'PDMA KPK',
    type: 'Provincial Government Authority',
    description:
        'Apex disaster management body for KPK. Coordinates flood, earthquake, and relief operations.',
    initials: 'PD',
    phones: [
      PhoneEntry('Toll-Free Helpline', '1700'),
      PhoneEntry('Main Office', '0919219635'),
    ],
  ),

  // Hospitals
  Organization(
    name: 'Ayub Teaching Hospital (ATH)',
    type: 'Government Tertiary Hospital',
    description:
        'Largest hospital in Northern Pakistan (1,500 beds). 24/7 emergency, trauma, and ICU.',
    initials: 'AT',
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
    initials: 'BH',
    phones: [
      PhoneEntry('Main', '0992333739'),
      PhoneEntry('Alt. 1', '09929310198'),
      PhoneEntry('Alt. 2', '09929310199'),
    ],
  ),
  Organization(
    name: 'INOR — Nuclear Medicine & Oncology',
    type: 'Specialized Government Hospital',
    description:
        'Located within Ayub Medical Complex. Advanced oncology and diagnostics for the Hazara region.',
    initials: 'IN',
    phones: [
      PhoneEntry('Main', '0992383149'),
      PhoneEntry('Alt.', '0992385462'),
    ],
  ),
  Organization(
    name: 'Bach Christian Hospital',
    type: 'Private / Mission Hospital',
    description:
        'Long-established private hospital with emergency and surgical services in Hazara.',
    initials: 'BC',
    phones: [PhoneEntry('Main', '0992370007')],
  ),

  // NGOs
  Organization(
    name: 'Al-Khidmat Foundation — KPK',
    type: 'NGO / Humanitarian',
    description:
        'Active in disaster management, health, and clean water. Deployed in 2005 earthquake and floods.',
    initials: 'AK',
    phones: [
      PhoneEntry('KPK Office', '0912263651'),
      PhoneEntry('KPK Office Alt.', '0912263652'),
    ],
  ),
  Organization(
    name: 'Rural Development Organization (RDO)',
    type: 'Local NGO',
    description:
        'Abbottabad-based NGO providing community welfare and disaster humanitarian support.',
    initials: 'RD',
    phones: [PhoneEntry('Office', '03319109040')],
  ),
  Organization(
    name: 'Saibaan Development Organization',
    type: 'PCP-Certified NGO',
    description:
        'Certified relief NGO providing shelter, livelihood, and disaster response in the Hazara region.',
    initials: 'SD',
    phones: [
      PhoneEntry('Office Line 1', '0997440528'),
      PhoneEntry('Office Line 2', '0997440529'),
    ],
  ),
  Organization(
    name: 'PIRC — Rehabilitation & Community Development',
    type: 'Rehabilitation NGO',
    description:
        'Abbottabad-based NGO for rehabilitation and support for disaster-affected communities.',
    initials: 'PI',
    phones: [PhoneEntry('Tel', '0992414465')],
  ),
];

class OfflineConnectivity extends StatelessWidget {
  const OfflineConnectivity({super.key});

  Future<void> _call(BuildContext context, String number) async {
    final uri = Uri.parse('tel:$number');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not call $number'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: AppBar(
        backgroundColor: AppColors.accentRose,
        title: const Text('Offline Mode', style: AppText.appHeader),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _orgs.length,
          itemBuilder: (context, index) {
            final org = _orgs[index];
            return _buildOrganizationCard(context, org);
          },
        ),
      ),
    );
  }

  Widget _buildOrganizationCard(BuildContext context, Organization org) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryMaroon,
                        AppColors.primaryMaroon.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryMaroon.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      org.initials,
                      style: const TextStyle(
                        fontFamily: 'SFPro',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Name + Type Badge
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        org.name,
                        style: AppText.fieldLabel.copyWith(fontSize: 15),
                      ),
                      const SizedBox(height: 6),
                      // Type Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryMaroon.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primaryMaroon.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          org.type,
                          style: const TextStyle(
                            fontFamily: 'SFPro',
                            fontSize: 10,
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

            const SizedBox(height: 12),

            // Description
            Text(
              org.description,
              style: AppText.small.copyWith(
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),

            // Divider
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Phone icon
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.phone_outlined,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 10),
          // Label and number
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  phone.label,
                  style: const TextStyle(
                    fontFamily: 'SFPro',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  phone.number,
                  style: const TextStyle(
                    fontFamily: 'SFPro',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkCharcoal,
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            icon: const Icon(Icons.call, size: 16),
            label: const Text(
              'Call',
              style: TextStyle(
                fontFamily: 'SFPro',
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
