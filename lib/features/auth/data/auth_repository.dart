import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/user_roles.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../core/network/supabase_client.dart';
import '../../../core/storage/local_cache_service.dart';
import '../../../core/utils/audit_logger.dart';
import '../domain/user_profile_model.dart';

abstract class AuthRepository {
  Future<UserProfile?> getCurrentUser();
  Future<UserProfile> signInWithEmail(String email, String password);
  Future<UserProfile> signUp({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  });
  Future<void> signOut();
  Future<void> sendPasswordReset(String email);
  Future<void> updateProfile(UserProfile profile);
}

class SupabaseAuthRepository implements AuthRepository {
  static const _cachedUserKey = 'auracare_cached_user';

  @override
  Future<UserProfile?> getCurrentUser() async {
    final client = SupabaseService.client;

    if (client != null && client.auth.currentUser != null) {
      try {
        final res = await client
            .from('profiles')
            .select()
            .eq('id', client.auth.currentUser!.id)
            .maybeSingle();

        if (res != null) {
          final profile = UserProfile.fromJson(res);
          await _cacheUser(profile);
          return profile;
        }
      } catch (e) {
        debugPrint('Error fetching remote profile: $e');
      }
    }

    // Try reading cached offline profile
    return _getCachedUser();
  }

  @override
  Future<UserProfile> signInWithEmail(String email, String password) async {
    final client = SupabaseService.client;

    if (client != null && SupabaseService.isInitialized) {
      try {
        final response = await client.auth.signInWithPassword(
          email: email.trim(),
          password: password,
        );

        if (response.user == null) {
          throw const ApiException('Invalid credentials');
        }

        final profileData = await client
            .from('profiles')
            .select()
            .eq('id', response.user!.id)
            .single();

        final profile = UserProfile.fromJson(profileData);
        await _cacheUser(profile);
        await AuditLogger.logAction(
          action: 'LOGIN',
          entity: 'auth',
          entityId: profile.id,
          metadata: {'role': profile.role.code},
        );
        return profile;
      } catch (e) {
        throw ApiException.fromError(e);
      }
    }

    // Local / Dev Fallback: Allows testing without active cloud Supabase
    debugPrint('Authenticating in local developer mode for $email');
    UserRole inferredRole = UserRole.patient;
    if (email.contains('admin')) {
      inferredRole = UserRole.hospitalAdmin;
    } else if (email.contains('doctor') || email.contains('dr.')) {
      inferredRole = UserRole.doctor;
    } else if (email.contains('nurse')) {
      inferredRole = UserRole.nurse;
    } else if (email.contains('pharm')) {
      inferredRole = UserRole.pharmacist;
    }

    final mockUser = UserProfile(
      id: 'local-${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      fullName: email.split('@').first.replaceAll('.', ' ').toUpperCase(),
      role: inferredRole,
      createdAt: DateTime.now(),
    );

    await _cacheUser(mockUser);
    return mockUser;
  }

  @override
  Future<UserProfile> signUp({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  }) async {
    final client = SupabaseService.client;

    if (client != null && SupabaseService.isInitialized) {
      try {
        final response = await client.auth.signUp(
          email: email.trim(),
          password: password,
          data: {
            'full_name': fullName,
            'role': role.code,
          },
        );

        if (response.user == null) {
          throw const ApiException('Failed to create account');
        }

        final newProfile = UserProfile(
          id: response.user!.id,
          email: email,
          fullName: fullName,
          role: role,
          createdAt: DateTime.now(),
        );

        await _cacheUser(newProfile);
        return newProfile;
      } catch (e) {
        throw ApiException.fromError(e);
      }
    }

    // Local fallback
    final mockUser = UserProfile(
      id: 'local-${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      fullName: fullName,
      role: role,
      createdAt: DateTime.now(),
    );
    await _cacheUser(mockUser);
    return mockUser;
  }

  @override
  Future<void> signOut() async {
    final client = SupabaseService.client;
    if (client != null) {
      try {
        await client.auth.signOut();
      } catch (_) {}
    }
    final cache = await LocalCacheService.getInstance();
    await cache.remove(_cachedUserKey);
    await AuditLogger.logAction(action: 'LOGOUT', entity: 'auth');
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    final client = SupabaseService.client;
    if (client != null && SupabaseService.isInitialized) {
      await client.auth.resetPasswordForEmail(email.trim());
    }
  }

  @override
  Future<void> updateProfile(UserProfile profile) async {
    final client = SupabaseService.client;
    if (client != null) {
      await client
          .from('profiles')
          .update(profile.toJson())
          .eq('id', profile.id);
    }
    await _cacheUser(profile);
  }

  Future<void> _cacheUser(UserProfile user) async {
    final cache = await LocalCacheService.getInstance();
    await cache.saveJson(_cachedUserKey, user.toJson());
  }

  Future<UserProfile?> _getCachedUser() async {
    final cache = await LocalCacheService.getInstance();
    final json = cache.getJson(_cachedUserKey);
    if (json != null && json is Map<String, dynamic>) {
      return UserProfile.fromJson(json);
    }
    return null;
  }
}
