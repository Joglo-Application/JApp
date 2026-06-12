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

  void _onPay() {
    final order = context.read<OrderProvider>();
    final cashPaid = _cashRaw.isEmpty
        ? order.total
        : (double.tryParse(_cashRaw) ?? 0);

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => TransactionSuccessDialog(
        total: order.total,
        cashPaid: cashPaid,
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
    order.clear();

    if (memberName.isNotEmpty && memberPoints != null && earned > 0) {
      final newPoints = memberPoints + earned;
      updateMemberPoints(memberName, newPoints);
      order.setMember(memberName, newPoints);
    } else if (memberName.isNotEmpty && memberPoints != null) {
      order.setMember(memberName, memberPoints);
    }
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
