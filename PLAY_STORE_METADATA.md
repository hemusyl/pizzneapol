# Google Play Store Listing & Submission Guide

Use the exact details below when completing your app submission on the [Google Play Console](https://play.google.com/console).

---

## 1. Store Listing Details

### App Name (max 30 characters)
```text
PIZZNEAPOL - Pizza Delivery
```

### Short Description (max 80 characters)
```text
Order fresh artisan Neapolitan pizza delivered hot & fast to your doorstep!
```

### Full Description (max 4000 characters)
```text
Craving authentic Neapolitan pizza made with fresh ingredients and traditional stone-baked perfection? Welcome to PIZZNEAPOL!

PIZZNEAPOL brings artisan Italian pizzas, fresh salads, decadent desserts, crispy sides, and refreshing beverages right to your doorstep with real-time tracking, seamless ordering, and exclusive deals.

🍕 WHY YOU'LL LOVE PIZZNEAPOL:

• Artisan Neapolitan Pizzas: Crafted with high-grade flour, hand-stretched dough, San Marzano tomato sauce, fresh mozzarella, and aromatic basil baked to perfection.
• Easy Customization: Choose your favorite toppings, crust styles, and pizza sizes (Personal, Medium, Large) tailored to your cravings.
• Exclusive Daily Deals & Coupons: Enjoy instant percentage discounts, buy-one-get-one specials, and free delivery vouchers directly from the Offers tab.
• Lightning Fast Delivery & Live Order Tracking: Track your order progress in real-time from the oven to your table.
• Multiple Payment Options: Flexible checkout with Cash on Delivery, Mobile Banking, and digital credit/debit card payments.
• Reorder in One Tap: Access your previous orders from the drawer or orders tab and repeat your favorite pizza combinations instantly.
• Dietary Varieties: Whether you are vegetarian, craving meat lovers, or searching for halal & gluten-conscious options, we have something delicious for everyone.

Download PIZZNEAPOL today and experience pizza made with passion!
```

---

## 2. Store Assets & Graphics Checklist

| Asset | Specifications | Status |
| :--- | :--- | :--- |
| **App Icon** | 512 x 512 px, 32-bit PNG, up to 1024KB | ✅ Generated at `assets/images/logo/playstore_icon_512.png` |
| **Feature Graphic** | 1024 x 500 px, JPEG or 24-bit PNG (no alpha) | ✅ Generated at `assets/images/banners/playstore_feature_graphic_1024x500.png` |
| **Phone Screenshots** | Min 2 screenshots (16:9 or 9:16 aspect ratio) | Capture 3-5 screenshots directly from emulator or phone (Home, Menu, Product Details, Cart, Checkout) |

---

## 3. Categorization & Contact Details

- **Application Type**: App
- **Category**: Food & Drink
- **Tags**: Food Delivery, Restaurants, Pizza, Online Ordering
- **Content Rating**: Everyone (PEGI 3 / ESRB Everyone)
- **Contact Email**: support@pizzneapol.com (or your business support email)
- **Website**: `https://pizzaabd.shop`

---

## 4. Google Play Data Safety Form Answers

Google Play Console requires accurate declarations in the **App Content > Data Safety** section. Use the following answers:

### 1. Does your app collect or share any user data?
- **Yes**

### 2. Is all user data collected encrypted in transit?
- **Yes**, all communications with the backend use HTTPS (`https://pizzaabd.shop/api`).

### 3. Do you provide a way for users to request that their data be deleted?
- **Yes**, users can request account deletion via the support email or settings.

### 4. Data Types Collected & Purposes:
| Data Type | Purpose | Shared with 3rd Parties? |
| :--- | :--- | :--- |
| **Name** | App functionality (Account management, order delivery name) | No |
| **Email address** | App functionality (Account management, order receipts) | No |
| **Phone number** | App functionality (Delivery driver communication & order confirmation) | No |
| **Physical address** | App functionality (Order delivery fulfillment) | No |
| **Purchase history** | App functionality (Order history & reordering) | No |

---

## 5. Release Build Command

To generate the production Android App Bundle (`.aab`) ready for uploading to the Play Console:

```bash
flutter build appbundle --release
```

The resulting file will be located at:
`build/app/outputs/bundle/release/app-release.aab`
