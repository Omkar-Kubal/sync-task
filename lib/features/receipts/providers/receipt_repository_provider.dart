import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../tasks/providers/task_controller.dart';
import '../data/receipt_repository.dart';

final receiptRepositoryProvider = Provider<ReceiptRepository>((ref) {
  return ReceiptRepository(ref.watch(appDatabaseProvider));
});

final receiptHistoryProvider = FutureProvider<List<ReceiptListItem>>((ref) {
  return ref.watch(receiptRepositoryProvider).listReceipts();
});

final receiptQuotaProvider = FutureProvider<ReceiptQuotaStatus>((ref) {
  return ref.watch(receiptRepositoryProvider).quotaStatus();
});

final savedReceiptProvider = FutureProvider.family<SavedReceipt?, String>((
  ref,
  receiptId,
) {
  return ref.watch(receiptRepositoryProvider).getReceipt(receiptId);
});
