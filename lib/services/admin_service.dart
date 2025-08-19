import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:planit_mt/screens/admin/platform_stats_model.dart';
import '../models/vendor/app_vendor.dart';

class AdminService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late final CollectionReference<AppVendor> _vendorsRef;

  AdminService() {
    _vendorsRef = _db.collection('vendors').withConverter<AppVendor>(
          fromFirestore: (snapshot, _) => AppVendor.fromJson(snapshot.data()!),
          toFirestore: (vendor, _) => vendor.toJson(),
        );
  }

  Future<PlatformStats> getPlatformStatistics() async {
    int totalUsers = 0;
    int totalVendors = 0;
    int pendingVendors = 0;
    int eventsPlanned = 0;

    try {
      // Aggregate COUNT (fast). Falls back to paged count if unsupported/blocked
      final usersSnapshot = await _db.collection('users').count().get();
      totalUsers = usersSnapshot.count ?? 0;
    } catch (e) {
      if (kDebugMode) {
        print("Error counting users via aggregate, falling back: $e");
      }
      totalUsers = await _pagedCount(_db.collection('users'));
    }

    try {
      final vendorsSnapshot = await _db.collection('vendors').count().get();
      totalVendors = vendorsSnapshot.count ?? 0;
    } catch (e) {
      if (kDebugMode) {
        print("Error counting vendors via aggregate, falling back: $e");
      }
      totalVendors = await _pagedCount(_db.collection('vendors'));
    }

    try {
      final pendingSnapshot = await _db
          .collection('vendors')
          .where('isApproved', isEqualTo: false)
          .count()
          .get();
      pendingVendors = pendingSnapshot.count ?? 0;
    } catch (e) {
      if (kDebugMode) {
        print(
            "!!! CRITICAL ERROR counting pending vendors (INDEX LIKELY MISSING): $e");
      }
      // Fallback (non-aggregate). Safe for small demo data.
      try {
        pendingVendors = (await _db
                .collection('vendors')
                .where('isApproved', isEqualTo: false)
                .get())
            .docs
            .length;
      } catch (_) {}
    }

    try {
      final eventsAgg = await _db.collectionGroup('events').count().get();
      eventsPlanned = eventsAgg.count ?? 0;
    } catch (e) {
      if (kDebugMode) {
        print(
            "Error counting events via collectionGroup aggregate, falling back: $e");
      }
      // Fallback: iterate users and sum events (sufficient for demo sizes)
      try {
        int sum = 0;
        final users = await _db.collection('users').get();
        for (final u in users.docs) {
          final ev = await _db
              .collection('users')
              .doc(u.id)
              .collection('events')
              .get();
          sum += ev.docs.length;
        }
        eventsPlanned = sum;
      } catch (_) {}
    }

    return PlatformStats(
      totalUsers: totalUsers,
      totalVendors: totalVendors,
      pendingVendors: pendingVendors,
      eventsPlanned: eventsPlanned,
    );
  }

  // Efficient paged counter (fallback when aggregate not available)
  Future<int> _pagedCount(Query<Map<String, dynamic>> base) async {
    const pageSize = 1000; // plenty for demo; adjust for prod tooling
    int total = 0;
    Query<Map<String, dynamic>> q =
        base.orderBy(FieldPath.documentId).limit(pageSize);
    while (true) {
      final snap = await q.get();
      total += snap.docs.length;
      if (snap.docs.length < pageSize) break;
      q = base
          .orderBy(FieldPath.documentId)
          .startAfter([snap.docs.last.id]).limit(pageSize);
    }
    return total;
  }

  Future<List<AppVendor>> getPendingVendors() async {
    try {
      final querySnapshot =
          await _vendorsRef.where('isApproved', isEqualTo: false).get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching pending vendors (INDEX LIKELY MISSING): $e");
      }
      return []; // Return an empty list on error
    }
  }

  Future<List<AppVendor>> getAllVendors() async {
    try {
      final querySnapshot = await _vendorsRef.get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching all vendors: $e");
      }
      return []; // Return an empty list on error
    }
  }

  Future<void> updateVendorApprovalStatus(
      String vendorId, bool isApproved) async {
    await _db
        .collection('vendors')
        .doc(vendorId)
        .update({'isApproved': isApproved});
  }

  Future<void> deleteVendor(String vendorId) async {
    await _db.collection('vendors').doc(vendorId).delete();
  }
}
