import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/app.dart';
import 'core/network/dio_client.dart';
import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/favorites/data/datasources/favorites_local_datasource.dart';
import 'features/favorites/data/repositories/favorites_repository.dart';
import 'features/news/data/datasources/news_remote_datasource.dart';
import 'features/news/data/repositories/news_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize local persistent storage: SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // 2. Initialize local offline storage: Hive
  await Hive.initFlutter();
  final favoritesBox = await Hive.openBox<Map>(
    FavoritesLocalDataSourceImpl.boxName,
  );

  // 3. Initialize Network Client: Dio
  final dioClient = DioClient();

  // 4. Initialize Data Sources & Repositories
  final authLocalDataSource = AuthLocalDataSourceImpl(
    sharedPreferences: sharedPreferences,
  );
  final authRepository = AuthRepositoryImpl(
    localDataSource: authLocalDataSource,
  );

  final favoritesLocalDataSource = FavoritesLocalDataSourceImpl(
    favoritesBox: favoritesBox,
  );
  final favoritesRepository = FavoritesRepositoryImpl(
    localDataSource: favoritesLocalDataSource,
  );

  final newsRemoteDataSource = NewsRemoteDataSourceImpl(dioClient: dioClient);
  final newsRepository = NewsRepositoryImpl(
    remoteDataSource: newsRemoteDataSource,
  );

  runApp(
    MiniNewsApp(
      authRepository: authRepository,
      newsRepository: newsRepository,
      favoritesRepository: favoritesRepository,
    ),
  );
}
