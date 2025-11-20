# Profile Screen - Supabase Integration Guide

## Overview
The profile screen has been updated to use Supabase as the backend. This document explains the database schema, setup process, and how to use the profile features.

## Database Schema

### Tables Created

1. **`profiles`** - Extended user profile information
   - Links to `users` table via `user_id`
   - Stores: full name, phone, bio, profile picture, membership status
   - Tracks: total orders, total spent, wishlist count, review count

2. **`addresses`** - User shipping/billing addresses
   - Multiple addresses per user
   - Support for default address
   - Fields: full name, phone, address lines, city, state, postal code, country

3. **`orders`** - Customer orders
   - Order tracking with status (pending, processing, shipped, delivered, cancelled, refunded)
   - Payment tracking
   - Links to shipping address

4. **`order_items`** - Items within each order
   - Product details, quantity, price
   - Size and color variants

5. **`wishlists`** - User product wishlists
   - Many-to-many relationship between users and products
   - Unique constraint prevents duplicates

6. **`reviews`** - Product reviews
   - Rating (1-5 stars)
   - Title, comment, images
   - Verified purchase flag
   - Helpful count

## Setup Instructions

### Step 1: Run SQL Setup Script

1. Open your Supabase project dashboard
2. Navigate to **SQL Editor**
3. Copy the contents of `supabase_profile_setup.sql`
4. Paste and run the SQL script
5. Verify all tables are created successfully

### Step 2: Set Up Storage Bucket (Optional)

For profile picture uploads:

1. Go to **Storage** in Supabase dashboard
2. Create a new bucket named `avatars`
3. Make it public
4. Set up storage policies:
   ```sql
   -- Allow authenticated users to upload their own avatars
   CREATE POLICY "Users can upload their own avatar"
   ON storage.objects FOR INSERT
   WITH CHECK (
     bucket_id = 'avatars' 
     AND auth.uid()::text = (storage.foldername(name))[1]
   );

   -- Allow users to update their own avatar
   CREATE POLICY "Users can update their own avatar"
   ON storage.objects FOR UPDATE
   USING (
     bucket_id = 'avatars' 
     AND auth.uid()::text = (storage.foldername(name))[1]
   );
   ```

### Step 3: Configure Supabase in Flutter

Ensure your `main.dart` has Supabase initialized:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );
  
  runApp(MyApp());
}
```

## Features Implemented

### Profile Service (`lib/services/profile_service.dart`)

The `ProfileService` class provides methods for:

#### User Profile Management
- **`getUserProfile()`** - Fetches complete user profile with stats
- **`updateProfile()`** - Updates profile information
- **`uploadProfilePicture()`** - Uploads profile picture to Supabase Storage

#### Statistics
- **`_getOrdersCount()`** - Counts user's orders
- **`_getWishlistCount()`** - Counts wishlist items
- **`_getReviewsCount()`** - Counts user reviews

#### Data Retrieval
- **`getUserAddresses()`** - Fetches all user addresses
- **`getUserOrders()`** - Fetches order history with items

#### Account Management
- **`deleteAccount()`** - Deletes user account (cascades to related data)
- **`signOut()`** - Signs out current user

### Profile Screen (`lib/profile_screen.dart`)

#### Features:
- ✅ Real-time profile data from Supabase
- ✅ Loading states with spinner
- ✅ Error handling with retry button
- ✅ Pull-to-refresh functionality
- ✅ Dynamic profile picture (network image or initials)
- ✅ Live statistics (orders, wishlist, reviews)
- ✅ Membership status display
- ✅ User ID and join date
- ✅ Logout with Supabase sign out

## Database Queries Reference

### Get User Profile with Stats
```sql
-- Get user data
SELECT * FROM users WHERE id = 'user_id';

-- Get profile data
SELECT * FROM profiles WHERE user_id = 'user_id';

-- Get orders count
SELECT COUNT(*) FROM orders WHERE user_id = 'user_id';

-- Get wishlist count
SELECT COUNT(*) FROM wishlists WHERE user_id = 'user_id';

-- Get reviews count
SELECT COUNT(*) FROM reviews WHERE user_id = 'user_id';
```

### Create/Update Profile
```sql
-- Insert new profile
INSERT INTO profiles (user_id, full_name, phone_number, bio)
VALUES ('user_id', 'John Doe', '+63 912 345 6789', 'Bio text');

-- Update existing profile
UPDATE profiles 
SET full_name = 'John Doe', 
    phone_number = '+63 912 345 6789',
    updated_at = NOW()
WHERE user_id = 'user_id';
```

### Get User Orders
```sql
SELECT o.*, 
       json_agg(oi.*) as items
FROM orders o
LEFT JOIN order_items oi ON o.id = oi.order_id
WHERE o.user_id = 'user_id'
GROUP BY o.id
ORDER BY o.created_at DESC
LIMIT 10;
```

### Get User Addresses
```sql
SELECT * FROM addresses 
WHERE user_id = 'user_id'
ORDER BY is_default DESC, created_at DESC;
```

## Security

### Row Level Security (RLS)
All tables have RLS enabled with policies that ensure:
- Users can only access their own data
- Reviews are publicly readable but only editable by the author
- Order items are accessible through order ownership

### Authentication
- Uses Supabase Auth (`auth.uid()`)
- All queries check user authentication
- Automatic session management

## Testing

### Create Test Data

```sql
-- Insert test profile
INSERT INTO profiles (user_id, full_name, phone_number, membership_status)
VALUES (auth.uid(), 'Test User', '+63 912 345 6789', 'premium');

-- Insert test address
INSERT INTO addresses (user_id, full_name, phone_number, address_line1, city, state, postal_code)
VALUES (auth.uid(), 'Test User', '+63 912 345 6789', '123 Test St', 'Manila', 'NCR', '1000');

-- Insert test wishlist item (requires existing product)
INSERT INTO wishlists (user_id, product_id)
VALUES (auth.uid(), 'existing_product_id');
```

## Troubleshooting

### Profile Not Loading
1. Check Supabase connection in Flutter
2. Verify user is authenticated (`Supabase.instance.client.auth.currentUser`)
3. Check RLS policies are properly set
4. Review console logs for errors

### Images Not Displaying
1. Verify Storage bucket is public
2. Check storage policies allow read access
3. Ensure image URLs are valid

### Stats Not Updating
1. Profiles table stats are cached - they update when orders/wishlists/reviews change
2. Consider adding triggers to auto-update counts:
```sql
-- Example: Update wishlist count on insert
CREATE OR REPLACE FUNCTION update_wishlist_count()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE profiles 
  SET wishlist_count = (
    SELECT COUNT(*) FROM wishlists WHERE user_id = NEW.user_id
  )
  WHERE user_id = NEW.user_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER wishlist_count_trigger
AFTER INSERT OR DELETE ON wishlists
FOR EACH ROW EXECUTE FUNCTION update_wishlist_count();
```

## Next Steps

### Recommended Enhancements
1. **Edit Profile Screen** - Allow users to update their profile information
2. **Address Management** - Add/edit/delete addresses
3. **Order History Screen** - Detailed order viewing
4. **Image Upload** - Implement profile picture upload from camera/gallery
5. **Membership Tiers** - Implement premium features
6. **Push Notifications** - Order status updates

## API Reference

See `lib/services/profile_service.dart` for complete API documentation.

## Support

For issues or questions:
1. Check Supabase logs in dashboard
2. Review Flutter console output
3. Verify database schema matches expected structure
4. Check RLS policies are not blocking legitimate requests
