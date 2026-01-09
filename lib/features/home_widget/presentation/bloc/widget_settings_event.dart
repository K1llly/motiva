import 'package:equatable/equatable.dart';

abstract class WidgetSettingsEvent extends Equatable {
  const WidgetSettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadWidgetSettingsEvent extends WidgetSettingsEvent {
  const LoadWidgetSettingsEvent();
}

class UpdateBackgroundColorEvent extends WidgetSettingsEvent {
  final int color;

  const UpdateBackgroundColorEvent(this.color);

  @override
  List<Object?> get props => [color];
}

class UpdateTextColorEvent extends WidgetSettingsEvent {
  final int color;

  const UpdateTextColorEvent(this.color);

  @override
  List<Object?> get props => [color];
}

class ToggleGlassModeEvent extends WidgetSettingsEvent {
  const ToggleGlassModeEvent();
}

class SaveWidgetSettingsEvent extends WidgetSettingsEvent {
  const SaveWidgetSettingsEvent();
}
