class Employee {
  final int? id;
  final String name;
  final String number;
  final String email;
  final String? createdAt;

  const Employee({
    this.id,
    required this.name,
    required this.number,
    required this.email,
    this.createdAt,
  });

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      number: map['number'] as String? ?? '',
      email: map['email'] as String? ?? '',
      createdAt: map['createdAt'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'number': number,
      'email': email,
    };
  }
}
