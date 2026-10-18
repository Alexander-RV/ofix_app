import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme/app_theme.dart';
import 'widgets/ofix_widgets.dart';
import 'services/api_service.dart';
import 'pages/client_home_page.dart';
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
        final uri = Uri.tryParse(settings.name ?? '/');

        // Enlace del correo de recuperación de contraseña.
        if (uri != null && uri.path == '/reset-password') {
          final token = uri.queryParameters['token'];

          if (token != null && token.isNotEmpty) {
            return MaterialPageRoute(
              builder: (_) => ResetPasswordPage(token: token),
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

// ---------------------------------------------------------------------------
// Navegación y utilidades compartidas por bienvenida y login
// ---------------------------------------------------------------------------

void _abrirLogin(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const OfixLoginPage()),
  );
}

// Abre el registro. Si la cuenta se crea y luegoLogin es true, abre el login.
Future<void> _abrirRegistro(
  BuildContext context, {
  bool luegoLogin = false,
}) async {
  final creada = await Navigator.push<bool>(
    context,
    MaterialPageRoute(builder: (_) => const RegisterPage()),
  );

  if (luegoLogin && creada == true && context.mounted) {
    _abrirLogin(context);
  }
}

// Icono según el nombre de la categoría (si no hay coincidencia, uno genérico).
IconData _iconoCategoria(String nombre) {
  final n = nombre.toLowerCase();

  if (n.contains('electr')) return Icons.bolt;
  if (n.contains('plom')) return Icons.plumbing;
  if (n.contains('limpi')) return Icons.cleaning_services;
  if (n.contains('pint')) return Icons.format_paint;
  if (n.contains('jard')) return Icons.yard;
  if (n.contains('carpint')) return Icons.carpenter;
  if (n.contains('cerraj')) return Icons.key;
  if (n.contains('aire') || n.contains('climat')) return Icons.ac_unit;
  if (n.contains('mudanz') || n.contains('transp')) {
    return Icons.local_shipping;
  }
  if (n.contains('tecn') || n.contains('técn') || n.contains('comput')) {
    return Icons.computer;
  }

  return Icons.handyman;
}

// (color del icono, color de fondo) que se van alternando entre categorías
const List<(Color, Color)> _paletaCategorias = [
  (OfixColors.primary, OfixColors.primarySoft),
  (OfixColors.warning, OfixColors.warningSoft),
  (OfixColors.success, OfixColors.successSoft),
  (OfixColors.error, OfixColors.errorSoft),
  (OfixColors.darkBlue, Color(0xFFE6ECF7)),
];

// ---------------------------------------------------------------------------
// Bienvenida
// ---------------------------------------------------------------------------

class OfixWelcomePage extends StatefulWidget {
  const OfixWelcomePage({super.key});

  @override
  State<OfixWelcomePage> createState() => _OfixWelcomePageState();
}

class _OfixWelcomePageState extends State<OfixWelcomePage> {
  // Categorías reales del backend (endpoint público)
  late Future<List<Map<String, dynamic>>> _categorias;

  @override
  void initState() {
    super.initState();
    _categorias = ApiService.listarCategoriasPublicas();
  }

  void _recargar() {
    setState(() {
      _categorias = ApiService.listarCategoriasPublicas();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.sizeOf(context).width;

    // Pantalla grande (PC) o celular: cambia la distribución
    final esAncho = ancho >= 800;
    final double anchoContenido = (ancho > 1100 ? 1100.0 : ancho) - 40;

    return Scaffold(
      body: Column(
        children: [
          _barraSuperior(),
          Expanded(
            child: SingleChildScrollView(
              child: OfixMaxWidth(
                maxWidth: 1100,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _hero(esAncho),
                      const SizedBox(height: 40),
                      _servicios(anchoContenido, esAncho),
                      const SizedBox(height: 40),
                      _bannerProfesional(esAncho),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Barra fija: logo + Ingresar / Regístrate
  Widget _barraSuperior() {
    return Container(
      decoration: const BoxDecoration(
        color: OfixColors.white,
        border: Border(bottom: BorderSide(color: OfixColors.border)),
      ),
      child: SafeArea(
        bottom: false,
        child: OfixMaxWidth(
          maxWidth: 1100,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                const OfixLogo(size: 26),
                const Spacer(),
                FilledButton(
                  onPressed: () => _abrirLogin(context),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                  ),
                  child: const Text('Ingresar'),
                ),
                const SizedBox(width: 8),
                // minimumSize propio: el tema define ancho infinito y
                // dentro de un Row daría error de layout
                OutlinedButton(
                  onPressed: () => _abrirRegistro(context, luegoLogin: true),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    side: const BorderSide(color: OfixColors.border),
                  ),
                  child: const Text('Regístrate'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Título, subtítulo, buscador e imagen
  Widget _hero(bool esAncho) {
    final textos = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Soluciones para tu hogar, en manos expertas',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontSize: esAncho ? 44 : 32,
                height: 1.15,
              ),
        ),
        const SizedBox(height: 14),
        // Cuando exista la verificación de profesionales, aquí se
        // cambia por "profesionales verificados"
        Text(
          'Encuentra profesionales para resolver '
          'tus necesidades en Medellín.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: OfixColors.textSecondary,
                height: 1.5,
              ),
        ),
        const SizedBox(height: 24),
        _buscador(),
      ],
    );

    final grafico = _graficoHero(esAncho);

    if (esAncho) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(flex: 5, child: textos),
          const SizedBox(width: 32),
          Expanded(flex: 5, child: grafico),
        ],
      );
    }

    return Column(
      children: [
        textos,
        const SizedBox(height: 24),
        grafico,
      ],
    );
  }

  // Buscador: por ahora invita a iniciar sesión para solicitar un servicio
  Widget _buscador() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 520),
      decoration: BoxDecoration(
        color: OfixColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: OfixColors.border),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => _abrirLogin(context),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.search, color: OfixColors.textSecondary),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '¿Qué servicio necesitas?',
                      style: TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 18,
                  color: OfixColors.error,
                ),
                const SizedBox(width: 6),
                const Text(
                  'Medellín',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: OfixColors.textPrimary,
                  ),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () => _abrirLogin(context),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                  child: const Text('Buscar'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Imagen provisional (degradado + insignia), hasta tener fotos reales
  Widget _graficoHero(bool esAncho) {
    return Container(
      height: esAncho ? 340 : 210,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [OfixColors.darkBlue, OfixColors.primary],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              top: 10,
              child: Icon(
                Icons.home_repair_service_outlined,
                size: esAncho ? 220 : 150,
                color: Colors.white.withValues(alpha: 0.18),
              ),
            ),
            Positioned(
              left: 16,
              bottom: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: OfixColors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Personas reales',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: OfixColors.darkBlue,
                      ),
                    ),
                    Text(
                      'Soluciones reales',
                      style: TextStyle(
                        fontSize: 16,
                        color: OfixColors.darkBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Categorías reales en tarjetas (3 por fila en celular, 6 en PC)
  Widget _servicios(double anchoContenido, bool esAncho) {
    final columnas = esAncho ? 6 : 3;
    const espacio = 12.0;
    final anchoTarjeta = (anchoContenido - espacio * (columnas - 1)) / columnas;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const OfixSectionHeader(titulo: 'Servicios disponibles'),
        const SizedBox(height: 12),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _categorias,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snap.hasError) {
              return OfixCard(
                child: Row(
                  children: [
                    const Expanded(
                      child: Text('No se pudieron cargar los servicios.'),
                    ),
                    TextButton(
                      onPressed: _recargar,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            final visibles = (snap.data ?? []).take(6).toList();

            if (visibles.isEmpty) {
              return const SizedBox.shrink();
            }

            return Wrap(
              spacing: espacio,
              runSpacing: espacio,
              children: [
                for (var i = 0; i < visibles.length; i++)
                  SizedBox(
                    width: anchoTarjeta,
                    child: _tarjetaCategoria(visibles[i], i),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _tarjetaCategoria(Map<String, dynamic> categoria, int indice) {
    final nombre = (categoria['nombre'] ?? '').toString();
    final (color, fondo) = _paletaCategorias[indice % _paletaCategorias.length];

    return OfixCard(
      onTap: () => _abrirLogin(context),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(color: fondo, shape: BoxShape.circle),
            child: Icon(_iconoCategoria(nombre), color: color),
          ),
          const SizedBox(height: 10),
          Text(
            nombre,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: OfixColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // Franja azul para atraer profesionales
  Widget _bannerProfesional(bool esAncho) {
    final icono = Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.engineering, color: OfixColors.white, size: 30),
    );

    final textos = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          '¿Eres un profesional?',
          style: TextStyle(
            color: OfixColors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Únete a OFIX y consigue más clientes.',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
        ),
      ],
    );

    final boton = FilledButton(
      onPressed: () => _abrirRegistro(context, luegoLogin: true),
      style: FilledButton.styleFrom(
        backgroundColor: OfixColors.white,
        foregroundColor: OfixColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 22),
      ),
      child: const Text('Quiero ser un profesional'),
    );

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: OfixColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: esAncho
          ? Row(
              children: [
                icono,
                const SizedBox(width: 18),
                Expanded(child: textos),
                const SizedBox(width: 18),
                boton,
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                icono,
                const SizedBox(height: 14),
                textos,
                const SizedBox(height: 18),
                SizedBox(width: double.infinity, child: boton),
              ],
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// Login
// ---------------------------------------------------------------------------

class OfixLoginPage extends StatefulWidget {
  const OfixLoginPage({super.key});

  @override
  State<OfixLoginPage> createState() => _OfixLoginPageState();
}

class _OfixLoginPageState extends State<OfixLoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // true mientras se espera la respuesta del servidor
  bool cargando = false;

  // true cuando el usuario pulsa el ojito para ver la contraseña
  bool verPassword = false;

  // Libera los controllers
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  // Según el rol guardado en el login, abre el inicio que corresponde
  Future<void> _irAlHome() async {
    final prefs = await SharedPreferences.getInstance();
    final rol = prefs.getString('rol');

    if (!mounted) {
      return;
    }

    if (rol == 'TRABAJADOR') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WorkerHomePage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ClientHomePage()),
      );
    }
  }

  // Valida los campos, llama al backend y muestra el mensaje adecuado
  Future<void> _iniciarSesion() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    final messenger = ScaffoldMessenger.of(context);

    // Validación local antes de llamar al servidor
    if (email.isEmpty || password.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Ingresa tu correo y tu contraseña')),
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

      // Login correcto: entramos al inicio
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
      // Sin conexión o servidor apagado
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
      // Siempre se vuelve a habilitar el botón
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
    }
  }

  // Etiqueta pequeña sobre cada campo
  Widget _etiqueta(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: OfixColors.textPrimary,
        ),
      ),
    );
  }

  // Pestañas "Iniciar sesión" (activa) / "Crear cuenta" (lleva al registro)
  Widget _pestanas() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: OfixColors.primary, width: 2),
              ),
            ),
            child: const Text(
              'Iniciar sesión',
              style: TextStyle(
                color: OfixColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: () => _abrirRegistro(context),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: OfixColors.border, width: 2),
                ),
              ),
              child: const Text(
                'Crear cuenta',
                style: TextStyle(
                  color: OfixColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              // En PC la tarjeta no se estira más de 440
              constraints: const BoxConstraints(maxWidth: 440),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: OfixColors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: OfixColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Volver a la bienvenida
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: OfixColors.textSecondary,
                          padding: EdgeInsets.zero,
                        ),
                        icon: const Icon(Icons.arrow_back, size: 18),
                        label: const Text('Volver'),
                      ),
                    ),

                    const SizedBox(height: 8),
                    const Center(child: OfixLogo(size: 34)),
                    const SizedBox(height: 18),

                    Center(
                      child: Text(
                        'Bienvenido a OFIX',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: Text(
                        'Inicia sesión para continuar',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),

                    const SizedBox(height: 22),
                    _pestanas(),
                    const SizedBox(height: 24),

                    _etiqueta('Correo electrónico'),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'tu@correo.com',
                      ),
                    ),

                    const SizedBox(height: 18),

                    _etiqueta('Contraseña'),
                    TextField(
                      controller: passwordController,
                      obscureText: !verPassword,
                      // Enter en el teclado también inicia sesión
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) {
                        if (!cargando) {
                          _iniciarSesion();
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Tu contraseña',
                        // Ojito para mostrar u ocultar la contraseña
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              verPassword = !verPassword;
                            });
                          },
                          icon: Icon(
                            verPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: OfixColors.textSecondary,
                          ),
                        ),
                      ),
                    ),

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
                        child: const Text('¿Olvidaste tu contraseña?'),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Botón principal (spinner mientras carga)
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

                    const SizedBox(height: 18),

                    // Wrap evita desbordes en pantallas muy angostas
                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text(
                            '¿No tienes una cuenta?',
                            style: TextStyle(color: OfixColors.textSecondary),
                          ),
                          TextButton(
                            onPressed: () => _abrirRegistro(context),
                            child: const Text('Regístrate'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}