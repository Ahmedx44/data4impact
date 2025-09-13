// lib/core/repository/base_repository.dart
import 'dart:async';
import 'package:hive/hive.dart';
import 'package:data4impact/core/service/app_logger.dart';

class RepositoryException implements Exception {
  RepositoryException(this.message);

  final String message;

  @override
  String toString() => 'RepositoryException: $message';
}

abstract class BaseRepository<T> {
  BaseRepository(this.boxName);
  final String boxName;

  Future<Box<T>> openBox() async {
    return Hive.openBox<T>(boxName);
  }

  Future<List<T>> getAll() async {
    try {
      final box = await openBox();
      return box.values.toList();
    } catch (e, stack) {
      AppLogger.logError('Failed to retrieve all entities', e, stack);
      throw RepositoryException('Failed to retrieve entities: $e');
    }
  }

  Future<T?> getById(String id) async {
    try {
      final box = await openBox();
      return box.get(id);
    } catch (e, stack) {
      AppLogger.logError('Failed to retrieve entity', e, stack);
      throw RepositoryException('Failed to retrieve entity: $e');
    }
  }

  Future<void> add(String id, T entity) async {
    try {
      final box = await openBox();
      await box.put(id, entity);
    } catch (e, stack) {
      AppLogger.logError('Failed to add entity', e, stack);
      throw RepositoryException('Failed to add entity: $e');
    }
  }

  Future<void> addAll(Map<String, T> entities) async {
    try {
      final box = await openBox();
      await box.putAll(entities);
    } catch (e, stack) {
      AppLogger.logError('Failed to add multiple entities', e, stack);
      throw RepositoryException('Failed to add multiple entities: $e');
    }
  }

  Future<void> update(String id, T entity) async {
    try {
      final box = await openBox();
      await box.put(id, entity);
    } catch (e, stack) {
      AppLogger.logError('Failed to update entity', e, stack);
      throw RepositoryException('Failed to update entity: $e');
    }
  }

  Future<void> delete(String id) async {
    try {
      final box = await openBox();
      await box.delete(id);
    } catch (e, stack) {
      AppLogger.logError('Failed to delete entity', e, stack);
      throw RepositoryException('Failed to delete entity: $e');
    }
  }

  Future<void> deleteAll(List<String> ids) async {
    try {
      final box = await openBox();
      await box.deleteAll(ids);
    } catch (e, stack) {
      AppLogger.logError('Failed to delete multiple entities', e, stack);
      throw RepositoryException('Failed to delete multiple entities: $e');
    }
  }

  Future<int> count() async {
    try {
      final box = await openBox();
      return box.length;
    } catch (e, stack) {
      AppLogger.logError('Failed to count entities', e, stack);
      throw RepositoryException('Failed to count entities: $e');
    }
  }

  Future<void> clear() async {
    try {
      final box = await openBox();
      await box.clear();
    } catch (e, stack) {
      AppLogger.logError('Failed to clear repository', e, stack);
      throw RepositoryException('Failed to clear repository: $e');
    }
  }

  Future<bool> exists(String id) async {
    try {
      final box = await openBox();
      return box.containsKey(id);
    } catch (e, stack) {
      AppLogger.logError('Failed to check entity existence', e, stack);
      throw RepositoryException('Failed to check entity existence: $e');
    }
  }

  Future<List<String>> getAllKeys() async {
    try {
      final box = await openBox();
      return box.keys.cast<String>().toList();
    } catch (e, stack) {
      AppLogger.logError('Failed to retrieve keys', e, stack);
      throw RepositoryException('Failed to retrieve keys: $e');
    }
  }
}