import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/payment_method.dart';
import '../providers/order_provider.dart';
import 'pilih_member_page.dart';
import '../widgets/payment/cash_numpad_panel.dart';
import '../widgets/payment/payment_method_sidebar.dart';
import '../widgets/payment/qris_payment_panel.dart';
import '../widgets/payment/transaction_success_dialog.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  PaymentMethod _selected = PaymentMethod.tunai;
  String _cashRaw = '';

  void _onNumpad(String key) {
    setState(() {
      if (key == 'C') {
        _cashRaw = '0';
      } else if (_cashRaw == '0') {
        _cashRaw = key == '00' ? '0' : key;
      } else if (_cashRaw.length < 12) {
        final next = _cashRaw + key;
        _cashRaw = next.replaceAll(RegExp(r'^0+(?=\d)'), '');
      }
    });
  }

  void _onQuickAmount(double amount) {
    setState(() {
      _cashRaw = amount.toInt().toString();
    });
  }

  Future<void> _onPay() async {
    final order = context.read<OrderProvider>();
    final messenger = ScaffoldMessenger.of(context);

    // Non-Dine-In: pesanan belum dibuat → buat sekarang (masuk dapur + potong
    // stok) tepat saat pembayaran, baru lanjut bayar. Dine-In sudah dikirim.
    if (!order.isSentToKitchen) {
      final created = await order.kirimDapur();
      if (!mounted) return;
      if (!created) {
        messenger.showSnackBar(
          SnackBar(content: Text(order.submitError ?? 'Gagal membuat pesanan')),
        );
        return;
      }
    }

    final total = order.payableTotal;

    // Cash can be over-tendered (change is returned); non-cash pays exact total.
    final jumlahBayar = _selected == PaymentMethod.tunai
        ? (_cashRaw.isEmpty ? total.round() : (int.tryParse(_cashRaw) ?? 0))
        : total.round();

    if (jumlahBayar < total.round()) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Jumlah bayar kurang dari total')),
      );
      return;
    }

    final payment = await order.bayar(metode: _selected, jumlahBayar: jumlahBayar);
    if (!mounted) return;

    if (payment == null) {
      messenger.showSnackBar(
        SnackBar(content: Text(order.submitError ?? 'Pembayaran gagal')),
      );
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => TransactionSuccessDialog(
        total: total,
        cashPaid: payment.jumlahBayar,
        onNew: () => _finishTransaction(order),
        onPrint: () => _finishTransaction(order),
      ),
    );
  }

  void _finishTransaction(OrderProvider order) {
    final memberName = order.customerName;
    final memberPoints = order.memberPoints;
    final earned = order.earnedPoints;

    Navigator.of(context)
      ..pop()
      ..pop();

    // Simpan poin yang diperoleh ke server. Sengaja tidak ditunggu supaya
    // reset layar tidak tertahan jaringan; kegagalannya sudah ditangani di
    // dalam updateMemberPoints dan tidak membatalkan pembayaran yang sudah
    // tercatat.
    if (memberName.isNotEmpty && memberPoints != null && earned > 0) {
      unawaited(updateMemberPoints(memberName, memberPoints + earned));
    }

    // Reset everything — including the customer name — so the panel shows the
    // default "Name Customer" ready for the next transaction.
    order.clear();
  }

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrderProvider>();

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            SizedBox(
              width: 320,
              child: PaymentMethodSidebar(
                selected: _selected,
                onSelect: (m) => setState(() {
                  _selected = m;
                  _cashRaw = '';
                }),
                itemCount: order.itemCount,
              ),
            ),
            Expanded(
              child: switch (_selected) {
                PaymentMethod.tunai => CashNumpadPanel(
                    orderTotal: order.total,
                    cashRaw: _cashRaw,
                    onNumpad: _onNumpad,
                    onQuickAmount: _onQuickAmount,
                    onPay: _onPay,
                    onClose: () => Navigator.of(context).pop(),
                  ),
                PaymentMethod.qris => QrisPaymentPanel(
                    orderTotal: order.total,
                    onDone: _onPay,
                    onClose: () => Navigator.of(context).pop(),
                  ),
                _ => const _ComingSoon(),
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ComingSoon extends StatelessWidget {
  const _ComingSoon();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Segera hadir'),
    );
  }
}
