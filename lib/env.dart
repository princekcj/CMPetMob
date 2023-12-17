// lib/env/env.dart
import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env', requireEnvFile: true)
class Env {
  @EnviedField(varName: 'INTERNAL_API_ENDPOINT')
  static const String key1 = _Env.key1;
  @EnviedField(varName: 'API_KEY')
  static const String key2 = _Env.key2;
}