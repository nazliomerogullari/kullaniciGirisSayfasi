import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  // Bu satır Firebase başlamadan önce Flutter'ın hazır olduğundan emin olur
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase'i senin oluşturduğun ayarlarla başlatıyoruz
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Profesyonel Auth Sistemi',
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      home: const LoginPage(),
    );
  }
}

// --- GİRİŞ SAYFASI ---
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isLoading = false; // Giriş butonu için yükleme durumu

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Giriş yapma simülasyonu
  // En üstteki importlar zaten duruyor: import 'package:firebase_auth/firebase_auth.dart';

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Firebase'e giriş isteği gönderiyoruz
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Başarıyla giriş yapıldı!")),
          );
          // Burada girişten sonra gitmek istediğin sayfaya yönlendirme yapabilirsin
        }
      } on FirebaseAuthException catch (e) {
        // Hata durumlarını yakalıyoruz
        String message = "Giriş başarısız";
        if (e.code == 'user-not-found')
          message = "Bu e-posta ile kayıtlı kullanıcı bulunamadı.";
        if (e.code == 'wrong-password') message = "Hatalı şifre girdiniz.";

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo[900]!, Colors.indigo[600]!],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 80),
            // Güncellenen Giriş Başlığı
            _buildHeader("Hoş Geldiniz", "Devam etmek için hesabınıza erişin"),
            const SizedBox(height: 40),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(30),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildInputField(
                          controller: _emailController,
                          hint: "E-posta Adresi",
                          icon: Icons.email_outlined,
                          validator: (v) => v!.contains("@")
                              ? null
                              : "Geçerli bir e-posta giriniz",
                        ),
                        const SizedBox(height: 20),

                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          validator: (v) => v!.length < 6
                              ? "Şifre en az 6 karakter olmalı"
                              : null,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Colors.indigo,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () => setState(
                                () => _isPasswordVisible = !_isPasswordVisible,
                              ),
                            ),
                            hintText: "Şifre",
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Şifre sıfırlama bağlantısı gönderildi.",
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              "Şifremi Unuttum?",
                              style: TextStyle(
                                color: Colors.indigo,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Yükleme Simgeli Giriş Butonu
                        _buildActionButton("Giriş Yap", _login),

                        const SizedBox(height: 20),
                        const Text(
                          "veya",
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 20),

                        // Kendi eklediğin asset ikonuyla Google Butonu
                        _buildGoogleSignInButton(),

                        const SizedBox(height: 30),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Hesabınız yok mu?"),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const RegisterPage(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Kayıt Ol",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleSignInButton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        onTap: _isLoading
            ? null
            : () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Google ile giriş yapılıyor..."),
                  ),
                );
              },
        borderRadius: BorderRadius.circular(15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // KENDİ EKLEDİĞİN ASSET LOGOSU
            Image.asset(
              'assets/images/google_logo.png',
              height: 24,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.g_mobiledata, color: Colors.red, size: 30),
            ),
            const SizedBox(width: 12),
            const Text(
              "Google ile Devam Et",
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: _isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.indigo[800],
        disabledBackgroundColor: Colors.indigo[800]?.withOpacity(0.6),
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
      ),
      child: _isLoading
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}

// --- KAYIT OL SAYFASI ---
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _regFormKey = GlobalKey<FormState>();
  bool _isRegPasswordVisible = false;
  bool _isRegLoading = false; // Kayıt butonu için yükleme durumu

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  // main.dart dosyasının en alt kısımlarında, RegisterPage bölümünde:

  void _register() async {
    if (_regFormKey.currentState!.validate()) {
      setState(() => _isRegLoading = true);

      try {
        // BURASI GERÇEK KAYIT İŞLEMİNİ YAPAR
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passController.text.trim(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Hesabınız başarıyla oluşturuldu!")),
          );
          Navigator.pop(context); // Kayıt başarılıysa giriş ekranına geri döner
        }
      } on FirebaseAuthException catch (e) {
        // Hata durumunda (mesela e-posta zaten varsa) burası çalışır
        String message = "Bir hata oluştu";
        if (e.code == 'email-already-in-use')
          message = "Bu e-posta zaten kullanımda.";
        if (e.code == 'weak-password') message = "Şifre çok zayıf.";
        if (e.code == 'invalid-email') message = "Geçersiz e-posta formatı.";

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) {
          setState(() => _isRegLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo[900],
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        color: Colors.indigo[900],
        child: Column(
          children: [
            // Kayıt Sayfası Hoş Geldiniz Başlığı
            _buildHeader("Hoş Geldiniz", "Yeni bir dünya için ilk adımı atın"),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(30),
                  child: Form(
                    key: _regFormKey,
                    child: Column(
                      children: [
                        _buildInputField(
                          controller: _nameController,
                          hint: "Ad Soyad",
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 20),
                        _buildInputField(
                          controller: _emailController,
                          hint: "E-posta",
                          icon: Icons.email_outlined,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _passController,
                          obscureText: !_isRegPasswordVisible,
                          validator: (v) => v!.length < 6
                              ? "Şifre en az 6 karakter olmalı"
                              : null,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Colors.indigo,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isRegPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () => setState(
                                () => _isRegPasswordVisible =
                                    !_isRegPasswordVisible,
                              ),
                            ),
                            hintText: "Şifre",
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Yükleme Simgeli Kayıt Butonu
                        ElevatedButton(
                          onPressed: _isRegLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo[800],
                            minimumSize: const Size(double.infinity, 55),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: _isRegLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "Hesap Oluştur",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- YARDIMCI BİLEŞENLER (WIDGETS) ---

Widget _buildHeader(String title, String subtitle) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 30),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ],
    ),
  );
}

Widget _buildInputField({
  required TextEditingController controller,
  required String hint,
  required IconData icon,
  String? Function(String?)? validator,
}) {
  return TextFormField(
    controller: controller,
    validator:
        validator ?? (v) => v!.isEmpty ? "Bu alan boş bırakılamaz" : null,
    decoration: InputDecoration(
      prefixIcon: Icon(icon, color: Colors.indigo),
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    ),
  );
}
