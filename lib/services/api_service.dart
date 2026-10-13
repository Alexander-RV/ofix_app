import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080';

  // Login
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(
        'token',
        data['token'],
      );

      await prefs.setString(
        'rol',
        data['rol'],
      );
    }

    return {
      'statusCode': response.statusCode,
      'data': data,
    };
  }

  // Recuperar JWT guardado
  static Future<String?> obtenerToken() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('token');
  }

  // Obtener servicios del backend
  static Future<Map<String, dynamic>> listarServicios() async {
    final token = await obtenerToken();

    final response = await http.get(
      Uri.parse('$baseUrl/api/servicios'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return {
      'statusCode': response.statusCode,
      'data': jsonDecode(response.body),
    };
  }

  // Obtener servicios disponibles para trabajadores
  static Future<Map<String, dynamic>> listarServiciosDisponibles() async {
    final token = await obtenerToken();

    final response = await http.get(
      Uri.parse('$baseUrl/api/servicios/disponibles'),
      headers: {
        'content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  

    return {
      'statusCode': response.statusCode,
      'data': jsonDecode(response.body),
    };
  }

  // Obtener servicios asignados al trabajador
  static Future<Map<String, dynamic>> listarMisServicios() async {
    final token = await obtenerToken();

    final response = await http.get(
      Uri.parse('$baseUrl/api/servicios/mis-servicios'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return {
      'statusCode': response.statusCode,
      'data': jsonDecode(response.body),
    };
  }

  // Aceptar servicio
  static Future<Map<String, dynamic>> aceptarServicio(
    int servicioId,
  ) async {
    final token = await obtenerToken();

    final response = await http.put(
      Uri.parse('$baseUrl/api/servicios/$servicioId/aceptar'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final body = response.body.trim();

    final data = body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(body);

    return {
      'statusCode': response.statusCode,
      'data': data,
    };
  }

  // Finalizar servicio
  static Future<Map<String, dynamic>> finalizarServicio(
    int servicioId,
  ) async {
    final token = await obtenerToken();

    final response = await http.put(
      Uri.parse('$baseUrl/api/servicios/$servicioId/finalizar'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final body = response.body.trim();

    final data = body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(body);

    return {
      'statusCode': response.statusCode,
      'data': data,
    };
  }

  // Cancelar servicio
  static Future<Map<String, dynamic>> cancelarServicio(
    int servicioId,
  ) async {
    final token = await obtenerToken();

    final response = await http.put(
      Uri.parse('$baseUrl/api/servicios/$servicioId/cancelar'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final body = response.body.trim();

    final data = body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(body);

    return {
      'statusCode': response.statusCode,
      'data': data,
    };
  }


  // Crear servicio
  static Future<Map<String, dynamic>> crearServicio(
    String titulo,
    String descripcion,
    String direccion,
    int categoriaId,
  ) async {
    final token = await obtenerToken();

    final response = await http.post(
      Uri.parse('$baseUrl/api/servicios'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'titulo': titulo,
        'descripcion': descripcion,
        'direccion': direccion,
        'categoriaId': categoriaId,
      }),
    );

    final body = response.body.trim();

    final data = body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(body);

    return {
      'statusCode': response.statusCode,
      'data': data,
    };
  }

  // Obtener perfil del usuario autenticado
  static Future<Map<String, dynamic>> obtenerMiPerfil() async {
    final token = await obtenerToken();

    final response = await http.get(
      Uri.parse('$baseUrl/api/usuarios/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final body = response.body.trim();

    final data = body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(body);

    return {
      'statusCode': response.statusCode,
      'data': data,
    };
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('token');
    await prefs.remove('rol');
  }

  // Actualizar perfil
  static Future<Map<String, dynamic>> actualizarMiPerfil(
    String nombre,
    String apellido,
    String email,
  ) async {
    final token = await obtenerToken();

    final response = await http.put(
      Uri.parse('$baseUrl/api/usuarios/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'nombre': nombre,
        'apellido': apellido,
        'email': email,
      }),
    );

    final body = response.body.trim();

    final data = body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(body);

    return {
      'statusCode': response.statusCode,
      'data': data,
    };
  }

  // Cambiar contraseña
  static Future<Map<String, dynamic>> cambiarPassword(
    String passwordActual,
    String nuevaPassword,
    String confirmarPassword,
  ) async {
    final token = await obtenerToken();

    final response = await http.put(
      Uri.parse('$baseUrl/api/usuarios/me/password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'passwordActual': passwordActual,
        'nuevaPassword': nuevaPassword,
        'confirmarPassword': confirmarPassword,
      }),
    );

    final body = response.body.trim();

    final data = body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(body);

    return {
      'statusCode': response.statusCode,
      'data': data,
    };
  }

  static Future<Map<String, dynamic>> solicitarRecuperacion(
    String email,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/forgot-password'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
      }),
    );

    final body = response.body.trim();

    final data = body.isEmpty
        ? <String, dynamic>{}
        : body;

    return {
      'statusCode': response.statusCode,
      'data': data,
    };
  }

  static Future<Map<String, dynamic>> restablecerPassword(
    String token,
    String nuevaPassword,
    String confirmarPassword,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/reset-password'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'token': token,
        'nuevaPassword': nuevaPassword,
        'confirmarPassword': confirmarPassword,
      }),
    );

    final body = response.body.trim();

    final data = body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(body);

    return {
      'statusCode': response.statusCode,
      'data': data,
    };
  }

  // Registro público: cliente o profesional.
  static Future<Map<String, dynamic>> registrarUsuario({
    required String nombre,
    required String apellido,
    required String email,
    required String password,
    required String rol, // 'CLIENTE' o 'TRABAJADOR'
    String? profesion,
    int? anosExperiencia,
    String? descripcionProfesional,
    String? zonaTrabajo,
    List<int>? categoriaIds,
  }) async {
    final body = <String, dynamic>{
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'password': password,
      'rol': rol,
    };

    if (rol == 'TRABAJADOR') {
      body['profesion'] = profesion;
      body['anosExperiencia'] = anosExperiencia;
      body['descripcionProfesional'] = descripcionProfesional;
      body['zonaTrabajo'] = zonaTrabajo;
      body['categoriaIds'] = categoriaIds;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/usuarios'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    return {
      'statusCode': response.statusCode,
      'data': jsonDecode(response.body),
    };
  }

  // Categorías activas para el formulario de registro (endpoint público).
  static Future<List<Map<String, dynamic>>> listarCategoriasPublicas() async {
    final response = await http.get(Uri.parse('$baseUrl/api/categorias'));

    if (response.statusCode != 200) {
      throw Exception('No se pudieron cargar las categorías');
    }

    final lista = jsonDecode(response.body) as List<dynamic>;
    return lista
        .cast<Map<String, dynamic>>()
        .where((c) => c['activo'] == true)
        .toList();
  }
}