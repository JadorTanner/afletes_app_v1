// ignore_for_file: avoid_init_to_null

class User {
  Map userData = {};
  String firstName = '';
  String lastName = '';
  String fullName = '';
  String email = '';
  String documentNumber = '';
  String legalName = '';
  bool isCarrier = false;
  bool isLoadGenerator = false;
  int cityId = 0;
  String latitude = '';
  String longitude = '';
  String cellphone = '';

  Future login() async {
    //TODO: Login con afletes
  }

  Future register() async {
    //TODO: Registro con afletes
  }

  userFromArray() {
    return User(
      fullName: userData['full_name'],
      firstName: userData['first_name'],
      lastName: userData['last_name'],
      email: userData['email'],
    );
  }

  User({
    this.userData = const {},
    this.firstName = '',
    this.lastName = '',
    this.fullName = '',
    this.email = '',
    this.documentNumber = '',
    this.legalName = '',
    this.isCarrier = false,
    this.isLoadGenerator = false,
    this.cityId = 0,
    this.latitude = '',
    this.longitude = '',
    this.cellphone = '',
  });
}
