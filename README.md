# 🏆 Dance Studio Discovery App  

This project is a dance studio discovery app developed with **Flutter**.  
Users can **list, filter, view dance studios on a map**, add them to favorites, and make reservations.  

---

## 🚀 Features  
✅ **Firebase Authentication** for user login and registration  
✅ **Firestore Database** to store dance studio information  
✅ **Google Maps API** integration to show studio locations on the map  
✅ **Add to favorites, create reservations, and list studios**  
✅ **Advanced search and filtering options**  

---

## 📦 Installation  


### 🎯 1. Install Flutter and Required Dependencies  

Make sure you have the **Flutter SDK** installed:  
[Flutter Installation Guide](https://flutter.dev/docs/get-started/install)  

Then, run the following command in your terminal to get the project dependencies:  

```sh
flutter pub get
```

---

# 🔥 Firebase Integration

### Running the project with Firebase
To use this project with Firebase, follow these steps:

1️⃣ **Create a Firebase Project**
   - Go to Firebase Console
   - Create a new Firebase project

2️⃣ **Enable Firebase Authentication**
   - Go to **Firebase Console > Authentication > Sign-in method**
   - Enable **Email/Password** provider

3️⃣ **Enable Cloud Firestore**
   - Go to **Firebase Console > Firestore Database > Create Database**

4️⃣ **Add Firebase SDK to Your Project**
   - Install the Firebase packages by running the following command:

   ```sh
   flutter pub add firebase_core firebase_auth cloud_firestore
   ```
## 🔹 Firebase Database: Creating Collection and Document

In Firebase Firestore, you can create a `dance_studios` collection and store each dance studio as a document.

#### 📌 Dance Studios Collection
1. Create a **"dance_studios"** collection in Firestore.
2. For each dance studio, create a document with the following fields:
   - **name**: The name of the dance studio
   - **address**: The address of the studio
   - **latitude**: The latitude coordinate of the studio
   - **longitude**: The longitude coordinate of the studio
   - **styles**: A list of dance styles offered (e.g., Salsa, Hip-hop, etc.)

Here is an example of a document:

```json
{
  "name": "The Dance Studio",
  "address": "123 Main Street, City",
  "latitude": 40.712776,
  "longitude": -74.005974,
  "styles": ["Salsa", "Hip-hop", "Ballet"]
}
```

---

### 🗺 Google Maps API Key Integration

To use Google Maps in your Flutter application, you need to obtain a Google Maps API Key from the Google Developer Console.

#### 📌 Add API Key Directly in AndroidManifest.xml

1. Obtain the Google Maps API Key from the Google Developer Console.
2. Open **AndroidManifest.xml** in your project at `android/app/src/main/AndroidManifest.xml`.
3. Add the API key inside the `<application>` tag as follows:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.flutter_google_map">
    
    <application
        android:label="flutter_google_map"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme" />
              
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        
        <!-- Google Maps API Key -->
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="YOUR-API-KEY-HERE"/>
    </application>
</manifest>
```
## Configuring for Android

To use the Google Maps SDK on Android, the minSDK must be set to 23.

    android/app/build.gradle

    ```gradle
    android{
        defaultConfig {
        applicationId = "com.example.flutter_application"
        minSdk 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        }
    }
    ```
---

## 🔒 Secure API Keys & Firebase Configuration

To keep sensitive information secure, the following files are added to .gitignore and should not be included in version control:

Android: android/app/google-services.json
```
{
  "project_info": {
    "project_number": "702575491728",
    "project_id": "flutter-application-214d4",
    "storage_bucket": "flutter-application-214d4.firebasestorage.app"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:702575491728:android:31d6b5561ac6d667ae7615",
        "android_client_info": {
          "package_name": "com.example.flutter_application"
        }
      },
      "oauth_client": [],
      "api_key": [
        {
          "current_key": "API_KEY_HERE"
        }
      ],
      "services": {
        "appinvite_service": {
          "other_platform_oauth_client": []
        }
      }
    }
  ],
  "configuration_version": "1"
}
```

iOS: ios/Runner/GoogleService-Info.plist
```
<plist version="1.0">
<dict>
	<key>API_KEY</key>
	<string>API_KEY_HERE</string>
```

### 🎯 Packages Used

Here are some important packages used in this project:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # The following adds the Cupertino Icons font to your application.
  # Use with the CupertinoIcons class for iOS style icons.
  cupertino_icons: ^1.0.8
  firebase_core: ^3.11.0
  firebase_auth: ^5.4.1
  cloud_firestore: ^5.6.3
  google_maps_flutter: ^2.10.0
  intl: ^0.20.2
  ```

---

### 📝 Gitignore

The following files are added to gitignore for security and privacy reasons:

- **firebase_options.dart**: The Firebase configuration file, which contains sensitive information like API keys.
- **AndroidManifest.xml**: Contains Google Maps API key and other sensitive information.