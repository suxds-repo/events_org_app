import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockUser extends Mock implements User {}

class MockAuthResponse extends Mock implements GoTrueClient {}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder {}
