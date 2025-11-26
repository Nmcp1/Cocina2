import 'package:flutter/material.dart';
import 'package:cocinagame/constants/theme.dart';
import 'package:cocinagame/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground1,
      body: Stack(
        children: [
          // MEDIA ELIPSE SUPERIOR
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 150,
              decoration: BoxDecoration(
                color: kPrimary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.elliptical(400, 250),
                  bottomRight: Radius.elliptical(400, 250),
                ),
              ),
            ),
          ),

          // TÍTULO SUPERIOR
          Positioned(
            top: 65,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'COCINA2',
                style: const TextStyle(
                  fontSize: 48,
                  color: kBackground1,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // CONTENIDO PRINCIPAL
          Positioned(
            top: 180,
            left: 0,
            right: 0,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // LOGO CIRCULAR
                  ClipOval(
                    child: SizedBox(
                      width: 180,
                      height: 180,
                      child: Image.asset(
                        'assets/images/logo_cocina2.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Crear Cuenta",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: kText1,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // EMAIL
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: "Correo electrónico",
                      labelStyle: const TextStyle(color: kPrimary),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: kPrimary,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: kPrimary,
                          width: 2,
                        ),
                      ),
                      fillColor: kBackground2,
                      filled: true,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // CONTRASEÑA
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: "Contraseña",
                      labelStyle: const TextStyle(color: kPrimary),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: kPrimary,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: kPrimary,
                          width: 2,
                        ),
                      ),
                      fillColor: kBackground2,
                      filled: true,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: kPrimary,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // CONFIRMAR CONTRASEÑA
                  TextField(
                    controller: _confirmController,
                    obscureText: _obscureConfirm,
                    decoration: InputDecoration(
                      labelText: "Confirmar contraseña",
                      labelStyle: const TextStyle(color: kPrimary),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: kPrimary,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: kPrimary,
                          width: 2,
                        ),
                      ),
                      fillColor: kBackground2,
                      filled: true,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: kPrimary,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirm = !_obscureConfirm;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // BOTÓN REGISTRAR
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kSecondary,
                      minimumSize: const Size(200, 50),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _loading ? null : _registerUser,
                    child: _loading
                        ? const CircularProgressIndicator(
                            color: kBackground1,
                          )
                        : const Text(
                            "Crear Cuenta",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: kBackground1,
                            ),
                          ),
                  ),

                  const SizedBox(height: 30),

                  // BOTÓN LOGIN
                  TextButton(
                    onPressed: () {
                      // Reemplaza la ruta actual para evitar URLs raras en web
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text(
                      "¿Ya tienes cuenta? Inicia sesión",
                      style: TextStyle(
                        color: kText1,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _registerUser() async {
    final email = _emailController.text.trim();
    final pass = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (email.isEmpty || pass.isEmpty || confirm.isEmpty) {
      _showMessage("Completa todos los campos");
      return;
    }

    if (pass != confirm) {
      _showMessage("Las contraseñas no coinciden");
      return;
    }

    setState(() => _loading = true);

    try {
      await AuthService().register(email, pass);

      if (!mounted) return;

      // Después de registrar, ir directo al menú y limpiar el stack
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/',
        (route) => false,
      );
    } catch (e) {
      _showMessage("Error: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
}
