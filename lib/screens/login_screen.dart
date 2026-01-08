import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../core/ferro_colors.dart';
import '../widgets/ferro_logo.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _showForgotPasswordDialog(BuildContext context, LanguageProvider lp, AuthProvider ap) {
    final emailCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: FerroColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          lp.translate('resetPasswordTitle'),
          style: const TextStyle(color: FerroColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              lp.translate('resetPasswordMsg'),
              style: const TextStyle(color: FerroColors.textMuted, fontSize: 14),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: emailCtrl,
              label: lp.translate('email'),
              hintText: lp.translate('emailHint'),
              icon: Icons.email_outlined,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              lp.translate('cancel'),
              style: const TextStyle(color: FerroColors.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (emailCtrl.text.isNotEmpty) {
                await ap.resetPassword(emailCtrl.text);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(lp.translate('resetLinkSent')),
                      backgroundColor: FerroColors.success,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: FerroColors.amber,
              foregroundColor: FerroColors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(lp.translate('sendLink')),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoSection(AuthProvider ap, LanguageProvider lp) {
    return Column(
      children: [
        Text(
          lp.isRTL ? "دخول سريع (تجريبي)" : "Quick Login (Demo)",
          style: const TextStyle(color: FerroColors.textMuted, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _demoBtn(ap, 'customer@demo.com', lp.translate('customer'), Icons.person),
              _demoBtn(ap, 'workshop@demo.com', lp.translate('workshopOwner'), Icons.build),
              _demoBtn(ap, 'tow_driver@demo.com', lp.translate('towTruck'), Icons.build),
              _demoBtn(ap, 'driver@demo.com', lp.translate('deliveryDriver'), Icons.delivery_dining),
              _demoBtn(ap, 'supplier@demo.com', lp.translate('supplier'), Icons.store),
            ],
          ),
        ),
      ],
    );
  }

  Widget _demoBtn(AuthProvider ap, String email, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ActionChip(
        avatar: Icon(icon, size: 16, color: FerroColors.black),
        label: Text(label, style: const TextStyle(fontSize: 12, color: FerroColors.black)),
        backgroundColor: FerroColors.amber.withOpacity(0.7),
        onPressed: () => ap.login(email, 'password'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lp = Provider.of<LanguageProvider>(context);
    final ap = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const FerroLogo(size: 80),
              const SizedBox(height: 60),
              Text(
                lp.translate('login'),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: FerroColors.textPrimary,
                ),
              ),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _emailController,
                      label: lp.translate('email'),
                      hintText: lp.translate('emailHint'),
                      icon: Icons.email_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return lp.translate('requiredField');
                        }
                        if (!value.contains('@')) {
                          return lp.translate('invalidEmail');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _passwordController,
                      label: lp.translate('password'),
                      hintText: lp.translate('passwordHint'),
                      icon: Icons.lock_outline,
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return lp.translate('requiredField');
                        }
                        if (value.length < 6) {
                          return lp.isRTL ? "كلمة المرور قصيرة جداً" : "Password is too short";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              Align(
                alignment: lp.isRTL ? Alignment.centerLeft : Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _showForgotPasswordDialog(context, lp, ap),
                  child: Text(
                    lp.translate('forgotPassword'),
                    style: const TextStyle(color: FerroColors.textMuted),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() => _isLoading = true);
                    await ap.login(_emailController.text, _passwordController.text);
                    if (mounted) setState(() => _isLoading = false);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: FerroColors.amber,
                  foregroundColor: FerroColors.black,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: FerroColors.black)
                  : Text(lp.translate('login'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 24),
              _buildDemoSection(ap, lp),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(lp.translate('dontHaveAccount'), style: const TextStyle(color: FerroColors.textMuted)),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen())),
                    child: Text(
                      lp.translate('signUp'),
                      style: const TextStyle(color: FerroColors.amber, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: FerroColors.textPrimary),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        hintStyle: const TextStyle(color: FerroColors.textMuted, fontSize: 14),
        labelStyle: const TextStyle(color: FerroColors.textMuted),
        prefixIcon: Icon(icon, color: FerroColors.textMuted),
        filled: true,
        fillColor: FerroColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: FerroColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: FerroColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: FerroColors.amber),
        ),
      ),
    );
  }
}
