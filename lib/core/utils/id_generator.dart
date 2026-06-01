import 'package:uuid/uuid.dart';

/// Utility class for generating unique identifiers.
///
/// Uses UUID v4 (random) for all entity IDs. This keeps IDs consistent
/// whether the app is running locally (Hive) or connected to a remote API.
class IdGenerator {
  IdGenerator._();

  static const _uuid = Uuid();

  /// Generates a new unique ID (UUID v4).
  static String generate() => _uuid.v4();
}
