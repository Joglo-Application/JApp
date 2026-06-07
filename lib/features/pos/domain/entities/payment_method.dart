enum PaymentMethod {
  tunai,
  qris,
  debitCard,
  qrisNetzme;

  String get label {
    switch (this) {
      case tunai:
        return 'TUNAI';
      case qris:
        return 'QRIS';
      case debitCard:
        return 'DEBIT CARD';
      case qrisNetzme:
        return 'QRIS by Netzme';
    }
  }

  bool get isActive => this != qrisNetzme;
}
