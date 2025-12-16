import 'package:flutter/material.dart';
import 'src/core/config/injection.dart';
import 'supabase/supabase_config.dart';
import 'park_my_whip_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseConfig.initialize();
  setupDependencyInjection();

  runApp(const ParkMyWhipApp());
}
