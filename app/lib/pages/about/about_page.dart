import 'package:flutter/material.dart';
import 'package:localsend_app/config/fork_config.dart';
import 'package:localsend_app/gen/strings.g.dart';
import 'package:localsend_app/pages/debug/debug_page.dart';
import 'package:localsend_app/widget/lotus_share_logo.dart';
import 'package:localsend_app/widget/responsive_list_view.dart';
import 'package:routerino/routerino.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t.aboutPage.title),
      ),
      body: ResponsiveListView(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        children: [
          const SizedBox(height: 20),
          const LotusShareLogo(withText: true),
          Text(
            t.tsudev.copyright(year: DateTime.now().year),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Center(
            child: TextButton(
              onPressed: () async {
                await launchUrl(Uri.parse(forkHomepageUrl));
              },
              child: Text(Uri.parse(forkHomepageUrl).host),
            ),
          ),
          const SizedBox(height: 10),
          Text(t.aboutPage.description.join('\n\n')),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton(
                onPressed: () async {
                  await launchUrl(Uri.parse(forkHomepageUrl));
                },
                child: Text(t.tsudev.homepage),
              ),
              TextButton(
                onPressed: () async {
                  await launchUrl(Uri.parse(forkRepositoryUrl), mode: LaunchMode.externalApplication);
                },
                child: Text(t.tsudev.sourceCode),
              ),
              TextButton(
                onPressed: () async {
                  await launchUrl(Uri.parse(forkEcosystemUrl), mode: LaunchMode.externalApplication);
                },
                child: const Text('tsudev.com'),
              ),
              // Giấy phép Apache 2.0 + thông báo NOTICE (nghĩa vụ giấy phép, đăng ký ở config/init.dart).
              TextButton(
                onPressed: () async {
                  await context.push(() => const LicensePage());
                },
                child: Text(t.tsudev.licenseNotices),
              ),
              TextButton(
                onPressed: () async {
                  await context.push(() => const DebugPage());
                },
                child: Text(t.tsudev.debugging),
              ),
            ],
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
