import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
import 'package:journexa_app/domain/use_cases/auth/login_with_google.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late LoginWithGoogleUseCase useCase;

  const traceId = 'test-trace-id';

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = LoginWithGoogleUseCase(mockAuthRepository);
  });

  group('LoginWithGoogleUseCase', () {
    test(
      'returns AppResult.success when repository loginWithGoogle succeeds',
      () async {
        when(
          () => mockAuthRepository.loginWithGoogle(traceId: traceId),
        ).thenAnswer((_) async => const AppResult<void>.success(null));

        final result = await useCase.execute(
          traceId: traceId,
        );

        expect(result, equals(const AppResult<void>.success(null)));
        verify(
          () => mockAuthRepository.loginWithGoogle(traceId: traceId),
        ).called(1);
      },
    );

    test(
      'returns AppResult.failure when repository loginWithGoogle fails',
      () async {
        const failure = AppResult<void>.failure(
          AppException(
            'Google log in canceled by user',
            code: AppExceptionCode.loginCanceled,
          ),
        );
        when(
          () => mockAuthRepository.loginWithGoogle(traceId: traceId),
        ).thenAnswer((_) async => failure);

        final result = await useCase.execute(
          traceId: traceId,
        );

        expect(result, equals(failure));
        verify(
          () => mockAuthRepository.loginWithGoogle(traceId: traceId),
        ).called(1);
      },
    );
  });
}
