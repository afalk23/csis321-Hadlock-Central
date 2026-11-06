import 'package:flutter_test/flutter_test.dart';
import 'package:hadlock_central_flutter/data/equipment_repository.dart';

void main() {
  test(
    'overlapping reservations respect quantity and stay account specific',
    () async {
      final repository = InMemoryEquipmentRepository();
      final item = (await repository.getItems()).firstWhere(
        (entry) => entry.id == 'bike',
      );
      final start = DateTime.now().add(const Duration(days: 2));
      final end = start.add(const Duration(hours: 1));

      expect(
        await repository.availableCount(item.id, start, end),
        item.quantity,
      );
      await repository.reserve(
        item: item,
        accountId: 'student-a',
        studentId: '1001',
        start: start,
        end: end,
      );
      await repository.reserve(
        item: item,
        accountId: 'student-b',
        studentId: '1002',
        start: start,
        end: end,
      );
      expect(await repository.availableCount(item.id, start, end), 0);
      await expectLater(
        repository.reserve(
          item: item,
          accountId: 'student-c',
          studentId: '1003',
          start: start,
          end: end,
        ),
        throwsA(isA<EquipmentUnavailableException>()),
      );
      expect((await repository.reservationsFor('student-a')).length, 1);
      expect(
        (await repository.reservationsFor('student-a')).single.studentId,
        '1001',
      );
      expect((await repository.reservationsFor('student-c')).isEmpty, true);
      expect(
        await repository.availableCount(
          item.id,
          end,
          end.add(const Duration(hours: 1)),
        ),
        item.quantity,
      );
    },
  );
}
