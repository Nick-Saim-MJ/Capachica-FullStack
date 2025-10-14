import 'package:aplicativo_capachica/core/widgets/role_visibility.dart';
import 'package:aplicativo_capachica/features/emprendedores/presentation/pages/EmprendedorDetallePage.dart';
import 'package:aplicativo_capachica/features/emprendedores/presentation/pages/EmprendedorFormEditPage.dart';
import 'package:aplicativo_capachica/features/emprendedores/presentation/pages/emprendedor_form_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/emprendedor.dart';
import '../bloc/emprendedor_bloc.dart';
import '../bloc/emprendedor_event.dart';


class EmprendedorCard extends StatelessWidget {
  final EmprendedorEntity emprendedor;
  final VoidCallback onUpdated;

  const EmprendedorCard({super.key, required this.emprendedor, required this.onUpdated,});

  /// 👉 Función para abrir WhatsApp
  Future<void> _abrirWhatsApp(BuildContext context, String phone) async {
    String numero = phone.replaceAll(RegExp(r'[^0-9]'), '');
    numero = numero.replaceFirst(RegExp(r'^0+'), '');

    if (numero.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Número inválido')),
      );
      return;
    }

    if (numero.length < 7) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Número demasiado corto')),
      );
      return;
    }

    if (!numero.startsWith('51')) {
      numero = '51$numero';
    }

    final Uri whatsappUri = Uri.parse("https://wa.me/$numero");

    try {
      final bool launched = await launchUrl(
        whatsappUri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No se pudo abrir WhatsApp")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }
  void _mostrarDetalles(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            emprendedor.nombre,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  emprendedor.descripcion ?? "Sin descripción disponible",
                ),
                const SizedBox(height: 8),
                if (emprendedor.ubicacion != null)
                  Text("📍 ${emprendedor.ubicacion!}"),
                if (emprendedor.asociacionId != null)
                  Text("🤝 Asociación: ${emprendedor.asociacionId!}"),
                if (emprendedor.telefono != null) ...[
                  Text("📞 ${emprendedor.telefono!}"),
                  const SizedBox(height: 6),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[800],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      _abrirWhatsApp(context, emprendedor.telefono!);
                    },
                    icon: const Icon(Icons.phone),
                    label: const Text("WhatsApp"),
                  ),
                ],
                if (emprendedor.email != null)
                  Text("✉️ ${emprendedor.email!}"),
                if (emprendedor.capacidadAforo != null)
                  Text(
                      "👥 Capacidad de aforo: ${emprendedor.capacidadAforo} personas"),
                if (emprendedor.precioRango != null)
                  Text("💲 Rango de precios: ${emprendedor.precioRango!}"),
                if (emprendedor.horarioAtencion != null)
                  Text("🕒 Horario de atención: ${emprendedor.horarioAtencion!}"),
                const SizedBox(height: 12),
                if (emprendedor.metodosPago.isNotEmpty) ...[
                  const Text("Métodos de pago:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 6,
                    children: emprendedor.metodosPago
                        .map(
                          (m) => Chip(
                        label: Text(m),
                        avatar: const Icon(Icons.payment,
                            size: 16, color: Colors.blue),
                        backgroundColor: Colors.blue.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: Colors.blue.shade200),
                        ),
                      ),
                    )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cerrar"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade200,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        EmprendedorDetallePage(emprendedor: emprendedor),
                  ),
                );
              },
              child: const Text("Ver más"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 4,
      shadowColor: Colors.amber.shade200,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (emprendedor.imagenes.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Builder(
                builder: (context) {
                  final String firstImage = emprendedor.imagenes.first;
                  final String imagePath = firstImage.startsWith('assets/')
                      ? firstImage
                      : 'assets/emprendedores/$firstImage';

                  return Image.asset(
                    imagePath,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        emprendedor.nombre,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        emprendedor.categoria,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  emprendedor.descripcion ?? "Sin descripción disponible",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),

                const SizedBox(height: 8),

                if (emprendedor.ubicacion != null)
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 16, color: Colors.amber[800]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          emprendedor.ubicacion!,
                          style: const TextStyle(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                if (emprendedor.asociacionId != null)
                  Row(
                    children: [
                      Icon(Icons.groups, size: 16, color: Colors.amber[800]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          emprendedor.asociacionId!.toString(),
                          style: const TextStyle(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 10),

                // ✅ BOTONES CRUD + Ver detalles
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /*
                    RoleVisibility(
                      anyOf: ['admin'],
                      fallback: const SizedBox.shrink(),
                      child: IconButton(
                        icon: const Icon(Icons.add, color: Colors.green),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EmprendedorFormPage(),
                            ),
                          );
                        },
                      ),
                    ),

                     */

                    RoleVisibility(
                      anyOf: ['admin'],
                      fallback: const SizedBox.shrink(),
                      child: IconButton(
                        icon: Icon(Icons.edit, color: Colors.amber[800]),
                        onPressed: () async {
                          final updated = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EmprendedorFormEditPage(emprendedor: emprendedor),
                            ),
                          );

                          if (updated == true) {
                            onUpdated();
                          }
                        },
                      ),
                    ),


                    RoleVisibility(
                      anyOf: ['admin'],
                      fallback: const SizedBox.shrink(),
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirmar eliminación'),
                              content: Text('¿Estás seguro de eliminar "${emprendedor.nombre}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Cancelar'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text('Eliminar'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            try {
                              // Llamada a la API para eliminar
                              await context.read<EmprendedorBloc>().deleteEmprendedor(emprendedor.id);

                              // Recargar lista completa después de eliminar
                              onUpdated();

                              // Opcional: mostrar snackbar de éxito
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('"${emprendedor.nombre}" eliminado correctamente'))
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error al eliminar: $e'))
                              );
                            }
                          }
                        },
                      ),
                    ),



                    ElevatedButton(
                      onPressed: () => _mostrarDetalles(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[800],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Ver detalles"),
                    ),
                  ],

                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
