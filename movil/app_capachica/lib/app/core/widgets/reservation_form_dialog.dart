import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import '../controllers/cart_controller.dart';
import '../controllers/theme_controller.dart';
import '../../services/reserva_service.dart';
import '../../data/models/services_capachica_model.dart';

class ReservationFormDialog extends StatefulWidget {
  final ServicioCapachica servicio;
  final VoidCallback onReservationAdded;

  const ReservationFormDialog({
    Key? key,
    required this.servicio,
    required this.onReservationAdded,
  }) : super(key: key);

  @override
  State<ReservationFormDialog> createState() => _ReservationFormDialogState();
}

class _ReservationFormDialogState extends State<ReservationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final TextEditingController _horaInicioController = TextEditingController(text: '09:00');
  final TextEditingController _horaFinController = TextEditingController(text: '10:00');
  final TextEditingController _cantidadController = TextEditingController(text: '1');
  final TextEditingController _duracionController = TextEditingController(text: '60');
  final TextEditingController _notasController = TextEditingController();
  
  // Calendar variables
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  bool _showCalendar = false;
  bool _showTimeSelection = false;
  
  // Availability variables
  bool _availabilityChecked = false;
  bool _isAvailable = false;
  String _availabilityMessage = '';
  
  // Time slots for selection
  final List<String> _timeSlots = [
    '08:00', '08:30', '09:00', '09:30', '10:00', '10:30',
    '11:00', '11:30', '12:00', '12:30', '13:00', '13:30',
    '14:00', '14:30', '15:00', '15:30', '16:00', '16:30',
    '17:00', '17:30', '18:00', '18:30', '19:00', '19:30'
  ];
  
  @override
  void dispose() {
    _horaInicioController.dispose();
    _horaFinController.dispose();
    _cantidadController.dispose();
    _duracionController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    
    return Obx(() {
      final isDark = themeController.isDarkMode;
      final primaryColor = isDark ? const Color(0xFF3B82F6) : const Color(0xFFFF6B35);
      
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.92,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.90,
            maxWidth: 450,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2937) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, primaryColor.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Confirmar Reserva',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.servicio.nombre,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              
              // Form content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Date and time selection
                        _buildDateTimeSection(isDark, primaryColor),
                        const SizedBox(height: 16),
                        
                        // Quantity and duration
                        _buildQuantityDurationSection(isDark, primaryColor),
                        const SizedBox(height: 16),
                        
                        // Notes
                        _buildNotesSection(isDark, primaryColor),
                        const SizedBox(height: 16),
                        
                        // Availability status
                        if (_availabilityChecked) _buildAvailabilityStatus(isDark),
                        if (_availabilityChecked) const SizedBox(height: 16),
                        
                        // Action buttons
                        _buildActionButtons(isDark, primaryColor),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildDateTimeSection(bool isDark, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.event, color: primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              'Fecha y Horario',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF374151),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Selected date and time display
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF374151) : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDate(_selectedDate),
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.white : const Color(0xFF374151),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_horaInicioController.text} - ${_horaFinController.text}',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _showCalendar = !_showCalendar;
                        _showTimeSelection = false;
                        _resetAvailability();
                      });
                    },
                    icon: Icon(
                      _showCalendar ? Icons.keyboard_arrow_up : Icons.edit_calendar,
                      color: primaryColor,
                      size: 20,
                    ),
                    label: Text(
                      _showCalendar ? 'Cerrar' : 'Cambiar',
                      style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Calendar and Time Selection
        if (_showCalendar) ...[
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF374151) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB),
              ),
            ),
            child: Column(
              children: [
                // Calendar
                TableCalendar<DateTime>(
                  firstDay: DateTime.now(),
                  lastDay: DateTime.now().add(const Duration(days: 365)),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDate = selectedDay;
                      _focusedDay = focusedDay;
                      _showTimeSelection = true;
                      _resetAvailability();
                    });
                  },
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    selectedDecoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    defaultTextStyle: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF374151),
                    ),
                    weekendTextStyle: TextStyle(
                      color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                    ),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF374151),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    leftChevronIcon: Icon(
                      Icons.chevron_left,
                      color: isDark ? Colors.white : const Color(0xFF374151),
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right,
                      color: isDark ? Colors.white : const Color(0xFF374151),
                    ),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(
                      color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                      fontWeight: FontWeight.w600,
                    ),
                    weekendStyle: TextStyle(
                      color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                
                // Time Selection
                if (_showTimeSelection) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF8FAFC),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selecciona el horario',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : const Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildTimeSlotGrid(isDark, primaryColor),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTimeSlotGrid(bool isDark, Color primaryColor) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _timeSlots.map((time) {
        final isSelected = _horaInicioController.text == time;
        return GestureDetector(
          onTap: () => _selectTimeSlot(time),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected 
                ? primaryColor 
                : (isDark ? const Color(0xFF374151) : Colors.white),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected 
                  ? primaryColor 
                  : (isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB)),
              ),
            ),
            child: Text(
              time,
              style: TextStyle(
                color: isSelected 
                  ? Colors.white 
                  : (isDark ? Colors.white : const Color(0xFF374151)),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuantityDurationSection(bool isDark, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.people, color: primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              'Detalles adicionales',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF374151),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: _buildNumberField(
                controller: _cantidadController,
                label: 'Cantidad',
                isDark: isDark,
                primaryColor: primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildNumberField(
                controller: _duracionController,
                label: 'Duración (min)',
                isDark: isDark,
                primaryColor: primaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotesSection(bool isDark, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.note_alt, color: primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              'Notas adicionales',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF374151),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        TextFormField(
          controller: _notasController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Escribe cualquier información adicional...',
            hintStyle: TextStyle(
              color: isDark ? Colors.white54 : const Color(0xFF9CA3AF),
            ),
            filled: true,
            fillColor: isDark ? const Color(0xFF374151) : const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryColor, width: 2),
            ),
          ),
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF374151),
          ),
        ),
      ],
    );
  }

  Widget _buildAvailabilityStatus(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isAvailable 
          ? Colors.green.withOpacity(0.1) 
          : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isAvailable ? Colors.green : Colors.red,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isAvailable ? Icons.check_circle : Icons.error,
            color: _isAvailable ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _availabilityMessage,
              style: TextStyle(
                color: _isAvailable ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isDark, Color primaryColor) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: primaryColor),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: (_availabilityChecked && _isAvailable) 
              ? _addToCart 
              : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
            ),
            child: Text(
              'Agregar al Carrito',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }



  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required bool isDark,
    required Color primaryColor,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? Colors.white70 : const Color(0xFF6B7280),
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF374151) : const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),
      style: TextStyle(
        color: isDark ? Colors.white : const Color(0xFF374151),
      ),
      onChanged: (_) => _resetAvailability(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Requerido';
        }
        if (int.tryParse(value) == null || int.parse(value) <= 0) {
          return 'Número válido';
        }
        return null;
      },
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    const weekdays = [
      'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'
    ];
    
    return '${weekdays[date.weekday - 1]}, ${date.day} de ${months[date.month - 1]} ${date.year}';
  }

  void _selectTimeSlot(String startTime) {
    setState(() {
      _horaInicioController.text = startTime;
      
      // Calcular hora de fin automáticamente (1 hora después)
      final parts = startTime.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      final startDateTime = DateTime(2024, 1, 1, hour, minute);
      final endDateTime = startDateTime.add(Duration(hours: 1));
      
      _horaFinController.text = '${endDateTime.hour.toString().padLeft(2, '0')}:${endDateTime.minute.toString().padLeft(2, '0')}';
      
      // Verificar disponibilidad automáticamente
      _checkAvailability();
    });
  }

  void _resetAvailability() {
    setState(() {
      _availabilityChecked = false;
      _isAvailable = false;
      _availabilityMessage = '';
    });
  }

  Future<void> _checkAvailability() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _availabilityChecked = false;
    });

    try {
      final reservaService = Get.find<ReservaService>();
      final reservas = await reservaService.obtenerMisReservas();
      
      final fechaStr = _selectedDate.toIso8601String().split('T')[0];
      final horaInicio = _horaInicioController.text.trim();
      final horaFin = _horaFinController.text.trim();
      
      bool disponible = true;
      for (final reserva in reservas) {
        if (reserva['fechaInicio'] == fechaStr) {
          // Verificar si hay cruce de horarios
          if (!(horaFin.compareTo(reserva['horaInicio']) <= 0 || 
                horaInicio.compareTo(reserva['horaFin']) >= 0)) {
            disponible = false;
            break;
          }
        }
      }
      
      setState(() {
        _availabilityChecked = true;
        _isAvailable = disponible;
        _availabilityMessage = disponible 
          ? '¡Horario disponible! Puedes proceder con la reserva.'
          : 'El horario seleccionado no está disponible. Por favor, elige otro horario.';
        
        // Cerrar calendario automáticamente si está disponible
        if (disponible) {
          _showCalendar = false;
          _showTimeSelection = false;
        }
      });
    } catch (e) {
      // Si hay error, asumimos que está disponible
      setState(() {
        _availabilityChecked = true;
        _isAvailable = true;
        _availabilityMessage = '¡Horario disponible! Puedes proceder con la reserva.';
        
        // Cerrar calendario automáticamente
        _showCalendar = false;
        _showTimeSelection = false;
      });
    } finally {
      // No necesitamos setState aquí ya que ya se hizo arriba
    }
  }

  Future<void> _addToCart() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final cartController = Get.find<CartController>();
      final reserva = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'servicioId': widget.servicio.id,
        'emprendedorId': widget.servicio.emprendedorId,
        'fechaInicio': _selectedDate.toIso8601String().split('T')[0],
        'fechaFin': _selectedDate.toIso8601String().split('T')[0],
        'horaInicio': _horaInicioController.text,
        'horaFin': _horaFinController.text,
        'duracionMinutos': int.tryParse(_duracionController.text) ?? 60,
        'cantidad': int.tryParse(_cantidadController.text) ?? 1,
        'notasCliente': _notasController.text.isNotEmpty ? _notasController.text : null,
        'estado': 'pendiente',
        'metodoPago': null,
        'precioTotal': double.tryParse(widget.servicio.precioReferencial) ?? 0,
        'createdAt': DateTime.now().toIso8601String(),
        'servicio': {
          'id': widget.servicio.id,
          'nombre': widget.servicio.nombre,
          'descripcion': widget.servicio.descripcion,
          'precioReferencial': double.tryParse(widget.servicio.precioReferencial) ?? 0,
          'imagenUrl': '',
        },
        'emprendedor': {
          'id': widget.servicio.emprendedor.id,
          'nombre': widget.servicio.emprendedor.nombre,
          'tipoServicio': widget.servicio.emprendedor.tipoServicio,
        },
      };

      await cartController.agregarReserva(reserva);
      Navigator.of(context).pop();
      
      // Mostrar diálogo de confirmación
      Future.delayed(const Duration(milliseconds: 300), () {
        cartController.mostrarDialogoConfirmacion();
      });
      
      widget.onReservationAdded();
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo agregar la reserva: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}