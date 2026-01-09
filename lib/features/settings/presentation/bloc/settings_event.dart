import 'dart:ui';
import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettingsEvent extends SettingsEvent {
  const LoadSettingsEvent();
}

class ChangeLanguageEvent extends SettingsEvent {
  final Locale locale;

  const ChangeLanguageEvent(this.locale);

  @override
  List<Object?> get props => [locale];
}
