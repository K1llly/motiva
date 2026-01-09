import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_widget_settings.dart';
import '../../domain/usecases/update_widget_appearance.dart';
import 'widget_settings_event.dart';
import 'widget_settings_state.dart';

class WidgetSettingsBloc
    extends Bloc<WidgetSettingsEvent, WidgetSettingsState> {
  final GetWidgetSettings getWidgetSettings;
  final UpdateWidgetAppearance updateWidgetAppearance;

  WidgetSettingsBloc({
    required this.getWidgetSettings,
    required this.updateWidgetAppearance,
  }) : super(const WidgetSettingsInitial()) {
    on<LoadWidgetSettingsEvent>(_onLoadSettings);
    on<UpdateBackgroundColorEvent>(_onUpdateBackgroundColor);
    on<UpdateTextColorEvent>(_onUpdateTextColor);
    on<ToggleGlassModeEvent>(_onToggleGlassMode);
    on<SaveWidgetSettingsEvent>(_onSaveSettings);
  }

  Future<void> _onLoadSettings(
    LoadWidgetSettingsEvent event,
    Emitter<WidgetSettingsState> emit,
  ) async {
    emit(const WidgetSettingsLoading());

    final result = await getWidgetSettings(const NoParams());

    result.fold(
      (failure) => emit(WidgetSettingsError(failure.message)),
      (settings) => emit(WidgetSettingsLoaded(settings: settings)),
    );
  }

  void _onUpdateBackgroundColor(
    UpdateBackgroundColorEvent event,
    Emitter<WidgetSettingsState> emit,
  ) {
    final currentState = state;
    if (currentState is WidgetSettingsLoaded) {
      emit(WidgetSettingsLoaded(
        settings: currentState.settings.copyWith(backgroundColor: event.color),
        hasUnsavedChanges: true,
      ));
    }
  }

  void _onUpdateTextColor(
    UpdateTextColorEvent event,
    Emitter<WidgetSettingsState> emit,
  ) {
    final currentState = state;
    if (currentState is WidgetSettingsLoaded) {
      emit(WidgetSettingsLoaded(
        settings: currentState.settings.copyWith(textColor: event.color),
        hasUnsavedChanges: true,
      ));
    }
  }

  void _onToggleGlassMode(
    ToggleGlassModeEvent event,
    Emitter<WidgetSettingsState> emit,
  ) {
    final currentState = state;
    if (currentState is WidgetSettingsLoaded) {
      emit(WidgetSettingsLoaded(
        settings: currentState.settings.copyWith(
          isGlassModeEnabled: !currentState.settings.isGlassModeEnabled,
        ),
        hasUnsavedChanges: true,
      ));
    }
  }

  Future<void> _onSaveSettings(
    SaveWidgetSettingsEvent event,
    Emitter<WidgetSettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is WidgetSettingsLoaded) {
      emit(WidgetSettingsSaving(settings: currentState.settings));

      final result = await updateWidgetAppearance(
        UpdateWidgetAppearanceParams(settings: currentState.settings),
      );

      result.fold(
        (failure) => emit(WidgetSettingsError(failure.message)),
        (_) => emit(WidgetSettingsLoaded(
          settings: currentState.settings,
          hasUnsavedChanges: false,
        )),
      );
    }
  }
}
