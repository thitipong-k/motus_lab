import 'package:drift/drift.dart';
import 'package:motus_lab/core/database/app_database.dart';

class SyncManager {
  final AppDatabase _db;

  SyncManager(this._db);

  /// 1. Queue Data (Save Local)
  /// Saves data to the local database and marks it as unsynced.
  Future<void> queueScanResult(int vehicleId, String dtcCodes) async {
    await _db.into(_db.scanHistory).insert(
          ScanHistoryCompanion.insert(
            vehicleId: vehicleId,
            dtcCodes: dtcCodes,
            // timestamp defaults to now
            isSynced: const Value(false),
          ),
        );
  }

  /// 2. Sync Pending Items (Push to Cloud)
  /// Finds all unsynced items and attempts to send them to the API.
  Future<void> syncPendingItems() async {
    // a. Query unsynced items
    final pendingItems = await (_db.select(_db.scanHistory)
          ..where((tbl) => tbl.isSynced.equals(false)))
        .get();

    if (pendingItems.isEmpty) return;

    print("Found ${pendingItems.length} items to sync...");

    for (var item in pendingItems) {
      try {
        // b. Mock API Call
        await _mockPushToCloud(item);

        // c. Mark as synced
        await (_db.update(_db.scanHistory)
              ..where((tbl) => tbl.id.equals(item.id)))
            .write(
          const ScanHistoryCompanion(
            isSynced: Value(true),
          ),
        );

        print("Item ${item.id} synced!");
      } catch (e) {
        print("Failed to sync item ${item.id}: $e");
      }
    }
  }

  Future<void> _mockPushToCloud(dynamic item) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    // 80% success rate simulation
    if (DateTime.now().millisecond % 5 == 0) throw Exception("Network Error");
  }
}
