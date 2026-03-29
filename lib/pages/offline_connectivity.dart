import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:life_line/models/phone_entry.dart';
import 'package:life_line/models/organization.dart';

const String kRescue = 'Rescue & Emergency Services';
const String kGov = 'Government Disaster Management';
const String kHosp = 'Hospitals & Emergency Medical Centers';
const String kNgo = 'NGOs & Humanitarian Organizations';

const List<Organization> _orgs = [
  // Rescue & Emergency
  Organization(
    category: kRescue,
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
    category: kRescue,
    name: 'Edhi Foundation — Abbottabad',
    type: 'NGO / Ambulance Service',
    description:
        "Pakistan's largest ambulance network providing 24/7 emergency transport and disaster relief.",
    initials: 'EF',
    phones: [PhoneEntry('Ambulance Hotline', '115')],
  ),

  // Government Disaster Management
  Organization(
    category: kGov,
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
    category: kHosp,
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
    category: kHosp,
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
    category: kHosp,
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
    category: kHosp,
    name: 'Bach Christian Hospital',
    type: 'Private / Mission Hospital',
    description:
        'Long-established private hospital with emergency and surgical services in Hazara.',
    initials: 'BC',
    phones: [PhoneEntry('Main', '0992370007')],
  ),

  // NGOs
  Organization(
    category: kNgo,
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
    category: kNgo,
    name: 'Rural Development Organization (RDO)',
    type: 'Local NGO',
    description:
        'Abbottabad-based NGO providing community welfare and disaster humanitarian support.',
    initials: 'RD',
    phones: [PhoneEntry('Office', '03319109040')],
  ),
  Organization(
    category: kNgo,
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
    category: kNgo,
    name: 'PIRC — Rehabilitation & Community Development',
    type: 'Rehabilitation NGO',
    description:
        'Abbottabad-based NGO for rehabilitation and support for disaster-affected communities.',
    initials: 'PI',
    phones: [PhoneEntry('Tel', '0992414465')],
  ),
];

Color _catColor(String cat) {
  switch (cat) {
    case kRescue:
      return const Color(0xFFD32F2F);
    case kGov:
      return const Color(0xFF1565C0);
    case kHosp:
      return const Color(0xFF2E7D32);
    case kNgo:
      return const Color(0xFFE65100);
    default:
      return const Color(0xFF546E7A);
  }
}

IconData _catIcon(String cat) {
  switch (cat) {
    case kRescue:
      return Icons.emergency;
    case kGov:
      return Icons.account_balance_outlined;
    case kHosp:
      return Icons.local_hospital_outlined;
    case kNgo:
      return Icons.volunteer_activism_outlined;
    default:
      return Icons.business_outlined;
  }
}

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
    // Group orgs by category
    final Map<String, List<Organization>> grouped = {};
    for (final org in _orgs) {
      grouped.putIfAbsent(org.category, () => []).add(org);
    }

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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE8E8EE), height: 1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 32),
        children: [
          for (final category in grouped.keys) ...[
            _CategoryHeader(category),
            for (final org in grouped[category]!)
              _OrgCard(org: org, onCall: (number) => _call(context, number)),
          ],
        ],
      ),
    );
  }
}

// ── Category header ───────────────────────────────────────────────────────────

class _CategoryHeader extends StatelessWidget {
  final String category;
  const _CategoryHeader(this.category);

  @override
  Widget build(BuildContext context) {
    final color = _catColor(category);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 24, 4, 8),
      child: Row(
        children: [
          Icon(_catIcon(category), color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            category.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Organization card ─────────────────────────────────────────────────────────

class _OrgCard extends StatelessWidget {
  final Organization org;
  final void Function(String) onCall;

  const _OrgCard({required this.org, required this.onCall});

  @override
  Widget build(BuildContext context) {
    final color = _catColor(org.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + name + type badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: color.withOpacity(0.12),
                // TODO: swap child for logo —
                // backgroundImage: AssetImage('assets/logos/${org.initials}.png')
                child: Text(
                  org.initials,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      org.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        org.type,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Description
          Text(
            org.description,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF5A5C72),
              height: 1.5,
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Color(0xFFF0F1F6)),
          ),

          // Phone rows
          for (final phone in org.phones)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.phone_outlined,
                    size: 14,
                    color: color.withOpacity(0.65),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: RichText(
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${phone.label}  ',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF9A9BB0),
                            ),
                          ),
                          TextSpan(
                            text: phone.number,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Call button
                  GestureDetector(
                    onTap: () => onCall(phone.number),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.call_rounded,
                            color: Colors.white,
                            size: 13,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Call',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
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
