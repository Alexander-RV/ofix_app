import 'package:flutter/material.dart';
import '../main.dart' show OfixWelcomePage;
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../widgets/ofix_widgets.dart';
import '../widgets/servicio_utils.dart';
import '../widgets/soporte_card.dart';
import 'coming_soon_page.dart';
import 'create_service_page.dart';
import 'my_client_services_page.dart';
import 'profile_page.dart';

class ClientHomePage extends StatefulWidget {
  const ClientHomePage({super.key});

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  late Future<List<dynamic>> serviciosFuture;
  String nombreUsuario = '';

  // Texto del buscador (por ahora solo visual)
  final TextEditingController buscarController = TextEditingController();

  @override
  void initState() {
    super.initState();
    serviciosFuture = cargarServicios();
    cargarNombre();
  }

  @override
  void dispose() {
    buscarController.dispose();
    super.dispose();
  }

  // Trae los servicios del cliente, del más reciente al más antiguo
  Future<List<dynamic>> cargarServicios() async {
    final resultado = await ApiService.listarServicios();

    if (resultado['statusCode'] != 200) {
      throw Exception('No se pudieron cargar los servicios');
    }

    final lista = List<dynamic>.from(resultado['data']);

    lista.sort(
      (a, b) => ((b['id'] ?? 0) as num).compareTo((a['id'] ?? 0) as num),
    );

    return lista;
  }

  Future<void> cargarNombre() async {
    final resultado = await ApiService.obtenerMiPerfil();

    if (!mounted) {
      return;
    }

    if (resultado['statusCode'] == 200) {
      setState(() {
        nombreUsuario = resultado['data']['nombre'] ?? '';
      });
    }
  }

  void _recargar() {
    setState(() {
      serviciosFuture = cargarServicios();
    });
  }

  // ---- Navegación (al volver se refrescan los datos) ----

  Future<void> _abrirNuevaSolicitud() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateServicePage()),
    );

    if (!mounted) {
      return;
    }

    _recargar();
  }

  Future<void> _abrirMisSolicitudes() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MyClientServicesPage()),
    );

    if (!mounted) {
      return;
    }

    _recargar();
  }

  Future<void> _abrirPerfil() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfilePage()),
    );

    if (!mounted) {
      return;
    }

    // Por si cambió su nombre al editar el perfil
    cargarNombre();
  }

  // Abre la pantalla "Muy pronto" de una función aún no disponible
  void _proximamente(String titulo, IconData icono, String descripcion) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ComingSoonPage(
          titulo: titulo,
          icono: icono,
          descripcion: descripcion,
        ),
      ),
    );
  }

  void _abrirNotificaciones() {
    _proximamente(
      'Notificaciones',
      Icons.notifications_none,
      'Te avisaremos cuando recibas una oferta o cambie el estado '
          'de tus solicitudes.',
    );
  }

  // Por ahora el buscador es solo visual
  void _buscar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'La búsqueda llegará pronto. Mientras tanto, '
          'pulsa "Nueva solicitud".',
        ),
      ),
    );
  }

  Future<void> _cerrarSesion() async {
    await ApiService.logout();

    if (!mounted) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const OfixWelcomePage()),
      (route) => false,
    );
  }

  // Botón flotante: crear una nueva solicitud
  Widget _botonNuevaSolicitud() {
    return FloatingActionButton.extended(
      onPressed: _abrirNuevaSolicitud,
      backgroundColor: OfixColors.primary,
      foregroundColor: OfixColors.white,
      icon: const Icon(Icons.add),
      label: const Text('Nueva solicitud'),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 900 px o más (PC): barra lateral. Menos (celular): menú + barra inferior.
    final esAncho = MediaQuery.sizeOf(context).width >= 900;

    if (esAncho) {
      return Scaffold(
        floatingActionButton: _botonNuevaSolicitud(),
        body: Row(
          children: [
            _menuLateral(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(32, 24, 32, 100),
                child: OfixMaxWidth(
                  maxWidth: 860,
                  child: Column(
                    children: [
                      // Campana y avatar arriba a la derecha (como el mockup)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: _abrirNotificaciones,
                            icon: const Icon(Icons.notifications_none),
                          ),
                          const SizedBox(width: 8),
                          _avatar(),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _contenido(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      // En celular el menú completo está en el cajón lateral (hamburguesa)
      drawer: Drawer(width: 250, child: _menuLateral(enDrawer: true)),
      appBar: AppBar(
        title: const OfixLogo(size: 24),
        actions: [
          IconButton(
            onPressed: _abrirNotificaciones,
            icon: const Icon(Icons.notifications_none),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4, right: 16),
            child: _avatar(),
          ),
        ],
      ),
      floatingActionButton: _botonNuevaSolicitud(),
      body: RefreshIndicator(
        onRefresh: () async {
          _recargar();
          await serviciosFuture;
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          // Espacio abajo para que el botón flotante no tape la última tarjeta
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          child: _contenido(),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Mis solicitudes',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        onDestinationSelected: (index) {
          if (index == 1) {
            _abrirMisSolicitudes();
          }

          if (index == 2) {
            _abrirPerfil();
          }
        },
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Contenido principal (igual en celular y PC)
  // ---------------------------------------------------------------------

  Widget _contenido() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            nombreUsuario.isEmpty ? 'Hola 👋' : 'Hola, $nombreUsuario 👋',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        const SizedBox(height: 4),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '¿Qué servicio necesitas hoy?',
            style: TextStyle(fontSize: 15, color: OfixColors.textSecondary),
          ),
        ),
        const SizedBox(height: 20),

        _buscador(),

        const SizedBox(height: 20),

        FutureBuilder<List<dynamic>>(
          future: serviciosFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(30),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
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

            final servicios = snapshot.data ?? [];

            // Cuenta cuántos servicios hay en cada estado
            int contar(String estado) =>
                servicios.where((s) => s['estado'] == estado).length;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Resumen: calculado con los datos reales del cliente
                Row(
                  children: [
                    Expanded(
                      child: OfixStatTile(
                        valor: '${contar('EN_PROCESO')}',
                        etiqueta: 'En progreso',
                        color: OfixColors.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OfixStatTile(
                        valor: '${contar('PENDIENTE')}',
                        etiqueta: 'Pendientes',
                        color: OfixColors.warning,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OfixStatTile(
                        valor: '${contar('COMPLETADO')}',
                        etiqueta: 'Completados',
                        color: OfixColors.success,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                OfixSectionHeader(
                  titulo: 'Mis solicitudes',
                  accion: servicios.isEmpty ? null : 'Ver todas',
                  onAccion: _abrirMisSolicitudes,
                ),

                const SizedBox(height: 8),

                if (servicios.isEmpty)
                  const OfixCard(
                    child: OfixEmptyState(
                      icono: Icons.assignment_outlined,
                      mensaje: 'Todavía no tienes solicitudes.\n'
                          'Pulsa "Nueva solicitud" para pedir tu primer '
                          'servicio.',
                    ),
                  )
                else
                  // Solo las 3 más recientes; el resto en "Ver todas"
                  ...servicios.take(3).map(_tarjetaSolicitud),
              ],
            );
          },
        ),

        const SizedBox(height: 24),

        // Tarjeta de ayuda con el correo de soporte
        const SoporteCard(),
      ],
    );
  }

  // Buscador visual (la búsqueda real se conecta más adelante)
  Widget _buscador() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 6, 6, 6),
      decoration: BoxDecoration(
        color: OfixColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: OfixColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: buscarController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _buscar(),
              decoration: const InputDecoration(
                hintText: 'Busca un servicio…',
                filled: false,
                isDense: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: OfixColors.primary,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: _buscar,
              borderRadius: BorderRadius.circular(12),
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(Icons.search, color: OfixColors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tarjeta compacta de una solicitud (icono, título, detalle y estado)
  Widget _tarjetaSolicitud(dynamic servicio) {
    final categoria = (servicio['categoriaNombre'] ?? '').toString();
    final (color, fondo) = colorCategoria(categoria);

    // Si tiene fecha programada la muestra; si no, la dirección
    final detalle = formatearFechaServicio(servicio['fechaProgramada']) ??
        (servicio['direccion'] ?? '').toString();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: OfixCard(
        onTap: _abrirMisSolicitudes,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: fondo,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(iconoCategoria(categoria), color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (servicio['titulo'] ?? '').toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    categoria,
                    style: const TextStyle(
                      fontSize: 13,
                      color: OfixColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    detalle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: OfixColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            EstadoChip((servicio['estado'] ?? '').toString()),
            const Icon(Icons.chevron_right, color: OfixColors.textSecondary),
          ],
        ),
      ),
    );
  }

  // Círculo con la inicial del nombre (abre el perfil)
  Widget _avatar() {
    final inicial =
        nombreUsuario.isEmpty ? '?' : nombreUsuario[0].toUpperCase();

    return InkWell(
      onTap: _abrirPerfil,
      customBorder: const CircleBorder(),
      child: CircleAvatar(
        radius: 18,
        backgroundColor: OfixColors.primarySoft,
        child: Text(
          inicial,
          style: const TextStyle(
            color: OfixColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Menú lateral: barra fija en PC y cajón (drawer) en celular
  // ---------------------------------------------------------------------

  Widget _menuLateral({bool enDrawer = false}) {
    // En el cajón, primero se cierra y luego se ejecuta la acción
    VoidCallback accion(VoidCallback f) {
      return () {
        if (enDrawer) {
          Navigator.pop(context);
        }
        f();
      };
    }

    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: OfixColors.white,
        border: Border(right: BorderSide(color: OfixColors.border)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: OfixLogo(size: 28),
              ),
              const SizedBox(height: 24),

              // Scroll por si la pantalla es baja y no caben todas las opciones
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _itemMenu(
                        Icons.home_outlined,
                        'Inicio',
                        activo: true,
                        onTap: accion(() {}),
                      ),
                      _itemMenu(
                        Icons.receipt_long_outlined,
                        'Mis solicitudes',
                        onTap: accion(_abrirMisSolicitudes),
                      ),
                      _itemMenu(
                        Icons.chat_bubble_outline,
                        'Mensajes',
                        onTap: accion(
                          () => _proximamente(
                            'Mensajes',
                            Icons.chat_bubble_outline,
                            'Aquí podrás chatear con los profesionales que '
                                'te enviaron ofertas.',
                          ),
                        ),
                      ),
                      _itemMenu(
                        Icons.favorite_border,
                        'Favoritos',
                        onTap: accion(
                          () => _proximamente(
                            'Favoritos',
                            Icons.favorite_border,
                            'Guarda a los profesionales que más te gustaron '
                                'para contratarlos de nuevo.',
                          ),
                        ),
                      ),
                      _itemMenu(
                        Icons.place_outlined,
                        'Mis direcciones',
                        onTap: accion(
                          () => _proximamente(
                            'Mis direcciones',
                            Icons.place_outlined,
                            'Guarda las direcciones de tu casa u oficina '
                                'para solicitar servicios más rápido.',
                          ),
                        ),
                      ),
                      _itemMenu(
                        Icons.person_outline,
                        'Mi perfil',
                        onTap: accion(_abrirPerfil),
                      ),
                      _itemMenu(
                        Icons.settings_outlined,
                        'Configuración',
                        onTap: accion(
                          () => _proximamente(
                            'Configuración',
                            Icons.settings_outlined,
                            'Administra tus notificaciones, tu privacidad y '
                                'las preferencias de tu cuenta.',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(),
              const SizedBox(height: 4),
              _itemMenu(
                Icons.logout,
                'Cerrar sesión',
                onTap: accion(_cerrarSesion),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _itemMenu(
    IconData icono,
    String texto, {
    bool activo = false,
    VoidCallback? onTap,
  }) {
    final color = activo ? OfixColors.primary : OfixColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: activo ? OfixColors.primarySoft : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(icono, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    texto,
                    style: TextStyle(
                      color: color,
                      fontWeight: activo ? FontWeight.w700 : FontWeight.w500,
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