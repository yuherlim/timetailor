import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timetailor/core/theme/custom_theme.dart';
import 'package:timetailor/domain/user_management/providers/user_provider.dart';

class StyledButton extends ConsumerWidget {
  final void Function()? onPressed;
  final Widget child;

  const StyledButton({
    super.key,
    this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(isLoadingProvider);

    return TextButton(
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isLoading ? [
              Theme.of(context).disabledColor,
              Theme.of(context).disabledColor,
            ] : [
              AppColors.primaryColor,
              AppColors.primaryAccent,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(15))
        ),
        child: child,
      ),
    );
  }
}
