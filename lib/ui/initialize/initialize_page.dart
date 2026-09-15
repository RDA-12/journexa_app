import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:journexa_app/di.dart';
import 'package:journexa_app/ui/initialize/bloc/initialize_bloc.dart';
import 'package:journexa_app/ui/initialize/widgets/initializing_box.dart';

/// Page for initializing app.
///
/// The process include seeding default system accounts
class InitializePage extends StatelessWidget {
  /// Creates new [InitializePage]
  const new({
    this.initializeBloc,
    super.key,
  });

  ///[InitializeBloc] that will be provided to children.
  ///
  /// If null, creates new [InitializeBloc].
  final InitializeBloc? initializeBloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => (initializeBloc ?? getIt<InitializeBloc>())
        ..add(
          const InitializeEvent.initialize(),
        ),
      child: const Scaffold(
        body: _InitializeView(),
      ),
    );
  }
}

class _InitializeView extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return BlocListener<InitializeBloc, InitializeState>(
      listener: (context, state) {
        state.whenOrNull(
          initialized: () {
            context.go('/home');
          },
        );
      },
      child: const Center(
        child: InitializingBox(),
      ),
    );
  }
}
