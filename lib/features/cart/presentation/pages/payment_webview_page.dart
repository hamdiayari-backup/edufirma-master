import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/constants/api_constants.dart';

/// WebView page for payment gateway
class PaymentWebViewPage extends StatefulWidget {
  final String url;
  final String title;

  const PaymentWebViewPage({
    super.key,
    required this.url,
    this.title = 'Paiement',
  });

  @override
  State<PaymentWebViewPage> createState() => _PaymentWebViewPageState();
}

class _PaymentWebViewPageState extends State<PaymentWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  double _progress = 0;

  /// True si la page de paiement initiale n'est pas le site LMS (ClicToPay, Konnect, etc.).
  late final bool _openedExternalPaymentHost;

  @override
  void initState() {
    super.initState();
    final initialHost = Uri.tryParse(widget.url)?.host.toLowerCase();
    final appHost = _normalizedSiteHost();
    _openedExternalPaymentHost = appHost != null &&
        initialHost != null &&
        !_hostsEqual(initialHost, appHost);
    _initWebView();
  }

  static String? _normalizedSiteHost() {
    try {
      final h = Uri.parse(ApiConstants.domain).host.toLowerCase();
      return h.isEmpty ? null : h;
    } catch (_) {
      return null;
    }
  }

  static bool _hostsEqual(String a, String b) {
    final na = a.startsWith('www.') ? a.substring(4) : a;
    final nb = b.startsWith('www.') ? b.substring(4) : b;
    return na == nb;
  }

  /// Le backend renvoie parfois vers l'accueil du site au lieu de `/payments/status`.
  static bool _isMerchantPublicLandingAfterPayment(String url) {
    final appHost = _normalizedSiteHost();
    if (appHost == null) return false;
    final uri = Uri.tryParse(url);
    if (uri == null || uri.host.isEmpty) return false;
    if (!_hostsEqual(uri.host.toLowerCase(), appHost)) return false;

    final path = uri.path;
    if (path.isEmpty || path == '/') return true;
    // Sites multilingues : /fr, /ar, …
    if (RegExp(r'^/[a-z]{2}/?$').hasMatch(path)) return true;
    if (path == '/home' || path == '/accueil') return true;
    return false;
  }

  bool _shouldPopSuccess(String url) {
    final lower = url.toLowerCase();
    if (_isBankPaymentStatusPage(lower)) return true;
    if (_openedExternalPaymentHost &&
        _isMerchantPublicLandingAfterPayment(url)) {
      return true;
    }
    return false;
  }

  /// ClicToPay (and similar) bank return: server verifies then redirects to `/payments/status`.
  static bool _isBankPaymentStatusPage(String urlLower) {
    return urlLower.contains('/payments/status');
  }

  /// Let this URL load in the WebView so the backend can finalize the order.
  static bool _isClicToPayVerifyReturn(String urlLower) {
    return urlLower.contains('payments/verify/clictopay') ||
        urlLower.contains('payment/verify/clictopay');
  }

  /// Android emulator / CA store : handshake OK sur PC, échec WebView (ex. net_error -202).
  /// [proceed] uniquement pour les hôtes officiels ClicToPay, pas un bypass SSL global.
  static bool _isTrustedClicToPayPaymentHost(String? host) {
    if (host == null || host.isEmpty) return false;
    final h = host.toLowerCase();
    return h == 'clictopay.com' || h.endsWith('.clictopay.com');
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.background)
      ..setNavigationDelegate(
        NavigationDelegate(
          onSslAuthError: (SslAuthError error) async {
            final payHost = Uri.tryParse(widget.url)?.host;
            if (_isTrustedClicToPayPaymentHost(payHost)) {
              debugPrint(
                'Payment WebView SSL: proceed for ClicToPay host=$payHost',
              );
              await error.proceed();
            } else {
              debugPrint('Payment WebView SSL: cancel (untrusted host)');
              await error.cancel();
            }
          },
          onProgress: (int progress) {
            setState(() {
              _progress = progress / 100;
            });
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
            debugPrint('Payment WebView loading: $url');
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            debugPrint('Payment WebView finished: $url');

            // Check for success/failure URLs
            _checkPaymentStatus(url);
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint(
              'WebView error: ${error.description} (type=${error.errorType}, code=${error.errorCode})',
            );
          },
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;
            final urlLower = url.toLowerCase();

            if (_shouldPopSuccess(url)) {
              Navigator.pop(context, true);
              return NavigationDecision.prevent;
            }

            if (_isClicToPayVerifyReturn(urlLower)) {
              return NavigationDecision.navigate;
            }

            final callbackSuccess =
                urlLower.contains('callback') && urlLower.contains('status=success');
            if (urlLower.contains('success') ||
                callbackSuccess ||
                (urlLower.contains('payment/verify') &&
                    !_isClicToPayVerifyReturn(urlLower))) {
              Navigator.pop(context, true);
              return NavigationDecision.prevent;
            }

            if (urlLower.contains('cancel') ||
                urlLower.contains('failed') ||
                urlLower.contains('error')) {
              Navigator.pop(context, false);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  void _checkPaymentStatus(String url) {
    final lowerUrl = url.toLowerCase();

    if (_shouldPopSuccess(url)) {
      Navigator.pop(context, true);
      return;
    }

    // Check for success indicators in URL
    if (lowerUrl.contains('success') ||
        lowerUrl.contains('approved') ||
        lowerUrl.contains('completed')) {
      Navigator.pop(context, true);
    }

    // Check for failure indicators
    if (lowerUrl.contains('failed') ||
        lowerUrl.contains('cancelled') ||
        lowerUrl.contains('rejected')) {
      Navigator.pop(context, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: AppColors.textPrimary),
          onPressed: () => _showExitConfirmation(),
        ),
        title: Text(
          widget.title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh, color: AppColors.textPrimary),
            onPressed: () => _controller.reload(),
          ),
        ],
        bottom: _isLoading
            ? PreferredSize(
                preferredSize: const Size.fromHeight(3),
                child: LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: AppColors.grey100,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : null,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading && _progress < 0.1)
            Container(
              color: AppColors.background,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: 16),
                    Text(
                      'Chargement de la page de paiement...',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showExitConfirmation() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Annuler le paiement?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir quitter? Votre paiement sera annulé.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Continuer',
              style: GoogleFonts.poppins(color: AppColors.primary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Quitter',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (shouldExit == true && mounted) {
      Navigator.pop(context, false);
    }
  }
}
