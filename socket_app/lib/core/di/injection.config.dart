// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/websocket_chat/data/datasources/websocket_remote_datasource_impl.dart'
    as _i35;
import '../../features/websocket_chat/data/datasources/websocket_remote_datasoure.dart'
    as _i75;
import '../../features/websocket_chat/data/repositories/websocket_repository_impl.dart'
    as _i949;
import '../../features/websocket_chat/domain/repositories/websocket_repository.dart'
    as _i369;
import '../../features/websocket_chat/domain/usecases/connect_websocket.dart'
    as _i790;
import '../../features/websocket_chat/domain/usecases/disconnect_websocket.dart'
    as _i467;
import '../../features/websocket_chat/domain/usecases/send_message.dart'
    as _i97;
import '../../features/websocket_chat/presentation/bloc/web_socket_bloc.dart'
    as _i705;
import '../network/network_info.dart' as _i932;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final connectivityModule = _$ConnectivityModule();
    gh.lazySingleton<_i895.Connectivity>(() => connectivityModule.connectivity);
    gh.lazySingleton<_i75.WebSocketRemoteDataSource>(
      () => _i35.WebSocketRemoteDataSourceImpl(),
    );
    gh.lazySingleton<_i932.NetworkInfo>(
      () => _i932.NetworkInfoImpl(gh<_i895.Connectivity>()),
    );
    gh.lazySingleton<_i369.WebSocketRepository>(
      () => _i949.WebSocketRepositoryImpl(
        gh<_i75.WebSocketRemoteDataSource>(),
        gh<_i932.NetworkInfo>(),
      ),
    );
    gh.lazySingleton<_i790.ConnectWebSocket>(
      () => _i790.ConnectWebSocket(gh<_i369.WebSocketRepository>()),
    );
    gh.lazySingleton<_i467.DisconnectWebSocket>(
      () => _i467.DisconnectWebSocket(gh<_i369.WebSocketRepository>()),
    );
    gh.lazySingleton<_i97.SendMessage>(
      () => _i97.SendMessage(gh<_i369.WebSocketRepository>()),
    );
    gh.factory<_i705.WebSocketBloc>(
      () => _i705.WebSocketBloc(
        gh<_i790.ConnectWebSocket>(),
        gh<_i97.SendMessage>(),
        gh<_i467.DisconnectWebSocket>(),
        gh<_i369.WebSocketRepository>(),
      ),
    );
    return this;
  }
}

class _$ConnectivityModule extends _i932.ConnectivityModule {}
