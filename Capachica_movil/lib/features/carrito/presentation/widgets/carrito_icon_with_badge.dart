import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/carrito_cubit.dart';
import '../cubit/carrito_event.dart';
import '../cubit/carrito_state.dart';
import '../pages/carrito_page.dart';

class CarritoIconWithBadge extends StatelessWidget {
  final Color? iconColor;
  final Color? badgeColor;
  final Color? badgeTextColor;

  const CarritoIconWithBadge({super.key, this.iconColor, this.badgeColor, this.badgeTextColor});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CarritoCubit>();
    if (!cubit.isClosed && cubit.state is! CarritoLoaded) {
      cubit.add(LoadCarrito());
    }
    return BlocBuilder<CarritoCubit, CarritoState>(
      builder: (context, state) {
        int itemCount = 0;
        if (state is CarritoLoaded) {
          itemCount = state.carrito.totalItems;
        }
        return Stack(
          children: [
            IconButton(
              icon: Icon(Icons.shopping_cart, color: iconColor ?? Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<CarritoCubit>(),
                      child: const CarritoPage(),
                    ),
                  ),
                );
              },
            ),
            if (itemCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(color: badgeColor ?? Colors.red, borderRadius: BorderRadius.circular(10)),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    itemCount > 99 ? '99+' : itemCount.toString(),
                    style: TextStyle(color: badgeTextColor ?? Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}


