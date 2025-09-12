enum AppStorage {
  ///
  idToken('idToken'),
  isFirstTimeAppOpen('isFirstTimeAppOpen'),
  isLoggedIn('isLoggedIn'),
  themeMode('themeMode'),
  isTutorialCompleted('isTutorialCompleted'), /// Eklenebilir dursun şimdilik.
  username('username');

  ///
  const AppStorage(this.key);
  final String key;
}
