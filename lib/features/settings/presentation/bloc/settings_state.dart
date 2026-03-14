import 'dart:ui';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

class SettingsLoaded extends SettingsState {
  final Locale? locale;
  final ThemeMode themeMode;
  final bool notificationsEnabled;
  final int notificationHour;
  final int notificationMinute;
  final String appFontKey;

  const SettingsLoaded({
    this.locale,
    this.themeMode = ThemeMode.system,
    this.notificationsEnabled = true,
    this.notificationHour = 7,
    this.notificationMinute = 0,
    this.appFontKey = 'classic',
  });

  SettingsLoaded copyWith({
    Locale? locale,
    ThemeMode? themeMode,
    bool? notificationsEnabled,
    int? notificationHour,
    int? notificationMinute,
    String? appFontKey,
  }) {
    return SettingsLoaded(
      locale: locale ?? this.locale,
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationHour: notificationHour ?? this.notificationHour,
      notificationMinute: notificationMinute ?? this.notificationMinute,
      appFontKey: appFontKey ?? this.appFontKey,
    );
  }

  @override
  List<Object?> get props => [
        locale,
        themeMode,
        notificationsEnabled,
        notificationHour,
        notificationMinute,
        appFontKey,
      ];
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError(this.message);

  @override
  List<Object?> get props => [message];
}
