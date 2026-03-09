import 'package:movaro_app/app/bootstrap/bootstrap.dart';
import 'package:movaro_app/core/environment/app_flavor.dart';

Future<void> main() async {
  await bootstrap(defaultFlavor: AppFlavor.development);
}
