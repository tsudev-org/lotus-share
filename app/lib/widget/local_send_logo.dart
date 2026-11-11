import 'package:flutter/material.dart';
import 'package:localsend_app/config/fork_config.dart';
import 'package:localsend_app/gen/assets.gen.dart';

class LocalSendLogo extends StatelessWidget {
  final bool withText;

  const LocalSendLogo({required this.withText});

  @override
  Widget build(BuildContext context) {
    // lotus-share: dấu hiệu tsudev giữ nguyên màu (BRAND_ASSETS mục 8 cấm đổi màu), không tô màu chủ đạo như logo gốc.
    final logo = Assets.img.logo512.image(
      width: 200,
      height: 200,
    );

    if (withText) {
      return Column(
        children: [
          logo,
          const Text(
            forkProductName, // lotus-share
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else {
      return logo;
    }
  }
}
