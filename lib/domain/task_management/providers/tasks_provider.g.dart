// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tasks_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tasksNotifierHash() => r'de3e502e39fb5b3b3756dcbbf45737212b86b46d';

/// See also [TasksNotifier].
@ProviderFor(TasksNotifier)
final tasksNotifierProvider =
    AutoDisposeNotifierProvider<TasksNotifier, List<Task>>.internal(
  TasksNotifier.new,
  name: r'tasksNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tasksNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TasksNotifier = AutoDisposeNotifier<List<Task>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package