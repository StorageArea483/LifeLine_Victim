import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:life_line/models/phone_entry.dart';
import 'package:life_line/models/organization.dart';

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
    final uri = Uri(scheme: 'tel', path: number);
    if (!await launchUrl(uri) && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not call $number')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 20,
        title: const Text(
          'Emergency Contacts',
          style: TextStyle(
            color: Color(0xFF1A1A2E),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _orgs.length,
        itemBuilder: (context, index) {
          final org = _orgs[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),

              // Avatar
              leading: CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFE3E8FF),
                child: Text(
                  org.initials,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ),

              // Name + Description
              title: Text(
                org.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),

              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),

                  Text(
                    org.type,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    org.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),

                  const SizedBox(height: 8),

                  // Phone numbers
                  for (final phone in org.phones)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.phone, size: 14),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${phone.label}: ${phone.number}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.call, size: 18),
                            onPressed: () => _call(context, phone.number),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
