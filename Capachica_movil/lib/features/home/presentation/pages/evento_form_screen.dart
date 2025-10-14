import 'dart:io';

import 'package:aplicativo_capachica/features/home/presentation/bloc/evento_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart' as picker;

import '../../data/models/evento_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/custom_date_picker.dart';
import '../../../../core/widgets/custom_time_picker.dart';


// 👇 Mapbox
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mbx hide ImageSource;
class EventoFormScreen extends StatefulWidget {
  final EventoModel? evento; // null para crear, con datos para editar

  const EventoFormScreen({Key? key, this.evento}) : super(key: key);

  @override
  State<EventoFormScreen> createState() => _EventoFormScreenState();
}

class _EventoFormScreenState extends State<EventoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Controllers
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  late TextEditingController _tipoEventoController;
  late TextEditingController _idiomaPrincipalController;
  late TextEditingController _duracionHorasController;
  late TextEditingController _coordenadaXController; // Latitud
  late TextEditingController _coordenadaYController; // Longitud
  late TextEditingController _queLlevarController;

  // Form data
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  TimeOfDay? _horaInicio;
  TimeOfDay? _horaFin;
  int _selectedEmprendedorId = 1; // Ajusta según tu selector real

  // Sliders
  List<SliderFormData> _sliders = [];

  bool get _isEditing => widget.evento != null;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadInitialData();
  }

  void _initializeControllers() {
    _nombreController = TextEditingController();
    _descripcionController = TextEditingController();
    _tipoEventoController = TextEditingController();
    _idiomaPrincipalController = TextEditingController();
    _duracionHorasController = TextEditingController();
    _coordenadaXController = TextEditingController();
    _coordenadaYController = TextEditingController();
    _queLlevarController = TextEditingController();
  }

  void _loadInitialData() {
    if (_isEditing && widget.evento != null) {
      final e = widget.evento!;
      _nombreController.text = e.nombre;
      _descripcionController.text = e.descripcion ?? '';
      _tipoEventoController.text = e.tipoEvento;
      _idiomaPrincipalController.text = e.idiomaPrincipal;
      _duracionHorasController.text = e.duracionHoras?.toString() ?? '';
      _coordenadaXController.text = e.coordenadaX?.toString() ?? '';
      _coordenadaYController.text = e.coordenadaY?.toString() ?? '';
      _queLlevarController.text = e.queLlevar ?? '';
      _fechaInicio = e.fechaInicio;
      _fechaFin = e.fechaFin;

      try {
        final hi = e.horaInicio.split(':');
        _horaInicio = TimeOfDay(hour: int.parse(hi[0]), minute: int.parse(hi[1]));
        final hf = e.horaFin.split(':');
        _horaFin = TimeOfDay(hour: int.parse(hf[0]), minute: int.parse(hf[1]));
      } catch (_) {}

      _selectedEmprendedorId = e.idEmprendedor;

      if (e.sliders != null) {
        _sliders = e.sliders!
            .map((s) => SliderFormData(
          id: s.id,
          nombre: s.nombre,
          url: s.url,
          orden: s.orden,
          activo: s.activo,
          esPrincipal: s.esPrincipal,
        ))
            .toList();
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _tipoEventoController.dispose();
    _idiomaPrincipalController.dispose();
    _duracionHorasController.dispose();
    _coordenadaXController.dispose();
    _coordenadaYController.dispose();
    _queLlevarController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar evento' : 'Crear evento'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Guardar',
            icon: const Icon(Icons.save),
            onPressed: _submitForm,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _submitForm,
        icon: const Icon(Icons.check),
        label: const Text('Guardar'),
      ),
      body: BlocListener<EventoBloc, EventoState>(
        listener: (context, state) {
          if (state is EventoCreated || state is EventoUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_isEditing
                    ? 'Evento actualizado exitosamente'
                    : 'Evento creado exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop(true);
          }
          if (state is EventoError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: Form(
          key: _formKey,
          child: Scrollbar(
            controller: _scrollController,
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBasicInfoSection(),
                  const SizedBox(height: 24),
                  _buildDateTimeSection(),
                  const SizedBox(height: 24),
                  _buildLocationSection(), // 👈 incluye Mapbox picker
                  /*const SizedBox(height: 24),
                  _buildSlidersSection(),*/
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Información Básica',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _nombreController,
              label: 'Nombre del evento',
              validator: (v) => (v == null || v.trim().isEmpty) ? 'El nombre es obligatorio' : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _descripcionController,
              label: 'Descripción',
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _tipoEventoController,
                    label: 'Tipo de evento',
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'El tipo es obligatorio' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    controller: _idiomaPrincipalController,
                    label: 'Idioma principal',
                    validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'El idioma es obligatorio' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _queLlevarController,
              label: '¿Qué llevar?',
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fechas y Horarios',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomDatePicker(
                    label: 'Fecha de inicio',
                    selectedDate: _fechaInicio,
                    onDateSelected: (d) => setState(() => _fechaInicio = d),
                    validator: (d) => d == null ? 'La fecha de inicio es obligatoria' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomDatePicker(
                    label: 'Fecha de fin',
                    selectedDate: _fechaFin,
                    onDateSelected: (d) => setState(() => _fechaFin = d),
                    validator: (d) {
                      if (d == null) return 'La fecha de fin es obligatoria';
                      if (_fechaInicio != null && d.isBefore(_fechaInicio!)) {
                        return 'Debe ser posterior al inicio';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomTimePicker(
                    label: 'Hora de inicio',
                    selectedTime: _horaInicio,
                    onTimeSelected: (t) => setState(() => _horaInicio = t),
                    validator: (t) => t == null ? 'La hora de inicio es obligatoria' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTimePicker(
                    label: 'Hora de fin',
                    selectedTime: _horaFin,
                    onTimeSelected: (t) => setState(() => _horaFin = t),
                    validator: (t) => t == null ? 'La hora de fin es obligatoria' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _duracionHorasController,
              label: 'Duración en horas (opcional)',
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v != null && v.isNotEmpty) {
                  final d = int.tryParse(v);
                  if (d == null || d <= 0) return 'Debe ser un número positivo';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Ubicación',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 👇 MAPBOX PICKER
            MapboxPicker(
              initialLat: double.tryParse(_coordenadaXController.text),
              initialLng: double.tryParse(_coordenadaYController.text),
              onPicked: (lat, lng) {
                _coordenadaXController.text = lat.toStringAsFixed(6);
                _coordenadaYController.text = lng.toStringAsFixed(6);
                setState(() {});
              },
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _coordenadaXController,
                    label: 'Latitud',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Latitud obligatoria';
                      final d = double.tryParse(v);
                      if (d == null || d < -90 || d > 90) return 'Latitud entre -90 y 90';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    controller: _coordenadaYController,
                    label: 'Longitud',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Longitud obligatoria';
                      final d = double.tryParse(v);
                      if (d == null || d < -180 || d > 180) return 'Longitud entre -180 y 180';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Toca el mapa para colocar el pin. Los campos se llenan automáticamente.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
/*
  Widget _buildSlidersSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.photo_library, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Imágenes del Evento',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _addSlider,
                  icon: const Icon(Icons.add_photo_alternate),
                  color: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_sliders.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(Icons.photo_library_outlined, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text('No hay imágenes agregadas', style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(height: 8),
                    ElevatedButton(onPressed: _addSlider, child: const Text('Agregar imagen')),
                  ],
                ),
              )
            else
              ...List.generate(_sliders.length, (i) => _buildSliderItem(i)),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderItem(int index) {
    final slider = _sliders[index];
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text('Imagen ${index + 1}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500)),
              const Spacer(),
            ]),
            const SizedBox(height: 12),
            if (slider.imagePath != null || slider.url != null)
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: slider.imagePath != null
                      ? Image.file(File(slider.imagePath!), fit: BoxFit.cover)
                      : Image.network(
                    slider.url!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[200],
                      child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                    ),
                  ),
                ),
              )
            else
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                  color: Colors.grey[50],
                ),
                child: InkWell(
                  onTap: () => _selectImage(index),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo, size: 32, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Seleccionar imagen', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            if (slider.imagePath != null || slider.url != null)
              ElevatedButton.icon(
                onPressed: () => _selectImage(index),
                icon: const Icon(Icons.edit),
                label: const Text('Cambiar'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
              ),
            const SizedBox(height: 12),
            CustomTextField(
              initialValue: slider.nombre ?? '',
              label: 'Nombre de la imagen',
              onChanged: (v) => setState(() => _sliders[index] = slider.copyWith(nombre: v)),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              initialValue: slider.titulo ?? '',
              label: 'Título (opcional)',
              onChanged: (v) => setState(() => _sliders[index] = slider.copyWith(titulo: v)),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              initialValue: slider.descripcion ?? '',
              label: 'Descripción (opcional)',
              maxLines: 2,
              onChanged: (v) => setState(() => _sliders[index] = slider.copyWith(descripcion: v)),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Checkbox(
                  value: slider.activo ?? true,
                  onChanged: (val) => setState(() => _sliders[index] = slider.copyWith(activo: val)),
                ),
                const Text('Activo'),
                const SizedBox(width: 20),
                Checkbox(
                  value: slider.esPrincipal ?? false,
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        for (int i = 0; i < _sliders.length; i++) {
                          _sliders[i] = _sliders[i].copyWith(esPrincipal: i == index);
                        }
                      } else {
                        _sliders[index] = slider.copyWith(esPrincipal: false);
                      }
                    });
                  },
                ),
                const Text('Principal'),
              ],
            ),
          ],
        ),
      ),
    );
  }*/

  void _addSlider() {
    setState(() {
      _sliders.add(SliderFormData(
        orden: _sliders.length + 1,
        activo: true,
        esPrincipal: _sliders.isEmpty,
      ));
    });
  }
/*
  void _selectImage(int index) async {
    final ip = picker.ImagePicker();

    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar foto'),
              onTap: () async {
                Navigator.pop(context);
                final picker.XFile? img = await ip.pickImage(
                  source: picker.ImageSource.camera,
                );
                if (img != null) {
                  setState(() {
                    _sliders[index] =
                        _sliders[index].copyWith(imagePath: img.path);
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Seleccionar de galería'),
              onTap: () async {
                Navigator.pop(context);
                final picker.XFile? img = await ip.pickImage(
                  source: picker.ImageSource.gallery,
                );
                if (img != null) {
                  setState(() {
                    _sliders[index] =
                        _sliders[index].copyWith(imagePath: img.path);
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }*/

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    if (_fechaInicio == null || _fechaFin == null || _horaInicio == null || _horaFin == null) {
      _showError('Completa fechas y horas');
      return;
    }

    final coordX = double.tryParse(_coordenadaXController.text.trim());
    final coordY = double.tryParse(_coordenadaYController.text.trim());
    if (coordX == null || coordY == null) {
      _showError('Selecciona la ubicación (latitud/longitud)');
      return;
    }

    final request = CreateEventoRequest(
      nombre: _nombreController.text.trim(),
      descripcion: _descripcionController.text.trim().isNotEmpty ? _descripcionController.text.trim() : null,
      tipoEvento: _tipoEventoController.text.trim(),
      idiomaPrincipal: _idiomaPrincipalController.text.trim(),
      fechaInicio: _fechaInicio!,
      horaInicio:
      '${_horaInicio!.hour.toString().padLeft(2, '0')}:${_horaInicio!.minute.toString().padLeft(2, '0')}:00',
      fechaFin: _fechaFin!,
      horaFin:
      '${_horaFin!.hour.toString().padLeft(2, '0')}:${_horaFin!.minute.toString().padLeft(2, '0')}:00',
      duracionHoras: _duracionHorasController.text.trim().isNotEmpty
          ? int.tryParse(_duracionHorasController.text.trim())
          : null,
      coordenadaX: coordX, // 👈 obligatorios
      coordenadaY: coordY, // 👈 obligatorios
      idEmprendedor: _selectedEmprendedorId,
      queLlevar: _queLlevarController.text.trim().isNotEmpty ? _queLlevarController.text.trim() : null,
      sliders: _sliders
          .map((s) => CreateSliderRequest(
        id: s.id,
        nombre: s.nombre,
        titulo: s.titulo,
        descripcion: s.descripcion,
        url: s.url,
        orden: s.orden,
        activo: s.activo,
        esPrincipal: s.esPrincipal,
      ))
          .toList(),
    );

    if (_isEditing) {
      context.read<EventoBloc>().add(UpdateEvento(widget.evento!.id, request));
    } else {
      context.read<EventoBloc>().add(CreateEvento(request));
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }
}

// ===== Mapbox Picker embebido =====

class MapboxPicker extends StatefulWidget {
  final double? initialLat; // latitud
  final double? initialLng; // longitud
  final void Function(double lat, double lng) onPicked;
  final double height;
  final String? styleUri;

  const MapboxPicker({
    Key? key,
    this.initialLat,
    this.initialLng,
    required this.onPicked,
    this.height = 260,
    this.styleUri,
  }) : super(key: key);

  @override
  State<MapboxPicker> createState() => _MapboxPickerState();
}

class _MapboxPickerState extends State<MapboxPicker> {
  mbx.MapboxMap? _map;
  mbx.PointAnnotationManager? _pointManager;

  @override
  Widget build(BuildContext context) {
    final bool hasInitial =
        widget.initialLat != null && widget.initialLng != null;

    // 👇 Casts explícitos a double
    final double centerLat = (widget.initialLat ?? -12.0464).toDouble();
    final double centerLng = (widget.initialLng ?? -77.0428).toDouble();

    final mbx.Point centerPoint = mbx.Point(
      coordinates: mbx.Position(centerLng, centerLat),
    );

    return SizedBox(
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: mbx.MapWidget(
          key: const ValueKey('mapbox_picker'),
          styleUri: widget.styleUri ?? mbx.MapboxStyles.MAPBOX_STREETS,
          cameraOptions: mbx.CameraOptions(
            center: centerPoint,
            zoom: hasInitial ? 14 : 10,
          ),
          onMapCreated: _onMapCreated,

          // 👉 Si tu versión soporta este listener directo:
          onTapListener: (mbx.MapContentGestureContext ctx) async {
            final pos = ctx.point.coordinates; // mbx.Position
            // 👇 Casts explícitos
            final double lat = (pos.lat as num).toDouble();
            final double lng = (pos.lng as num).toDouble();

            await _placeMarker(lat, lng);
            widget.onPicked(lat, lng);
          },

          // Si tu SDK no tiene onTapListener,
          // comenta lo de arriba y usa el addOnMapClickListener en _onMapCreated (ver abajo).
        ),
      ),
    );
  }

  Future<void> _onMapCreated(mbx.MapboxMap map) async {
    _map = map;
    _pointManager =
    await _map!.annotations.createPointAnnotationManager();

    if (widget.initialLat != null && widget.initialLng != null) {
      await _placeMarker(widget.initialLat!.toDouble(),
          widget.initialLng!.toDouble());
    }

    // 👇 Alternativa si tu MapWidget NO tiene onTapListener:
    // await _map!.gestures.addOnMapClickListener((mbx.ScreenCoordinate sc) async {
    //   final mbx.Point p = await _map!.pixelForCoordinateInverse(sc);
    //   final mbx.Position pos = p.coordinates;
    //   final double lat = (pos.lat as num).toDouble();
    //   final double lng = (pos.lng as num).toDouble();
    //   await _placeMarker(lat, lng);
    //   widget.onPicked(lat, lng);
    // });
  }

  Future<void> _placeMarker(double lat, double lng) async {
    if (_pointManager == null) return;

    await _pointManager!.deleteAll();

    await _pointManager!.create(
      mbx.PointAnnotationOptions(
        geometry: mbx.Point(
          coordinates: mbx.Position(
            (lng as num).toDouble(),
            (lat as num).toDouble(),
          ),
        ),
      ),
    );

    // Mueve cámara con casts explícitos
    await _map?.flyTo(
      mbx.CameraOptions(
        center: mbx.Point(
          coordinates: mbx.Position(
            (lng as num).toDouble(),
            (lat as num).toDouble(),
          ),
        ),
        zoom: 15,
      ),
      mbx.MapAnimationOptions(duration: 800),
    );
  }
}

// ===== Clase auxiliar sliders (se mantiene igual) =====

class SliderFormData {
  final int? id;
  final String? nombre;
  final String? titulo;
  final String? descripcion;
  final String? url;
  final int? orden;
  final bool? activo;
  final bool? esPrincipal;
  final String? imagePath;

  SliderFormData({
    this.id,
    this.nombre,
    this.titulo,
    this.descripcion,
    this.url,
    this.orden,
    this.activo,
    this.esPrincipal,
    this.imagePath,
  });

  SliderFormData copyWith({
    int? id,
    String? nombre,
    String? titulo,
    String? descripcion,
    String? url,
    int? orden,
    bool? activo,
    bool? esPrincipal,
    String? imagePath,
  }) {
    return SliderFormData(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      url: url ?? this.url,
      orden: orden ?? this.orden,
      activo: activo ?? this.activo,
      esPrincipal: esPrincipal ?? this.esPrincipal,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}