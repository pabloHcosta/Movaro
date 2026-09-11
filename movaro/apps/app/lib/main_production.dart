import 'package:mudavi_app/app/bootstrap/bootstrap.dart';
import 'package:mudavi_app/core/environment/app_flavor.dart';

Future<void> main() async {
  await bootstrap(defaultFlavor: AppFlavor.production);
}
