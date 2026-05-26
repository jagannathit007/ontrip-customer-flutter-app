import '../../app_export.dart';

class AppUrl {
  static Future<void> _myUriLaunch({
    required String url,
    LaunchMode mode = LaunchMode.platformDefault,
    WebViewConfiguration webViewConfiguration = const WebViewConfiguration(enableJavaScript: true),
    String notLaunchMsg = "Unable to open url",
    String errorMsg = "Unable to process your request right now, Please try again later.",
  }) async {
    try {
      final uri = Uri.parse(url);
      debugPrint('🔗 Attempting to launch URL: $url');

      // Try to launch directly first, as canLaunchUrl is often restricted by Android package visibility
      bool launched = await launchUrl(uri, mode: mode, webViewConfiguration: webViewConfiguration);

      if (!launched) {
        // Fallback to external application if the first attempt failed
        debugPrint('⚠️ Initial launch failed, trying external application fallback...');
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      }

      if (launched) {
        debugPrint('✅ Successfully launched URL: $url');
      } else {
        debugPrint('❌ Cannot launch URL: $url');
        Fluttertoast.showToast(msg: notLaunchMsg);
      }
    } catch (e) {
      debugPrint('❌ Error launching URL: $e');
      Fluttertoast.showToast(msg: errorMsg);
    }
  }

  static Future<void> urlLaunch({
    required String url,
    LaunchMode mode = LaunchMode.inAppBrowserView,
    String notLaunchMsg = "Unable to open url",
    String errorMsg = "Failed to open url",
  }) async {
    return await _myUriLaunch(url: url, mode: mode, notLaunchMsg: notLaunchMsg, errorMsg: errorMsg);
  }

  static Future<void> mail({
    required String email,
    String? subject,
    String? body,
    String notLaunchMsg = "Unable to send mail",
    String errorMsg = "Failed to send mail",
  }) async => await _myUriLaunch(
    url: Uri(scheme: 'mailto', path: email, query: '''subject=${subject ?? ''}&body=${body ?? ''}''').toString(),
    notLaunchMsg: notLaunchMsg,
    errorMsg: errorMsg,
  );

  static Future<void> sms({required String mobile, String? body, String notLaunchMsg = "Unable to send sms", String errorMsg = "Failed to send sms"}) async =>
      await _myUriLaunch(
        url: Uri(scheme: 'sms', path: mobile, query: '''body=${body ?? ''}''').toString(),
        notLaunchMsg: notLaunchMsg,
        errorMsg: errorMsg,
      );

  static Future<void> call(String s, {required String mobile, String notLaunchMsg = "Unable to dial call", String errorMsg = "Failed to call"}) async =>
      await _myUriLaunch(
        url: Uri(scheme: "tel", path: mobile).toString(),
        notLaunchMsg: notLaunchMsg,
        errorMsg: errorMsg,
      );

  static Future<void> whatsApp({
    required String mobile,
    String? msg,
    String notLaunchMsg = "Unable to open whatsapp",
    String errorMsg = "Failed to open whatsapp",
  }) async {
    String link = "https://api.whatsapp.com/send/?phone=$mobile&text=${msg ?? ''}";
    await _myUriLaunch(url: Uri.parse(link).toString(), notLaunchMsg: notLaunchMsg, errorMsg: errorMsg);
  }
}
