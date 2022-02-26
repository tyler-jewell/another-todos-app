import 'package:flutter_services_binding/flutter_services_binding.dart';
import 'package:flutter_todos/bootstrap.dart';

Future<void> main() async {
  FlutterServicesBinding.ensureInitialized();

  bootstrap();
}
