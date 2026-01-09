import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/settings_repository.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository _repository;

  SettingsBloc(this._repository) : super(const SettingsInitial()) {
    on<LoadSettingsEvent>(_onLoadSettings);
    on<ChangeLanguageEvent>(_onChangeLanguage);
  }

  Future<void> _onLoadSettings(
    LoadSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());
    try {
      final locale = await _repository.getSelectedLocale();
      emit(SettingsLoaded(locale: locale));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onChangeLanguage(
    ChangeLanguageEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _repository.saveSelectedLocale(event.locale);
      emit(SettingsLoaded(locale: event.locale));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }
}
