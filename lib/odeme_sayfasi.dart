import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OdemeSayfasi extends StatefulWidget {
  final String requestId;
  final String listingTitle;
  final String price;

  const OdemeSayfasi({
    super.key,
    required this.requestId,
    required this.listingTitle,
    required this.price,
  });

  @override
  State<OdemeSayfasi> createState() => _OdemeSayfasiState();
}

class _OdemeSayfasiState extends State<OdemeSayfasi> {
  final TextEditingController cardNameController = TextEditingController();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiryController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();
  final TextEditingController secureCodeController = TextEditingController();

  bool odemeYapiliyor = false;
  bool secureStep = false;

  String kartMarkasi() {
    final number = cardNumberController.text.trim();

    if (number.startsWith('4')) {
      return 'VISA';
    }

    if (number.startsWith('5')) {
      return 'Mastercard';
    }

    return 'Card';
  }

  String gizliKartNumarasi() {
    final number = cardNumberController.text.trim();

    if (number.isEmpty) {
      return '•••• •••• •••• ••••';
    }

    final visible = number.length <= 4
        ? number
        : number.substring(number.length - 4);

    return '•••• •••• •••• $visible';
  }

  @override
  void dispose() {
    cardNameController.dispose();
    cardNumberController.dispose();
    expiryController.dispose();
    cvvController.dispose();
    secureCodeController.dispose();
    super.dispose();
  }

  void kartBilgileriniKontrolEt() {
    final cardName = cardNameController.text.trim();
    final cardNumber = cardNumberController.text.trim();
    final expiry = expiryController.text.trim();
    final cvv = cvvController.text.trim();

    if (cardName.isEmpty ||
        cardNumber.isEmpty ||
        expiry.isEmpty ||
        cvv.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all payment fields.'),
        ),
      );
      return;
    }

    if (cardNumber.replaceAll(' ', '').length != 16) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid card number.'),
        ),
      );
      return;
    }

    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(expiry)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter expiry date as MM/YY.'),
        ),
      );
      return;
    }

    final parts = expiry.split('/');
    final int? month = int.tryParse(parts[0]);
    final int? yearShort = int.tryParse(parts[1]);

    if (month == null || yearShort == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid expiry date.'),
        ),
      );
      return;
    }

    if (month < 1 || month > 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Expiry month must be between 01 and 12.'),
        ),
      );
      return;
    }

    final now = DateTime.now();
    final int currentYear = now.year;
    final int currentMonth = now.month;

    final int fullYear = 2000 + yearShort;
    final int maxAllowedYear = currentYear + 10;

    if (fullYear < currentYear ||
        (fullYear == currentYear && month < currentMonth)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Expiry date cannot be in the past.'),
        ),
      );
      return;
    }

    if (fullYear > maxAllowedYear) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Expiry date cannot be more than 10 years from now.'),
        ),
      );
      return;
    }
    if (cvv.length != 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid CVV.'),
        ),
      );
      return;
    }

    setState(() {
      secureStep = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('3D Secure code sent. Demo code: 123456'),
      ),
    );
  }

  Future<void> odemeYap() async {
    final secureCode = secureCodeController.text.trim();

    if (secureCode != '123456') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid 3D Secure code.'),
        ),
      );
      return;
    }

    try {
      setState(() {
        odemeYapiliyor = true;
      });

      await FirebaseFirestore.instance
          .collection('booking_requests')
          .doc(widget.requestId)
          .update({
        'paymentStatus': 'paid',
        'escrowStatus': 'held',
        'paymentMethod': 'demo_card',
        'threeDSecureVerified': true,
        'paidAt': FieldValue.serverTimestamp(),
        'providerSeen': false,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment completed. The payment is held safely.'),
        ),
      );

      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment error: $e'),
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        odemeYapiliyor = false;
      });
    }
  }

  Widget inputField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    void Function(String)? onChanged,
  }) {

    
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  Widget kartOnizleme() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF064B35),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.20),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(
                Icons.credit_card,
                color: Colors.white,
                size: 34,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  kartMarkasi(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            gizliKartNumarasi(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              letterSpacing: 1.8,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  cardNameController.text.trim().isEmpty
                      ? 'CARD HOLDER'
                      : cardNameController.text.trim().toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                expiryController.text.trim().isEmpty
                    ? 'MM/YY'
                    : expiryController.text.trim(),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  

  @override
  Widget build(BuildContext context) {
    const Color mainGreen = Color(0xFF0B7A53);
    const Color cardGreen = Color(0xFF168A61);

    return Scaffold(
      backgroundColor: mainGreen,
      appBar: AppBar(
        backgroundColor: mainGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Payment',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardGreen,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.payment,
                color: Colors.white,
                size: 48,
              ),
              const SizedBox(height: 18),
              const Text(
                'Payment Summary',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Service: ${widget.listingTitle}',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 10),
              Text(
                'Amount: ${widget.price}',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 22),

              if (!secureStep) ...[
                kartOnizleme(),
                const SizedBox(height: 22),
                const Text(
                  'Card Information',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                inputField(
                  controller: cardNameController,
                  hint: 'Card Holder Name',
                  onChanged: (_) {
                    setState(() {});
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: cardNumberController,
                  keyboardType: TextInputType.number,
                  maxLength: 16,
                  onChanged: (_) {
                    setState(() {});
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(16),
                  ],
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Card Number',
                    counterText: '',
                    hintStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: 
                      TextField(
                        controller: expiryController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) {
                          setState(() {});
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          ExpiryDateFormatter(),
                        ],
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'MM/YY',
                          hintStyle: TextStyle(color: Colors.white70),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white24),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: 
                      TextField(
                        controller: cvvController,
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        maxLength: 3,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'CVV',
                          counterText: '',
                          hintStyle: TextStyle(color: Colors.white70),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white24),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'This is a demo payment system. No real money is charged.',
                  style: TextStyle(
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: kartBilgileriniKontrolEt,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: mainGreen,
                    ),
                    child: const Text(
                      'Continue to 3D Secure',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ] else ...[
                const Text(
                  '3D Secure Verification',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'A demo verification code was sent to your phone. Use 123456 to complete the payment.',
                  style: TextStyle(
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                inputField(
                  controller: secureCodeController,
                  hint: '3D Secure Code',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: odemeYapiliyor ? null : odemeYap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: mainGreen,
                    ),
                    child: Text(
                      odemeYapiliyor ? 'Processing...' : 'Complete Payment',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: odemeYapiliyor
                      ? null
                      : () {
                          setState(() {
                            secureStep = false;
                          });
                        },
                  child: const Text(
                    'Back to card information',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.length > 4) {
      digits = digits.substring(0, 4);
    }

    String formatted = digits;

    if (digits.length > 2) {
      formatted = '${digits.substring(0, 2)}/${digits.substring(2)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}