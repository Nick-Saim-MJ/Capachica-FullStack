import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../data/models/servicio_model.dart';

typedef OnHorariosChanged = void Function(List<HorarioCapachica> horarios);

class ServicioHorariosField extends StatefulWidget {
  final List<HorarioCapachica> initialHorarios;
  final OnHorariosChanged onHorariosChanged;
  final bool isDark;

  const ServicioHorariosField({
    super.key,
    required this.initialHorarios,
    required this.onHorariosChanged,
    required this.isDark,
  });

  @override
  State<ServicioHorariosField> createState() => ServicioHorariosFieldState ();

  static bool isValid(GlobalKey<ServicioHorariosFieldState> key) {
    return key.currentState?.mounted == true
        ? key.currentState!.validateHorarios()
        : true;
  }
}

class ServicioHorariosFieldState  extends State<ServicioHorariosField> {
  late List<HorarioCapachica> _currentHorarios;
  late Color _cardColor;
  late Color _textColor;
  late Color _borderColor;

  @override
  void initState() {
    super.initState();
    _currentHorarios = List.from(widget.initialHorarios);
  }

  @override
  void didUpdateWidget(covariant ServicioHorariosField oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateColors();
  }

  void _updateColors() {
    _cardColor = widget.isDark ? const Color(0xFF1F2937) : Colors.white;
    _textColor = widget.isDark ? Colors.white : const Color(0xFF1F2937);
    _borderColor = widget.isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB);
  }

  // ------------------------- LÓGICA DE MANEJO DE ESTADO -------------------------

  void _addHorario() {
    setState(() {
      _currentHorarios.add(HorarioCapachica(
        diaSemana: 'lunes', // Default
        horaInicio: '09:00:00', // Default
        horaFin: '17:00:00', // Default
        activo: true,
      ));
      // Notificar al widget padre (el formulario)
      widget.onHorariosChanged(_currentHorarios);
    });
  }

  void _removeHorario(int index) {
    setState(() {
      _currentHorarios.removeAt(index);
      widget.onHorariosChanged(_currentHorarios);
    });
  }

  void _updateHorario(int index, HorarioCapachica newHorario) {
    setState(() {
      _currentHorarios[index] = newHorario;
      widget.onHorariosChanged(_currentHorarios);
    });
  }

  // ------------------------- BUILDER -------------------------

  @override
  Widget build(BuildContext context) {
    _updateColors();
    final buttonColor = const Color(0xFF2563EB); // primary-600
    final buttonHoverColor = const Color(0xFF1D4ED8); // primary-700
    final warningBgColor = widget.isDark ? Colors.yellow.shade900.withOpacity(0.2) : Colors.yellow.shade50;
    final warningTextColor = widget.isDark ? Colors.yellow.shade300 : Colors.yellow.shade800;

    return Card(
      color: _cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Horarios Disponibles',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _textColor),
                ),
                IconButton(
                    onPressed: _addHorario,
                    icon: const Icon(Icons.add, size: 20),
                    style: IconButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: buttonColor,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(12),
                    ).copyWith(
                      overlayColor: MaterialStatePropertyAll(buttonHoverColor),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Lista de horarios o mensaje de advertencia
            if (_currentHorarios.isEmpty)
              Container(
                decoration: BoxDecoration(
                  color: warningBgColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.yellow.shade400.withOpacity(0.5)),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: warningTextColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Atención', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: warningTextColor)),
                          const SizedBox(height: 4),
                          Text(
                            'No hay horarios disponibles definidos. Este servicio no estará disponible para reservas hasta que se añada al menos un horario.',
                            style: TextStyle(fontSize: 12, color: warningTextColor.withOpacity(0.8)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: _cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: _borderColor.withOpacity(0.5),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _currentHorarios.length,
                  separatorBuilder: (context, index) => Divider(color: _borderColor, height: 1),
                  itemBuilder: (context, index) {
                    final horario = _currentHorarios[index];
                    return _HorarioItem(
                      key: ValueKey(horario.id ?? index), // Clave para asegurar la reconstrucción correcta
                      horario: horario,
                      index: index,
                      isDark: widget.isDark,
                      onChanged: (newHorario) => _updateHorario(index, newHorario),
                      onRemoved: () => _removeHorario(index),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Helper para convertir string a TimeOfDay (Moverlo aquí para que validateHorarios lo use)
  TimeOfDay _timeOfDayFromString(String timeString) {
    final parts = timeString.split(':');
    if (parts.length < 2) return const TimeOfDay(hour: 9, minute: 0);
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  bool validateHorarios() {
    for (var horario in _currentHorarios) {
      final TimeOfDay horaInicio = _timeOfDayFromString(horario.horaInicio);
      final TimeOfDay horaFin = _timeOfDayFromString(horario.horaFin);

      if (horaFin.hour * 60 + horaFin.minute <= horaInicio.hour * 60 + horaInicio.minute) {
        return false;
      }
    }
    return true;
  }
}

// ------------------------- WIDGET PRIVADO PARA CADA ÍTEM DE HORARIO -------------------------

class _HorarioItem extends StatelessWidget {
  final HorarioCapachica horario;
  final int index;
  final bool isDark;
  final ValueChanged<HorarioCapachica> onChanged;
  final VoidCallback onRemoved;

  const _HorarioItem({
    super.key,
    required this.horario,
    required this.index,
    required this.isDark,
    required this.onChanged,
    required this.onRemoved,
  });

  @override
  Widget build(BuildContext context) {
    final labelColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280); // gray-400/500
    final inputBgColor = isDark ? const Color(0xFF374151) : Colors.white; // gray-700 / white
    final inputTextColor = isDark ? Colors.white : Colors.black;
    final inputBorderColor = isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB); // gray-600 / gray-300
    final errorColor = isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626); // red-400/600

    // Función para convertir HH:mm:ss a TimeOfDay (solo HORA y MINUTO)
    TimeOfDay _timeOfDayFromString(String timeString) {
      final parts = timeString.split(':');
      if (parts.length < 2) return const TimeOfDay(hour: 9, minute: 0);
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    // Función para convertir TimeOfDay a HH:mm:ss
    String _timeStringFromTimeOfDay(TimeOfDay time) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
    }

    // Convertir el formato del widget web (HH:mm:ss) a TimeOfDay para los TimePickers
    final TimeOfDay horaInicio = _timeOfDayFromString(horario.horaInicio);
    final TimeOfDay horaFin = _timeOfDayFromString(horario.horaFin);

    final isTimeInvalid = horaFin.hour * 60 + horaFin.minute <= horaInicio.hour * 60 + horaInicio.minute;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row( // Fila para el Título del Día y el botón de Eliminar
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Día de la semana (Dropdown - Ocupa casi todo el ancho)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Día de la semana', style: TextStyle(fontSize: 12, color: labelColor, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      value: horario.diaSemana,
                      items: diasSemana.map((day) {
                        return DropdownMenuItem(
                          value: day,
                          child: Text(
                            day[0].toUpperCase() + day.substring(1),
                            style: TextStyle(color: inputTextColor, fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          onChanged(horario.copyWith(diaSemana: newValue));
                        }
                      },
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        fillColor: inputBgColor,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: inputBorderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: inputBorderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: const Color(0xFF2563EB)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Botón Eliminar (A la derecha del Dropdown)
              IconButton(
                onPressed: onRemoved,
                icon: Icon(Icons.delete_forever, color: errorColor),
                tooltip: 'Eliminar horario',
                padding: const EdgeInsets.only(left: 16, top: 20), // Ajustar padding para alinearse
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Fila para Horas de Inicio y Fin
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hora de inicio (Time Picker)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: labelColor),
                        const SizedBox(width: 4),
                        Text(
                          'Hora inicio',
                          style: TextStyle(
                            fontSize: 12,
                            color: labelColor,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: inputBgColor,
                        foregroundColor: inputTextColor,
                        padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: inputBorderColor),
                        ),
                      ).copyWith(
                        overlayColor: MaterialStateProperty.all(
                          isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.black.withOpacity(0.05),
                        ),
                      ),
                      onPressed: () async {
                        final newTime = await showTimePicker(
                          context: context,
                          initialTime: horaInicio,
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                timePickerTheme: TimePickerThemeData(
                                  backgroundColor: inputBgColor,
                                  hourMinuteTextColor: inputTextColor,
                                  dayPeriodTextColor: inputTextColor,
                                  dialHandColor: const Color(0xFF2563EB),
                                  dialBackgroundColor: isDark
                                      ? const Color(0xFF374151)
                                      : Colors.grey.shade100,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );

                        if (newTime != null) {
                          onChanged(
                            horario.copyWith(
                              horaInicio: _timeStringFromTimeOfDay(newTime),
                            ),
                          );
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Icon(Icons.schedule, size: 16, color: inputTextColor),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              horaInicio.format(context),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Hora de fin (Time Picker)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.access_time_filled, size: 14, color: labelColor),
                        const SizedBox(width: 4),
                        Text(
                          'Hora fin',
                          style: TextStyle(
                            fontSize: 12,
                            color: labelColor,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: inputBgColor,
                        foregroundColor: inputTextColor,
                        padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: inputBorderColor),
                        ),
                      ).copyWith(
                        overlayColor: MaterialStateProperty.all(
                          isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.black.withOpacity(0.05),
                        ),
                      ),
                      onPressed: () async {
                        final newTime = await showTimePicker(
                          context: context,
                          initialTime: horaFin,
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                timePickerTheme: TimePickerThemeData(
                                  backgroundColor: inputBgColor,
                                  hourMinuteTextColor: inputTextColor,
                                  dayPeriodTextColor: inputTextColor,
                                  dialHandColor: const Color(0xFF2563EB),
                                  dialBackgroundColor: isDark
                                      ? const Color(0xFF374151)
                                      : Colors.grey.shade100,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );

                        if (newTime != null) {
                          onChanged(
                            horario.copyWith(
                              horaFin: _timeStringFromTimeOfDay(newTime),
                            ),
                          );
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Icon(Icons.schedule, size: 16, color: inputTextColor),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              horaFin.format(context),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Activo (Checkbox - Ocupa todo el ancho si es necesario)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Estado', style: TextStyle(fontSize: 12, color: labelColor, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Checkbox(
                    value: horario.activo,
                    onChanged: (value) {
                      if (value != null) {
                        onChanged(horario.copyWith(activo: value));
                      }
                    },
                    activeColor: const Color(0xFF2563EB),
                  ),
                  Text('Activo', style: TextStyle(color: inputTextColor, fontSize: 14)),
                ],
              ),
            ],
          ),

          if (isTimeInvalid)
            Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.error_outline, size: 16, color: errorColor),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'La hora de fin debe ser posterior a la hora de inicio',
                            style: TextStyle(color: errorColor, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
        ],
      ),
    );
  }
}