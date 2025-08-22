# EmailJS Setup Guide for Premoda

## Overview
EmailJS is now integrated into your Flutter app as an alternative to Supabase SMTP. This allows sending verification emails directly from the client side without server-side configuration.

## Step 1: Create EmailJS Account

1. Go to https://www.emailjs.com/
2. Sign up for a free account (100 emails/month free)
3. Verify your email address

## Step 2: Add Email Service

1. In your EmailJS dashboard, go to **Email Services**
2. Click **Add New Service**
3. Choose your email provider:
   - **Gmail** (recommended for simplicity)
   - **Outlook**
   - **Yahoo**
   - **Custom SMTP**

### For Gmail:
- Service ID: Will be generated (e.g., `service_abc123`)
- User ID: Your Gmail address
- Access Token: Use Gmail's OAuth (click "Connect Account")

### For Other Providers:
- Follow the provider-specific setup instructions

## Step 3: Create Email Template

1. Go to **Email Templates** in your EmailJS dashboard
2. Click **Create New Template**
3. Use this template structure:

### Template Variables:
- `{{to_email}}` - Recipient's email
- `{{user_name}}` - User's name
- `{{otp_code}}` - 6-digit verification code
- `{{app_name}}` - App name (Premoda)
- `{{from_name}}` - Sender name

### Sample Template:
```html
Subject: {{app_name}} - Verification Code

Hi {{user_name}},

Welcome to {{app_name}}! Please use the following verification code to complete your registration:

Verification Code: {{otp_code}}

This code will expire in 10 minutes.

If you didn't create an account with {{app_name}}, please ignore this email.

Best regards,
{{from_name}}
```

## Step 4: Get Your Credentials

After setting up the service and template, you'll need:

1. **Service ID** - From your email service (e.g., `service_abc123`)
2. **Template ID** - From your email template (e.g., `template_xyz789`)
3. **Public Key** - From Account > API Keys (e.g., `user_123abc456def`)
4. **Private Key** (optional) - For enhanced security

## Step 5: Update Configuration

Update the file `lib/services/emailjs_config.dart` with your credentials:

```dart
class EmailJSConfig {
  static const String serviceId = 'service_abc123'; // Your Service ID
  static const String templateId = 'template_xyz789'; // Your Template ID
  static const String publicKey = 'user_123abc456def'; // Your Public Key
  
  // Optional: Private key for increased security
  static const String? privateKey = 'your_private_key'; // Your Private Key (optional)
}
```

## Step 6: Test the Setup

1. Run your Flutter app: `flutter run`
2. Try to sign up with a real email address
3. Check your email inbox for the verification code
4. Enter the code in the app to complete verification

## Troubleshooting

### Email Not Received
1. Check your spam/junk folder
2. Verify your EmailJS service is properly connected
3. Check EmailJS dashboard for error logs
4. Ensure template variables match exactly

### "Service not found" Error
- Double-check your Service ID in `emailjs_config.dart`
- Ensure the service is active in your EmailJS dashboard

### "Template not found" Error
- Verify your Template ID in `emailjs_config.dart`
- Make sure the template is published

### Rate Limiting
- Free tier allows 100 emails/month
- Upgrade to paid plan if you need more

## Benefits of EmailJS vs Supabase SMTP

✅ **Easier Setup** - No server-side configuration needed
✅ **Better Deliverability** - Uses established email services
✅ **Free Tier** - 100 emails/month at no cost
✅ **Client-side** - Works directly from Flutter app
✅ **Multiple Providers** - Support for Gmail, Outlook, etc.
✅ **Template Management** - Easy-to-use template editor

## Security Considerations

- EmailJS runs client-side, so API keys are visible in the app
- Use the Private Key feature for additional security
- Consider server-side implementation for production apps with high volume
- Monitor usage to prevent abuse

## Next Steps

1. Set up your EmailJS account with the steps above
2. Update the configuration file with your credentials
3. Test the signup flow
4. Monitor email delivery in EmailJS dashboard

Your email verification should now work reliably!
