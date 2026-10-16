import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'services/api_service.dart';
import 'pages/client_home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/worker_home_page.dart';
import 'pages/forgot_password_page.dart';
import 'pages/reset_password_page.dart';
import 'pages/register_page.dart';

void main() {
  runApp(const OfixApp());
}

class OfixApp extends StatelessWidget {
  const OfixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OFIX',
      theme: OfixTheme.theme,
      initialRoute: Uri.base.toString(),
      onGenerateRoute: (settings) {
        final uri = Uri.tryParse(
          settings.name ?? '/',
        );

        // Enlace del correo de recuperación de contraseña.
        if (uri != null &&
            uri.path == '/reset-password') {
          final token = uri.queryParameters['token'];

          if (token != null &&
              token.isNotEmpty) {
            return MaterialPageRoute(
              builder: (_) => ResetPasswordPage(
                token: token,
              ),
            );
          }
        }

        return MaterialPageRoute(
          builder: (_) => const OfixWelcomePage(),
        );
      },
    );
  }
}

// Bienvenida
class OfixWelcomePage extends StatelessWidget {
  const OfixWelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 28,
              vertical: 24,
            ),
            child: Column(
              children: [
                const SizedBox(height: 30),

                // Logo OFIX
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: OfixColors.darkBlue,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Center(
                    child: Text(
                      'OFIX',
                      style: TextStyle(
                        color: OfixColors.white,
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                Text(
                  'Soluciones para tu hogar',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),

                const SizedBox(height: 14),

                Text(
                  'Encuentra profesionales confiables '
                  'para realizar los servicios que necesitas.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: OfixColors.textSecondary,
                        height: 1.5,
                      ),
                ),

                const SizedBox(height: 45),

                // Ilustración provisional
                Container(
                  width: double.infinity,
                  height: 190,
                  decoration: BoxDecoration(
                    color: OfixColors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.home_repair_service_outlined,
                        size: 72,
                        color: OfixColors.primary,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Profesionales para lo que necesitas',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: OfixColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 45),

                // Iniciar sesión (solo abre la pantalla de login)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OfixLoginPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Iniciar sesión',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Crear cuenta
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      final creada = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterPage()),
                      );

                      // Si se registró, lo llevamos al login.
                      if (creada == true && context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const OfixLoginPage()),
                        );
                      }
                    },
                    child: const Text(
                      'Crear una cuenta',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Servicios confiables, cerca de ti.',
                  style: TextStyle(
                    fontSize: 13,
                    color: OfixColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Sesión de login
class OfixLoginPage extends StatefulWidget {
  const OfixLoginPage({super.key});

  @override
  State<OfixLoginPage> createState() => _OfixLoginPageState();
}

class _OfixLoginPageState extends State<OfixLoginPage> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  // true mientras se espera la respuesta del servidor.
  bool cargando = false;

  // Libera los controllers.
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  // Según el rol guardado en el login, abre el inicio que corresponde.
  Future<void> _irAlHome() async {
    final prefs = await SharedPreferences.getInstance();

    final rol = prefs.getString('rol');

    if (!mounted) {
      return;
    }

    if (rol == 'TRABAJADOR') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const WorkerHomePage(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const ClientHomePage(),
        ),
      );
    }
  }

  // Valida los campos, llama al backend y muestra el mensaje adecuado.
  Future<void> _iniciarSesion() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    final messenger = ScaffoldMessenger.of(context);

    // Validación local antes de llamar al servidor.
    if (email.isEmpty || password.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Ingresa tu correo y tu contraseña'),
        ),
      );
      return;
    }

    setState(() {
      cargando = true;
    });

    try {
      final resultado = await ApiService.login(email, password);

      if (!mounted) {
        return;
      }

      final codigo = resultado['statusCode'];

      // Login correcto: entramos al inicio.
      if (codigo == 200) {
        await _irAlHome();
        return;
      }

      // 401 = credenciales malas, 400 = cuenta suspendida o datos inválidos.
      // En ambos casos el backend manda el texto en "mensaje".
      final data = resultado['data'];
      String mensaje;

      if ((codigo == 401 || codigo == 400) &&
          data is Map &&
          data['mensaje'] != null) {
        mensaje = data['mensaje'].toString();
      } else {
        mensaje = 'Ocurrió un problema en el servidor. Inténtalo de nuevo.';
      }

      messenger.showSnackBar(SnackBar(content: Text(mensaje)));
    } catch (_) {
      // Sin conexión o servidor apagado.
      if (!mounted) {
        return;
      }

      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo conectar con el servidor. Revisa tu conexión.',
          ),
        ),
      );
    } finally {
      // Siempre se vuelve a habilitar el botón.
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar sesión'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 28,
              vertical: 30,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                Text(
                  'Bienvenido a OFIX',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),

                const SizedBox(height: 10),

                Text(
                  'Inicia sesión para continuar.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                const SizedBox(height: 40),

                const Text(
                  'Correo electrónico',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: OfixColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 8),

                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'correo@ejemplo.com',
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                    ),
                    filled: true,
                    fillColor: OfixColors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                const Text(
                  'Contraseña',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: OfixColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 8),

                TextField(
                  controller: passwordController,
                  obscureText: true,
                  // Enter en el teclado también inicia sesión.
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) {
                    if (!cargando) {
                      _iniciarSesion();
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'Ingresa tu contraseña',
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                    ),
                    filled: true,
                    fillColor: OfixColors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordPage(),
                        ),
                      );
                    },
                    child: const Text(
                      '¿Olvidaste tu contraseña?',
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Botón iniciar sesión (con spinner mientras carga)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: cargando ? null : _iniciarSesion,
                    child: cargando
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Iniciar sesión',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 25),

                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterPage()),
                      );
                    },
                    child: const Text(
                      '¿No tienes una cuenta? Crear cuenta',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}