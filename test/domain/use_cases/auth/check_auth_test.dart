import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
import 'package:journexa_app/domain/use_cases/auth/check_auth.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  const traceId = 'trace';
  const userId = 'userId';

  late IAuthRepository mockAuthRepository;
  late CheckAuthUseCase useCase;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    when(
      () => mockAuthRepository.getCurrentUserId(traceId: traceId),
    ).thenAnswer((_) async => const AppResult.success(userId));
    useCase = CheckAuthUseCase(
      authRepository: mockAuthRepository,
    );
  });

  group('CheckAuthUseCase', () {
    test('returns AppResultSuccess with true '
        'when getCurrentUserId succeed', () async {
      final result = await useCase.execute(traceId: traceId);

      expect(result, const AppResult.success(true));
      verify(
        () => mockAuthRepository.getCurrentUserId(traceId: traceId),
      ).called(1);
    });

    test('returns AppResultSuccess with false '
        'when getCurrentUserId failed with unauthenticated code', () async {
      when(
        () => mockAuthRepository.getCurrentUserId(traceId: traceId),
      ).thenAnswer(
        (_) async => const AppResult.failure(
          AppException(
            'unauthenticated',
            code: AppExceptionCode.unauthenticated,
          ),
        ),
      );

      final result = await useCase.execute(traceId: traceId);

      expect(result, const AppResult.success(false));
      verify(
        () => mockAuthRepository.getCurrentUserId(traceId: traceId),
      ).called(1);
    });

    test('returns AppResultFailure '
        'when getCurrentUserId failed with not unauthenticated code', () async {
      when(
        () => mockAuthRepository.getCurrentUserId(traceId: traceId),
      ).thenAnswer(
        (_) async => AppResult.failure(
          AppException.test(),
        ),
      );

      final result = await useCase.execute(traceId: traceId);

      expect(result, AppResult<bool>.failure(AppException.test()));
      verify(
        () => mockAuthRepository.getCurrentUserId(traceId: traceId),
      ).called(1);
    });
  });
}
