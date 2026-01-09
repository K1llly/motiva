import 'package:equatable/equatable.dart';
import '../../domain/entities/widget_settings.dart';

abstract class WidgetSettingsState extends Equatable {
  const WidgetSettingsState();

  @override
  List<Object?> get props => [];
}

class WidgetSettingsInitial extends WidgetSettingsState {
  const WidgetSettingsInitial();
}

class WidgetSettingsLoading extends WidgetSettingsState {
  const WidgetSettingsLoading();
}

class WidgetSettingsLoaded extends WidgetSettingsState {
  final WidgetSettings settings;
  final bool hasUnsavedChanges;

  const WidgetSettingsLoaded({
    required this.settings,
    this.hasUnsavedChanges = false,
  });

  @override
  List<Object?> get props => [settings, hasUnsavedChanges];
}

class WidgetSettingsSaving extends WidgetSettingsState {
  final WidgetSettings settings;

  const WidgetSettingsSaving({required this.settings});

  @override
  List<Object?> get props => [settings];
}

class WidgetSettingsError extends WidgetSettingsState {
  final String message;

  const WidgetSettingsError(this.message);

  @override
  List<Object?> get props => [message];
}
