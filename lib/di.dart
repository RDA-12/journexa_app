import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/di.config.dart';

/// Global [GetIt] instance
final GetIt getIt = GetIt.instance;

/// Configure dependencies
///
/// Run `flutter pub run build_runner build` to generate the code
@InjectableInit()
Future<void> configureDependencies() => getIt.init();
