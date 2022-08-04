class UserDto {
  const UserDto({
    required this.uuid,
    required this.first_name,
    required this.last_name,
    required this.email,
    required this.token,
  });

  final String uuid;
  final String first_name;
  final String last_name;
  final String email;
  final String token;

  static UserDto fromJson(Map<String, dynamic> json) {
    return UserDto(
      uuid: json['uuid'],
      first_name: json['first_name'],
      last_name: json['last_name'],
      email: json['email'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'first_name': first_name,
      'last_name': last_name,
      'email': email,
      'token': token,
    };
  }
}

class CreateUserDto {
  const CreateUserDto({
    required this.first_name,
    required this.last_name,
    required this.email,
    required this.token,
  });

  final String first_name;
  final String last_name;
  final String email;
  final String token;

  Map<String, dynamic> toJson() {
    return {
      'first_name': first_name,
      'last_name': last_name,
      'email': email,
      'token': token,
    };
  }
}
