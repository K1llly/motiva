import 'dart:ui';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

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

class ChangeThemeModeEvent extends SettingsEvent {
  final ThemeMode themeMode;

  const ChangeThemeModeEvent(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}

class ToggleNotificationsEvent extends SettingsEvent {
  final bool enabled;

  const ToggleNotificationsEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class ChangeNotificationTimeEvent extends SettingsEvent {
  final int hour;
  final int minute;

  const ChangeNotificationTimeEvent(this.hour, this.minute);

  @override
  List<Object?> get props => [hour, minute];
}

class ChangeAppFontEvent extends SettingsEvent {
  final String fontKey;

  const ChangeAppFontEvent(this.fontKey);

  @override
  List<Object?> get props => [fontKey];
}
