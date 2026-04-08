// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'GuIA';

  @override
  String get appTagline => 'Seu guia inteligente de viagens';

  @override
  String get newSearch => 'Nova busca';

  @override
  String get back => 'Voltar';

  @override
  String get tryAgain => 'Tentar novamente';

  @override
  String get save => 'SALVAR';

  @override
  String get cancel => 'Cancelar';

  @override
  String get discard => 'Descartar';

  @override
  String get clear => 'Limpar';

  @override
  String get close => 'Fechar';

  @override
  String get edit => 'Editar';

  @override
  String get ok => 'OK';

  @override
  String get loading => 'Carregando...';

  @override
  String get useMyLocation => 'Usar minha localização';

  @override
  String get orChooseCity => 'ou escolha uma cidade';

  @override
  String get cityHint => 'Ex: Paris, Tokyo, Nova York...';

  @override
  String get explore => 'Explorar cidade';

  @override
  String get whereToToday => 'Para onde vamos hoje?';

  @override
  String get useLocationOrCity =>
      'Use sua localização atual ou escolha uma cidade para explorar.';

  @override
  String get gettingLocation => 'Obtendo sua localização...';

  @override
  String get findingYouOnMap => 'Encontrando você no mapa...';

  @override
  String get loadingMsg1 => 'Abrindo o mapa do seu destino...';

  @override
  String get loadingMsg2 => 'Tirando a poeira do mapa...';

  @override
  String get loadingMsg3 => 'Buscando os melhores roteiros...';

  @override
  String get loadingMsg4 => 'Garimpando as melhores viagens...';

  @override
  String get loadingMsg5 => 'Consultando guias locais...';

  @override
  String get loadingMsg6 => 'Preparando sugestões incríveis para você...';

  @override
  String get sectionItinerary => 'Seu Roteiro';

  @override
  String get sectionTours => 'Passeios';

  @override
  String get sectionRestaurants => 'Restaurantes';

  @override
  String get sectionTips => 'Dicas do Viajante';

  @override
  String get sectionInterests => 'O que você gosta de fazer?';

  @override
  String get interestHint => 'Ex: bike, sushi, trilha...';

  @override
  String get createPersonalItinerary => 'Criar Roteiro Personalizado';

  @override
  String get creatingItinerary => 'Criando seu roteiro personalizado...';

  @override
  String get generateNewItinerary => 'Gerar novo roteiro';

  @override
  String get editItinerary => 'Editar roteiro';

  @override
  String get discardChanges => 'Descartar alterações?';

  @override
  String get discardChangesBody => 'Você reordenou o roteiro mas não salvou.';

  @override
  String get dragToMove =>
      'Segure e arraste para mover os passeios. Refeições ficam fixas.';

  @override
  String get mealsAreFixed => 'Refeições ficam fixas no horário.';

  @override
  String get noFreeSlot => 'Não há espaço disponível nesse horário.';

  @override
  String routeOptimized(String km) {
    return 'Rota otimizada — $km km no total';
  }

  @override
  String get history => 'Histórico';

  @override
  String get historyTitle => 'Histórico';

  @override
  String get noCitiesYet => 'Nenhuma cidade visitada ainda';

  @override
  String get noItinerariesYet => 'Nenhum roteiro gerado ainda';

  @override
  String get clearHistory => 'Limpar histórico';

  @override
  String get confirmClearCities => 'Deseja apagar todo o histórico de cidades?';

  @override
  String get confirmClearItineraries =>
      'Deseja apagar todos os roteiros salvos?';

  @override
  String get today => 'Hoje';

  @override
  String daysAgo(int n) {
    return '$n dias atrás';
  }

  @override
  String get weatherNow => 'Clima agora';

  @override
  String feelsLike(String temp) {
    return 'Sensação $temp°';
  }

  @override
  String get skyClear => 'Céu limpo';

  @override
  String get skyMostlyClear => 'Predominantemente limpo';

  @override
  String get skyPartlyCloudy => 'Parcialmente nublado';

  @override
  String get skyCloudy => 'Nublado';

  @override
  String get skyFog => 'Neblina';

  @override
  String get skyDrizzle => 'Chuvisco';

  @override
  String get skyRain => 'Chuva';

  @override
  String get skySnow => 'Neve';

  @override
  String get skyShowers => 'Pancadas de chuva';

  @override
  String get skyStorm => 'Tempestade';

  @override
  String get openMapIn => 'Abrir rota em...';

  @override
  String get premiumTitle => 'GuIA Premium';

  @override
  String get premiumSubtitle =>
      'Assine o GuIA Premium para explorar sem limites!';

  @override
  String get subscribeNow => 'Assinar agora';

  @override
  String get perMonth => '/mês';

  @override
  String get bestValue => 'Melhor custo-benefício';

  @override
  String get featureUnlimitedSearches => 'Buscas ilimitadas de cidades';

  @override
  String get featureUnlimitedItineraries => 'Roteiros ilimitados por dia';

  @override
  String get featureLoadMore => 'Carregamento de mais resultados sem limite';

  @override
  String get featureSmartRoute =>
      'Rota inteligente com passeios e restaurantes';

  @override
  String get featureAllPlus => 'Tudo do plano Plus';

  @override
  String get termsOfUse => 'Termos de Uso';

  @override
  String get privacyPolicy => 'Política de Privacidade';

  @override
  String get autoRenewInfo =>
      'Renovação automática, cancele a qualquer momento nas configurações da App Store.';

  @override
  String get subscriptionChargeInfo =>
      'A assinatura será cobrada na sua conta Apple ID.';

  @override
  String get limitReached => 'Você atingiu o limite diário';

  @override
  String limitReachedBody(int limit, String actionName) {
    return 'O plano gratuito permite $limit $actionName por dia. Assine o GuIA Premium para explorar sem limites!';
  }

  @override
  String get actionAiCalls => 'chamadas de IA';

  @override
  String get errorNoInternet => 'Sem conexão com a internet.';

  @override
  String get errorNeedsInternet =>
      'Este recurso precisa de conexão com a internet.';

  @override
  String get errorCheckConnection => 'Verifique sua conexão e tente novamente.';

  @override
  String get errorTimeout => 'A busca demorou demais. Tente novamente.';

  @override
  String get errorTimeoutNetwork =>
      'A busca demorou demais. Verifique sua conexão e tente novamente.';

  @override
  String get errorItineraryTimeout =>
      'A criação do roteiro demorou demais. Tente novamente.';

  @override
  String get errorEmptyResponse =>
      'Resposta vazia do servidor. Tente novamente.';

  @override
  String get errorUnknown => 'Erro desconhecido';

  @override
  String get errorLocationDenied => 'Permissão de localização negada.';

  @override
  String get errorLocationDeniedForever =>
      'Permissão de localização negada permanentemente. Ative nas configurações.';

  @override
  String get errorLocationDisabled => 'Serviço de localização desativado.';

  @override
  String get errorLocationFailed => 'Falha ao obter endereço da localização.';

  @override
  String errorCityNotFound(String city) {
    return 'Cidade \"$city\" não encontrada.';
  }

  @override
  String get errorEmptyCity => 'Nome da cidade não pode ser vazio.';

  @override
  String get errorBuyFailed => 'Erro ao iniciar compra.';

  @override
  String get errorRestoreFailed => 'Erro ao restaurar compras.';

  @override
  String get errorPurchase => 'Erro na compra.';

  @override
  String get errorAppStore => 'Não foi possível conectar à App Store.';

  @override
  String get errorPlansLoad => 'Não foi possível carregar os planos.';

  @override
  String get errorValidatePurchase =>
      'Não foi possível validar sua compra. Tente restaurar.';

  @override
  String get errorValidateUsage =>
      'Não foi possível validar seu uso. Tente novamente.';

  @override
  String get errorIncompleteInit =>
      'Inicialização incompleta. Reabra o app e tente novamente.';
}
