import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In pt, this message translates to:
  /// **'GuIA'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In pt, this message translates to:
  /// **'Seu guia inteligente de viagens'**
  String get appTagline;

  /// No description provided for @newSearch.
  ///
  /// In pt, this message translates to:
  /// **'Nova busca'**
  String get newSearch;

  /// No description provided for @back.
  ///
  /// In pt, this message translates to:
  /// **'Voltar'**
  String get back;

  /// No description provided for @tryAgain.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get tryAgain;

  /// No description provided for @save.
  ///
  /// In pt, this message translates to:
  /// **'SALVAR'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @discard.
  ///
  /// In pt, this message translates to:
  /// **'Descartar'**
  String get discard;

  /// No description provided for @clear.
  ///
  /// In pt, this message translates to:
  /// **'Limpar'**
  String get clear;

  /// No description provided for @close.
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get close;

  /// No description provided for @edit.
  ///
  /// In pt, this message translates to:
  /// **'Editar'**
  String get edit;

  /// No description provided for @ok.
  ///
  /// In pt, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @loading.
  ///
  /// In pt, this message translates to:
  /// **'Carregando...'**
  String get loading;

  /// No description provided for @useMyLocation.
  ///
  /// In pt, this message translates to:
  /// **'Usar minha localização'**
  String get useMyLocation;

  /// No description provided for @orChooseCity.
  ///
  /// In pt, this message translates to:
  /// **'ou escolha uma cidade'**
  String get orChooseCity;

  /// No description provided for @cityHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex: Paris, Tokyo, Nova York...'**
  String get cityHint;

  /// No description provided for @explore.
  ///
  /// In pt, this message translates to:
  /// **'Explorar cidade'**
  String get explore;

  /// No description provided for @whereToToday.
  ///
  /// In pt, this message translates to:
  /// **'Para onde vamos hoje?'**
  String get whereToToday;

  /// No description provided for @useLocationOrCity.
  ///
  /// In pt, this message translates to:
  /// **'Use sua localização atual ou escolha uma cidade para explorar.'**
  String get useLocationOrCity;

  /// No description provided for @gettingLocation.
  ///
  /// In pt, this message translates to:
  /// **'Obtendo sua localização...'**
  String get gettingLocation;

  /// No description provided for @findingYouOnMap.
  ///
  /// In pt, this message translates to:
  /// **'Encontrando você no mapa...'**
  String get findingYouOnMap;

  /// No description provided for @loadingMsg1.
  ///
  /// In pt, this message translates to:
  /// **'Abrindo o mapa do seu destino...'**
  String get loadingMsg1;

  /// No description provided for @loadingMsg2.
  ///
  /// In pt, this message translates to:
  /// **'Tirando a poeira do mapa...'**
  String get loadingMsg2;

  /// No description provided for @loadingMsg3.
  ///
  /// In pt, this message translates to:
  /// **'Buscando os melhores roteiros...'**
  String get loadingMsg3;

  /// No description provided for @loadingMsg4.
  ///
  /// In pt, this message translates to:
  /// **'Garimpando as melhores viagens...'**
  String get loadingMsg4;

  /// No description provided for @loadingMsg5.
  ///
  /// In pt, this message translates to:
  /// **'Consultando guias locais...'**
  String get loadingMsg5;

  /// No description provided for @loadingMsg6.
  ///
  /// In pt, this message translates to:
  /// **'Preparando sugestões incríveis para você...'**
  String get loadingMsg6;

  /// No description provided for @sectionItinerary.
  ///
  /// In pt, this message translates to:
  /// **'Seu Roteiro'**
  String get sectionItinerary;

  /// No description provided for @sectionTours.
  ///
  /// In pt, this message translates to:
  /// **'Passeios'**
  String get sectionTours;

  /// No description provided for @sectionRestaurants.
  ///
  /// In pt, this message translates to:
  /// **'Restaurantes'**
  String get sectionRestaurants;

  /// No description provided for @sectionTips.
  ///
  /// In pt, this message translates to:
  /// **'Dicas do Viajante'**
  String get sectionTips;

  /// No description provided for @sectionInterests.
  ///
  /// In pt, this message translates to:
  /// **'O que você gosta de fazer?'**
  String get sectionInterests;

  /// No description provided for @interestHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex: bike, sushi, trilha...'**
  String get interestHint;

  /// No description provided for @createPersonalItinerary.
  ///
  /// In pt, this message translates to:
  /// **'Criar Roteiro Personalizado'**
  String get createPersonalItinerary;

  /// No description provided for @creatingItinerary.
  ///
  /// In pt, this message translates to:
  /// **'Criando seu roteiro personalizado...'**
  String get creatingItinerary;

  /// No description provided for @generateNewItinerary.
  ///
  /// In pt, this message translates to:
  /// **'Gerar novo roteiro'**
  String get generateNewItinerary;

  /// No description provided for @editItinerary.
  ///
  /// In pt, this message translates to:
  /// **'Editar roteiro'**
  String get editItinerary;

  /// No description provided for @discardChanges.
  ///
  /// In pt, this message translates to:
  /// **'Descartar alterações?'**
  String get discardChanges;

  /// No description provided for @discardChangesBody.
  ///
  /// In pt, this message translates to:
  /// **'Você reordenou o roteiro mas não salvou.'**
  String get discardChangesBody;

  /// No description provided for @dragToMove.
  ///
  /// In pt, this message translates to:
  /// **'Segure e arraste para mover os passeios. Refeições ficam fixas.'**
  String get dragToMove;

  /// No description provided for @mealsAreFixed.
  ///
  /// In pt, this message translates to:
  /// **'Refeições ficam fixas no horário.'**
  String get mealsAreFixed;

  /// No description provided for @noFreeSlot.
  ///
  /// In pt, this message translates to:
  /// **'Não há espaço disponível nesse horário.'**
  String get noFreeSlot;

  /// No description provided for @routeOptimized.
  ///
  /// In pt, this message translates to:
  /// **'Rota otimizada — {km} km no total'**
  String routeOptimized(String km);

  /// No description provided for @history.
  ///
  /// In pt, this message translates to:
  /// **'Histórico'**
  String get history;

  /// No description provided for @historyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Histórico'**
  String get historyTitle;

  /// No description provided for @noCitiesYet.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma cidade visitada ainda'**
  String get noCitiesYet;

  /// No description provided for @noItinerariesYet.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum roteiro gerado ainda'**
  String get noItinerariesYet;

  /// No description provided for @clearHistory.
  ///
  /// In pt, this message translates to:
  /// **'Limpar histórico'**
  String get clearHistory;

  /// No description provided for @confirmClearCities.
  ///
  /// In pt, this message translates to:
  /// **'Deseja apagar todo o histórico de cidades?'**
  String get confirmClearCities;

  /// No description provided for @confirmClearItineraries.
  ///
  /// In pt, this message translates to:
  /// **'Deseja apagar todos os roteiros salvos?'**
  String get confirmClearItineraries;

  /// No description provided for @today.
  ///
  /// In pt, this message translates to:
  /// **'Hoje'**
  String get today;

  /// No description provided for @daysAgo.
  ///
  /// In pt, this message translates to:
  /// **'{n} dias atrás'**
  String daysAgo(int n);

  /// No description provided for @weatherNow.
  ///
  /// In pt, this message translates to:
  /// **'Clima agora'**
  String get weatherNow;

  /// No description provided for @feelsLike.
  ///
  /// In pt, this message translates to:
  /// **'Sensação {temp}°'**
  String feelsLike(String temp);

  /// No description provided for @skyClear.
  ///
  /// In pt, this message translates to:
  /// **'Céu limpo'**
  String get skyClear;

  /// No description provided for @skyMostlyClear.
  ///
  /// In pt, this message translates to:
  /// **'Predominantemente limpo'**
  String get skyMostlyClear;

  /// No description provided for @skyPartlyCloudy.
  ///
  /// In pt, this message translates to:
  /// **'Parcialmente nublado'**
  String get skyPartlyCloudy;

  /// No description provided for @skyCloudy.
  ///
  /// In pt, this message translates to:
  /// **'Nublado'**
  String get skyCloudy;

  /// No description provided for @skyFog.
  ///
  /// In pt, this message translates to:
  /// **'Neblina'**
  String get skyFog;

  /// No description provided for @skyDrizzle.
  ///
  /// In pt, this message translates to:
  /// **'Chuvisco'**
  String get skyDrizzle;

  /// No description provided for @skyRain.
  ///
  /// In pt, this message translates to:
  /// **'Chuva'**
  String get skyRain;

  /// No description provided for @skySnow.
  ///
  /// In pt, this message translates to:
  /// **'Neve'**
  String get skySnow;

  /// No description provided for @skyShowers.
  ///
  /// In pt, this message translates to:
  /// **'Pancadas de chuva'**
  String get skyShowers;

  /// No description provided for @skyStorm.
  ///
  /// In pt, this message translates to:
  /// **'Tempestade'**
  String get skyStorm;

  /// No description provided for @openMapIn.
  ///
  /// In pt, this message translates to:
  /// **'Abrir rota em...'**
  String get openMapIn;

  /// No description provided for @premiumTitle.
  ///
  /// In pt, this message translates to:
  /// **'GuIA Premium'**
  String get premiumTitle;

  /// No description provided for @premiumSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Assine o GuIA Premium para explorar sem limites!'**
  String get premiumSubtitle;

  /// No description provided for @subscribeNow.
  ///
  /// In pt, this message translates to:
  /// **'Assinar agora'**
  String get subscribeNow;

  /// No description provided for @perMonth.
  ///
  /// In pt, this message translates to:
  /// **'/mês'**
  String get perMonth;

  /// No description provided for @bestValue.
  ///
  /// In pt, this message translates to:
  /// **'Melhor custo-benefício'**
  String get bestValue;

  /// No description provided for @featureUnlimitedSearches.
  ///
  /// In pt, this message translates to:
  /// **'Buscas ilimitadas de cidades'**
  String get featureUnlimitedSearches;

  /// No description provided for @featureUnlimitedItineraries.
  ///
  /// In pt, this message translates to:
  /// **'Roteiros ilimitados por dia'**
  String get featureUnlimitedItineraries;

  /// No description provided for @featureLoadMore.
  ///
  /// In pt, this message translates to:
  /// **'Carregamento de mais resultados sem limite'**
  String get featureLoadMore;

  /// No description provided for @featureSmartRoute.
  ///
  /// In pt, this message translates to:
  /// **'Rota inteligente com passeios e restaurantes'**
  String get featureSmartRoute;

  /// No description provided for @featureAllPlus.
  ///
  /// In pt, this message translates to:
  /// **'Tudo do plano Plus'**
  String get featureAllPlus;

  /// No description provided for @termsOfUse.
  ///
  /// In pt, this message translates to:
  /// **'Termos de Uso'**
  String get termsOfUse;

  /// No description provided for @privacyPolicy.
  ///
  /// In pt, this message translates to:
  /// **'Política de Privacidade'**
  String get privacyPolicy;

  /// No description provided for @autoRenewInfo.
  ///
  /// In pt, this message translates to:
  /// **'Renovação automática, cancele a qualquer momento nas configurações da App Store.'**
  String get autoRenewInfo;

  /// No description provided for @subscriptionChargeInfo.
  ///
  /// In pt, this message translates to:
  /// **'A assinatura será cobrada na sua conta Apple ID.'**
  String get subscriptionChargeInfo;

  /// No description provided for @limitReached.
  ///
  /// In pt, this message translates to:
  /// **'Você atingiu o limite diário'**
  String get limitReached;

  /// No description provided for @limitReachedBody.
  ///
  /// In pt, this message translates to:
  /// **'O plano gratuito permite {limit} {actionName} por dia. Assine o GuIA Premium para explorar sem limites!'**
  String limitReachedBody(int limit, String actionName);

  /// No description provided for @actionAiCalls.
  ///
  /// In pt, this message translates to:
  /// **'chamadas de IA'**
  String get actionAiCalls;

  /// No description provided for @errorNoInternet.
  ///
  /// In pt, this message translates to:
  /// **'Sem conexão com a internet.'**
  String get errorNoInternet;

  /// No description provided for @errorNeedsInternet.
  ///
  /// In pt, this message translates to:
  /// **'Este recurso precisa de conexão com a internet.'**
  String get errorNeedsInternet;

  /// No description provided for @errorCheckConnection.
  ///
  /// In pt, this message translates to:
  /// **'Verifique sua conexão e tente novamente.'**
  String get errorCheckConnection;

  /// No description provided for @errorTimeout.
  ///
  /// In pt, this message translates to:
  /// **'A busca demorou demais. Tente novamente.'**
  String get errorTimeout;

  /// No description provided for @errorTimeoutNetwork.
  ///
  /// In pt, this message translates to:
  /// **'A busca demorou demais. Verifique sua conexão e tente novamente.'**
  String get errorTimeoutNetwork;

  /// No description provided for @errorItineraryTimeout.
  ///
  /// In pt, this message translates to:
  /// **'A criação do roteiro demorou demais. Tente novamente.'**
  String get errorItineraryTimeout;

  /// No description provided for @errorEmptyResponse.
  ///
  /// In pt, this message translates to:
  /// **'Resposta vazia do servidor. Tente novamente.'**
  String get errorEmptyResponse;

  /// No description provided for @errorUnknown.
  ///
  /// In pt, this message translates to:
  /// **'Erro desconhecido'**
  String get errorUnknown;

  /// No description provided for @errorLocationDenied.
  ///
  /// In pt, this message translates to:
  /// **'Permissão de localização negada.'**
  String get errorLocationDenied;

  /// No description provided for @errorLocationDeniedForever.
  ///
  /// In pt, this message translates to:
  /// **'Permissão de localização negada permanentemente. Ative nas configurações.'**
  String get errorLocationDeniedForever;

  /// No description provided for @errorLocationDisabled.
  ///
  /// In pt, this message translates to:
  /// **'Serviço de localização desativado.'**
  String get errorLocationDisabled;

  /// No description provided for @errorLocationFailed.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao obter endereço da localização.'**
  String get errorLocationFailed;

  /// No description provided for @errorCityNotFound.
  ///
  /// In pt, this message translates to:
  /// **'Cidade \"{city}\" não encontrada.'**
  String errorCityNotFound(String city);

  /// No description provided for @errorEmptyCity.
  ///
  /// In pt, this message translates to:
  /// **'Nome da cidade não pode ser vazio.'**
  String get errorEmptyCity;

  /// No description provided for @errorBuyFailed.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao iniciar compra.'**
  String get errorBuyFailed;

  /// No description provided for @errorRestoreFailed.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao restaurar compras.'**
  String get errorRestoreFailed;

  /// No description provided for @errorPurchase.
  ///
  /// In pt, this message translates to:
  /// **'Erro na compra.'**
  String get errorPurchase;

  /// No description provided for @errorAppStore.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível conectar à App Store.'**
  String get errorAppStore;

  /// No description provided for @errorPlansLoad.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar os planos.'**
  String get errorPlansLoad;

  /// No description provided for @errorValidatePurchase.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível validar sua compra. Tente restaurar.'**
  String get errorValidatePurchase;

  /// No description provided for @errorValidateUsage.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível validar seu uso. Tente novamente.'**
  String get errorValidateUsage;

  /// No description provided for @errorIncompleteInit.
  ///
  /// In pt, this message translates to:
  /// **'Inicialização incompleta. Reabra o app e tente novamente.'**
  String get errorIncompleteInit;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
