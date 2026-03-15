enum UserRole   { farmer, admin }
enum UserStatus { pending, approved, rejected }

class AppUser {
  final String     id;
  final String     name;
  final String     phone;
  final String     district;
  final String     village;
  final UserRole   role;
  final UserStatus status;
  final DateTime   createdAt;
  final String?    token;

  AppUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.district,
    required this.village,
    required this.role,
    required this.status,
    required this.createdAt,
    this.token,
  });

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
    id:        j['id'].toString(),
    name:      j['name']     ?? '',
    phone:     j['phone']    ?? '',
    district:  j['district'] ?? '',
    village:   j['village']  ?? '',
    role:      j['role'] == 'admin' ? UserRole.admin : UserRole.farmer,
    status:    _parseStatus(j['status']),
    createdAt: DateTime.tryParse(j['created_at'] ?? '') ?? DateTime.now(),
    token:     j['token'],
  );

  static UserStatus _parseStatus(String? s) {
    switch (s) {
      case 'approved': return UserStatus.approved;
      case 'rejected': return UserStatus.rejected;
      default:         return UserStatus.pending;
    }
  }

  bool get isAdmin    => role == UserRole.admin;
  bool get isApproved => status == UserStatus.approved;
}