import 'package:life_line/models/phone_entry.dart';

class Organization {
  final String name;
  final String type;
  final String description;
  final String initials;
  final List<PhoneEntry> phones;

  const Organization({
    required this.name,
    required this.type,
    required this.description,
    required this.initials,
    required this.phones,
  });
}
