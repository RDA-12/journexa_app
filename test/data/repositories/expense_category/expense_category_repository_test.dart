import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/data/repositories/account/account.dart';
import 'package:journexa_app/data/repositories/expense_category/expense_category.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/expense_category.dart';
import 'package:journexa_app/domain/repositories/i_expense_category.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

void main() {
  const userId = 'userId';
  const traceId = 'traceId';

  final parentAccount = SystemDefinedAccount.rootExpense;
  final initialCategories = List.generate(5, (index) {
    return ExpenseCategory(
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
  late IExpenseCategoryRepository repository;

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
          .doc('users/$userId/expenseCategories/${category.id}')
          .set(FirestoreExpenseCategory.fromDomain(category).toJson());
    }

    repository = FirestoreExpenseCategoryRepository(db: fakeFirestore);
  });

  tearDown(() async {
    await fakeFirestore.clearPersistence();
  });

  group('save', () {
    final newCategory = ExpenseCategory(
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
        final expectedCategory = ExpenseCategory(
          id: 'expected',
          name: 'expected name',
          icon: 'icon',
          account: Account(
            code: '50.1000',
            name: 'expected name',
            type: AccountType.expense,
            parent: parentAccount,
          ),
        );
        final categoryDoc = fakeFirestore.doc(
          'users/$userId/expenseCategories/${expectedCategory.id}',
        );
        await categoryDoc.set(
          FirestoreExpenseCategory.fromDomain(expectedCategory).toJson(),
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
          isA<AppResultFailure<List<ExpenseCategory>>>().having(
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
          isA<AppResultFailure<List<ExpenseCategory>>>().having(
            (e) => e.error.code,
            'error.code',
            AppExceptionCode.internalException,
          ),
        );
      },
    );
  });

  group('delete', () {
    test(
      'returns success and delete correct Category and the Account',
      () async {
        final deletedCategory = initialCategories.first;

        final result = await repository.delete(
          userId: userId,
          category: deletedCategory,
          traceId: traceId,
        );

        expect(result, const AppResult.success(null));

        final categoryDocRef = fakeFirestore.doc(
          'users/$userId/expenseCategories/${deletedCategory.id}',
        );
        final categorySnapshot = await categoryDocRef.get();
        expect(categorySnapshot.exists, isFalse);

        final accountDocRef = fakeFirestore.doc(
          'users/$userId/accounts/${deletedCategory.account.code}',
        );
        final accountSnapshot = await accountDocRef.get();
        expect(accountSnapshot.exists, isFalse);
      },
    );

    test(
      'do nothing when category does not exist',
      () async {
        final nonExistentCategory = ExpenseCategory(
          id: 'non-existent',
          name: 'non-existent',
          icon: 'icon',
          account: Account(
            code: '50.0100',
            name: 'non-existent',
            type: AccountType.expense,
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
          'users/$userId/expenseCategories/${nonExistentCategory.id}',
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
            .doc('users/$userId/expenseCategories/${updatedCategory.id}')
            .get();
        expect(
          categoryDoc.data(),
          FirestoreExpenseCategory.fromDomain(updatedCategory).toJson(),
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
