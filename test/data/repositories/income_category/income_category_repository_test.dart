import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/data/repositories/account/account.dart';
import 'package:journexa_app/data/repositories/income_category/income_category.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/income_category.dart';
import 'package:journexa_app/domain/repositories/i_income_category.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

void main() {
  const userId = 'userId';
  const traceId = 'traceId';

  final parentAccount = SystemDefinedAccount.rootRevenue;
  final initialCategories = List.generate(5, (index) {
    return IncomeCategory(
      id: 'category_id_$index',
      name: 'Category $index',
      icon: 'category_$index',
      account: Account.user(
        parent: parentAccount,
        name: 'Category $index',
        currentChildrenCount: index,
      ),
    );
  });

  late FirebaseFirestore fakeFirestore;
  late IIncomeCategoryRepository repository;

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
    final parentDoc = fakeFirestore.doc(
      'users/$userId/accounts/${parentAccount.code}',
    );
    await parentDoc.set(FirestoreAccount.fromDomain(parentAccount).toJson());
    for (final category in initialCategories) {
      await fakeFirestore
          .doc(
            'users/$userId/accounts/${category.account.code}',
          )
          .set(FirestoreAccount.fromDomain(category.account).toJson());
      await fakeFirestore
          .doc('users/$userId/incomeCategories/${category.id}')
          .set(FirestoreIncomeCategory.fromDomain(category).toJson());
    }

    repository = FirestoreIncomeCategoryRepository(db: fakeFirestore);
  });

  tearDown(() async {
    await fakeFirestore.clearPersistence();
  });

  group('save', () {
    final newCategory = IncomeCategory(
      id: 'completely-new',
      name: 'completely new',
      icon: 'icon',
      account: Account.user(
        parent: parentAccount,
        name: 'completely new',
        currentChildrenCount: initialCategories.length,
      ),
    );

    test('returns success and save correct category and account', () async {
      final result = await repository.save(
        userId: userId,
        traceId: traceId,
        category: newCategory,
      );

      expect(result, const AppResult.success(null));
    });

    test(
      'returns failure with categoryNameAlreadyExists code '
      'when saving existing category name',
      () async {
        final existingName = initialCategories.first.name;

        final result = await repository.save(
          userId: userId,
          traceId: traceId,
          category: newCategory.copyWith(
            name: existingName,
            account: newCategory.account.copyWith(
              name: existingName,
            ),
          ),
        );

        expect(
          result,
          isA<AppResultFailure<Null>>().having(
            (e) => e.error.code,
            'error.code',
            AppExceptionCode.categoryNameAlreadyExists,
          ),
        );
      },
    );

    test(
      'returns failure with serverException code '
      'when firestore throws FirebaseException',
      () async {
        whenCalling(Invocation.method(#save, null))
            .on(repository)
            .thenThrow(
              FirebaseException(plugin: 'firestore'),
            );

        final result = await repository.save(
          userId: userId,
          category: newCategory,
          traceId: traceId,
        );

        expect(
          result,
          isA<AppResultFailure<Null>>().having(
            (e) => e.error.code,
            'error.code',
            AppExceptionCode.serverException,
          ),
        );
      },
    );

    test(
      'returns failure with internalException code '
      'when firestore throws Exception',
      () async {
        whenCalling(
          Invocation.method(#save, null),
        ).on(repository).thenThrow(Exception());

        final result = await repository.save(
          userId: userId,
          category: newCategory,
          traceId: traceId,
        );

        expect(
          result,
          isA<AppResultFailure<Null>>().having(
            (e) => e.error.code,
            'error.code',
            AppExceptionCode.internalException,
          ),
        );
      },
    );
  });

  group('getAll', () {
    test(
      'returns success with correct categories',
      () async {
        final result = await repository.getAll(
          userId: userId,
          traceId: traceId,
        );

        expect(result, AppResult.success(initialCategories));
      },
    );

    test(
      'returns success with correct categories when query provided',
      () async {
        final expectedCategory = IncomeCategory(
          id: 'expected',
          name: 'expected name',
          icon: 'icon',
          account: Account(
            code: '40.1000',
            name: 'expected name',
            type: AccountType.revenue,
            parent: parentAccount,
          ),
        );
        final categoryDoc = fakeFirestore.doc(
          'users/$userId/incomeCategories/${expectedCategory.id}',
        );
        await categoryDoc.set(
          FirestoreIncomeCategory.fromDomain(expectedCategory).toJson(),
        );
        final accountDoc = fakeFirestore.doc(
          'users/$userId/accounts/${expectedCategory.account.code}',
        );
        await accountDoc.set(
          FirestoreAccount.fromDomain(expectedCategory.account).toJson(),
        );

        final result = await repository.getAll(
          userId: userId,
          query: 'expected',
          traceId: traceId,
        );

        expect(result, AppResult.success([expectedCategory]));
      },
    );

    test(
      'returns failure with serverException code '
      'when firestore throws FirebaseException',
      () async {
        whenCalling(Invocation.method(#getAll, null))
            .on(repository)
            .thenThrow(
              FirebaseException(plugin: 'firestore'),
            );

        final result = await repository.getAll(
          userId: userId,
          traceId: traceId,
        );

        expect(
          result,
          isA<AppResultFailure<List<IncomeCategory>>>().having(
            (e) => e.error.code,
            'error.code',
            AppExceptionCode.serverException,
          ),
        );
      },
    );

    test(
      'returns failure with internalException code '
      'when firestore throws Exception',
      () async {
        whenCalling(
          Invocation.method(#getAll, null),
        ).on(repository).thenThrow(Exception());

        final result = await repository.getAll(
          userId: userId,
          traceId: traceId,
        );

        expect(
          result,
          isA<AppResultFailure<List<IncomeCategory>>>().having(
            (e) => e.error.code,
            'error.code',
            AppExceptionCode.internalException,
          ),
        );
      },
    );
  });
}
