// lib/core/widgets/custom_time_picker.dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CustomTimePicker extends StatelessWidget {
  final String label;
  final TimeOfDay? selectedTime;
  final void Function(TimeOfDay) onTimeSelected;
  final String? Function(TimeOfDay?)? validator;

  const CustomTimePicker({
    Key? key,
    required this.label,
    required this.selectedTime,
    required this.onTimeSelected,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FormField<TimeOfDay>(
      initialValue: selectedTime,
      validator: validator,
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => _selectTime(context, field),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: field.hasError
                        ? Colors.red
                        : Colors.grey[300]!,
                    width: field.hasError ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[50],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            selectedTime != null
                                ? selectedTime!.format(context)
                                : 'Seleccionar hora',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: selectedTime != null
                                  ? Colors.black87
                                  : Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 16),
                child: Text(
                  field.errorText!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _selectTime(BuildContext context, FormFieldState<TimeOfDay> field) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null && picked != selectedTime) {
      onTimeSelected(picked);
      field.didChange(picked);
    }
  }
}