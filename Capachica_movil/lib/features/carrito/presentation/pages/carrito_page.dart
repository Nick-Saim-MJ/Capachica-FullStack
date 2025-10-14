import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../cubit/carrito_cubit.dart';
import '../cubit/carrito_event.dart';
import '../cubit/carrito_state.dart';
import '../../domain/entities/carrito_item.dart';

class CarritoPage extends StatefulWidget {
  const CarritoPage({super.key});

  @override
  State<CarritoPage> createState() => _CarritoPageState();
}

class _CarritoPageState extends State<CarritoPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final cubit = context.read<CarritoCubit>();
        if (!cubit.isClosed) {
          cubit.add(LoadCarrito());
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1419) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Mi Carrito de Planes Turísticos',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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
                  ? [const Color(0xFF0EA5E9), const Color(0xFF38BDF8)]
                  : [const Color(0xFF0EA5E9), const Color(0xFF7DD3FC)],
            ),
          ),
        ),
      ),
      body: BlocBuilder<CarritoCubit, CarritoState>(
        builder: (context, state) {
          if (state is CarritoLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CarritoError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (mounted) {
                        final cubit = context.read<CarritoCubit>();
                        if (!cubit.isClosed) {
                          cubit.add(LoadCarrito());
                        }
                      }
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          if (state is CarritoLoaded) {
            if (state.carrito.isEmpty) {
              return _buildEmptyCarrito(context, isDark);
            }
            return _buildCarritoContent(context, state.carrito, isDark);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildEmptyCarrito(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 100, color: isDark ? Colors.grey[400] : Colors.grey[600]),
          const SizedBox(height: 24),
          Text('Tu carrito está vacío',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.grey[800])),
          const SizedBox(height: 16),
          Text('Agrega algunos servicios para comenzar tu aventura',
              style: TextStyle(fontSize: 16, color: isDark ? Colors.grey[400] : Colors.grey[600]), textAlign: TextAlign.center),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0EA5E9),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Explorar Servicios', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildCarritoContent(BuildContext context, dynamic carrito, bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Revisa y confirma tus planes de turismo seleccionados',
              style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[300] : Colors.grey[600])),
          const SizedBox(height: 12),
          Expanded(
            child: isTablet
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _buildServiciosPanel(context, carrito, isDark)),
                      const SizedBox(width: 16),
                      Expanded(flex: 1, child: _buildResumenPanel(context, carrito, isDark)),
                    ],
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.6, child: _buildServiciosPanel(context, carrito, isDark)),
                        const SizedBox(height: 16),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.4, child: _buildResumenPanel(context, carrito, isDark)),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiciosPanel(BuildContext context, dynamic carrito, bool isDark) {
    return Card(
      elevation: 4,
      shadowColor: isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF0EA5E9),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Icon(Icons.shopping_bag, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Servicios (${carrito.totalServiciosUnicos})',
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.white, size: 20),
                  onPressed: () => _showClearCarritoDialog(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: carrito.items.length,
              itemBuilder: (context, index) {
                final item = carrito.items[index];
                return _buildServicioItem(context, item, isDark);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicioItem(BuildContext context, CarritoItem item, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(color: const Color(0xFF0EA5E9).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Stack(
                    children: [
                      const Center(child: Icon(Icons.business, color: Color(0xFF0EA5E9), size: 24)),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(color: Color(0xFF0EA5E9), shape: BoxShape.circle),
                          child: Center(
                            child: Text('${item.cantidad}',
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.servicio.nombre,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.grey[800]),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFF0EA5E9).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: Text('${item.cantidad} horario${item.cantidad > 1 ? 's' : ''}',
                            style: const TextStyle(color: Color(0xFF0EA5E9), fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showRemoveItemDialog(context, item),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(item.servicio.emprendedor.nombre,
                      style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[300] : Colors.grey[600])),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.schedule, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text('Horarios seleccionados:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.grey[300] : Colors.grey[600])),
              ],
            ),
            const SizedBox(height: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(DateFormat('dd/MM/yyyy').format(item.fechaSeleccionada),
                          style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[300] : Colors.grey[600]),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text('${item.horaInicio} - ${item.horaFin}',
                          style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[300] : Colors.grey[600]),
                          overflow: TextOverflow.ellipsis),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFF0EA5E9).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                      child: Text('${_calculateDuration(item.horaInicio, item.horaFin)}min',
                          style: const TextStyle(color: Color(0xFF0EA5E9), fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Notas: ${item.notas}',
                style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[300] : Colors.grey[600]),
                overflow: TextOverflow.ellipsis,
                maxLines: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenPanel(BuildContext context, dynamic carrito, bool isDark) {
    return Card(
      elevation: 4,
      shadowColor: isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF0EA5E9),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Row(children: const [
              Icon(Icons.description, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(child: Text('Resumen', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildResumenRow(Icons.business, 'Servicios únicos:', '${carrito.totalServiciosUnicos}')
                ,
                const SizedBox(height: 8),
                _buildResumenRow(Icons.schedule, 'Total horarios:', '${carrito.totalItems}')
                ,
                const SizedBox(height: 8),
                Row(children: [
                  const Text('Estado:', style: TextStyle(fontSize: 12)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFF0EA5E9).withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: const [
                      Icon(Icons.schedule, color: Color(0xFF0EA5E9), size: 12),
                      SizedBox(width: 2),
                      Text('Pendiente', style: TextStyle(color: Color(0xFF0EA5E9), fontWeight: FontWeight.bold, fontSize: 10)),
                    ]),
                  ),
                ]),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0EA5E9),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.check, color: Colors.white, size: 18),
                    label: const Text('Confirmar Reserva', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    onPressed: () => _confirmarReserva(context),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 18),
                    label: const Text('Vaciar Carrito', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 14)),
                    onPressed: () => _showClearCarritoDialog(context),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF0EA5E9), size: 18),
                  label: const Text('Continuar agregando servicios', style: TextStyle(color: Color(0xFF0EA5E9), fontWeight: FontWeight.bold, fontSize: 12)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenRow(IconData icon, String label, String value) {
    return Row(children: [
      Icon(icon, size: 16, color: Colors.grey[600]),
      const SizedBox(width: 6),
      Expanded(child: Text(label, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
      Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
    ]);
  }

  String _calculateDuration(String startTime, String endTime) {
    try {
      final start = DateTime.parse('1970-01-01 $startTime');
      final end = DateTime.parse('1970-01-01 $endTime');
      final difference = end.difference(start);
      return difference.inMinutes.toString();
    } catch (_) {
      return '60';
    }
  }

  void _showRemoveItemDialog(BuildContext context, CarritoItem item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar servicio'),
          content: Text('¿Estás seguro de que quieres eliminar "${item.servicio.nombre}" del carrito?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (mounted) {
                  final cubit = context.read<CarritoCubit>();
                  if (!cubit.isClosed) {
                    cubit.add(RemoveItemFromCarrito(item.id));
                  }
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  void _showClearCarritoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Vaciar carrito'),
          content: const Text('¿Estás seguro de que quieres vaciar todo el carrito?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (mounted) {
                  final cubit = context.read<CarritoCubit>();
                  if (!cubit.isClosed) {
                    cubit.add(ClearCarrito());
                  }
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Vaciar'),
            ),
          ],
        );
      },
    );
  }

  void _confirmarReserva(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Función de confirmación de reserva próximamente'),
      backgroundColor: Color(0xFF0EA5E9),
    ));
  }
}


