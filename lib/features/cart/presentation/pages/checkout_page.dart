import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio;
import '../../../../config/theme/app_colors.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../providers/cart_provider.dart';
import '../../../../providers/profile_provider.dart';
import '../../../../providers/app_language_provider.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/services/offline_payment_service.dart';
import '../../../../core/network/http_client.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/constants/api_constants.dart';
import '../../data/models/checkout_model.dart';
import '../../data/models/cart_model.dart';
import 'payment_webview_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  CheckoutModel? _checkoutData;
  PaymentChannel? _selectedPaymentChannel;
  bool _isLoading = true;
  bool _isProcessingPayment = false;
  OfflinePaymentService? _offlinePaymentService;

  /// Parses gateway JSON from [POST /panel/payments/request] (e.g. ClicToPay `pay_url` in `data`).
  static String? _extractGatewayPaymentUrl(String body) {
    final trimmed = body.trim();
    if (trimmed.startsWith('http')) return trimmed;
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) return null;
      String? pick(Map<String, dynamic>? m) {
        if (m == null) return null;
        for (final key in ['pay_url', 'redirect_url', 'url', 'payment_url']) {
          final v = m[key];
          if (v is String && v.trim().isNotEmpty && v.startsWith('http')) {
            return v.trim();
          }
        }
        return null;
      }

      Map<String, dynamic>? dataMap;
      final data = decoded['data'];
      if (data is Map<String, dynamic>) {
        dataMap = data;
      } else if (data is Map) {
        dataMap = Map<String, dynamic>.from(data);
      }
      return pick(decoded) ?? pick(dataMap);
    } catch (_) {
      final urlMatch = RegExp(r'https?://[^\s"<>]+').firstMatch(body);
      return urlMatch?.group(0);
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize offline payment service
    _initializeOfflinePaymentService();
    // Defer the loading to after the build phase to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCheckoutData();
    });
  }

  void _initializeOfflinePaymentService() {
    try {
      final storage = LocalStorage();
      final dioInstance = dio.Dio();
      final httpClient = HttpClient(storage, dioInstance);
      _offlinePaymentService = OfflinePaymentService(httpClient, storage);
    } catch (e) {
      // Silently handle initialization errors
    }
  }

  Future<void> _loadCheckoutData() async {
    setState(() => _isLoading = true);

    final checkoutData = await context.read<CartProvider>().checkout();

    if (checkoutData != null) {
      // Add account charge option (title will be translated in UI)
      checkoutData.paymentChannels ??= [];
      // Hide legacy bank card gateway in mobile (ClicToPay is used instead).
      checkoutData.paymentChannels!.removeWhere((channel) =>
          (channel.title ?? '').trim().toLowerCase() == 'carte bancaire');
      checkoutData.paymentChannels!.add(
        PaymentChannel(
          id: -1,
          title: 'account_balance', // Translation key
          type: 'charge',
          image: 'wallet',
        ),
      );

      // Add offline payment option if no offline channels exist
      final hasOfflineChannel = checkoutData.paymentChannels!
          .any((channel) => channel.type == 'offline');
      if (!hasOfflineChannel) {
        checkoutData.paymentChannels!.add(
          PaymentChannel(
            id: -2,
            title: 'Virement Bancaire',
            type: 'offline',
            image: 'bank',
          ),
        );
      }

      // Add pay with points option if user has points
      try {
        final profileProvider = context.read<ProfileProvider>();
        await profileProvider.fetchDashboard();
        await profileProvider.fetchRewards();
        final availablePoints = profileProvider.dashboard?['available_points'];
        final points = availablePoints is int
            ? availablePoints
            : (availablePoints != null
                ? int.tryParse(availablePoints.toString())
                : null);
        if (points != null && points > 0) {
          checkoutData.paymentChannels!.add(
            PaymentChannel(
              id: -3,
              title: 'Payer avec les points',
              type: 'points',
              image: 'medal',
            ),
          );
        }
      } catch (_) {}
    }

    setState(() {
      _checkoutData = checkoutData;
      _isLoading = false;
    });
  }

  Future<void> _processPayment() async {
    if (_selectedPaymentChannel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un mode de paiement'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() => _isProcessingPayment = true);

    try {
      final cartProvider = context.read<CartProvider>();

      if (_selectedPaymentChannel!.type == 'charge') {
        // Pay with account balance
        if (_checkoutData?.order?.id != null) {
          final success =
              await cartProvider.payWithCredit(_checkoutData!.order!.id!);

          if (success && mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.paymentStatus,
              (route) => route.isFirst,
              arguments: 'success',
            );
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Solde insuffisant'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          }
        } else {
          throw Exception('Aucune commande trouvée pour le paiement par solde');
        }
      } else if (_selectedPaymentChannel!.type == 'online') {
        // Online payment via gateway
        if (_checkoutData?.order?.id == null ||
            _selectedPaymentChannel?.id == null) {
          throw Exception('Données de commande invalides');
        }

        // Le backend utilise le montant de la commande (order total) — pas de montant client
        final paymentResponse = await cartProvider.requestPayment(
          _selectedPaymentChannel!.id!,
          _checkoutData!.order!.id!,
        );

        if (paymentResponse != null && mounted) {
          // The response might be a URL or HTML page
          String? paymentUrl;

          if (paymentResponse is String) {
            paymentUrl = _extractGatewayPaymentUrl(paymentResponse);
          }

          final finalPaymentUrl = paymentUrl;
          if (finalPaymentUrl != null && finalPaymentUrl.isNotEmpty) {
            // Navigate to WebView page for payment
            if (mounted) {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentWebViewPage(
                    url: finalPaymentUrl,
                    title: 'Paiement',
                  ),
                ),
              );

              // After returning from payment
              if (mounted) {
                if (result == true) {
                  // Payment was successful
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.paymentStatus,
                    (route) => route.isFirst,
                    arguments: 'success',
                  );
                } else {
                  // Payment was cancelled or pending
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.paymentStatus,
                    (route) => route.isFirst,
                    arguments: 'pending',
                  );
                }
              }
            }
          } else {
            throw Exception('URL de paiement invalide');
          }
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors du paiement'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else if (_selectedPaymentChannel!.type == 'offline') {
        // Offline payment — montant = total de la commande (backend)
        final orderAmount = _checkoutData?.amounts?.totalDouble ?? 0.0;
        final orderId = _checkoutData?.order?.id;

        if (orderId != null &&
            orderAmount > 0 &&
            _offlinePaymentService != null) {
          _showOfflinePaymentForm(orderId, orderAmount);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Informations de commande invalides'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else if (_selectedPaymentChannel!.type == 'points') {
        // Pay entire order with loyalty points
        final orderId = _checkoutData?.order?.id;
        if (orderId != null) {
          final result = await cartProvider.payWithPoints(orderId);
          if (mounted) {
            final ok = result['success'] == true;
            if (ok) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.paymentStatus,
                (route) => route.isFirst,
                arguments: 'success',
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    result['message']?.toString() ??
                        'Points insuffisants ou paiement en points impossible',
                  ),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Informations de commande invalides'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Payment error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessingPayment = false);
      }
    }
  }

  /// Format total for display (montant après remise, 2 decimals)
  String _formatCheckoutTotal(CartAmounts? amounts) {
    if (amounts != null) {
      return amounts.totalDouble.toStringAsFixed(2);
    }
    final orderAmount = _checkoutData?.order?.totalAmount;
    if (orderAmount == null) return '0.00';
    if (orderAmount is num) return orderAmount.toDouble().toStringAsFixed(2);
    return (double.tryParse(orderAmount.toString()) ?? 0.0).toStringAsFixed(2);
  }

  void _showOfflinePaymentForm(int orderId, double amount) {
    final picker = ImagePicker();
    File? attachment;
    String referenceNumber = '';
    String payDate = DateTime.now().toString().substring(0, 10);
    int? selectedBankId;
    List<dynamic> banks = [];
    bool isLoadingBanks = true;
    bool isSubmitting = false;
    bool isPickingImage = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          // Load bank info on first build
          if (isLoadingBanks && banks.isEmpty) {
            _offlinePaymentService?.getBankAccountInfo().then((bankData) {
              if (bankData != null) {
                setModalState(() {
                  banks = bankData['banks'] as List? ?? [];
                  isLoadingBanks = false;
                  // Auto-select first bank if available
                  if (banks.isNotEmpty) {
                    selectedBankId = banks.first['id'] as int?;
                  }
                });
              } else {
                setModalState(() {
                  isLoadingBanks = false;
                });
              }
            });
          }

          return Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child:
                            const Icon(Iconsax.bank, color: AppColors.primary),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Paiement hors ligne',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Montant à payer: ${amount.toStringAsFixed(2)} TND',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Bank Selection and Information
                  if (isLoadingBanks)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child:
                            CircularProgressIndicator(color: AppColors.primary),
                      ),
                    )
                  else if (banks.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.orange),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Aucune banque disponible. Veuillez contacter le support.',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    // Bank Selection Dropdown
                    Text(
                      'Sélectionner une banque *',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.grey300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: selectedBankId,
                          hint: Text(
                            'Choisir une banque',
                            style: GoogleFonts.poppins(
                                color: AppColors.textSecondary),
                          ),
                          items: banks.map<DropdownMenuItem<int>>((bank) {
                            return DropdownMenuItem<int>(
                              value: bank['id'] as int?,
                              child: Text(
                                bank['title'] ?? 'Banque',
                                style: GoogleFonts.poppins(),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setModalState(() {
                              selectedBankId = value;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Display selected bank specifications
                    if (selectedBankId != null) ...[
                      Builder(builder: (context) {
                        final selectedBank = banks.firstWhere(
                          (b) => b['id'] == selectedBankId,
                          orElse: () => null,
                        );
                        if (selectedBank == null) return const SizedBox();

                        final specs =
                            selectedBank['specifications'] as List? ?? [];
                        final bankTitle = selectedBank['title'] ?? 'Banque';
                        final bankLogo = selectedBank['logo'];

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppColors.primary.withOpacity(0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Bank header with logo
                              Row(
                                children: [
                                  if (bankLogo != null &&
                                      bankLogo.toString().isNotEmpty)
                                    Container(
                                      width: 50,
                                      height: 50,
                                      margin: const EdgeInsets.only(right: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: AppColors.grey300),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          bankLogo.toString(),
                                          fit: BoxFit.contain,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(
                                            Iconsax.bank,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Effectuez votre virement vers:',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        Text(
                                          bankTitle,
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),

                              // Bank specifications with copy buttons
                              if (specs.isNotEmpty) ...[
                                ...specs.map<Widget>((spec) {
                                  final specName =
                                      spec['name']?.toString() ?? '';
                                  final specValue =
                                      spec['value']?.toString() ?? '';
                                  final isAccountNumber = specName
                                          .toLowerCase()
                                          .contains('rib') ||
                                      specName.toLowerCase().contains('iban') ||
                                      specName
                                          .toLowerCase()
                                          .contains('compte') ||
                                      specName
                                          .toLowerCase()
                                          .contains('account') ||
                                      specName.toLowerCase().contains('numéro');

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border:
                                          Border.all(color: AppColors.grey300),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                specName,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                specValue,
                                                style: GoogleFonts.poppins(
                                                  fontSize:
                                                      isAccountNumber ? 16 : 14,
                                                  fontWeight: isAccountNumber
                                                      ? FontWeight.bold
                                                      : FontWeight.w500,
                                                  color: AppColors.textPrimary,
                                                  letterSpacing:
                                                      isAccountNumber ? 1.2 : 0,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (specValue.isNotEmpty)
                                          IconButton(
                                            onPressed: () {
                                              Clipboard.setData(ClipboardData(
                                                  text: specValue));
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content:
                                                      Text('$specName copié!'),
                                                  duration: const Duration(
                                                      seconds: 1),
                                                  backgroundColor:
                                                      AppColors.primary,
                                                ),
                                              );
                                            },
                                            icon: const Icon(
                                              Iconsax.copy,
                                              size: 20,
                                              color: AppColors.primary,
                                            ),
                                            tooltip: 'Copier',
                                          ),
                                      ],
                                    ),
                                  );
                                }),
                              ] else ...[
                                // Show message if no specifications
                                Text(
                                  'Veuillez contacter le support pour obtenir les coordonnées bancaires.',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],

                              // Important notice
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Iconsax.info_circle,
                                      size: 20,
                                      color: Colors.orange,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Utilisez exactement ces coordonnées pour votre virement',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.orange.shade800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                    ],
                  ],

                  // Reference number
                  Text(
                    'Numéro de référence *',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    onChanged: (value) {
                      referenceNumber = value;
                    },
                    decoration: InputDecoration(
                      hintText: 'Entrez le numéro de référence du virement',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Pay date
                  Text(
                    'Date de paiement *',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: TextEditingController(text: payDate),
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate:
                            DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setModalState(() {
                          payDate = date.toString().substring(0, 10);
                        });
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Sélectionnez la date',
                      suffixIcon: const Icon(Iconsax.calendar,
                          color: AppColors.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Attachment
                  Text(
                    'Preuve de paiement (optionnel)',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: isPickingImage
                        ? null
                        : () async {
                            setModalState(() => isPickingImage = true);
                            try {
                              final pickedFile = await picker.pickImage(
                                  source: ImageSource.gallery);
                              if (pickedFile != null) {
                                setModalState(() {
                                  attachment = File(pickedFile.path);
                                });
                              }
                            } catch (e) {
                              // Handle image picker error silently
                            } finally {
                              setModalState(() => isPickingImage = false);
                            }
                          },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.grey300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Iconsax.document_upload,
                              color: AppColors.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              attachment != null
                                  ? attachment!.path.split('/').last
                                  : 'Cliquez pour télécharger la preuve de paiement',
                              style: GoogleFonts.poppins(
                                color: attachment != null
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: referenceNumber.isEmpty ||
                              payDate.isEmpty ||
                              selectedBankId == null ||
                              isSubmitting
                          ? null
                          : () async {
                              setModalState(() => isSubmitting = true);

                              final result = await _offlinePaymentService
                                      ?.createOfflinePaymentWithOrder(
                                    orderId: orderId,
                                    bankId: selectedBankId!,
                                    referenceNumber: referenceNumber,
                                    payDate: payDate,
                                    amount: amount,
                                    attachment: attachment,
                                  ) ??
                                  {
                                    'success': false,
                                    'message':
                                        'Service de paiement hors ligne indisponible'
                                  };

                              if (mounted) {
                                Navigator.pop(context);
                                setState(() => _isProcessingPayment = false);

                                final isOfflineSuccess =
                                    result['success'] == true ||
                                        result['success'] == 1;
                                // Paiement hors ligne soumis = succès (vert), jamais rouge
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(result['message'] ??
                                        'Votre demande de paiement hors ligne a été soumise'),
                                    backgroundColor: isOfflineSuccess
                                        ? AppColors.success
                                        : Colors.red,
                                    duration: const Duration(seconds: 4),
                                  ),
                                );

                                if (isOfflineSuccess) {
                                  // Navigate to payment status or orders page
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    AppRoutes.paymentStatus,
                                    (route) => route.isFirst,
                                    arguments: 'pending',
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Soumettre la preuve de paiement'),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<AppLanguageProvider>().currentLanguage;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'payment_method'.tr(locale),
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _checkoutData == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Iconsax.warning_2,
                        size: 60,
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'error'.tr(locale),
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _loadCheckoutData,
                        child: Text('retry'.tr(locale)),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    // Payment Methods Grid
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 180),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Payment Methods Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'payment_methods'.tr(locale),
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'select_payment_method'.tr(locale),
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: GridView.builder(
                              physics: const BouncingScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 1.2,
                              ),
                              itemCount:
                                  _checkoutData!.paymentChannels?.length ?? 0,
                              itemBuilder: (context, index) {
                                final channel =
                                    _checkoutData!.paymentChannels![index];
                                final isSelected =
                                    _selectedPaymentChannel?.id == channel.id;

                                return _buildPaymentMethodCard(
                                    channel, isSelected, index, locale);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Bottom Payment Panel
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: _buildBottomPanel(locale),
                    ),
                  ],
                ),
    );
  }

  Widget _buildPaymentMethodCard(
      PaymentChannel channel, bool isSelected, int index, String locale) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentChannel = channel;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : AppColors.cardShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (channel.type == 'charge') ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.wallet_2,
                  size: 36,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                channel.type == 'charge'
                    ? 'account_balance'.tr(locale)
                    : (channel.title ?? 'payment_method'.tr(locale)),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_checkoutData?.userCharge ?? 0} TND',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ] else ...[
              if (channel.isClicToPay)
                Image.asset(
                  'assets/images/clic.png',
                  height: 50,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    Iconsax.card,
                    size: 40,
                    color: AppColors.primary,
                  ),
                )
              else if (channel.image != null && channel.image!.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: '${ApiConstants.domain}${channel.image}',
                  height: 50,
                  fit: BoxFit.contain,
                  errorWidget: (_, __, ___) => Icon(
                    channel.type == 'offline'
                        ? Iconsax.bank
                        : channel.type == 'points'
                            ? Iconsax.medal_star
                            : Iconsax.card,
                    size: 40,
                    color: AppColors.primary,
                  ),
                )
              else
                Icon(
                  channel.type == 'offline'
                      ? Iconsax.bank
                      : channel.type == 'points'
                          ? Iconsax.medal_star
                          : Iconsax.card,
                  size: 40,
                  color: AppColors.primary,
                ),
              const SizedBox(height: 12),
              Text(
                channel.title ?? 'Paiement',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              if (channel.type == 'points')
                Builder(
                  builder: (ctx) {
                    final rewardsData = ctx.read<ProfileProvider>().rewardsData;
                    final cr = rewardsData?['conversion_rate']
                        as Map<String, dynamic>?;
                    final pointsPerUnit = cr?['points_per_unit'];
                    final sign = rewardsData?['currency_sign']?.toString() ??
                        rewardsData?['currency']?['sign']?.toString() ??
                        (locale == 'ar' ? 'د.ت' : 'TND');
                    final showRate = pointsPerUnit != null &&
                        (pointsPerUnit is int
                            ? pointsPerUnit > 0
                            : (int.tryParse(pointsPerUnit.toString()) ?? 0) >
                                0);
                    if (showRate) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '$pointsPerUnit points = 1 $sign',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
            ],
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(
          duration: 400.ms,
          delay: Duration(milliseconds: 100 * index),
        )
        .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
  }

  Widget _buildBottomPanel(String locale) {
    // Total = montant de la commande (backend). Pas de recalcul client.
    final amounts = _checkoutData?.amounts;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      transform: Matrix4.translationValues(
        0,
        _selectedPaymentChannel != null ? 0 : 150,
        0,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'total'.tr(locale),
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      '${_formatCheckoutTotal(amounts)} TND',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isProcessingPayment ? null : _processPayment,
                  icon: _isProcessingPayment
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Iconsax.tick_circle),
                  label: Text(
                    _isProcessingPayment
                        ? 'processing'.tr(locale)
                        : 'confirm_payment'.tr(locale),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
