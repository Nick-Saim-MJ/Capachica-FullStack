// lib/features/home/presentation/pages/evento_detail_screen.dart
import 'package:aplicativo_capachica/features/home/presentation/bloc/evento_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/evento_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/date_formatter.dart';
// Importación correcta del modelo de Slider
import '../../data/models/slider_model.dart';
import 'dart:typed_data';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapBoxLocation extends StatefulWidget {
  final double latitude;
  final double longitude;

  const MapBoxLocation({required this.latitude, required this.longitude, super.key});

  @override
  State<MapBoxLocation> createState() => _MapBoxLocationState();
}

class _MapBoxLocationState extends State<MapBoxLocation> {
  MapboxMap? mapboxMap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ubicación del Evento')),
      body: MapWidget(
        styleUri: MapboxStyles.MAPBOX_STREETS,
        cameraOptions: CameraOptions(
          center: Point(coordinates: Position(widget.longitude, widget.latitude)),
          zoom: 14.0,
        ),
        onMapCreated: (controller) async {
          mapboxMap = controller;

          // Crear el PointAnnotationManager
          final pointAnnotationManager =
          await mapboxMap!.annotations.createPointAnnotationManager();

          // Crear marcador
          await pointAnnotationManager.create(PointAnnotationOptions(
            geometry: Point(coordinates: Position(widget.longitude, widget.latitude)),
            iconImage: "marker-15", // icono por defecto
            textField: "Evento",
            textSize: 16,
          ));
        },
      ),
    );
  }
}




class EventoDetailScreen extends StatefulWidget {
  final int eventoId;

  const EventoDetailScreen({
    Key? key,
    required this.eventoId,
  }) : super(key: key);

  @override
  State<EventoDetailScreen> createState() => _EventoDetailScreenState();
}

class _EventoDetailScreenState extends State<EventoDetailScreen> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<EventoBloc>().add(LoadEventoById(widget.eventoId));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<EventoBloc, EventoState>(
        listener: (context, state) {
          if (state is EventoError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is EventoLoading) {
            return _buildLoadingState();
          }

          if (state is EventoError) {
            return _buildErrorState(state.message);
          }

          if (state is EventoDetailLoaded) {
            return _buildDetailContent(state.evento);
          }

          return _buildLoadingState();
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber[800],
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop('refresh'); // <-- envía 'refresh'
          },
        ),
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber[800],
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop('refresh'); // <-- envía 'refresh'
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.errorCargarEvento,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<EventoBloc>().add(LoadEventoById(widget.eventoId));
              },
              child: const Text(AppStrings.reintentar),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailContent(EventoModel evento) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(evento),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBasicInfo(evento),
                  const SizedBox(height: 24),
                  _buildDateTimeSection(evento),
                  const SizedBox(height: 24),
                  _buildEmprendedorSection(evento),
                  if (evento.descripcion != null) ...[
                    const SizedBox(height: 24),
                    _buildDescriptionSection(evento),
                  ],
                  if (evento.queLlevar != null) ...[
                    const SizedBox(height: 24),
                    _buildQueLlevarSection(evento),
                  ],
                  if (evento.coordenadaX != null && evento.coordenadaY != null) ...[
                    const SizedBox(height: 24),
                    _buildLocationSection(evento),
                  ],
                  const SizedBox(height: 24),
                  _buildActionButtons(evento),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(EventoModel evento) {
    final images = evento.sliders?.where((s) => s.url.isNotEmpty).toList() ?? [];

    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.amber[800],
      foregroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.of(context).pop('refresh'); // <-- envía 'refresh'
        },
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: images.isNotEmpty
            ? _buildImageCarousel(images)
            : _buildPlaceholderImage(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () => _shareEvent(evento),
        ),
      ],
    );
  }

  Widget _buildImageCarousel(List<SliderModel> images) {
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: images.length,
          onPageChanged: (index) {
            if (mounted) {
              setState(() {
                _currentImageIndex = index;
              });
            }
          },
          itemBuilder: (context, index) {
            return CachedNetworkImage(
              imageUrl: images[index].url,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) => _buildPlaceholderImage(),
            );
          },
        ),
        if (images.length > 1) ...[
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: images.asMap().entries.map((entry) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == entry.key
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(
          Icons.event,
          size: 64,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildBasicInfo(EventoModel evento) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          evento.nombre,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildStatusChip(evento),
            const SizedBox(width: 8),
            Chip(
              label: Text(evento.tipoEvento),
              backgroundColor: Colors.amber[800]!.withOpacity(0.1),
              labelStyle: const TextStyle(color: Colors.amber),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip(EventoModel evento) {
    final now = DateTime.now();
    final isActive = evento.fechaFin.isAfter(now);
    final isUpcoming = evento.fechaInicio.isAfter(now);

    Color chipColor;
    String chipText;
    IconData chipIcon;

    if (isUpcoming) {
      chipColor = AppColors.info;
      chipText = 'Próximo';
      chipIcon = Icons.schedule;
    } else if (isActive) {
      chipColor = AppColors.success;
      chipText = 'Activo';
      chipIcon = Icons.play_circle;
    } else {
      chipColor = AppColors.error;
      chipText = 'Finalizado';
      chipIcon = Icons.stop_circle;
    }

    return Chip(
      avatar: Icon(
        chipIcon,
        size: 16,
        color: Colors.white,
      ),
      label: Text(chipText),
      backgroundColor: chipColor,
      labelStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildDateTimeSection(EventoModel evento) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fechas y Horarios',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Colors.amber[800],
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fecha de inicio',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        DateFormatter.formatDate(evento.fechaInicio),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.event,
                  color: Colors.amber[800],
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fecha de fin',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        DateFormatter.formatDate(evento.fechaFin),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: Colors.amber[800],
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Horario',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '${evento.horaInicio} - ${evento.horaFin}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (evento.duracionHoras != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.timer,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Duración',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '${evento.duracionHoras} horas',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.language,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Idioma principal',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        evento.idiomaPrincipal,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmprendedorSection(EventoModel evento) {
    if (evento.emprendedor == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Organizador',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    evento.emprendedor!.nombre.isNotEmpty
                        ? evento.emprendedor!.nombre[0].toUpperCase()
                        : 'E',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        evento.emprendedor!.nombre,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (evento.emprendedor!.email != null)
                        Text(
                          evento.emprendedor!.email!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(EventoModel evento) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Descripción',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              evento.descripcion!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQueLlevarSection(EventoModel evento) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.backpack,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '¿Qué llevar?',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              evento.queLlevar!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection(EventoModel evento) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Ubicación',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Latitud: ${evento.coordenadaX!.toStringAsFixed(6)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'Longitud: ${evento.coordenadaY!.toStringAsFixed(6)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MapBoxLocation(
                      latitude: evento.coordenadaX!,
                      longitude: evento.coordenadaY!,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.map),
              label: const Text('Ver en mapa'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(EventoModel evento) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _addToCalendar(evento),
            icon: const Icon(Icons.calendar_month),
            label: const Text('Agregar al calendario'),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[800],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _shareEvent(evento),
                icon: const Icon(Icons.share),
                label: const Text('Compartir'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _contactOrganizer(evento),
                icon: const Icon(Icons.contact_phone),
                label: const Text('Contactar'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _openMap(double lat, double lng) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir el mapa'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _shareEvent(EventoModel evento) {
    final String shareText = '''
🎉 ${evento.nombre}

📅 Inicio: ${DateFormatter.formatDate(evento.fechaInicio)}
📅 Fin: ${DateFormatter.formatDate(evento.fechaFin)}
⏰ Horario: ${evento.horaInicio} - ${evento.horaFin}
🏷️ Tipo: ${evento.tipoEvento}
${evento.idiomaPrincipal != null ? '🌐 Idioma: ${evento.idiomaPrincipal}' : ''}

${evento.descripcion != null ? '📝 Descripción:\n${evento.descripcion}\n' : ''}

${evento.emprendedor != null ? '👤 Organizador: ${evento.emprendedor!.nombre}' : ''}

${evento.coordenadaX != null && evento.coordenadaY != null ?
    '📍 Ubicación: https://www.google.com/maps/search/?api=1&query=${evento.coordenadaX},${evento.coordenadaY}' : ''}

¡No te lo pierdas! 🚀
  '''.trim();

    Share.share(
      shareText,
      subject: 'Evento: ${evento.nombre}',
    );
  }

  void _addToCalendar(EventoModel evento) async {
    try {
      // Crear URL para Google Calendar (funciona en web y móvil)
      final startDate = evento.fechaInicio;
      final endDate = evento.fechaFin;

      // Formatear fechas para Google Calendar (formato: YYYYMMDDTHHMMSSZ)
      final startFormatted = _formatDateForCalendar(startDate, evento.horaInicio);
      final endFormatted = _formatDateForCalendar(endDate, evento.horaFin);

      String description = '';
      if (evento.descripcion != null) {
        description += 'Descripción: ${evento.descripcion}\n\n';
      }
      if (evento.queLlevar != null) {
        description += 'Qué llevar: ${evento.queLlevar}\n\n';
      }
      if (evento.emprendedor != null) {
        description += 'Organizador: ${evento.emprendedor!.nombre}';
        if (evento.emprendedor!.email != null) {
          description += ' (${evento.emprendedor!.email})';
        }
        description += '\n\n';
      }
      description += 'Tipo de evento: ${evento.tipoEvento}\n';
      description += 'Idioma: ${evento.idiomaPrincipal}';

      String location = '';
      if (evento.coordenadaX != null && evento.coordenadaY != null) {
        location = '${evento.coordenadaX},${evento.coordenadaY}';
      }

      final googleCalendarUrl = Uri.https('calendar.google.com', '/calendar/render', {
        'action': 'TEMPLATE',
        'text': evento.nombre,
        'dates': '$startFormatted/$endFormatted',
        'details': description,
        'location': location,
        'sf': 'true',
        'output': 'xml',
      });

      if (await canLaunchUrl(googleCalendarUrl)) {
        await launchUrl(googleCalendarUrl, mode: LaunchMode.externalApplication);
      } else {
        // Fallback: crear archivo ICS para descargar
        await _createICSFile(evento);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al agregar al calendario: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDateForCalendar(DateTime date, String time) {
    // Parsear la hora (formato esperado: "HH:mm")
    final timeParts = time.split(':');
    final hour = int.tryParse(timeParts[0]) ?? 0;
    final minute = int.tryParse(timeParts[1]) ?? 0;

    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      hour,
      minute,
    );

    // Formato para Google Calendar: YYYYMMDDTHHMMSSZ
    return '${dateTime.year}'
        '${dateTime.month.toString().padLeft(2, '0')}'
        '${dateTime.day.toString().padLeft(2, '0')}'
        'T'
        '${dateTime.hour.toString().padLeft(2, '0')}'
        '${dateTime.minute.toString().padLeft(2, '0')}'
        '00Z';
  }

  Future<void> _createICSFile(EventoModel evento) async {
    try {
      final startDate = evento.fechaInicio;
      final endDate = evento.fechaFin;

      final startFormatted = _formatDateForCalendar(startDate, evento.horaInicio);
      final endFormatted = _formatDateForCalendar(endDate, evento.horaFin);

      String description = '';
      if (evento.descripcion != null) {
        description += 'Descripción: ${evento.descripcion}\\n\\n';
      }
      if (evento.queLlevar != null) {
        description += 'Qué llevar: ${evento.queLlevar}\\n\\n';
      }
      if (evento.emprendedor != null) {
        description += 'Organizador: ${evento.emprendedor!.nombre}';
        if (evento.emprendedor!.email != null) {
          description += ' (${evento.emprendedor!.email})';
        }
        description += '\\n\\n';
      }
      description += 'Tipo de evento: ${evento.tipoEvento}\\n';
      description += 'Idioma: ${evento.idiomaPrincipal}';

      String location = '';
      if (evento.coordenadaX != null && evento.coordenadaY != null) {
        location = 'Lat: ${evento.coordenadaX}, Lng: ${evento.coordenadaY}';
      }

      final icsContent = '''BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Aplicativo Capachica//ES
BEGIN:VEVENT
UID:${evento.id}@capachica.app
DTSTART:$startFormatted
DTEND:$endFormatted
SUMMARY:${evento.nombre}
DESCRIPTION:$description
LOCATION:$location
STATUS:CONFIRMED
END:VEVENT
END:VCALENDAR''';

      // Compartir el archivo ICS
      await Share.shareXFiles([
        XFile.fromData(
          Uint8List.fromList(icsContent.codeUnits),
          mimeType: 'text/calendar',
          name: '${evento.nombre}.ics',
        )
      ], text: 'Evento: ${evento.nombre}');

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear archivo de calendario: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _contactOrganizer(EventoModel evento) async {
    if (evento.emprendedor == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No hay información del organizador disponible'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    final organizer = evento.emprendedor!;

    // Mostrar opciones de contacto
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Contactar a ${organizer.nombre}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Opción de Email
              if (organizer.email != null) ...[
                ListTile(
                  leading: Icon(Icons.email, color: AppColors.primary),
                  title: const Text('Enviar Email'),
                  subtitle: Text(organizer.email!),
                  onTap: () {
                    Navigator.pop(context);
                    _sendEmail(organizer.email!, evento);
                  },
                ),
                const Divider(),
              ],

              // Opción de WhatsApp (si tienes el teléfono)
              if (organizer.telefono != null) ...[
                ListTile(
                  leading: Icon(Icons.phone, color: AppColors.primary),
                  title: const Text('Llamar'),
                  subtitle: Text(organizer.telefono!),
                  onTap: () {
                    Navigator.pop(context);
                    _makePhoneCall(organizer.telefono!);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Icon(Icons.chat, color: Colors.green),
                  title: const Text('WhatsApp'),
                  subtitle: Text(organizer.telefono!),
                  onTap: () {
                    Navigator.pop(context);
                    _sendWhatsApp(organizer.telefono!, evento);
                  },
                ),
                const Divider(),
              ],

              // Opción de compartir información de contacto
              ListTile(
                leading: Icon(Icons.share, color: AppColors.primary),
                title: const Text('Compartir contacto'),
                subtitle: const Text('Compartir información del organizador'),
                onTap: () {
                  Navigator.pop(context);
                  _shareOrganizerInfo(organizer);
                },
              ),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _sendEmail(String email, EventoModel evento) async {
    final subject = Uri.encodeComponent('Consulta sobre: ${evento.nombre}');
    final body = Uri.encodeComponent('''
Hola,

Me interesa el evento "${evento.nombre}" que se realizará el ${DateFormatter.formatDate(evento.fechaInicio)}.

Me gustaría obtener más información.

Saludos cordiales.
  ''');

    final emailUrl = Uri.parse('mailto:$email?subject=$subject&body=$body');

    if (await canLaunchUrl(emailUrl)) {
      await launchUrl(emailUrl);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir la aplicación de email'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _makePhoneCall(String phoneNumber) async {
    final phoneUrl = Uri.parse('tel:$phoneNumber');

    if (await canLaunchUrl(phoneUrl)) {
      await launchUrl(phoneUrl);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo realizar la llamada'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _sendWhatsApp(String phoneNumber, EventoModel evento) async {
    // Limpiar el número de teléfono
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    final message = Uri.encodeComponent('''
Hola, me interesa el evento "${evento.nombre}" que se realizará el ${DateFormatter.formatDate(evento.fechaInicio)}.

¿Podrías darme más información?

Gracias.
  ''');

    final whatsappUrl = Uri.parse('https://wa.me/$cleanNumber?text=$message');

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir WhatsApp'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _shareOrganizerInfo(emprendedor) {
    String contactInfo = '''
👤 Organizador: ${emprendedor.nombre}
''';

    if (emprendedor.email != null) {
      contactInfo += '📧 Email: ${emprendedor.email}\n';
    }

    if (emprendedor.telefono != null) {
      contactInfo += '📱 Teléfono: ${emprendedor.telefono}\n';
    }

    Share.share(contactInfo, subject: 'Contacto del organizador');
  }
}