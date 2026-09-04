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

  group('watch', () {
    test(
      'emits success with correct categories',
      () async {
        final result = repository.watch(
          userId: userId,
          traceId: traceId,
        );

        expect(result, emits(AppResult.success(initialCategories)));
      },
    );

    test(
      'emits success with correct categories when query provided',
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

        final result = repository.watch(
          userId: userId,
          query: 'expected',
          traceId: traceId,
        );

        expect(result, emits(AppResult.success([expectedCategory])));
      },
    );

    test(
      'emits success with correct categories when isDeleted provided',
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
          FirestoreIncomeCategory.fromDomain(
            expectedCategory,
          ).copyWith(isDeleted: true).toJson(),
        );
        final accountDoc = fakeFirestore.doc(
          'users/$userId/accounts/${expectedCategory.account.code}',
        );
        await accountDoc.set(
          FirestoreAccount.fromDomain(
            expectedCategory.account,
          ).copyWith(isDeleted: true).toJson(),
        );

        final result = repository.watch(
          userId: userId,
          isDeleted: false,
          traceId: traceId,
        );

        expect(result, emits(AppResult.success(initialCategories)));

        final result2 = repository.watch(
          userId: userId,
          isDeleted: true,
          traceId: traceId,
        );

        expect(result2, emits(AppResult.success([expectedCategory])));
      },
    );

    test(
      'emits failure with serverException code '
      'when firestore throws FirebaseException',
      () async {
        whenCalling(Invocation.method(#watch, null))
            .on(repository)
            .thenThrow(
              FirebaseException(plugin: 'firestore'),
            );

        final result = repository.watch(
          userId: userId,
          traceId: traceId,
        );

        expect(
          result,
          emits(
            isA<AppResultFailure<List<IncomeCategory>>>().having(
              (e) => e.error.code,
              'error.code',
              AppExceptionCode.serverException,
            ),
          ),
        );
      },
    );

    test(
      'emits failure with internalException code '
      'when firestore throws Exception',
      () async {
        whenCalling(
          Invocation.method(#watch, null),
        ).on(repository).thenThrow(Exception());

        final result = repository.watch(
          userId: userId,
          traceId: traceId,
        );

        expect(
          result,
          emits(
            isA<AppResultFailure<List<IncomeCategory>>>().having(
              (e) => e.error.code,
              'error.code',
              AppExceptionCode.internalException,
            ),
          ),
        );
      },
    );
  });

  group('delete', () {
    test(
      'returns success and set isDeleted to true '
      'for correct Category and the Account',
      () async {
        final deletedCategory = initialCategories.first;

        final result = await repository.delete(
          userId: userId,
          category: deletedCategory,
          traceId: traceId,
        );

        expect(result, const AppResult.success(null));

        final categoryDocRef = fakeFirestore.doc(
          'users/$userId/incomeCategories/${deletedCategory.id}',
        );
        final categorySnapshot = await categoryDocRef.get();
        expect(categorySnapshot.data()?['isDeleted'], isTrue);

        final accountDocRef = fakeFirestore.doc(
          'users/$userId/accounts/${deletedCategory.account.code}',
        );
        final accountSnapshot = await accountDocRef.get();
        expect(accountSnapshot.data()?['isDeleted'], isTrue);
      },
    );

    test(
      'do nothing when category does not exist',
      () async {
        final nonExistentCategory = IncomeCategory(
          id: 'non-existent',
          name: 'non-existent',
          icon: 'icon',
          account: Account(
            code: '40.1111',
            name: 'non-existent',
            type: AccountType.revenue,
            parent: parentAccount,
          ),
        );

        final result = await repository.delete(
          userId: userId,
          category: nonExistentCategory,
          traceId: traceId,
        );

        expect(result, const AppResult.success(null));

        final categoryDocRef = fakeFirestore.doc(
          'users/$userId/incomeCategories/${nonExistentCategory.id}',
        );
        final categorySnapshot = await categoryDocRef.get();
        expect(categorySnapshot.exists, isFalse);

        final accountDocRef = fakeFirestore.doc(
          'users/$userId/accounts/${nonExistentCategory.account.code}',
        );
        final accountSnapshot = await accountDocRef.get();
        expect(accountSnapshot.exists, isFalse);
      },
    );

    test(
      'returns failure with serverException '
      'when firestore throws FirebaseException',
      () async {
        whenCalling(
          Invocation.method(#delete, null),
        ).on(repository).thenThrow(FirebaseException(plugin: 'firestore'));

        final result = await repository.delete(
          userId: userId,
          category: initialCategories.first,
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
      'returns failure with internalException '
      'when firestore throws Exception',
      () async {
        whenCalling(
          Invocation.method(#delete, null),
        ).on(repository).thenThrow(Exception());

        final result = await repository.delete(
          userId: userId,
          category: initialCategories.first,
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

  group('update', () {
    final updatedCategory = initialCategories.first.update(name: 'new name');
    test(
      'returns success when succeeded',
      () async {
        final result = await repository.update(
          userId: userId,
          updatedCategory: updatedCategory,
          traceId: traceId,
        );

        expect(result, const AppResult.success(null));
      },
    );

    test(
      'update both Category and Account',
      () async {
        await repository.update(
          userId: userId,
          updatedCategory: updatedCategory,
          traceId: traceId,
        );

        final categoryDoc = await fakeFirestore
            .doc('users/$userId/incomeCategories/${updatedCategory.id}')
            .get();
        expect(
          categoryDoc.data(),
          FirestoreIncomeCategory.fromDomain(updatedCategory).toJson(),
        );

        final accountDoc = await fakeFirestore
            .doc('users/$userId/accounts/${updatedCategory.account.code}')
            .get();
        expect(
          accountDoc.data(),
          FirestoreAccount.fromDomain(updatedCategory.account).toJson(),
        );
      },
    );

    test(
      'returns failure with serverException '
      'when firestore throws FirebaseException',
      () async {
        whenCalling(
          Invocation.method(#update, null),
        ).on(repository).thenThrow(FirebaseException(plugin: 'firestore'));

        final result = await repository.update(
          userId: userId,
          updatedCategory: updatedCategory,
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
      'returns failure with internalException '
      'when firestore throws Exception',
      () async {
        whenCalling(
          Invocation.method(#update, null),
        ).on(repository).thenThrow(Exception());

        final result = await repository.update(
          userId: userId,
          updatedCategory: updatedCategory,
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
}
