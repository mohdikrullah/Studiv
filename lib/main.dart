import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'screens/main_screen.dart';
import 'services/local_db_service.dart';
import 'providers/task_provider.dart';
import 'providers/schedule_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalDbService.init();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()..fetchTasks()),
        ChangeNotifierProvider(create: (_) => ScheduleProvider()..loadSchedules()),
      ],
      child: const EduFlowApp(),
    ),
  );
}

class EduFlowApp extends StatelessWidget {
  const EduFlowApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'STUDIV',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainScreen(),
    );
  }
}
