import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart' as official;
import 'package:motus_lab/core/config/app_secrets.dart';
import 'package:motus_lab/core/utils/logger.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class AuthService {
  // Client ID for Windows/Web (Phase 12)
  static String get _windowsClientId => AppSecrets.googleWindowsClientId;

  // Use getters to avoid calling .instance before Firebase.initializeApp()
  FirebaseAuth get _auth => FirebaseAuth.instance;

  /// Stream to listen to auth state changes
  Stream<User?> get userChanges {
    try {
      return _auth.userChanges();
    } catch (_) {
      return const Stream.empty();
    }
  }

  /// Current authenticated user
  User? get currentUser {
    try {
      return _auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  /// Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  /// Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      Logger.info("Starting Google Sign-In...");

      String? accessToken;
      String? idToken;

      if (Platform.isWindows) {
        Logger.info(
            "AuthService: Initializing Windows Sign-In (Manual Flow)...");

        // 1. สร้าง Local Server เพื่อรอรับ Callback จาก Google
        // ที่ต้องทำเองเพราะ Plugin ปกติ (google_sign_in) ยังไม่รองรับ Windows เต็มรูปแบบ
        // ใช้ 127.0.0.1 แทน localhost เพื่อลดปัญหา IPv6 บน Windows
        final server =
            await HttpServer.bind(InternetAddress.loopbackIPv4, 3000);

        String? authCode;

        try {
          // 2. สร้าง URL สำหรับ Google OAuth 2.0
          // ต้องกำหนด Scopes ให้ครบเพื่อขออีเมลและโปรไฟล์
          final clientId = _windowsClientId;
          const redirectUri = 'http://localhost:3000';
          const scopes = 'email profile openid';

          final authUrl =
              Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
            'client_id': clientId,
            'redirect_uri': redirectUri,
            'response_type': 'code',
            'scope': scopes,
          });

          // 3. เปิด Default Browser ของเครื่อง
          Logger.info("Launching browser: $authUrl");
          if (await canLaunchUrl(authUrl)) {
            await launchUrl(authUrl, mode: LaunchMode.externalApplication);
          } else {
            throw "Could not launch browser";
          }

          // 4. รอรับ Response จาก Browser
          Logger.info("Waiting for callback on $redirectUri...");
          await for (var request in server) {
            final uri = request.uri;
            if (uri.queryParameters.containsKey('code')) {
              authCode = uri.queryParameters['code'];

              // ตอบกลับ Browser ให้ User รู้ว่าสำเร็จแล้ว
              void sendResponse(String message) {
                request.response
                  ..statusCode = HttpStatus.ok
                  ..headers.contentType = ContentType.html
                  ..write(
                      '<html><body><h1>$message</h1><script>setTimeout(function(){window.close()}, 1000);</script></body></html>');
                request.response.close();
              }

              sendResponse(
                  "Authentication Successful! You can close this tab.");
              await request.response.done; // รอให้ส่งข้อมูลเสร็จ
              break; // ปิด Server ทันทีเมื่อได้ Code
            } else {
              request.response
                ..statusCode = HttpStatus.badRequest
                ..write('No code returned');
              await request.response.close();
            }
          }
        } finally {
          await server.close(force: true);
        }

        if (authCode == null) {
          return null;
        }

        // 5. นำ Code ไปแลกเป็น Token (Exchange)
        // ขั้นตอนนี้สำคัญ เพราะเราต้องส่ง ClientID/Secret ไปยืนยันตัวตนกับ Google
        Logger.info("Exchanging code for tokens...");

        final tokenResponse = await http.post(
          Uri.parse('https://oauth2.googleapis.com/token'),
          body: {
            'client_id': _windowsClientId,
            // Secret สำคัญมาก! ต้องเก็บใน .env เท่านั้น ห้าม Hardcode
            'client_secret': AppSecrets.googleWindowsClientSecret,
            'code': authCode,
            'grant_type': 'authorization_code',
            'redirect_uri': 'http://localhost:3000',
          },
        );

        if (tokenResponse.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(tokenResponse.body);
          accessToken = data['access_token'];
          idToken = data['id_token'];
        } else {
          Logger.error("Token Exchange Failed: ${tokenResponse.body}");
          throw "Failed to exchange token";
        }
      } else {
        // กรณีไม่ใช่ Windows (เช่น Android) ใช้ Plugin มาตรฐานได้เลย
        // สะดวกกว่าและรองรับ Native UI ของเครื่องนั้นๆ
        final officialSignIn = official.GoogleSignIn();
        final officialUser = await officialSignIn.signIn();
        if (officialUser == null) return null;

        final officialAuth = await officialUser.authentication;
        accessToken = officialAuth.accessToken;
        idToken = officialAuth.idToken;
      }

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      Logger.info("Google Sign-In Successful: ${userCredential.user?.email}");
      return userCredential;
    } catch (e) {
      Logger.error("Google Sign-In Failed", e);
      return null;
    }
  }

  /// Sign in with Email/Password
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      Logger.error("Email Sign-In Failed", e);
      return null;
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    try {
      // Sign out from official if mobile/web
      if (!Platform.isWindows) {
        await official.GoogleSignIn().signOut();
      }

      // Sign out from Firebase
      await _auth.signOut();

      Logger.info("User session terminated.");
    } catch (e) {
      Logger.error("Sign Out Failed", e);
    }
  }

  /// Multi-Factor Authentication (MFA) logic (TOTP / SMS)
  /// Note: MFA requires upgrading Firebase project to Identity Platform.
  Future<void> enrollMFA() async {
    // Skeletal for future expansion
    Logger.info("MFA Enrollment triggered (Skeletal)");
  }
}
