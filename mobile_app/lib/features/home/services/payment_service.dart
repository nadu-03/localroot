import 'package:dio/dio.dart';

import '../../../common/models/user_model.dart';
import '../../../data/api/api_manager.dart';
import '../../../util/app_constant.dart';
import '../controllers/home_controller.dart';

class PaymentService {
  Future<PayhereCheckoutSession> createPayhereCheckout({
    required HomeProduct product,
    required UserModel buyer,
  }) async {
    final sellerId = product.sellerId;
    final buyerId = buyer.userId;
    if (buyerId == null) {
      throw Exception('Please sign in before buying this item.');
    }
    if (product.id == 0 || sellerId == null || sellerId == 0) {
      throw Exception('Item seller details are not available.');
    }
    if (buyerId == sellerId) {
      throw Exception('You cannot buy your own item.');
    }
    if ((buyer.email ?? '').trim().isEmpty) {
      throw Exception('Please add an email address to your profile before paying.');
    }

    final names = _splitName(buyer.fullName);
    final response = await ApiManager.instance.post<String>(
      AppConstant.createPayherePayment,
      data: {
        'buyer_id': buyerId,
        'seller_id': sellerId,
        'item_id': product.id,
        'amount': product.priceLkr,
        'currency': 'LKR',
        'first_name': names.$1,
        'last_name': names.$2,
        'email': buyer.email ?? '',
        'phone': buyer.phone ?? '0000000000',
        'return_url': AppConstant.payhereReturnUrl,
        'cancel_url': AppConstant.payhereCancelUrl,
      },
      options: Options(
        contentType: Headers.jsonContentType,
        responseType: ResponseType.plain,
      ),
    );

    final html = response.data;
    if (html == null || html.trim().isEmpty) {
      throw Exception('Payment gateway did not return checkout content.');
    }
    return PayhereCheckoutSession(
      checkoutHtml: html,
      transactionId: _extractTransactionId(html),
    );
  }

  Future<String?> getTransactionStatus(int transactionId) async {
    final response = await ApiManager.instance.get(
      '${AppConstant.transactions}/$transactionId',
    );
    final responseData = response.data;
    final data = responseData is Map && responseData['data'] != null
        ? responseData['data']
        : responseData;

    if (data is Map) {
      return data['status']?.toString();
    }
    return null;
  }

  (String, String) _splitName(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) return ('Customer', 'User');
    if (parts.length == 1) return (parts.first, 'User');
    return (parts.first, parts.sublist(1).join(' '));
  }

  int? _extractTransactionId(String html) {
    final patterns = [
      RegExp(r'''name=["']order_id["']\s+value=["']([^"']+)["']'''),
      RegExp(r'''value=["']([^"']+)["']\s+name=["']order_id["']'''),
      RegExp(r'''name=["']custom_1["']\s+value=["']([^"']+)["']'''),
      RegExp(r'''value=["']([^"']+)["']\s+name=["']custom_1["']'''),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(html);
      final value = match?.group(1);
      final transactionId = int.tryParse(value ?? '');
      if (transactionId != null) return transactionId;
    }
    return null;
  }
}

class PayhereCheckoutSession {
  final String checkoutHtml;
  final int? transactionId;

  const PayhereCheckoutSession({
    required this.checkoutHtml,
    required this.transactionId,
  });
}
