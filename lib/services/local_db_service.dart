import 'package:hive_flutter/hive_flutter.dart';
import '../models/schedule_model.dart';
import '../models/user_model.dart';
import '../utils/crypto_utils.dart';

class LocalDbService {
  static const String appBoxName = 'appBox';
  static const String usersBoxName = 'usersBox';

  static String? currentUser;
  static Box<ScheduleModel>? _userScheduleBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(ScheduleModelAdapter());
    Hive.registerAdapter(UserModelAdapter());
    
    await Hive.openBox(appBoxName);
    final usersBox = await Hive.openBox(usersBoxName);
    
    // Run backward compatibility migration
    await _migrateOldUserData(usersBox);
  }

  static Box get appBox => Hive.box(appBoxName);
  static Box get usersBox => Hive.box(usersBoxName);

  static Future<void> initUser(String username) async {
    currentUser = username;
    final boxName = 'schedulesBox_$username';
    if (!Hive.isBoxOpen(boxName)) {
      _userScheduleBox = await Hive.openBox<ScheduleModel>(boxName);
    } else {
      _userScheduleBox = Hive.box<ScheduleModel>(boxName);
    }
  }

  static Future<void> closeUser() async {
    if (_userScheduleBox != null && _userScheduleBox!.isOpen) {
      await _userScheduleBox!.close();
    }
    _userScheduleBox = null;
    currentUser = null;
  }

  // Generic Storage Methods (Prefixed per user)
  static Future<void> saveData(String key, dynamic data) async {
    if (currentUser == null) return;
    await appBox.put('${currentUser}_$key', data);
  }

  static dynamic getData(String key) {
    if (currentUser == null) return null;
    return appBox.get('${currentUser}_$key');
  }

  // Schedule Specific
  static Future<void> addSchedule(ScheduleModel schedule) async {
    if (_userScheduleBox == null) return;
    await _userScheduleBox!.put(schedule.id, schedule);
  }

  static List<ScheduleModel> getAllSchedules() {
    if (_userScheduleBox == null) return [];
    return _userScheduleBox!.values.toList();
  }

  static Future<void> deleteSchedule(String id) async {
    if (_userScheduleBox == null) return;
    await _userScheduleBox!.delete(id);
  }

  /// Migrates older dynamic Map user profiles to UserModel objects
  static Future<void> _migrateOldUserData(Box box) async {
    final keys = List.from(box.keys);
    for (var key in keys) {
      final rawData = box.get(key);
      if (rawData is Map) {
        try {
          final userMap = Map<String, dynamic>.from(rawData['user'] ?? {});
          final password = rawData['password'] as String?;
          
          // If the password is not hashed yet, hash it.
          // Standard SHA-256 hash length is 64 hex characters.
          String? hashedPassword;
          if (password != null) {
            hashedPassword = _isSha256(password) ? password : CryptoUtils.sha256(password);
          }

          final migratedUser = UserModel(
            id: userMap['id'] ?? DateTime.now().millisecondsSinceEpoch,
            username: userMap['username'] ?? key.toString(),
            email: userMap['email'] ?? '',
            passwordHash: hashedPassword,
            fullName: userMap['full_name'],
            campus: userMap['campus'],
            semester: userMap['semester'],
            profilePicture: userMap['profile_picture'],
          );

          await box.put(key, migratedUser);
        } catch (e) {
          // Fail silently to prevent startup crashes on corrupted entries
        }
      }
    }
  }

  static bool _isSha256(String str) {
    final reg = RegExp(r'^[a-fA-F0-9]{64}$');
    return reg.hasMatch(str);
  }
}
