import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'di/injection_container.dart';
import 'l10n/app_localizations.dart';
import 'presentation/pages/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final di = InjectionContainer();
  // Inicializa device identity + anon auth + sync Firestore antes do app subir.
  // Falhas não bloqueiam o boot; o checkCanUseAI() vai capturar offline depois.
  try {
    await di.initializeAsync();
  } catch (_) {}

  runApp(GuIAApp(di: di));
}

class GuIAApp extends StatelessWidget {
  final InjectionContainer di;

  const GuIAApp({super.key, required this.di});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GuIA',
      debugShowCheckedModeBanner: false,
      // Internacionaliza\u00e7\u00e3o: detecta automaticamente o idioma do dispositivo
      // entre pt-BR, en e es. Fallback pra portugu\u00eas se n\u00e3o for nenhum dos 3.
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en'),
        Locale('es'),
      ],
      localeResolutionCallback: (locale, supported) {
        if (locale == null) return const Locale('pt', 'BR');
        for (final s in supported) {
          if (s.languageCode == locale.languageCode) return s;
        }
        return const Locale('pt', 'BR');
      },
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF435892),
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF2EEE7),
        cardTheme: CardThemeData(
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      home: SplashPage(di: di),
    );
  }
}
