import 'package:flutter_test/flutter_test.dart';
import 'package:hadlock_central_flutter/data/equipment_repository.dart';
import 'package:hadlock_central_flutter/models/equipment_cart_entry.dart';

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

  test('staff inventory changes respect existing reservations', () async {
    final repository = InMemoryEquipmentRepository();
    final item = (await repository.getItems()).firstWhere(
      (entry) => entry.id == 'bike',
    );
    final start = DateTime.now().add(const Duration(days: 2));
    final end = start.add(const Duration(hours: 1));

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

    expect((await repository.getAllReservations()).length, 2);
    await expectLater(
      repository.updateQuantity(item.id, 1),
      throwsA(isA<EquipmentInventoryException>()),
    );
    await repository.updateQuantity(item.id, 3);
    expect(
      (await repository.getItems())
          .firstWhere((entry) => entry.id == item.id)
          .quantity,
      3,
    );
    expect(await repository.availableCount(item.id, start, end), 1);
  });

  test(
    'completion requires the rental to end and equipment to be returned',
    () async {
      var now = DateTime(2026, 11, 24, 10);
      final repository = InMemoryEquipmentRepository(now: () => now);
      final item = (await repository.getItems()).first;
      final reservation = await repository.reserve(
        item: item,
        accountId: 'student-a',
        studentId: '1001',
        start: now.add(const Duration(hours: 1)),
        end: now.add(const Duration(hours: 2)),
      );

      await expectLater(
        repository.completeReservation(reservation.id, returned: true),
        throwsA(isA<EquipmentReservationActionException>()),
      );
      now = now.add(const Duration(hours: 3));
      await expectLater(
        repository.completeReservation(reservation.id, returned: false),
        throwsA(isA<EquipmentReservationActionException>()),
      );
      await repository.completeReservation(reservation.id, returned: true);
      expect((await repository.getAllReservations()).single.completedAt, now);
      await expectLater(
        repository.completeReservation(reservation.id, returned: true),
        throwsA(isA<EquipmentReservationActionException>()),
      );
    },
  );

  test('cancellation requires checks and keeps a staff note', () async {
    final repository = InMemoryEquipmentRepository();
    final item = (await repository.getItems()).first;
    final start = DateTime.now().add(const Duration(days: 2));
    final reservation = await repository.reserve(
      item: item,
      accountId: 'student-a',
      studentId: '1001',
      start: start,
      end: start.add(const Duration(hours: 1)),
    );
    await expectLater(
      repository.cancelReservation(
        reservation.id,
        userContacted: false,
        bossApproved: true,
        reason: 'Reason',
      ),
      throwsA(isA<EquipmentReservationActionException>()),
    );
    await expectLater(
      repository.cancelReservation(
        reservation.id,
        userContacted: true,
        bossApproved: false,
        reason: 'Reason',
      ),
      throwsA(isA<EquipmentReservationActionException>()),
    );
    await expectLater(
      repository.cancelReservation(
        reservation.id,
        userContacted: true,
        bossApproved: true,
        reason: '  ',
      ),
      throwsA(isA<EquipmentReservationActionException>()),
    );
    expect((await repository.reservationsFor('student-a')).length, 1);
    await repository.cancelReservation(
      reservation.id,
      userContacted: true,
      bossApproved: true,
      reason: '  Schedule conflict  ',
    );
    expect(await repository.reservationsFor('student-a'), isEmpty);
    expect(await repository.getAllReservations(), isEmpty);
    expect(
      (await repository.getCancellations()).single.reason,
      'Schedule conflict',
    );
    expect(
      await repository.availableCount(
        item.id,
        start,
        start.add(const Duration(hours: 1)),
      ),
      item.quantity,
    );
  });

  test(
    'cart checkout reserves several items and time windows together',
    () async {
      final repository = InMemoryEquipmentRepository();
      final items = await repository.getItems();
      final bike = items.firstWhere((item) => item.id == 'bike');
      final helmet = items.firstWhere((item) => item.id == 'helmet');
      final start = DateTime.now().add(const Duration(days: 2));
      final entries = [
        EquipmentCartEntry(
          item: bike,
          startsAt: start,
          endsAt: start.add(const Duration(hours: 1)),
        ),
        EquipmentCartEntry(
          item: helmet,
          startsAt: start,
          endsAt: start.add(const Duration(hours: 1)),
        ),
        EquipmentCartEntry(
          item: bike,
          startsAt: start.add(const Duration(hours: 2)),
          endsAt: start.add(const Duration(hours: 3)),
        ),
      ];

      final saved = await repository.reserveCart(
        entries: entries,
        accountId: 'student-a',
        studentId: '1001',
      );
      expect(saved.length, 3);
      expect(saved.map((entry) => entry.id).toSet().length, 3);
      expect((await repository.reservationsFor('student-a')).length, 3);
    },
  );

  test('cart checkout rejects overlap without saving any rows', () async {
    final repository = InMemoryEquipmentRepository();
    final bike = (await repository.getItems()).firstWhere(
      (item) => item.id == 'bike',
    );
    final start = DateTime.now().add(const Duration(days: 2));
    final entries = List.generate(
      bike.quantity + 1,
      (_) => EquipmentCartEntry(
        item: bike,
        startsAt: start,
        endsAt: start.add(const Duration(hours: 1)),
      ),
    );
    await expectLater(
      repository.reserveCart(
        entries: entries,
        accountId: 'student-a',
        studentId: '1001',
      ),
      throwsA(isA<EquipmentUnavailableException>()),
    );
    expect(await repository.getAllReservations(), isEmpty);
  });

  test(
    'selected quantities change availability for overlapping times',
    () async {
      final repository = InMemoryEquipmentRepository();
      final bike = (await repository.getItems()).firstWhere(
        (item) => item.id == 'bike',
      );
      final start = DateTime.now().add(const Duration(days: 2));
      final end = start.add(const Duration(hours: 2));
      final saved = await repository.reserveCart(
        entries: [
          EquipmentCartEntry(
            item: bike,
            startsAt: start,
            endsAt: end,
            quantity: 1,
          ),
        ],
        accountId: 'student-a',
        studentId: '1001',
      );
      expect(saved.single.quantity, 1);
      expect(
        await repository.availableCount(
          bike.id,
          start.add(const Duration(minutes: 30)),
          end,
        ),
        1,
      );
      expect(
        await repository.availableCount(
          bike.id,
          end,
          end.add(const Duration(hours: 1)),
        ),
        2,
      );
      expect(
        await repository.availableCount(
          bike.id,
          start,
          end,
          cart: [
            EquipmentCartEntry(
              item: bike,
              startsAt: start,
              endsAt: end,
              quantity: 1,
            ),
          ],
        ),
        0,
      );

      await expectLater(
        repository.reserveCart(
          entries: [
            EquipmentCartEntry(
              item: bike,
              startsAt: start,
              endsAt: end,
              quantity: 2,
            ),
          ],
          accountId: 'student-b',
          studentId: '1002',
        ),
        throwsA(isA<EquipmentUnavailableException>()),
      );
      expect((await repository.getAllReservations()).length, 1);
      await repository.cancelReservation(
        saved.single.id,
        userContacted: true,
        bossApproved: true,
        reason: 'Changed plans',
      );
      expect(await repository.availableCount(bike.id, start, end), 2);
      final pair = await repository.reserveCart(
        entries: [
          EquipmentCartEntry(
            item: bike,
            startsAt: start,
            endsAt: end,
            quantity: 2,
          ),
        ],
        accountId: 'student-b',
        studentId: '1002',
      );
      expect(pair.single.quantity, 2);
      expect(await repository.availableCount(bike.id, start, end), 0);
    },
  );
}
