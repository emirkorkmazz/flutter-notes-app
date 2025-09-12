final class AppUrls {
  ///
  const AppUrls._();

  ///
  static const String verifyToken = '/api/v1/auth/verify-token';

  ///
  static const String userInfo = '/api/v1/auth/me';

  ///
  static const String getNotes = '/api/v1/notes/get';

  ///
  static const String createNote = '/api/v1/notes/create';

  ///
  static const String updateNote = '/api/v1/notes/update/{id}';

  ///
  static const String deleteNote = '/api/v1/notes/delete/{id}';

  ///
  static const String getNoteById = '/api/v1/notes/get/{id}';
}
