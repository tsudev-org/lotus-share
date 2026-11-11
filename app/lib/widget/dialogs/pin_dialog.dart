import 'dart:math';

import 'package:flutter/material.dart';
import 'package:localsend_app/config/theme.dart';
import 'package:localsend_app/gen/strings.g.dart';
import 'package:nanoid2/nanoid2.dart';
import 'package:routerino/routerino.dart';

class PinDialog extends StatefulWidget {
  final String? pin;
  final bool showInvalidPin;
  final bool obscureText;
  final bool generateRandom;

  /// tsudev-lotus: độ dài tối thiểu khi ĐẶT PIN (0 = không giới hạn, dùng khi nhập PIN của máy khác).
  final int minLength;

  const PinDialog({
    this.pin,
    required this.obscureText,
    this.showInvalidPin = false,
    this.generateRandom = false,
    this.minLength = 0,
    super.key,
  });

  @override
  State<PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<PinDialog> {
  final _textController = TextEditingController();
  bool _tooShort = false;

  void _submit() {
    final value = _textController.text;
    if (value.length < widget.minLength) {
      setState(() => _tooShort = true);
      return;
    }
    context.pop(value);
  }

  @override
  void initState() {
    super.initState();
    _textController.text = widget.pin ?? (widget.generateRandom ? generateSecurePin() : '');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(t.dialogs.pin.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _textController,
            autofocus: true,
            obscureText: widget.obscureText,
            onFieldSubmitted: (_) => _submit(),
          ),
          if (_tooShort)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                t.tsudev.pinTooShort(n: widget.minLength),
                style: TextStyle(color: Theme.of(context).colorScheme.warning),
              ),
            ),
          if (widget.showInvalidPin)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                t.web.invalidPin,
                style: TextStyle(color: Theme.of(context).colorScheme.warning),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: Text(t.general.cancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(t.general.confirm),
        ),
      ],
    );
  }
}

/// tsudev-lotus: độ dài PIN tối thiểu khi người dùng đặt PIN nhận tệp / chia sẻ qua liên kết.
const pinMinLength = 6;

/// tsudev-lotus: sinh PIN bằng bộ sinh số ngẫu nhiên mật mã của hệ điều hành (CSPRNG).
/// Truyền thẳng [Random.secure] để nanoid2 KHÔNG âm thầm lùi về [Random] thường khi nền tảng
/// thiếu nguồn ngẫu nhiên an toàn: khi đó [Random.secure] ném lỗi (fail-closed).
/// Bảng chữ `noDoppelganger` (49 ký tự, bỏ 0/O/o, 1/l/I, 2/Z, 5/S/s, u/v dễ nhầm); 8 ký tự ~ 2^45 tổ hợp.
String generateSecurePin({int length = 8, Random? random}) {
  return nanoid(alphabet: Alphabet.noDoppelganger, length: length, random: random ?? Random.secure());
}
