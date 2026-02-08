import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> addUserDetails({
  String? firstName,
  String? lastName,
  required String emailAddress,
  String? password,
  String? phoneNumber,
}) async {
  await FirebaseFirestore.instance.collection('victim-info-database').add({
    'firstName': firstName,
    'lastName': lastName,
    'emailAddress': emailAddress,
    'password': password,
    'phoneNumber': phoneNumber,
    'approved': false,
  });
}
