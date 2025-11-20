# PayMongo Integration Guide

## Overview
This app integrates PayMongo payment gateway for GCash and Bank Transfer payment methods. The integration is implemented in the checkout screen.

## Setup Instructions

### 1. Get PayMongo API Keys
1. Go to [PayMongo Dashboard](https://dashboard.paymongo.com/)
2. Sign up or log in to your account
3. Navigate to **Developers** section
4. Copy your:
   - **Secret Key** (starts with `sk_test_` for test mode or `sk_live_` for production)
   - **Public Key** (starts with `pk_test_` for test mode or `pk_live_` for production)

### 2. Configure API Keys
Open `lib/services/paymongo_service.dart` and replace the placeholder keys:

```dart
static const String _secretKey = 'YOUR_PAYMONGO_SECRET_KEY'; // Replace with sk_test_xxx or sk_live_xxx
static const String _publicKey = 'YOUR_PAYMONGO_PUBLIC_KEY'; // Replace with pk_test_xxx or pk_live_xxx
```

**IMPORTANT:** Never commit your API keys to version control. Consider using environment variables or secure storage for production.

### 3. Install Dependencies
Run the following command to install required packages:

```bash
flutter pub get
```

## Features Implemented

### GCash Payment
- Creates a PayMongo source for GCash payments
- Redirects user to GCash payment page
- Handles payment confirmation
- Amount is automatically converted to centavos (required by PayMongo)

### Bank Transfer
- Creates a payment intent for bank transfers
- Supports multiple banks via PayMongo:
  - BDO
  - Landbank
  - Metrobank
  - UnionBank
- Displays payment reference for tracking
- Shows bank transfer instructions to users

## How It Works

### Payment Flow

1. **User selects payment method** (GCash or Bank Transfer)
2. **User fills shipping information**
3. **User clicks "Place Order"**
4. **App processes payment:**
   - For GCash: Creates source → Redirects to GCash → User pays → Returns to app
   - For Bank Transfer: Creates payment intent → Shows bank details → User transfers → Admin confirms

### Key Files

- `lib/services/paymongo_service.dart` - PayMongo API integration
- `lib/screens/checkout_screen.dart` - Checkout UI with payment integration
- `lib/cart_screen.dart` - Shopping cart (unchanged, but referenced)

## Testing

### Test Mode
PayMongo provides test credentials for development:

**Test Cards:**
- Success: `4343434343434345`
- Insufficient Funds: `4571736000000075`

**Test GCash:**
Use any mobile number and follow the test prompts in the PayMongo checkout page.

### Production Mode
1. Switch to live API keys
2. Complete PayMongo business verification
3. Test with small real transactions
4. Monitor payments in PayMongo Dashboard

## API Methods Used

### `createSource()`
Creates a payment source for e-wallets (GCash, GrabPay)
- Used for: GCash payments
- Returns: Source object with checkout URL

### `createPaymentIntent()`
Creates a payment intent for various payment methods
- Used for: Bank transfers, cards
- Returns: Payment intent with client key

### `createPaymentMethod()`
Creates a payment method to attach to payment intent
- Used for: Card payments, online banking
- Returns: Payment method ID

### `attachPaymentIntent()`
Attaches payment method to payment intent
- Used for: Completing payment flow
- Returns: Updated payment intent

## Webhook Integration (Recommended)

For production, set up webhooks to receive real-time payment updates:

1. Go to PayMongo Dashboard → Webhooks
2. Add your webhook URL: `https://your-domain.com/api/paymongo-webhook`
3. Select events: `source.chargeable`, `payment.paid`, `payment.failed`
4. Implement webhook handler in your backend to:
   - Verify webhook signature
   - Update order status
   - Notify customer

## Security Best Practices

1. **Never expose secret keys in client-side code**
   - Move sensitive operations to backend
   - Use secure environment variables

2. **Validate webhook signatures**
   - Verify PayMongo webhook signatures
   - Prevent fraudulent webhook calls

3. **Use HTTPS for redirect URLs**
   - Ensure secure communication
   - Prevent man-in-the-middle attacks

4. **Implement proper error handling**
   - Log errors securely
   - Show user-friendly messages
   - Don't expose API details to users

## Troubleshooting

### Common Issues

**"Invalid API Key"**
- Check if you copied the correct key
- Ensure no extra spaces in the key
- Verify you're using the right environment (test/live)

**"Amount must be at least 10000 centavos"**
- Minimum amount is PHP 100.00
- Check your total calculation
- Remember: 1 PHP = 100 centavos

**"URL Launcher not working"**
- Ensure `url_launcher` is added to pubspec.yaml
- Run `flutter pub get`
- For iOS, configure URL schemes in Info.plist

### Support

For PayMongo-specific issues:
- Email: [email protected]
- Documentation: https://developers.paymongo.com/docs
- Dashboard: https://dashboard.paymongo.com/

## Future Enhancements

- [ ] Add credit/debit card payment support
- [ ] Implement PayMaya integration
- [ ] Add webhook handler for automatic order updates
- [ ] Store payment history in database
- [ ] Add payment status checking
- [ ] Implement refund functionality
- [ ] Add installment payment options

## License

This integration code is part of the PREMODA app.
