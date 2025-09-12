enum AppRouteName {
  /// Top-Level Rotalar
  landing('/landing'),
  login('/login'),
  register('/register'),
  home('/home'),
  addNote('/addNote'),
  editNote('/editNote/:noteId');

  const AppRouteName(this.path);
  final String path;

  /// goNamed ve pushNamed kullanırken
  /// '/' işaretini kaldırmak için bir getter ekliyoruz.
  /// Kullanımı: AppRoutName.home.withoutSlash
  String get withoutSlash => path.replaceFirst('/', '');

  /// Sub-Route'lar için sonuna '/' işareti koyman için.
  String get withTrailingSlash => '$path/';
}
