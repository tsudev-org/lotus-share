// Trang "Ủng hộ" chỉ dẫn tới kênh của hệ sinh thái tsudev (fork_config.dart).
import 'package:flutter/material.dart';
import 'package:localsend_app/config/fork_config.dart';
import 'package:localsend_app/gen/strings.g.dart';
import 'package:localsend_app/widget/responsive_list_view.dart';
import 'package:url_launcher/url_launcher.dart';

class DonationPage extends StatelessWidget {
  const DonationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t.donationPage.title),
      ),
      body: ResponsiveListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 50),
          Center(
            child: Text(
              t.donationPage.info,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          // lotus-share: điều kiện ủng hộ ngang hàng của Google Play (phiếu ~/projects/logs/handover/20261112-02).
          Center(
            child: Text(
              t.tsudev.donationVoluntary,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 34),
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              for (final link in forkSupportLinks)
                TextButton.icon(
                  onPressed: () async {
                    await launchUrl(Uri.parse(link.url), mode: LaunchMode.externalApplication);
                  },
                  icon: const Icon(Icons.open_in_new),
                  label: Text(link.label),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
