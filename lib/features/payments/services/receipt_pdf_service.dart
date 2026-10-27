import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:zeokash/core/storage/secure_storage.dart';

class ReceiptPdfService {
  static double getOperatorDiscountRate(String? op) {
    if (op == null) return 0.005;
    final lower = op.toLowerCase();
    if (lower.contains('bsnl')) return 0.015; // BSNL 1.5%
    if (lower.contains('vi') || lower.contains('vodafone') || lower.contains('idea')) return 0.020; // VI 2%
    if (lower.contains('airtel')) return 0.005; // Airtel 0.5%
    if (lower.contains('jio')) return 0.005; // Jio 0.5%
    if (lower.contains('mtnl')) return 0.005; // MTNL 0.5%
    return 0.005;
  }

  static String getOperatorDiscountPercentText(String? op) {
    final rate = getOperatorDiscountRate(op);
    final pct = rate * 100;
    if (pct == pct.roundToDouble()) {
      return '${pct.toInt()}%';
    }
    return '${pct.toStringAsFixed(1)}%';
  }

  static Map<String, double> deriveRechargeBreakdown(
    double netAmount, {
    String? operatorName,
    double? baseAmount,
    double? instantDiscount,
    double? gCoinDiscount,
  }) {
    double base = baseAmount ?? netAmount;
    final rate = getOperatorDiscountRate(operatorName);
    final discountFactor = 1.0 - rate - 0.05;
    if (baseAmount == null && netAmount > 0) {
      final possibleBase = (netAmount / discountFactor).roundToDouble();
      if ((possibleBase * discountFactor - netAmount).abs() < 0.15 && possibleBase >= 10) {
        base = possibleBase;
      }
    }
    if (base <= 0) base = 10.0;

    final inst = instantDiscount ?? double.parse((base * rate).toStringAsFixed(2));
    final gcoin = gCoinDiscount ?? double.parse((base * 0.05).toStringAsFixed(2));
    final net = double.parse((base - inst - gcoin).toStringAsFixed(2));

    return {
      'planAmount': base,
      'instantDiscount': inst,
      'gCoinDiscount': gcoin,
      'netPaid': net,
    };
  }

  static Future<Uint8List> generateReceiptPdf({
    required String title,
    required double amount,
    required String reference,
    required String date,
    required String status,
    required String paymentMode,
    required String merchant,
    String? userName,
    String? userMobile,
    String? mobileNumber,
    String? operatorName,
    String? circle,
    String? planName,
    double? baseAmount,
    double? instantDiscount,
    double? gCoinDiscount,
  }) async {
    // 1. Resolve true unicode fonts (NotoSans) to support Indian Rupee symbol & international glyphs
    pw.Font fontRegular;
    pw.Font fontBold;
    try {
      fontRegular = await PdfGoogleFonts.notoSansRegular();
      fontBold = await PdfGoogleFonts.notoSansBold();
    } catch (_) {
      fontRegular = pw.Font.helvetica();
      fontBold = pw.Font.helveticaBold();
    }

    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: fontRegular,
        bold: fontBold,
      ),
    );

    // 2. Load Brand Logo
    pw.MemoryImage? logoImage;
    try {
      final logoBytes = await rootBundle.load('assets/images/paisaji_primary.png');
      logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
    } catch (_) {
      try {
        final monoBytes = await rootBundle.load('assets/images/paisaji_monogram.png');
        logoImage = pw.MemoryImage(monoBytes.buffer.asUint8List());
      } catch (_) {}
    }

    // 3. User & Customer Details for Bill Top
    String effectiveUserName = userName ?? '';
    String effectiveUserMobile = userMobile ?? '';
    if (effectiveUserName.isEmpty || effectiveUserMobile.isEmpty) {
      try {
        final storage = SecureStorageService();
        final storedName = await storage.getFullName();
        final storedMobile = await storage.getLastMobileNumber();
        if (effectiveUserName.isEmpty && storedName != null && storedName.isNotEmpty) {
          effectiveUserName = storedName;
        }
        if (effectiveUserMobile.isEmpty && storedMobile != null && storedMobile.isNotEmpty) {
          effectiveUserMobile = storedMobile;
        }
      } catch (_) {}
    }
    if (effectiveUserName.isEmpty) effectiveUserName = 'amitesh';
    if (effectiveUserMobile.isEmpty) effectiveUserMobile = '+91 8448302749';

    // 4. Sanitize Service Details and Extract Operator/Circle/Mobile
    String cleanTitle = title;
    if (cleanTitle.contains('for MOBILE_RECHARGE') || cleanTitle.toLowerCase().contains('wallet spend')) {
      cleanTitle = 'Mobile Prepaid Recharge';
    }

    String effectiveOperator = operatorName ?? '';
    String effectiveCircle = circle ?? '';
    String effectiveConsumerMobile = mobileNumber ?? '';
    String effectivePlanName = planName ?? '';

    // Smart extraction from raw text if not explicitly provided
    if (effectiveOperator.isEmpty) {
      final lower = title.toLowerCase();
      if (lower.contains('airtel')) {
        effectiveOperator = 'Airtel';
      } else if (lower.contains('jio')) {
        effectiveOperator = 'Jio';
      } else if (lower.contains('vi') || lower.contains('vodafone') || lower.contains('idea')) {
        effectiveOperator = 'Vi';
      } else if (lower.contains('bsnl')) {
        effectiveOperator = 'BSNL';
      } else {
        effectiveOperator = 'Airtel';
      }
    }
    if (effectiveCircle.isEmpty) {
      effectiveCircle = 'Delhi NCR';
    }
    if (effectiveConsumerMobile.isEmpty) {
      final match = RegExp(r'(\+?91)?[6-9]\d{9}').firstMatch(title);
      if (match != null) {
        effectiveConsumerMobile = match.group(0)!;
      } else {
        effectiveConsumerMobile = effectiveUserMobile;
      }
    }
    if (effectivePlanName.isEmpty) {
      effectivePlanName = 'Prepaid Recharge Plan';
    }

    // 5. Derive MNC Standard Breakdown:
    // Recharge Value: 10.00, Instant Discount (1%): 0.10, G Coin (5%): 0.50, Net Paid: 9.40
    final breakdown = deriveRechargeBreakdown(
      amount,
      operatorName: operatorName,
      baseAmount: baseAmount,
      instantDiscount: instantDiscount,
      gCoinDiscount: gCoinDiscount,
    );
    final discountPctText = getOperatorDiscountPercentText(operatorName);

    final double effectiveBase = breakdown['planAmount']!;
    final double effectiveInstant = breakdown['instantDiscount']!;
    final double effectiveGCoin = breakdown['gCoinDiscount']!;
    final double effectiveNet = breakdown['netPaid']!;

    final isSuccess = status.toUpperCase() == 'SUCCESS' ||
        status.toUpperCase() == 'COMPLETED' ||
        status.toUpperCase() == 'POSTED';

    final primaryColor = PdfColor.fromInt(0xFF0047AB); // PaisaJi Brand Navy
    final successColor = PdfColor.fromInt(0xFF16A34A);
    final errorColor = PdfColor.fromInt(0xFFDC2626);
    final warningColor = PdfColor.fromInt(0xFFD97706);
    final textDark = PdfColor.fromInt(0xFF0F172A);
    final textGray = PdfColor.fromInt(0xFF64748B);
    final bgLight = PdfColor.fromInt(0xFFF8FAFC);
    final borderGray = PdfColor.fromInt(0xFFE2E8F0);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ================= Header Section =================
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (logoImage != null)
                        pw.Image(logoImage, height: 36)
                      else
                        pw.Text(
                          'PaisaJi',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        'PaisaJi Technologies India Private Limited',
                        style: pw.TextStyle(fontSize: 8, color: textGray),
                      ),
                      pw.Text(
                        'CIN: U72900DL2024PTC123456 | GSTIN: 07AAACP1234P1Z2',
                        style: pw.TextStyle(fontSize: 8, color: textGray),
                      ),
                      pw.Text(
                        'Email: support@paisaji.com | Web: https://paisaji.com',
                        style: pw.TextStyle(fontSize: 8, color: textGray),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: pw.BoxDecoration(
                          color: isSuccess ? PdfColor.fromInt(0xFFDCFCE7) : PdfColor.fromInt(0xFFFEE2E2),
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                        ),
                        child: pw.Text(
                          isSuccess ? 'TRANSACTION SUCCESSFUL' : 'TRANSACTION FAILED',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: isSuccess ? successColor : errorColor,
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        'TAX INVOICE / RECEIPT',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      pw.Text('Date: $date', style: pw.TextStyle(fontSize: 8, color: textGray)),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 12),
              pw.Divider(color: borderGray, thickness: 1),
              pw.SizedBox(height: 10),

              // ================= Bill Top: Username & Mobile Number =================
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: pw.BoxDecoration(
                  color: bgLight,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  border: pw.Border.all(color: borderGray, width: 0.8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'BILLED TO (CUSTOMER DETAILS)',
                          style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: textGray),
                        ),
                        pw.SizedBox(height: 3),
                        pw.Text(
                          'Customer Name: $effectiveUserName',
                          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: textDark),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Registered Mobile: $effectiveUserMobile',
                          style: pw.TextStyle(fontSize: 9, color: textDark),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'ORDER REFERENCE',
                          style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: textGray),
                        ),
                        pw.SizedBox(height: 3),
                        pw.Text(
                          reference,
                          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: primaryColor),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Currency: Indian Rupee (INR)',
                          style: pw.TextStyle(fontSize: 8, color: textGray),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 12),

              // ================= Hero Total Net Paid Card =================
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(14),
                decoration: pw.BoxDecoration(
                  color: bgLight,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
                  border: pw.Border.all(color: borderGray),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Total Net Paid (Wallet Deducted)', style: pw.TextStyle(fontSize: 10, color: textGray)),
                        pw.SizedBox(height: 3),
                        pw.Text(
                          'INR ${effectiveNet.toStringAsFixed(2)}',
                          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: textDark),
                        ),
                        pw.Text(
                          'Recharge Plan: INR ${effectiveBase.toStringAsFixed(2)}',
                          style: pw.TextStyle(fontSize: 9, color: primaryColor, fontWeight: pw.FontWeight.bold),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Service Description', style: pw.TextStyle(fontSize: 9, color: textGray)),
                        pw.SizedBox(height: 3),
                        pw.Text(cleanTitle, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: textDark)),
                        pw.Text('Consumer Number: $effectiveConsumerMobile', style: pw.TextStyle(fontSize: 9, color: textGray)),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 14),

              // ================= Transaction Summary Section =================
              pw.Text('Transaction Summary', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: primaryColor)),
              pw.SizedBox(height: 6),

              pw.Table(
                border: pw.TableBorder.all(color: borderGray, width: 0.5),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3.8),
                  1: const pw.FlexColumnWidth(6.2),
                },
                children: [
                  _buildTableRow('Transaction Reference ID', reference, textDark, textGray),
                  _buildTableRow('Recharge Plan', '$effectivePlanName (INR ${effectiveBase.toStringAsFixed(2)})', textDark, textGray),
                  _buildTableRow('Telecom Operator', effectiveOperator, textDark, textGray),
                  _buildTableRow('Telecom Circle', effectiveCircle, textDark, textGray),
                  _buildTableRow('Consumer Mobile Number', effectiveConsumerMobile, textDark, textGray),
                  _buildTableRow('Payment Method', paymentMode, textDark, textGray),
                  _buildTableRow('Transaction Timestamp', date, textDark, textGray),
                  _buildTableRow('Merchant / Gateway', merchant, textDark, textGray),
                  _buildTableRow('Transaction Status', isSuccess ? 'SUCCESS' : 'FAILED', isSuccess ? successColor : errorColor, textGray, isStatus: true),
                ],
              ),

              pw.SizedBox(height: 14),

              // ================= Payment & Plan Breakdown (MNC Aligned) =================
              pw.Text('Payment & Plan Breakdown', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: primaryColor)),
              pw.SizedBox(height: 6),

              pw.Table(
                border: pw.TableBorder.all(color: borderGray, width: 0.5),
                columnWidths: {
                  0: const pw.FlexColumnWidth(4.5),
                  1: const pw.FlexColumnWidth(2.5),
                  2: const pw.FlexColumnWidth(3.0),
                },
                children: [
                  // Table Header
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: bgLight),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        child: pw.Text('Item Description', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: textDark)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        child: pw.Text('Rate / Details', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: textDark)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        child: pw.Text('Amount in Indian Rupee', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: textDark)),
                      ),
                    ],
                  ),
                  // Row 1: Recharge Plan Value
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        child: pw.Text('Mobile Recharge Value', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: textDark)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        child: pw.Text('Base Plan', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 9, color: textGray)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        child: pw.Text('INR ${effectiveBase.toStringAsFixed(2)}', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: textDark)),
                      ),
                    ],
                  ),
                  // Row 2: Instant Discount
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        child: pw.Text('Instant Discount ($discountPctText)', style: pw.TextStyle(fontSize: 9, color: successColor)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        child: pw.Text('$discountPctText Instant Off', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 9, color: successColor)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        child: pw.Text('- INR ${effectiveInstant.toStringAsFixed(2)}', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: successColor)),
                      ),
                    ],
                  ),
                  // Row 3: G Coins Discount (5%)
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        child: pw.Text('G Coins Redeemed (5% Applied)', style: pw.TextStyle(fontSize: 9, color: warningColor)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        child: pw.Text('5.0% GCoin Off', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 9, color: warningColor)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        child: pw.Text('- INR ${effectiveGCoin.toStringAsFixed(2)}', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: warningColor)),
                      ),
                    ],
                  ),
                  // Row 4: Total Net Paid
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: bgLight),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        child: pw.Text('Total Net Paid (Wallet Deducted)', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: textDark)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        child: pw.Text('Net Paid', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        child: pw.Text('INR ${effectiveNet.toStringAsFixed(2)}', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                      ),
                    ],
                  ),
                ],
              ),

              pw.Spacer(),

              // ================= Footer & Support Notice =================
              pw.Divider(color: borderGray, thickness: 1),
              pw.SizedBox(height: 6),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Need help with this transaction?', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: textDark)),
                      pw.Text('Contact PaisaJi 24x7 Support: support@paisaji.com | WhatsApp: +91 8448302749', style: pw.TextStyle(fontSize: 8, color: textGray)),
                      pw.Text('PaisaJi Verified Secure Payment Gateway', style: pw.TextStyle(fontSize: 8, color: textGray)),
                    ],
                  ),
                  pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: 'https://paisaji.com/verify?ref=$reference&amt=$effectiveNet',
                    width: 40,
                    height: 40,
                  ),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Center(
                child: pw.Text(
                  'This is a digitally generated electronic receipt authorized by PaisaJi Technologies India Private Limited.',
                  style: pw.TextStyle(fontSize: 7, color: textGray),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.TableRow _buildTableRow(String label, String value, PdfColor textColor, PdfColor labelColor, {bool isStatus = false}) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
          child: pw.Text(label, style: pw.TextStyle(fontSize: 8.5, color: labelColor)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
          child: pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 8.5,
              fontWeight: isStatus ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }

  static Future<void> downloadOrShareReceipt(
    BuildContext context, {
    required String title,
    required double amount,
    required String reference,
    required String date,
    required String status,
    required String paymentMode,
    required String merchant,
    String? userName,
    String? userMobile,
    String? mobileNumber,
    String? operatorName,
    String? circle,
    String? planName,
    double? baseAmount,
    double? instantDiscount,
    double? gCoinDiscount,
  }) async {
    try {
      final pdfBytes = await generateReceiptPdf(
        title: title,
        amount: amount,
        reference: reference,
        date: date,
        status: status,
        paymentMode: paymentMode,
        merchant: merchant,
        userName: userName,
        userMobile: userMobile,
        mobileNumber: mobileNumber,
        operatorName: operatorName,
        circle: circle,
        planName: planName,
        baseAmount: baseAmount,
        instantDiscount: instantDiscount,
        gCoinDiscount: gCoinDiscount,
      );

      final tempDir = await getTemporaryDirectory();
      final sanitizedRef = reference.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
      final fileName = 'PaisaJi_Receipt_$sanitizedRef.pdf';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(pdfBytes);

      await SharePlus.instance.share(
        ShareParams(
          subject: 'PaisaJi Transaction Receipt - $reference',
          files: [XFile(file.path, mimeType: 'application/pdf', name: fileName)],
        ),
      );
    } catch (e) {
      debugPrint('Error generating/sharing PDF receipt: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate PDF: $e')),
        );
      }
    }
  }

  static Future<void> printReceipt({
    required String title,
    required double amount,
    required String reference,
    required String date,
    required String status,
    required String paymentMode,
    required String merchant,
    String? userName,
    String? userMobile,
    String? mobileNumber,
    String? operatorName,
    String? circle,
    String? planName,
    double? baseAmount,
    double? instantDiscount,
    double? gCoinDiscount,
  }) async {
    final pdfBytes = await generateReceiptPdf(
      title: title,
      amount: amount,
      reference: reference,
      date: date,
      status: status,
      paymentMode: paymentMode,
      merchant: merchant,
      userName: userName,
      userMobile: userMobile,
      mobileNumber: mobileNumber,
      operatorName: operatorName,
      circle: circle,
      planName: planName,
      baseAmount: baseAmount,
      instantDiscount: instantDiscount,
      gCoinDiscount: gCoinDiscount,
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'PaisaJi_Receipt_$reference.pdf',
    );
  }
}
