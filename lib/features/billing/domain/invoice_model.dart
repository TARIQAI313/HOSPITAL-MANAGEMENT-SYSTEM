class InvoiceItemModel {
  final String description;
  final String category; // consultation, lab, pharmacy, radiology, bed_charge, procedure
  final double unitPrice;
  final int quantity;
  final double totalPrice;

  const InvoiceItemModel({
    required this.description,
    required this.category,
    required this.unitPrice,
    this.quantity = 1,
    required this.totalPrice,
  });

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return InvoiceItemModel(
      description: json['description'] as String? ?? 'Service',
      category: json['category'] as String? ?? 'consultation',
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class InvoiceModel {
  final String id;
  final String invoiceNumber; // INV-2026-0001
  final String patientId;
  final String patientName;
  final double subtotal;
  final double tax;
  final double discount;
  final double totalAmount;
  final double paidAmount;
  final String status; // paid, unpaid, partial, refunded
  final DateTime dueDate;
  final List<InvoiceItemModel> items;

  const InvoiceModel({
    required this.id,
    required this.invoiceNumber,
    required this.patientId,
    required this.patientName,
    required this.subtotal,
    this.tax = 0.0,
    this.discount = 0.0,
    required this.totalAmount,
    this.paidAmount = 0.0,
    required this.status,
    required this.dueDate,
    this.items = const [],
  });

  double get balanceDue => (totalAmount - paidAmount).clamp(0, 999999);

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'] as String,
      invoiceNumber: json['invoice_number'] as String? ?? 'INV-000',
      patientId: json['patient_id'] as String? ?? '',
      patientName: json['patients']?['profiles']?['full_name'] as String? ??
          (json['patient_name'] as String? ?? 'Patient'),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'unpaid',
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : DateTime.now(),
      items: (json['invoice_items'] as List<dynamic>?)
              ?.map((e) => InvoiceItemModel.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
    );
  }
}
