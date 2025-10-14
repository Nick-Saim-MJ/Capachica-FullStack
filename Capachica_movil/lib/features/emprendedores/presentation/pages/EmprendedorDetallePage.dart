import 'package:flutter/material.dart';
import '../../domain/entities/emprendedor.dart';

class EmprendedorDetallePage extends StatelessWidget {
  final EmprendedorEntity emprendedor;

  const EmprendedorDetallePage({super.key, required this.emprendedor});

  Widget _buildInfoRow(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) Icon(icon, size: 18, color: Colors.blueGrey),
          if (icon != null) const SizedBox(width: 6),
          Expanded(
            child: Text("$label: $value", style: const TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(emprendedor.nombre)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Nombre y categoría
            Text(
              emprendedor.nombre,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              emprendedor.categoria,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const SizedBox(height: 16),

            /// Descripción
            Text(
              emprendedor.descripcion ?? "Sin descripción disponible",
              style: const TextStyle(fontSize: 16),
            ),

            const Divider(height: 32),

            /// 📌 Información básica
            if (emprendedor.tipoServicio != null)
              _buildInfoRow("Tipo de servicio", emprendedor.tipoServicio!),
            if (emprendedor.ubicacion != null)
              _buildInfoRow(
                "Ubicación",
                emprendedor.ubicacion!,
                icon: Icons.location_on,
              ),
            if (emprendedor.telefono != null)
              _buildInfoRow(
                "Teléfono",
                emprendedor.telefono!,
                icon: Icons.phone,
              ),
            if (emprendedor.email != null)
              _buildInfoRow("Email", emprendedor.email!, icon: Icons.email),
            if (emprendedor.paginaWeb != null)
              _buildInfoRow(
                "Página web",
                emprendedor.paginaWeb!,
                icon: Icons.language,
              ),
            if (emprendedor.horarioAtencion != null)
              _buildInfoRow(
                "Horario de atención",
                emprendedor.horarioAtencion!,
                icon: Icons.access_time,
              ),
            if (emprendedor.precioRango != null)
              _buildInfoRow(
                "Rango de precios",
                emprendedor.precioRango!,
                icon: Icons.attach_money,
              ),
            if (emprendedor.capacidadAforo != null)
              _buildInfoRow(
                "Capacidad de aforo",
                "${emprendedor.capacidadAforo}",
                icon: Icons.people,
              ),
            if (emprendedor.numeroPersonasAtiende != null)
              _buildInfoRow(
                "N° de personas que atiende",
                "${emprendedor.numeroPersonasAtiende}",
                icon: Icons.support_agent,
              ),
            if (emprendedor.comentariosResenas != null)
              _buildInfoRow(
                "Comentarios",
                emprendedor.comentariosResenas!,
                icon: Icons.comment,
              ),
            if (emprendedor.asociacionId != null)
              _buildInfoRow(
                "Asociación ID",
                emprendedor.asociacionId!.toString(),
                icon: Icons.groups,
              ),
            _buildInfoRow(
              "Facilidades para discapacidad",
              emprendedor.facilidadesDiscapacidad ? "Sí" : "No",
              icon: Icons.accessible,
            ),
            _buildInfoRow(
              "Estado",
              emprendedor.estado ? "Activo" : "Inactivo",
              icon: Icons.check_circle,
            ),

            const Divider(height: 32),

            /*
            /// 🚀 Servicios disponibles
            if (emprendedor.servicios.isNotEmpty) ...[
              const Text("Servicios disponibles:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: emprendedor.servicios
                    .map((s) => Chip(label: Text(s)))
                    .toList(),
              ),
              const SizedBox(height: 16),
            ],
*/
            /// Métodos de pago
            if (emprendedor.metodosPago.isNotEmpty) ...[
              const Text(
                "Métodos de pago:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Wrap(
                spacing: 6,
                children: emprendedor.metodosPago
                    .map((m) => Chip(label: Text(m)))
                    .toList(),
              ),
              const SizedBox(height: 16),
            ],

            /// Certificaciones
            if (emprendedor.certificaciones.isNotEmpty) ...[
              const Text(
                "Certificaciones:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Wrap(
                spacing: 6,
                children: emprendedor.certificaciones
                    .map((c) => Chip(label: Text(c)))
                    .toList(),
              ),
              const SizedBox(height: 16),
            ],

            /// Idiomas
            if (emprendedor.idiomasHablados.isNotEmpty) ...[
              const Text(
                "Idiomas:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Wrap(
                spacing: 6,
                children: emprendedor.idiomasHablados
                    .map((i) => Chip(label: Text(i)))
                    .toList(),
              ),
              const SizedBox(height: 16),
            ],

            /// Opciones de acceso
            if (emprendedor.opcionesAcceso.isNotEmpty) ...[
              const Text(
                "Opciones de acceso:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Wrap(
                spacing: 6,
                children: emprendedor.opcionesAcceso
                    .map((o) => Chip(label: Text(o)))
                    .toList(),
              ),
              const SizedBox(height: 16),
            ],

            /// Imágenes adicionales
            if (emprendedor.imagenes.length > 1) ...[
              const Text(
                "Más imágenes:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: emprendedor.imagenes.length,
                  itemBuilder: (context, index) {
                    final String firstImage = emprendedor.imagenes[index];
                    final String imagePath = firstImage.startsWith('assets/')
                        ? firstImage
                        : 'assets/emprendedores/$firstImage';

                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          imagePath,
                          width: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
