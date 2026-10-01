import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/supabase_client.dart';
import '../domain/invoice_model.dart';

final billingRepositoryProvider = Provider<BillingRepository>((ref) {
  return BillingRepository();
});

final invoiceListProvider = FutureProvider<List<InvoiceModel>>((ref) async {
  final repo = ref.watch(billingRepositoryProvider);
  return repo.getInvoices();
});

class BillingRepository {
  final List<InvoiceModel> _demoInvoices = [
    InvoiceModel(
      id: 'inv-1',
      invoiceNumber: 'INV-2026-0001',
      patientId: '30000000-0000-0000-0000-000000000001',
      patientName: 'Emma Stonehurst',
      subtotal: 150.00,
      tax: 7.50,
      discount: 0.0,
      totalAmount: 157.50,
      paidAmount: 157.50,
      status: 'paid',
      dueDate: DateTime.now().subtract(const Duration(days: 1)),
      items: const [
        InvoiceItemModel(
          description: 'Specialist Consultation - Dr. Sarah Watson',
          category: 'consultation',
          unitPrice: 150.00,
          quantity: 1,
          totalPrice: 150.00,
        ),
      ],
    ),
    InvoiceModel(
      id: 'inv-2',
      invoiceNumber: 'INV-2026-0002',
      patientId: '30000000-0000-0000-0000-000000000001',
      patientName: 'Emma Stonehurst',
      subtotal: 210.00,
      tax: 10.50,
      discount: 0.0,
      totalAmount: 220.50,
      paidAmount: 100.00,
      status: 'partial',
      dueDate: DateTime.now().add(const Duration(days: 7)),
      items: const [
        InvoiceItemModel(
          description: 'Complete Blood Count (CBC) Panel',
          category: 'lab',
          unitPrice: 35.00,
          quantity: 1,
          totalPrice: 35.00,
        ),
        InvoiceItemModel(
          description: 'Comprehensive Lipid Profile Fasting',
          category: 'lab',
          unitPrice: 45.00,
          quantity: 1,
          totalPrice: 45.00,
        ),
        InvoiceItemModel(
          description: 'Cardiology Follow-up Clinic Visit',
          category: 'consultation',
          unitPrice: 130.00,
          quantity: 1,
          totalPrice: 130.00,
        ),
      ],
    ),
  ];

  Future<List<InvoiceModel>> getInvoices({String? patientId}) async {
    final client = SupabaseService.client;
    if (client != null && SupabaseService.isInitialized) {
      try {
        final List res = await client
            .from('invoices')
            .select('*, invoice_items(*), patients(profiles(full_name))')
            .order('created_at', ascending: false);
        return res.map((e) => InvoiceModel.fromJson(Map<String, dynamic>.from(e))).toList();
      } catch (_) {}
    }
    return _demoInvoices;
  }

  Future<void> recordPayment(String invoiceId, double amount, String paymentMethod) async {
    final idx = _demoInvoices.indexWhere((i) => i.id == invoiceId);
    if (idx != -1) {
      final current = _demoInvoices[idx];
      final newPaid = (current.paidAmount + amount).clamp(0, current.totalAmount);
      final newStatus = newPaid >= current.totalAmount ? 'paid' : 'partial';

      _demoInvoices[idx] = InvoiceModel(
        id: current.id,
        invoiceNumber: current.invoiceNumber,
        patientId: current.patientId,
        patientName: current.patientName,
        subtotal: current.subtotal,
        tax: current.tax,
        discount: current.discount,
        totalAmount: current.totalAmount,
        paidAmount: newPaid.toDouble(),
        status: newStatus,
        dueDate: current.dueDate,
        items: current.items,
      );
    }
  }
}
