import 'package:aplicativo_capachica/features/emprendedores/domain/entities/emprendedor.dart';
import 'package:aplicativo_capachica/features/servicio/data/models/servicio_model.dart';
import 'package:aplicativo_capachica/features/servicio/domain/entities/servicio.dart';
import 'package:aplicativo_capachica/features/servicio/domain/repositories/servicio_repository.dart';
import 'package:aplicativo_capachica/features/servicio/presentation/widgets/map_card_widget.dart';
import 'package:aplicativo_capachica/features/servicio/presentation/widgets/servicios_relacionados_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../carrito/presentation/widgets/carrito_icon_with_badge.dart';
import '../../../carrito/presentation/cubit/carrito_cubit.dart';
import '../../../carrito/presentation/cubit/carrito_event.dart';
import '../../../carrito/domain/entities/carrito_item.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ServiceDetailScreen extends StatefulWidget {
  final ServiceEntity servicio;
  const ServiceDetailScreen({Key? key, required this.servicio}) : super(key: key);

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  static const List<String> _assetImages = [
    'assets/lugar-turistico1.jpg',
    'assets/lugar-turistico2.jpg',
    'assets/lugar-turistico3.jpg',
    'assets/lugar-turistico4.jpg',
    'assets/lugar-turistico5.jpg',
    'assets/lugar-turistico6.jpg',
    'assets/lugar-turistico-line1-1.jpg',
    'assets/lugar-turistico-line1-2.jpg',
    'assets/lugar-turistico-line2-1.jpg',
    'assets/lugar-turistico-line2-2.jpg',
    'assets/lugar-turistico-line3-1.jpg',
    'assets/lugar-turistico-line3-2.jpg',
    'assets/lugar-turistico-line4-1.jpg',
    'assets/lugar-turistico-line4-2.jpg',
    'assets/lugar-turistico-line5-1.jpg',
    'assets/lugar-turistico-line5-2.jpg',
  ];

  DateTime? _fechaConsulta;
  TimeOfDay? _horaInicio;
  TimeOfDay? _horaFin;
  bool _verificandoDisponibilidad = false;
  bool? _resultadoDisponibilidad; // null: no verificado, true: disponible, false: no disponible

  // 💡 Necesitarás el ServiceRepository (si no lo tienes ya inyectado)
  late final ServiceRepository _turismoService;

  @override
  void initState() {
    super.initState();
    // 💡 Inicializa el repositorio leyendo el contexto
    _turismoService = context.read<ServiceRepository>();
  }

  String _getAssetImage(int index) {
    return _assetImages[index % _assetImages.length];
  }

  String capitalizeFirst(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  void _showSnackBar(BuildContext context, String message, {Color? backgroundColor, Color? textColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: textColor ?? Colors.white)),
        backgroundColor: backgroundColor ?? Colors.blueGrey,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _verificarDisponibilidad() async {
    if (_fechaConsulta == null || _horaInicio == null || _horaFin == null) {
      // Mostrar SnackBar o feedback de campos incompletos
      _showSnackBar(context, 'Complete todos los campos de fecha y hora.', backgroundColor: Colors.amber[800]);
      return;
    }

    setState(() {
      _verificandoDisponibilidad = true;
      _resultadoDisponibilidad = null;
    });

    try {
      final fecha = DateFormat('yyyy-MM-dd').format(_fechaConsulta!);
      final horaInicio = _horaInicio!.format(context); // Esto puede requerir formato 24h
      final horaFin = _horaFin!.format(context);

      // Conversión a formato HH:mm:ss (necesario si tu API lo pide)
      final String horaInicioFormatted = '${_horaInicio!.hour.toString().padLeft(2, '0')}:${_horaInicio!.minute.toString().padLeft(2, '0')}:00';
      final String horaFinFormatted = '${_horaFin!.hour.toString().padLeft(2, '0')}:${_horaFin!.minute.toString().padLeft(2, '0')}:00';

      final resultado = await _turismoService.verificarDisponibilidadServicio(
        widget.servicio.id,
        fecha,
        horaInicioFormatted,
        horaFinFormatted,
      );

      setState(() {
        // Asumiendo que verificarDisponibilidadServicio devuelve un bool
        _resultadoDisponibilidad = resultado;
      });
    } catch (error) {
      print('Error al verificar disponibilidad: $error');
      _showSnackBar(context, 'Error al verificar disponibilidad.', backgroundColor: Colors.red);
      setState(() {
        _resultadoDisponibilidad = false;
      });
    } finally {
      setState(() {
        _verificandoDisponibilidad = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final categoria = widget.servicio.categorias.isNotEmpty ? widget.servicio.categorias[0].nombre : 'Servicio';
    final dias = widget.servicio.horarios.map((h) => capitalizeFirst(h.diaSemana)).toSet().toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1419) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(), // Usamos Navigator para volver
        ),
        title: const Text(
          'Detalle del Servicio',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [Colors.amber.shade700, Colors.amber.shade800]
                  : [Colors.amber.shade600, Colors.amber.shade800],
            ),
          ),
        ),
        actions: [
          const CarritoIconWithBadge(),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen principal optimizada
            _buildMainImage(context, isDark),

            // Contenido principal
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Título y precio
                  _buildTitleAndPriceCard(isDark, categoria),

                  const SizedBox(height: 16),

                  // Descripción
                  _buildDescriptionCard(isDark),

                  const SizedBox(height: 16),

                  // Información del servicio
                  _buildServiceInfoCard(isDark),

                  const SizedBox(height: 16),

                  // Emprendedor
                  _buildEmprendedorCard(isDark),

                  const SizedBox(height: 16),

                  _buildActionButtons(context, isDark),

                  const SizedBox(height: 16),

                  // Horarios de disponibilidad
                  if (widget.servicio.horarios.isNotEmpty) ...[
                    _buildSchedulesCard(isDark, dias),
                    const SizedBox(height: 16),
                  ],

                  MapCardWidget(servicio: widget.servicio),

                  const SizedBox(height: 16),

                  ServiciosRelacionadosWidget(servicioActual: widget.servicio),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainImage(BuildContext context, bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 240,
        width: double.infinity,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            Image.asset(
              _getAssetImage(widget.servicio.id.hashCode),
              height: 240,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Container(
              height: 240,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.1),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleAndPriceCard(bool isDark, String categoria) {
    return Card(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      elevation: 2,
      shadowColor: isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.servicio.nombre,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1A202C),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber[800],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'S/. ${widget.servicio.precioReferencial}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber[800],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    categoria,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.servicio.estado ? Colors.green[100] : Colors.red[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.servicio.estado ? 'Disponible' : 'No disponible',
                    style: TextStyle(
                      color: widget.servicio.estado ? Colors.green[900] : Colors.red[900],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard(bool isDark) {
    return Card(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      elevation: 2,
      shadowColor: isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Descripción',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1A202C),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.servicio.descripcion,
              style: TextStyle(
                color: isDark ? Colors.white70 : const Color(0xFF718096),
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceInfoCard(bool isDark) {
    return Card(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      elevation: 2,
      shadowColor: isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información del Servicio',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1A202C),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _infoRow(
              Icons.people,
              'Capacidad',
              '${widget.servicio.capacidad} personas',
              isDark,
            ),
            const SizedBox(height: 8),
            _infoRow(
              Icons.location_on,
              'Ubicación',
              widget.servicio.ubicacionReferencia,
              isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmprendedorCard(bool isDark) {
    final Color primaryColor = Colors.amber[800]!;
    final Color titleColor = isDark ? Colors.white : const Color(0xFF1A202C);
    final Color textColor = isDark ? Colors.white70 : const Color(0xFF718096);
    final EmprendedorEntity emprendedor = widget.servicio.emprendedor;

    return Card(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      elevation: 4,
      shadowColor: isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          expansionTileTheme: ExpansionTileThemeData(
            iconColor: primaryColor,
            collapsedIconColor: isDark ? Colors.white70 : Colors.grey.shade700,
          ),
        ),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),

          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Emprendedor',
                style: TextStyle(
                  color: titleColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.storefront,
                      color: primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          emprendedor.nombre,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: titleColor,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          emprendedor.tipoServicio!,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white70 : const Color(0xFF718096),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(height: 1, thickness: 0.5), // Separador visual
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (emprendedor.telefono!.isNotEmpty)
                    _buildDetailRow(
                      isDark,
                      Icons.phone,
                      emprendedor.telefono!,
                      textColor,
                    ),

                  if (emprendedor.email!.isNotEmpty)
                    _buildDetailRow(
                      isDark,
                      Icons.email,
                      emprendedor.email!,
                      textColor,
                    ),

                  if (emprendedor.ubicacion!.isNotEmpty)
                    _buildDetailRow(
                      isDark,
                      Icons.location_on,
                      emprendedor.ubicacion!,
                      textColor,
                    ),

                  if (emprendedor.precioRango!.isNotEmpty)
                    _buildDetailRow(
                      isDark,
                      Icons.attach_money,
                      emprendedor.precioRango!,
                      textColor,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      bool isDark,
      IconData icon,
      String text,
      Color textColor,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchedulesCard(bool isDark, List<String> dias) {
    final Color primaryColor = Colors.amber[800]!;
    final Color titleColor = isDark ? Colors.white : const Color(0xFF1A202C);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      elevation: 4,
      shadowColor: isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Horarios de Disponibilidad',
                style: TextStyle(
                  color: titleColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final int crossAxisCount = constraints.maxWidth < 200 ? 1 : 2;

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),

                    itemCount: widget.servicio.horarios.length,

                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 8.0,
                      crossAxisSpacing: 8.0,
                      mainAxisExtent: crossAxisCount == 1 ? 50 : 60,
                      //childAspectRatio: crossAxisCount == 1 ? 4.5 : 2.5,
                    ),

                    itemBuilder: (context, index) {
                      final h = widget.servicio.horarios[index];

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.calendar_today, color: Colors.green, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  capitalizeFirst(h.diaSemana),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green[900],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${h.horaInicio} - ${h.horaFin}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 16),
              const Divider(height: 1, thickness: 0.5),
              const SizedBox(height: 8),

              Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                  expansionTileTheme: ExpansionTileThemeData(
                    iconColor: primaryColor,
                    collapsedIconColor: isDark ? Colors.white70 : Colors.grey.shade700,
                  ),
                ),
                child: ExpansionTile(
                  initiallyExpanded: true,
                  tilePadding: EdgeInsets.zero,
                  title: Row(
                    children: [
                      Icon(Icons.calendar_month, color: primaryColor, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Verificar Disponibilidad',
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: _buildAvailabilityChecker(isDark),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvailabilityChecker(bool isDark) {
    final Color accentColor = Colors.amber[800]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        _buildDatePicker(isDark, accentColor),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildTimePicker(isDark, accentColor, 'Hora de inicio', _horaInicio, (TimeOfDay? newTime) {
              setState(() => _horaInicio = newTime);
            })),
            const SizedBox(width: 12),
            Expanded(child: _buildTimePicker(isDark, accentColor, 'Hora de fin', _horaFin, (TimeOfDay? newTime) {
              setState(() => _horaFin = newTime);
            })),
          ],
        ),
        const SizedBox(height: 20),

        ElevatedButton(
          onPressed: (_fechaConsulta != null && _horaInicio != null && _horaFin != null && !_verificandoDisponibilidad)
              ? _verificarDisponibilidad
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: accentColor,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            minimumSize: const Size(double.infinity, 48), // W-full
          ),
          child: _verificandoDisponibilidad
              ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              const SizedBox(width: 10),
              const Text('Verificando...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          )
              : const Text('Verificar Disponibilidad', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ),

        if (_resultadoDisponibilidad != null)
          _buildAvailabilityResult(isDark, _resultadoDisponibilidad!),
      ],
    );
  }

  Widget _buildDatePicker(bool isDark, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Fecha', style: TextStyle(fontSize: 14, color: isDark ? Colors.grey.shade300 : Colors.grey.shade700, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: _fechaConsulta ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(DateTime.now().year + 1),
            );
            if (picked != null) {
              setState(() => _fechaConsulta = picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: isDark ? Colors.grey.shade700.withOpacity(0.3) : Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _fechaConsulta == null ? 'Seleccionar fecha' : DateFormat('dd/MM/yyyy').format(_fechaConsulta!),
                  style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                ),
                Icon(Icons.date_range, color: accentColor),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker(bool isDark, Color accentColor, String label, TimeOfDay? selectedTime, Function(TimeOfDay?) onTimeSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: isDark ? Colors.grey.shade300 : Colors.grey.shade700, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: selectedTime ?? TimeOfDay.now(),
            );
            onTimeSelected(picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: isDark ? Colors.grey.shade700.withOpacity(0.3) : Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedTime == null ? 'HH:MM' : selectedTime.format(context),
                  style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                ),
                Icon(Icons.access_time, color: accentColor),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvailabilityResult(bool isDark, bool isAvailable) {
    final Color bgColor = isAvailable ? Colors.green.shade100 : Colors.red.shade100;
    final Color darkBgColor = isAvailable ? Colors.green.shade900.withOpacity(0.2) : Colors.red.shade900.withOpacity(0.2);
    final Color textColor = isAvailable ? Colors.green.shade800 : Colors.red.shade800;
    final Color iconColor = isAvailable ? Colors.green.shade600 : Colors.red.shade600;

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? darkBgColor : bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? iconColor.withOpacity(0.5) : iconColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(isAvailable ? Icons.check_circle : Icons.error, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                isAvailable ? '¡Servicio disponible!' : 'Servicio no disponible',
                style: TextStyle(color: isDark ? Colors.white : textColor, fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isAvailable
                ? 'Puedes agregar este servicio a tu carrito para la fecha y horario seleccionados.'
                : 'El servicio no está disponible en la fecha y horario seleccionados. Intenta con otro horario.',
            style: TextStyle(color: isDark ? Colors.white70 : Colors.grey.shade700, fontSize: 13),
          ),
        ],
      ),
    );
  }


  Widget _buildActionButtons(BuildContext context, bool isDark) {
    return Card(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      elevation: 2,
      shadowColor: isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white, size: 18),
                    label: const Text('WhatsApp', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    onPressed: () async {
                      final telefono = widget.servicio.emprendedor.telefono;

                      if (telefono?.isNotEmpty == true) {
                        final whatsappUri = Uri.parse('whatsapp://send?phone=+51$telefono');
                        final webUrl = Uri.parse('https://wa.me/+51$telefono');

                        bool launched = false;

                        // Intentar abrir con el URI de la app
                        if (await launchUrl(whatsappUri, mode: LaunchMode.externalApplication)) {
                          launched = true;
                        }
                        // Si la URI de la app falla, intentar con la URL web (que abre el navegador o la app si el SO lo permite)
                        else if (await launchUrl(webUrl, mode: LaunchMode.platformDefault)) {
                          launched = true;
                        }

                        if (!launched) {
                          _showSnackBar(context, 'No se pudo abrir WhatsApp. Verifica si la aplicación está instalada.',
                              backgroundColor: Colors.red, textColor: Colors.white);
                        }
                      } else {
                        _showSnackBar(context, 'El emprendedor no tiene número de WhatsApp disponible',
                            backgroundColor: Colors.orange, textColor: Colors.white);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF3B82F6) : const Color(0xFFFF6B35),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.shopping_cart, color: Colors.white, size: 18),
                    label: const Text('Agregar al carrito', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      if (_fechaConsulta == null || _horaInicio == null || _horaFin == null) {
                        _showSnackBar(context, 'Seleccione fecha y horas antes de agregar.', backgroundColor: Colors.orange);
                        return;
                      }
                      final item = CarritoItem(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        servicio: widget.servicio,
                        fechaSeleccionada: _fechaConsulta!,
                        horaInicio: '${_horaInicio!.hour.toString().padLeft(2, '0')}:${_horaInicio!.minute.toString().padLeft(2, '0')}:00',
                        horaFin: '${_horaFin!.hour.toString().padLeft(2, '0')}:${_horaFin!.minute.toString().padLeft(2, '0')}:00',
                        cantidad: 1,
                        notas: '',
                        fechaAgregado: DateTime.now(),
                      );
                    },
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          color: isDark ? const Color(0xFF3B82F6) : Colors.lightBlue,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF374151),
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF718096),
              fontSize: 14,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _handleReservar(BuildContext context, bool isLoggedIn) async {
    final box = GetStorage();
    final currentRoute = '/services-capachica/detail/${widget.servicio.id}';

    if (!isLoggedIn) {
      // Guardar ruta pendiente y mostrar diálogo de login
      box.write('pending_route', currentRoute);
      /*Get.dialog(AuthRedirectDialog(
        onLoginPressed: () {
          Get.toNamed('/login');
        },
        onRegisterPressed: () {
          Get.toNamed('/register');
        },
      ));*/
      return;
    }

    // Mostrar el nuevo formulario de reserva moderno
    /*showDialog(
      context: context,
      builder: (context) => ReservationFormDialog(
        servicio: widget.servicio,
        onReservationAdded: () {
          // Callback cuando se agrega una reserva
          setState(() {});
        },
      ),
    );*/
  }
}

