import 'package:bloc/bloc.dart';
import 'package:digi_hub/Data_Layer/Module/Cache_Memory_Module.dart';
import 'package:equatable/equatable.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(SettingsInitial(isNotificationOn: false)) {
    on<SettingsLoadRequired>(_loadSettings);
    on<SettingsNotificationUpdated>(_updateNotification);
  }

  _updateNotification(
      SettingsNotificationUpdated event, Emitter<SettingsState> emit) async {
    if (state.isNotificationOn) {
      await CacheMemory.cacheMemory.setString('notif', 'false');
      emit(SettingsUpdated(isNotificationOn: false));

      return;
    }
    await CacheMemory.cacheMemory.setString('notif', 'true');
    emit(SettingsUpdated(isNotificationOn: true));
  }

  _loadSettings(SettingsLoadRequired event, emit) {
    if (CacheMemory.cacheMemory.getString('notif') == 'true') {
      emit(SettingsLoaded(isNotificationOn: true));
      return;
    }
    emit(SettingsLoaded(isNotificationOn: false));
  }
}
