import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/di/service_locator.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://mfaeztthwkkhpyruzdkq.supabase.co',
    anonKey: 'sb_publishable_4b7swvCVtyIqCGD7a9p8aQ_RawDbLzi',
  );

  await di.init();
  runApp(const EcommerceApp());
}
