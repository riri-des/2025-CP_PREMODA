# Supabase Email Configuration Fix

## Current Issue
- Verification emails not sending during signup
- Gmail SMTP is designed for personal emails, not transactional messages
- Authentication issues with Gmail SMTP

## Solutions

### Option 1: Fix Gmail SMTP (Quick Fix)
1. Go to your Google Account settings
2. Enable 2-Factor Authentication
3. Generate an App Password:
   - Search "App passwords" in Google Account
   - Select "Mail" as the app
   - Use the generated password (not your regular password) in Supabase
4. Update Supabase SMTP settings:
   - Host: `smtp.gmail.com`
   - Port: `587`
   - Username: Your Gmail address
   - Password: The app password (16 characters)

### Option 2: Use Transactional Email Provider (Recommended)
Switch to one of these providers for better deliverability:

#### SendGrid (Free tier: 100 emails/day)
- Host: `smtp.sendgrid.net`
- Port: `587` or `2525`
- Username: `apikey`
- Password: Your SendGrid API key

#### Mailgun (Free tier: 5,000 emails/month)
- Host: `smtp.mailgun.org`
- Port: `587`
- Username: Your Mailgun SMTP username
- Password: Your Mailgun SMTP password

#### AWS SES (Very cheap)
- Host: `email-smtp.region.amazonaws.com`
- Port: `587`
- Username: Your SES SMTP username
- Password: Your SES SMTP password

### Option 3: Verify Current Settings
Test your current SMTP configuration:
1. In Supabase Auth settings, click "Send test email"
2. Check spam folder
3. Enable logging in Supabase to see detailed error messages

## Testing the Fix
After updating SMTP settings:
1. Try signing up with a test email
2. Check inbox and spam folders
3. Monitor Supabase Auth logs for errors
4. Test with different email providers (Gmail, Outlook, etc.)
