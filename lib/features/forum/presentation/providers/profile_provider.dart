import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final userHasProfileProvider = FutureProvider<bool>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return false;

  final data = await Supabase.instance.client
      .from('user_profiles')
      .select('id')
      .eq('id', user.id)
      .maybeSingle();

  return data != null;
});
