plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Add the Google services Gradle plugin
    id("com.google.gms.google-services")
}

android {
    namespace = "com.nextwe.caminandes"
    compileSdk = flutter.compileSdkVersion
    
    // 명시적으로 NDK 버전 설정
    ndkVersion = "29.0.13113456" // 시스템에 설치된 NDK 버전
    
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.nextwe.caminandes"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 23 // Firebase Auth를 위해 23으로 업데이트
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // 구글 맵 API 키 설정
        manifestPlaceholders["MAPS_API_KEY"] = "AIzaSyBXPSobl9bQL60ZXuvkEiM7kI0TFaxcQPk"
        
        // OpenGL ES 버전 설정 (2.0으로 변경)
        manifestPlaceholders["OPENGL_VERSION"] = 2
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
    
    // SQLite 관련 설정
    packagingOptions {
        jniLibs {
            useLegacyPackaging = true
        }
    }
    
    // OpenGL ES 관련 문제 해결을 위한 설정
    aaptOptions {
        noCompress.add("tflite")
        noCompress.add("lite")
    }
    
    // 추가 OpenGL ES 문제 해결을 위한 설정
    buildFeatures {
        renderScript = false
        aidl = false
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Import the Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
    
    // Add the dependency for the Firebase SDK for Google Analytics
    implementation("com.google.firebase:firebase-analytics")
    
    // 구글 맵 의존성 추가
    implementation("com.google.android.gms:play-services-maps:18.1.0")
    implementation("com.google.android.gms:play-services-location:21.0.1")
}
