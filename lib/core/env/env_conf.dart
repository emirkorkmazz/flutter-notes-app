import 'package:envied/envied.dart';

part 'env_conf.g.dart';

@Envied(path: '.env')
abstract class EnvConf {
  ///
  @EnviedField(varName: 'API_URL', defaultValue: '', obfuscate: true)
  static String apiUrl = _EnvConf.apiUrl;

}
