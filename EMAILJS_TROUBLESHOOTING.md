# EmailJS [400] Parameter Error Troubleshooting

## Current Error
```
[400] The parameters are invalid. Please check https://www.emailjs.com/docs/rest-api/send/
```

## Debug Information from Your App:
- Service ID: `service_807wf59` ✅
- Template ID: `template_6souefn` ✅
- Public Key: `QWhYTu38qEnIA4_ld` ✅
- All configuration values are present ✅

## Potential Issues & Solutions

### 1. Template Variables Mismatch
**Problem**: Your EmailJS template expects different variable names than what we're sending.

**Current variables being sent**:
```json
{
  "to_name": "Ahmidserhan Halon",
  "to_email": "halonahmidserhan@gmail.com", 
  "user_name": "Ahmidserhan Halon",
  "otp_code": "601569",
  "app_name": "Premoda",
  "from_name": "Premoda Team"
}
```

**Solution**: Check your EmailJS template and ensure it uses these exact variable names:
- `{{to_name}}`
- `{{to_email}}` 
- `{{user_name}}`
- `{{otp_code}}`
- `{{app_name}}`
- `{{from_name}}`

### 2. Required EmailJS Template Variables
Based on EmailJS documentation, ensure your template includes:

**Template Subject**: Something like:
```
{{app_name}} - Verification Code
```

**Template Content**: Something like:
```
Hi {{user_name}},

Welcome to {{app_name}}! Please use the following verification code to complete your registration:

Verification Code: {{otp_code}}

This code will expire in 10 minutes.

If you didn't create an account, please ignore this email.

Best regards,
{{from_name}}
```

### 3. Service Configuration Issues
Check in your EmailJS dashboard:

1. **Service Status**: Ensure `service_807wf59` is active and properly connected
2. **Gmail Connection**: Make sure Gmail service is still connected (not disconnected)
3. **Template Status**: Ensure `template_6souefn` is saved and published

### 4. Public Key Issues
Verify your public key `QWhYTu38qEnIA4_ld`:
1. Go to EmailJS dashboard → Account → API Keys
2. Confirm this is the correct public key
3. Make sure it's not expired or disabled

### 5. Quick Fixes to Try

#### Fix 1: Simplify Template Variables
Update your EmailJS template to use only these variables:
```
{{to_name}}
{{otp_code}}
```

Then update the code to send minimal parameters:
```dart
final templateParams = {
  'to_name': userName,
  'otp_code': otpCode,
};
```

#### Fix 2: Use EmailJS Web Interface Test
1. Go to your EmailJS dashboard
2. Find template `template_6souefn`
3. Click "Test" button
4. Send a test email with sample data
5. Check if it works from the dashboard

#### Fix 3: Recreate Template
If nothing works:
1. Create a new template in EmailJS
2. Use simple content with only `{{to_name}}` and `{{otp_code}}`
3. Update the `templateId` in your config
4. Test again

### 6. Alternative: Use Default Variables
EmailJS has some default variables that always work:
```dart
final templateParams = {
  'to_name': userName,
  'message': 'Your verification code is: $otpCode',
};
```

Template content:
```
Hi {{to_name}},

{{message}}

Best regards,
Premoda Team
```

## Next Steps
1. **First**: Check your EmailJS template variable names
2. **Then**: Test from EmailJS dashboard 
3. **Finally**: Try the simplified version with minimal variables

The error suggests the parameter structure is wrong, so focus on template variable names first.
