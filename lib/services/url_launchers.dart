import 'package:url_launcher/url_launcher.dart';

class UrlLauncherUtils {
  Future<void> launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.inAppBrowserView,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> launchEmail(String email) async {
    final Uri _emailLaunchUri = Uri(scheme: 'mailto', path: email);

    if (await launchUrl(_emailLaunchUri)) {
      await launchUrl(_emailLaunchUri);
    } else {
      // Handle the case where the email application cannot be launched
      print('Could not launch email application');
    }
  }
}
