/// Profile returned by sign-in and used to identify personal reservations.
class StudentAccount {
  const StudentAccount({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;

  factory StudentAccount.fromJson(Map<String, dynamic> json) => StudentAccount(
    id: json['id']?.toString() ?? '',
    firstName: json['firstName']?.toString() ?? '',
    lastName: json['lastName']?.toString() ?? '',
    email: json['email']?.toString() ?? '',
  );
}
