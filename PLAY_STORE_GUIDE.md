# Play Store Upload – Step-by-Step Guide (STUMPED)

Follow these steps in order. Each section ends with a “Done” so you know when to move on.

---

## Part 1: Google Play Console Access

1. **Create or use a Google Play Developer account**
   - Go to [Google Play Console](https://play.google.com/console).
   - Sign in with the Google account you want to use as the **developer**.
   - If it’s your first time:
     - Pay the **one-time $25 registration fee**.
     - Accept the Developer Distribution Agreement.
   - **Done:** You can open the Play Console dashboard.

2. **Create the app in Play Console**
   - In the Console, click **“Create app”**.
   - Fill in:
     - **App name:** STUMPED  
     - **Default language:** English (or your choice)  
     - **App or game:** App  
     - **Free or paid:** Free (or Paid if you intend to charge)
   - Accept declarations and click **Create app**.  
   - **Done:** You see the app’s “Dashboard” in Play Console.

---

## Part 2: App Identity and Signing (on your Mac)

Your app needs a **unique application ID** and a **release signing key**. We’ll set both in the project.

### Choose an application ID (package name)

- Current value in the project: **`app.stumped`**
- This will be the **permanent** package name on the Play Store.
- It must be unique; no other app can use it.  
  If you have a domain (e.g. `rainatandon.com`), you can use something like `com.rainatandon.stumped` instead.  
  To change it later you’d have to create a **new** Play Store listing.

### Create the upload keystore (one-time)

Run these in **Terminal** (you can use any strong passwords; keep them safe):

```bash
cd /Users/rainatandon/stumped_ui/android

keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

- When prompted:
  - Enter a **keystore password** (and remember it).
  - Enter again to confirm.
  - Fill in name/organization/city/country (or use placeholders).
  - Enter a **key password** for alias `upload` (often same as keystore password).
- **Important:** Store both passwords and the `upload-keystore.jks` file somewhere safe. You’ll need them for every future update. Losing them means you cannot update this app on Play Store.

**Done:** You have `android/upload-keystore.jks`.

### Tell the build how to use the keystore

Create the file `android/key.properties` (this file is git-ignored; do not commit it):

```bash
cd /Users/rainatandon/stumped_ui/android
```

Create a new file named **`key.properties`** in the `android` folder with this content (replace the placeholder values):

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=upload-keystore.jks
```

- Replace `YOUR_KEYSTORE_PASSWORD` and `YOUR_KEY_PASSWORD` with the passwords you used when creating the keystore.
- Save the file.

**Done:** `android/key.properties` exists and has the correct passwords and `storeFile=upload-keystore.jks`.

---

## Part 3: Build the Release App Bundle

1. **Check versions (optional but recommended)**  
   - In `pubspec.yaml`, you can set:
     - `version: 1.0.0+1`  
     - Format is `versionName+versionCode` (e.g. `1.0.0+1` → name `1.0.0`, code `1`).  
   - The project is already set up to use this for Android when present.

2. **Build the AAB**
   - In Terminal:
     ```bash
     cd /Users/rainatandon/stumped_ui
     flutter build appbundle --release
     ```
   - If you see signing or key.properties errors, double-check:
     - `android/key.properties` exists and paths/passwords are correct.
     - `android/upload-keystore.jks` exists.

3. **Locate the file**
   - After a successful build:
     - Path:  
       **`/Users/rainatandon/stumped_ui/build/app/outputs/bundle/release/app-release.aab`**

**Done:** You have `app-release.aab` ready to upload.

---

## Part 4: Store Listing and First Release in Play Console

1. **Store listing**
   - In Play Console, open your app → **Grow** → **Store presence** → **Main store listing** (or **Store setup** → **Main store listing**).
   - Fill in:
     - **App name:** STUMPED  
     - **Short description** (max 80 characters), e.g.  
       `Precision cricket scoring for the modern elite.`  
     - **Full description** (max 4000 characters): a few lines about features, who it’s for, etc.
   - **Graphics (required):**
     - **App icon:** 512×512 px PNG, 32-bit.  
     - **Feature graphic:** 1024×500 px.  
     - **Screenshots:** At least 2 phone screenshots (e.g. 1080×1920 or similar). You can capture from device/emulator or from Chrome if you run the app in a phone-sized window.

2. **Content rating**
   - In **Policy** → **App content** → **Content rating**:
     - Start questionnaire, choose “Utility” or “Sports” (or closest match), answer questions.
     - Submit and apply the rating to this app.

3. **Privacy**
   - If your app does **not** collect personal/sensitive data (no accounts, no analytics, no third‑party SDKs that collect data), you can typically:
     - Declare “No” to collecting user data, or  
     - Use a simple “privacy policy” stating you don’t collect data, and add that URL in the store listing if required.  
   - If you use any SDK that collects data, you’ll need a real privacy policy URL and possibly a Data safety form.

4. **Upload the AAB**
   - Go to **Release** → **Production** (or **Testing** → **Internal testing** if you want to test first).
   - **Create new release**.
   - Upload **`app-release.aab`** (from Step 3).
   - Add **Release name** (e.g. “1.0.0”) and **Release notes** (e.g. “Initial release”).
   - Save, then **Review release** → **Start rollout to Production** (or to your chosen track).

**Done:** Your build is uploaded and submitted.

---

## Part 5: After Submission

- **Review:** Google usually reviews within a few days. You’ll get an email when it’s approved or if they need changes.
- **Updates later:**  
  - Bump version in `pubspec.yaml` (e.g. `1.0.1+2`).  
  - Run `flutter build appbundle --release` again.  
  - In Play Console, create a new release and upload the new `.aab`.

---

## Checklist Before You Hit “Submit”

- [ ] `android/key.properties` created and correct; `upload-keystore.jks` in place.
- [ ] `flutter build appbundle --release` runs without errors.
- [ ] Application ID in `android/app/build.gradle.kts` is what you want (e.g. `app.stumped` or `com.yourname.stumped`).
- [ ] App name and icon in Play Console match your intentions.
- [ ] Store listing (short + full description) and all required graphics (icon, feature graphic, screenshots) are uploaded.
- [ ] Content rating and privacy/data forms are completed.

If you tell me which part you’re on (e.g. “creating the keystore” or “uploading the AAB”), I can give shorter, focused steps for that part next.
