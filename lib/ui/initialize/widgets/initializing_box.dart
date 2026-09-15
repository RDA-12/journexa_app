import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:journexa_app/ui/initialize/bloc/initialize_bloc.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/theme.dart';
import 'package:journexa_app/ui/shared/widgets/widgets.dart';

/// Creates box thats react to [InitializeBloc] state changes.
///
/// Shows [AppExceptionBox] when fail
/// and [LoadingIndicator] when loading.
class InitializingBox extends StatelessWidget {
  /// Creates new [InitializingBox]
  ///
  /// It reacts to [InitializeBloc] states.
  /// Make sure to provide [InitializeBloc] in the tree.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InitializeBloc, InitializeState>(
      builder: (context, state) {
        return state.maybeWhen(
          orElse: () {
            return Column(
              spacing: 8,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const LoadingIndicator(size: 32),
                Text(
                  context.l10n.initializeLoadingText,
                  textAlign: TextAlign.center,
                  style: context.text.titleMedium,
                ),
              ],
            );
          },
          failure: (exception) {
            return AppExceptionBox(
              title: context.l10n.initializeErrorTitle,
              description: exception.code.toLocalizedString(context),
            );
          },
        );
      },
    );
  }
}
