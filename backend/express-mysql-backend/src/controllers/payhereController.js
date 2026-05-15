const crypto = require('crypto');
const { Transaction, User, Item } = require('../models');

const sandboxUrl = 'https://sandbox.payhere.lk/pay/checkout';
const liveUrl = 'https://www.payhere.lk/pay/checkout';

const requiredCreateFields = [
  'buyer_id',
  'seller_id',
  'item_id',
  'amount',
  'currency',
  'first_name',
  'last_name',
  'email',
  'phone',
  'return_url',
  'cancel_url',
];

const md5Upper = (value) => crypto.createHash('md5').update(value).digest('hex').toUpperCase();

const formatAmount = (amount) => Number(amount).toFixed(2);

const buildCheckoutHash = ({ merchantId, orderId, amount, currency, merchantSecret }) => {
  if (!merchantSecret) return null;
  return md5Upper(`${merchantId}${orderId}${amount}${currency}${md5Upper(merchantSecret)}`);
};

const buildNotifyHash = ({ merchantId, orderId, amount, currency, statusCode, merchantSecret }) => {
  if (!merchantSecret) return null;
  return md5Upper(`${merchantId}${orderId}${amount}${currency}${statusCode}${md5Upper(merchantSecret)}`);
};

const escapeHtml = (value) =>
  String(value ?? '')
    .replace(/&/g, '&amp;')
    .replace(/"/g, '&quot;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;');

const hiddenInput = (name, value) =>
  `<input type="hidden" name="${escapeHtml(name)}" value="${escapeHtml(value)}">`;

exports.create = async (req, res, next) => {
  try {
    const missingFields = requiredCreateFields.filter((field) => req.body[field] === undefined || req.body[field] === null || req.body[field] === '');
    if (missingFields.length) {
      return res.status(400).json({
        success: false,
        code: 400,
        message: `Missing required fields: ${missingFields.join(', ')}`,
        data: null,
      });
    }

    const merchantId = process.env.PAYHERE_MERCHANT_ID;
    if (!merchantId) {
      return res.status(500).json({
        success: false,
        code: 500,
        message: 'PAYHERE_MERCHANT_ID is not configured',
        data: null,
      });
    }

    const buyer = await User.findByPk(req.body.buyer_id);
    const seller = await User.findByPk(req.body.seller_id);
    const item = await Item.findByPk(req.body.item_id);
    if (!buyer || !seller || !item) {
      return res.status(404).json({
        success: false,
        code: 404,
        message: 'Buyer, seller, or item not found',
        data: null,
      });
    }

    if (String(item.seller_id) !== String(req.body.seller_id)) {
      return res.status(400).json({
        success: false,
        code: 400,
        message: 'Seller does not own this item',
        data: null,
      });
    }

    const amount = formatAmount(req.body.amount);
    const currency = String(req.body.currency).toUpperCase();
    const transaction = await Transaction.create({
      buyer_id: req.body.buyer_id,
      seller_id: req.body.seller_id,
      item_id: req.body.item_id,
      amount,
      type: 'payhere',
      status: 'pending',
    });

    const orderId = transaction.transaction_id;
    const notifyUrl = `${(process.env.BASE_URL || `${req.protocol}://${req.get('host')}`).replace(/\/$/, '')}/payments/payhere/notify`;
    const hash = buildCheckoutHash({
      merchantId,
      orderId,
      amount,
      currency,
      merchantSecret: process.env.PAYHERE_SECRET,
    });

    const fields = {
      merchant_id: merchantId,
      return_url: req.body.return_url,
      cancel_url: req.body.cancel_url,
      notify_url: notifyUrl,
      order_id: orderId,
      items: item.title,
      currency,
      amount,
      first_name: req.body.first_name,
      last_name: req.body.last_name,
      email: req.body.email,
      phone: req.body.phone,
      address: req.body.address || buyer.location || 'N/A',
      city: req.body.city || 'Colombo',
      country: req.body.country || 'Sri Lanka',
      custom_1: String(transaction.transaction_id),
      custom_2: String(item.item_id),
      ...(hash ? { hash } : {}),
    };

    const actionUrl = String(process.env.PAYHERE_SANDBOX).toLowerCase() === 'false' ? liveUrl : sandboxUrl;
    const html = `<!doctype html>
<html>
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Redirecting to PayHere</title>
  </head>
  <body>
    <form id="payhere-form" method="post" action="${escapeHtml(actionUrl)}">
      ${Object.entries(fields).map(([name, value]) => hiddenInput(name, value)).join('\n      ')}
      <noscript><button type="submit">Continue to PayHere</button></noscript>
    </form>
    <script>document.getElementById('payhere-form').submit();</script>
  </body>
</html>`;

    res.set('Content-Type', 'text/html; charset=utf-8');
    return res.status(200).send(html);
  } catch (err) {
    next(err);
  }
};

exports.notify = async (req, res, next) => {
  try {
    const {
      merchant_id: merchantId,
      order_id: orderId,
      payhere_amount: payhereAmount,
      payhere_currency: payhereCurrency,
      status_code: statusCode,
      md5sig,
    } = req.body;

    const transaction = await Transaction.findByPk(orderId);
    if (!transaction) return res.status(404).send('Transaction not found');

    if (process.env.PAYHERE_SECRET && md5sig) {
      const expected = buildNotifyHash({
        merchantId,
        orderId,
        amount: payhereAmount,
        currency: payhereCurrency,
        statusCode,
        merchantSecret: process.env.PAYHERE_SECRET,
      });
      if (expected !== String(md5sig).toUpperCase()) {
        return res.status(400).send('Invalid signature');
      }
    }

    const nextStatus = String(statusCode) === '2' ? 'completed' : 'failed';
    await transaction.update({ status: nextStatus });
    if (nextStatus === 'completed') {
      await Item.update({ status: 'sold' }, { where: { item_id: transaction.item_id } });
    }

    return res.status(200).send('OK');
  } catch (err) {
    next(err);
  }
};
