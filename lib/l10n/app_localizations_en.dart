// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'GuIA';

  @override
  String get appTagline => 'Your smart travel guide';

  @override
  String get newSearch => 'New search';

  @override
  String get back => 'Back';

  @override
  String get tryAgain => 'Try again';

  @override
  String get save => 'SAVE';

  @override
  String get cancel => 'Cancel';

  @override
  String get discard => 'Discard';

  @override
  String get clear => 'Clear';

  @override
  String get close => 'Close';

  @override
  String get edit => 'Edit';

  @override
  String get ok => 'OK';

  @override
  String get loading => 'Loading...';

  @override
  String get useMyLocation => 'Use my location';

  @override
  String get orChooseCity => 'or pick a city';

  @override
  String get cityHint => 'e.g. Paris, Tokyo, New York...';

  @override
  String get explore => 'Explore city';

  @override
  String get whereToToday => 'Where are we going today?';

  @override
  String get useLocationOrCity =>
      'Use your current location or pick a city to explore.';

  @override
  String get gettingLocation => 'Getting your location...';

  @override
  String get findingYouOnMap => 'Finding you on the map...';

  @override
  String get loadingMsg1 => 'Opening the map of your destination...';

  @override
  String get loadingMsg2 => 'Dusting off the map...';

  @override
  String get loadingMsg3 => 'Looking for the best routes...';

  @override
  String get loadingMsg4 => 'Digging up the best trips...';

  @override
  String get loadingMsg5 => 'Asking local guides...';

  @override
  String get loadingMsg6 => 'Preparing amazing suggestions for you...';

  @override
  String get sectionItinerary => 'Your Itinerary';

  @override
  String get sectionTours => 'Tours';

  @override
  String get sectionRestaurants => 'Restaurants';

  @override
  String get sectionTips => 'Traveler Tips';

  @override
  String get sectionInterests => 'What do you like to do?';

  @override
  String get interestHint => 'e.g. bike, sushi, hiking...';

  @override
  String get createPersonalItinerary => 'Create Personal Itinerary';

  @override
  String get creatingItinerary => 'Creating your personal itinerary...';

  @override
  String get generateNewItinerary => 'Generate new itinerary';

  @override
  String get editItinerary => 'Edit itinerary';

  @override
  String get discardChanges => 'Discard changes?';

  @override
  String get discardChangesBody =>
      'You reordered the itinerary but didn\'t save it.';

  @override
  String get dragToMove => 'Hold and drag to move tours. Meals stay fixed.';

  @override
  String get mealsAreFixed => 'Meals stay locked to their time.';

  @override
  String get noFreeSlot => 'No free slot available at that time.';

  @override
  String routeOptimized(String km) {
    return 'Route optimized — $km km total';
  }

  @override
  String get history => 'History';

  @override
  String get historyTitle => 'History';

  @override
  String get noCitiesYet => 'No cities visited yet';

  @override
  String get noItinerariesYet => 'No itineraries generated yet';

  @override
  String get clearHistory => 'Clear history';

  @override
  String get confirmClearCities => 'Delete the entire city history?';

  @override
  String get confirmClearItineraries => 'Delete all saved itineraries?';

  @override
  String get today => 'Today';

  @override
  String daysAgo(int n) {
    return '$n days ago';
  }

  @override
  String get weatherNow => 'Weather now';

  @override
  String feelsLike(String temp) {
    return 'Feels like $temp°';
  }

  @override
  String get skyClear => 'Clear sky';

  @override
  String get skyMostlyClear => 'Mostly clear';

  @override
  String get skyPartlyCloudy => 'Partly cloudy';

  @override
  String get skyCloudy => 'Cloudy';

  @override
  String get skyFog => 'Fog';

  @override
  String get skyDrizzle => 'Drizzle';

  @override
  String get skyRain => 'Rain';

  @override
  String get skySnow => 'Snow';

  @override
  String get skyShowers => 'Showers';

  @override
  String get skyStorm => 'Storm';

  @override
  String get openMapIn => 'Open route in...';

  @override
  String get premiumTitle => 'GuIA Premium';

  @override
  String get premiumSubtitle =>
      'Subscribe to GuIA Premium to explore without limits!';

  @override
  String get subscribeNow => 'Subscribe now';

  @override
  String get perMonth => '/month';

  @override
  String get bestValue => 'Best value';

  @override
  String get featureUnlimitedSearches => 'Unlimited city searches';

  @override
  String get featureUnlimitedItineraries => 'Unlimited itineraries per day';

  @override
  String get featureLoadMore => 'Unlimited result loading';

  @override
  String get featureSmartRoute => 'Smart route with tours and restaurants';

  @override
  String get featureAllPlus => 'Everything in the Plus plan';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get autoRenewInfo =>
      'Auto-renews. Cancel anytime in your App Store settings.';

  @override
  String get subscriptionChargeInfo =>
      'The subscription will be charged to your Apple ID account.';

  @override
  String get limitReached => 'You reached the daily limit';

  @override
  String limitReachedBody(int limit, String actionName) {
    return 'The free plan allows $limit $actionName per day. Subscribe to GuIA Premium to explore without limits!';
  }

  @override
  String get actionAiCalls => 'AI calls';

  @override
  String get errorNoInternet => 'No internet connection.';

  @override
  String get errorNeedsInternet => 'This feature needs an internet connection.';

  @override
  String get errorCheckConnection => 'Check your connection and try again.';

  @override
  String get errorTimeout => 'The search took too long. Try again.';

  @override
  String get errorTimeoutNetwork =>
      'The search took too long. Check your connection and try again.';

  @override
  String get errorItineraryTimeout =>
      'Itinerary creation took too long. Try again.';

  @override
  String get errorEmptyResponse => 'Empty server response. Try again.';

  @override
  String get errorUnknown => 'Unknown error';

  @override
  String get errorLocationDenied => 'Location permission denied.';

  @override
  String get errorLocationDeniedForever =>
      'Location permission permanently denied. Enable it in settings.';

  @override
  String get errorLocationDisabled => 'Location service disabled.';

  @override
  String get errorLocationFailed => 'Failed to get address from your location.';

  @override
  String errorCityNotFound(String city) {
    return 'City \"$city\" not found.';
  }

  @override
  String get errorEmptyCity => 'City name cannot be empty.';

  @override
  String get errorBuyFailed => 'Failed to start the purchase.';

  @override
  String get errorRestoreFailed => 'Failed to restore purchases.';

  @override
  String get errorPurchase => 'Purchase error.';

  @override
  String get errorAppStore => 'Couldn\'t connect to the App Store.';

  @override
  String get errorPlansLoad => 'Couldn\'t load the plans.';

  @override
  String get errorValidatePurchase =>
      'Couldn\'t validate your purchase. Try restoring.';

  @override
  String get errorValidateUsage => 'Couldn\'t validate your usage. Try again.';

  @override
  String get errorIncompleteInit =>
      'Initialization incomplete. Reopen the app and try again.';
}
