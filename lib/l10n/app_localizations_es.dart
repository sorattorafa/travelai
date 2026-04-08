// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'GuIA';

  @override
  String get appTagline => 'Tu guía inteligente de viajes';

  @override
  String get newSearch => 'Nueva búsqueda';

  @override
  String get back => 'Volver';

  @override
  String get tryAgain => 'Intentar de nuevo';

  @override
  String get save => 'GUARDAR';

  @override
  String get cancel => 'Cancelar';

  @override
  String get discard => 'Descartar';

  @override
  String get clear => 'Limpiar';

  @override
  String get close => 'Cerrar';

  @override
  String get edit => 'Editar';

  @override
  String get ok => 'OK';

  @override
  String get loading => 'Cargando...';

  @override
  String get useMyLocation => 'Usar mi ubicación';

  @override
  String get orChooseCity => 'o elige una ciudad';

  @override
  String get cityHint => 'Ej: París, Tokio, Nueva York...';

  @override
  String get explore => 'Explorar ciudad';

  @override
  String get whereToToday => '¿Adónde vamos hoy?';

  @override
  String get useLocationOrCity =>
      'Usa tu ubicación actual o elige una ciudad para explorar.';

  @override
  String get gettingLocation => 'Obteniendo tu ubicación...';

  @override
  String get findingYouOnMap => 'Encontrándote en el mapa...';

  @override
  String get loadingMsg1 => 'Abriendo el mapa de tu destino...';

  @override
  String get loadingMsg2 => 'Quitándole el polvo al mapa...';

  @override
  String get loadingMsg3 => 'Buscando las mejores rutas...';

  @override
  String get loadingMsg4 => 'Cazando los mejores viajes...';

  @override
  String get loadingMsg5 => 'Consultando guías locales...';

  @override
  String get loadingMsg6 => 'Preparando sugerencias increíbles para ti...';

  @override
  String get sectionItinerary => 'Tu Itinerario';

  @override
  String get sectionTours => 'Paseos';

  @override
  String get sectionRestaurants => 'Restaurantes';

  @override
  String get sectionTips => 'Consejos del Viajero';

  @override
  String get sectionInterests => '¿Qué te gusta hacer?';

  @override
  String get interestHint => 'Ej: bici, sushi, senderismo...';

  @override
  String get createPersonalItinerary => 'Crear Itinerario Personal';

  @override
  String get creatingItinerary => 'Creando tu itinerario personal...';

  @override
  String get generateNewItinerary => 'Generar nuevo itinerario';

  @override
  String get editItinerary => 'Editar itinerario';

  @override
  String get discardChanges => '¿Descartar cambios?';

  @override
  String get discardChangesBody =>
      'Reordenaste el itinerario pero no lo guardaste.';

  @override
  String get dragToMove =>
      'Mantén pulsado y arrastra para mover los paseos. Las comidas quedan fijas.';

  @override
  String get mealsAreFixed => 'Las comidas quedan fijas en su horario.';

  @override
  String get noFreeSlot => 'No hay espacio disponible en ese horario.';

  @override
  String routeOptimized(String km) {
    return 'Ruta optimizada — $km km en total';
  }

  @override
  String get history => 'Historial';

  @override
  String get historyTitle => 'Historial';

  @override
  String get noCitiesYet => 'Aún no hay ciudades visitadas';

  @override
  String get noItinerariesYet => 'Aún no hay itinerarios generados';

  @override
  String get clearHistory => 'Limpiar historial';

  @override
  String get confirmClearCities => '¿Borrar todo el historial de ciudades?';

  @override
  String get confirmClearItineraries =>
      '¿Borrar todos los itinerarios guardados?';

  @override
  String get today => 'Hoy';

  @override
  String daysAgo(int n) {
    return 'hace $n días';
  }

  @override
  String get weatherNow => 'Clima ahora';

  @override
  String feelsLike(String temp) {
    return 'Sensación $temp°';
  }

  @override
  String get skyClear => 'Cielo despejado';

  @override
  String get skyMostlyClear => 'Mayormente despejado';

  @override
  String get skyPartlyCloudy => 'Parcialmente nublado';

  @override
  String get skyCloudy => 'Nublado';

  @override
  String get skyFog => 'Niebla';

  @override
  String get skyDrizzle => 'Llovizna';

  @override
  String get skyRain => 'Lluvia';

  @override
  String get skySnow => 'Nieve';

  @override
  String get skyShowers => 'Chubascos';

  @override
  String get skyStorm => 'Tormenta';

  @override
  String get openMapIn => 'Abrir ruta en...';

  @override
  String get premiumTitle => 'GuIA Premium';

  @override
  String get premiumSubtitle =>
      '¡Suscríbete a GuIA Premium para explorar sin límites!';

  @override
  String get subscribeNow => 'Suscribirme ahora';

  @override
  String get perMonth => '/mes';

  @override
  String get bestValue => 'Mejor relación calidad-precio';

  @override
  String get featureUnlimitedSearches => 'Búsquedas de ciudades ilimitadas';

  @override
  String get featureUnlimitedItineraries => 'Itinerarios ilimitados por día';

  @override
  String get featureLoadMore => 'Carga ilimitada de más resultados';

  @override
  String get featureSmartRoute => 'Ruta inteligente con paseos y restaurantes';

  @override
  String get featureAllPlus => 'Todo lo del plan Plus';

  @override
  String get termsOfUse => 'Términos de uso';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get autoRenewInfo =>
      'Renovación automática. Cancela cuando quieras en los ajustes de la App Store.';

  @override
  String get subscriptionChargeInfo =>
      'La suscripción se cargará a tu cuenta de Apple ID.';

  @override
  String get limitReached => 'Alcanzaste el límite diario';

  @override
  String limitReachedBody(int limit, String actionName) {
    return 'El plan gratuito permite $limit $actionName por día. ¡Suscríbete a GuIA Premium para explorar sin límites!';
  }

  @override
  String get actionAiCalls => 'llamadas de IA';

  @override
  String get errorNoInternet => 'Sin conexión a internet.';

  @override
  String get errorNeedsInternet => 'Esta función necesita conexión a internet.';

  @override
  String get errorCheckConnection =>
      'Comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get errorTimeout => 'La búsqueda tardó demasiado. Inténtalo de nuevo.';

  @override
  String get errorTimeoutNetwork =>
      'La búsqueda tardó demasiado. Comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get errorItineraryTimeout =>
      'La creación del itinerario tardó demasiado. Inténtalo de nuevo.';

  @override
  String get errorEmptyResponse =>
      'Respuesta vacía del servidor. Inténtalo de nuevo.';

  @override
  String get errorUnknown => 'Error desconocido';

  @override
  String get errorLocationDenied => 'Permiso de ubicación denegado.';

  @override
  String get errorLocationDeniedForever =>
      'Permiso de ubicación denegado permanentemente. Actívalo en ajustes.';

  @override
  String get errorLocationDisabled => 'Servicio de ubicación desactivado.';

  @override
  String get errorLocationFailed =>
      'No se pudo obtener la dirección de tu ubicación.';

  @override
  String errorCityNotFound(String city) {
    return 'Ciudad \"$city\" no encontrada.';
  }

  @override
  String get errorEmptyCity => 'El nombre de la ciudad no puede estar vacío.';

  @override
  String get errorBuyFailed => 'Error al iniciar la compra.';

  @override
  String get errorRestoreFailed => 'Error al restaurar las compras.';

  @override
  String get errorPurchase => 'Error en la compra.';

  @override
  String get errorAppStore => 'No se pudo conectar a la App Store.';

  @override
  String get errorPlansLoad => 'No se pudieron cargar los planes.';

  @override
  String get errorValidatePurchase =>
      'No se pudo validar tu compra. Intenta restaurar.';

  @override
  String get errorValidateUsage =>
      'No se pudo validar tu uso. Inténtalo de nuevo.';

  @override
  String get errorIncompleteInit =>
      'Inicialización incompleta. Reabre la app e inténtalo de nuevo.';
}
