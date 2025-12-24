class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email boş olamaz';
    final bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(value);
    return emailValid ? null : 'Geçerli bir email giriniz';
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Şifre boş olamaz';
    if (value.length < 6) return 'Şifre en az 6 karakter olmalıdır';
    return null;
  }
}