# Apple App Store Submission Guide: PIZZNEAPOL

This guide provides the complete end-to-end requirements, configuration steps, and critical Apple App Review guidelines to publish **PIZZNEAPOL** on the iOS App Store.

---

## 1. Prerequisites

1. **Apple Developer Account**:
   - An active enrollment in the [Apple Developer Program](https://developer.apple.com/programs/) ($99/year).
   - Can be registered as an **Individual** or **Organization**.
2. **Mac with Xcode**:
   - Xcode 15+ installed on macOS.
   - Command Line Tools installed (`xcode-select --install`).

---

## 2. Project & Bundle Configuration

Your iOS project configuration:
- **Bundle Identifier:** `com.pizzneapol.pizzneapol`
- **Display Name:** `PIZZNEAPOL` (configured in `ios/Runner/Info.plist`)
- **Version & Build:** `1.0.0 (1)` (managed in `pubspec.yaml`)
- **App Icons:** ✅ All required iPhone and iPad icon sizes (including the 1024x1024 App Store icon) have been generated and deployed in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`.

---

## 3. Critical Apple App Review Guidelines (Avoid Rejection!)

Food ordering and restaurant apps must adhere strictly to the following Apple rules to pass App Store review:

### A. Account Deletion Requirement (Guideline 5.1.1(v) - Critical!)
> **Apple Rule:** Any app that allows users to create an account **MUST** also provide an option to initiate account deletion directly within the app.
- **Action:** Ensure there is a "Delete Account" button in `ProfileView` or Settings that allows the user to delete or request deletion of their account.
- In the App Store submission notes, explicitly mention where this button is located (e.g. *Profile > Account Settings > Delete Account*).

### B. In-App Purchase vs Physical Goods (Guideline 3.1.5(a))
> **Apple Rule:** Apps selling physical goods or services that are consumed outside the app (such as food, pizza, groceries) **must not** use Apple In-App Purchases (IAP).
- **Good News:** PIZZNEAPOL uses external payments (Cash on Delivery, card/mobile payment), which is **100% compliant** with Apple's physical goods policy. You do NOT owe Apple the 30% IAP commission.

### C. Demo Account for App Reviewers
> **Apple Rule:** Reviewers must be able to log in and test all customer flows without hitting an error or needing a real phone verification code they cannot access.
- Under **App Store Connect > App Review Information**, provide:
  - **Username / Email:** `demo@pizzneapol.com`
  - **Password:** `YourDemoPassword123`
  - Notes for reviewer: *"This is a food ordering app for artisan Neapolitan pizza. Use the provided credentials to test user profile and ordering."*

### D. Privacy Policy & Data Nutrition Labels
- A publicly accessible Privacy Policy URL is mandatory. You can use the [`PRIVACY_POLICY.md`](./PRIVACY_POLICY.md) file we created.
- In App Store Connect **App Privacy**, declare:
  - **Contact Info**: Name, Email, Phone number, Physical address (used for app functionality / order delivery).
  - **Identifiers**: User ID (for account authentication).

---

## 4. Required Store Listing Assets

| Asset | Resolution | Requirements |
| :--- | :--- | :--- |
| **App Icon** | 1024 x 1024 px | PNG, 72 dpi, RGB, flat, **no alpha/transparency** (already configured in `AppIcon.appiconset`) |
| **6.7" iPhone Screenshots** | 1290 x 2796 px (or 1320 x 2868) | Required for iPhone 15/16 Pro Max (minimum 2 screenshots, max 10) |
| **6.5" iPhone Screenshots** | 1242 x 2688 px | Required for iPhone 11 Pro Max / XS Max |
| **12.9" iPad Screenshots** | 2048 x 2732 px | Required only if iPad support is enabled |

*Tip: You can capture high-resolution screenshots directly from the iOS Simulator by selecting **File > Save Screen** (or `Cmd + S`).*

---

## 5. Step-by-Step Build & Submission Workflow

### Step 1: Register App ID & Certificate in Apple Developer Portal
1. Go to [developer.apple.com/account](https://developer.apple.com/account).
2. Go to **Certificates, Identifiers & Profiles > Identifiers**.
3. Click `+` to add an **App ID**:
   - Description: `Pizzneapol`
   - Bundle ID: Explicit `com.pizzneapol.pizzneapol`.

### Step 2: Open Project in Xcode for Signing
1. Open terminal and run:
   ```bash
   open ios/Runner.xcworkspace
   ```
2. In Xcode:
   - Select the **Runner** project in the left sidebar.
   - Go to the **Signing & Capabilities** tab.
   - Check **Automatically manage signing**.
   - Under **Team**, select your Apple Developer account.
   - Ensure the Bundle Identifier shows `com.pizzneapol.pizzneapol`.

### Step 3: Create App in App Store Connect
1. Visit [appstoreconnect.apple.com](https://appstoreconnect.apple.com) and click **My Apps > `+` > New App**.
2. Select:
   - **Platform:** iOS
   - **Name:** `PIZZNEAPOL - Pizza Delivery`
   - **Primary Language:** English (US)
   - **Bundle ID:** `com.pizzneapol.pizzneapol`
   - **SKU:** `pizzneapol-ios-01`
   - **User Access:** Full Access

### Step 4: Build the iOS Release Archive (.ipa)
Run the following Flutter command from your project root:

```bash
flutter build ipa --release
```

Or build an archive directly in Xcode:
1. In Xcode, set target device to **Any iOS Device (arm64)**.
2. Go to **Product > Archive**.
3. Once archiving completes, Xcode's **Organizer** window opens.

### Step 5: Upload to App Store Connect
You can upload either:
- **Via Xcode Organizer**: Click **Distribute App** > **App Store Connect** > **Upload** > Follow prompts to upload your build.
- **Via Apple Transporter App**: Drag and drop the `.ipa` generated by Flutter (`build/ios/ipa/*.ipa`) into the official [Transporter app](https://apps.apple.com/app/transporter/id1450874784).

### Step 6: Test on TestFlight & Submit for Review
1. Once uploaded, wait 5–15 minutes for Apple to process the build.
2. In App Store Connect, go to **TestFlight** and invite internal/external testers to test the build.
3. Under the **App Store** tab:
   - Select the processed build.
   - Add screenshots, description, keywords, and support URL.
   - Fill out **App Privacy** nutrition labels.
   - Provide reviewer demo credentials.
4. Click **Add for Review** > **Submit to App Review**!
