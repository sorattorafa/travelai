enum StepType { tour, restaurant, transport, tip }

/// Classifica\u00e7\u00e3o sem\u00e2ntica da refei\u00e7\u00e3o (\u00e2ncora fixa no roteiro).
enum MealSlot { breakfast, lunch, dinner }

class ItineraryStep {
  final int order;
  final String name;
  final String description;
  final String time;        // ex: "09:00" ou "Manh\u00e3"
  final String duration;    // ex: "1h30"
  final StepType type;
  final String? address;
  final String? transport;  // ex: "10 min a p\u00e9", "Metr\u00f4 linha 2"
  final double? latitude;
  final double? longitude;
  final MealSlot? mealSlot; // se != null, passo \u00e9 \u00e2ncora fixa

  const ItineraryStep({
    required this.order,
    required this.name,
    required this.description,
    required this.time,
    required this.duration,
    required this.type,
    this.address,
    this.transport,
    this.latitude,
    this.longitude,
    this.mealSlot,
  });

  bool get isFixed => mealSlot != null;
  bool get hasCoords => latitude != null && longitude != null;

  ItineraryStep copyWith({
    int? order,
    String? name,
    String? description,
    String? time,
    String? duration,
    StepType? type,
    String? address,
    String? transport,
    double? latitude,
    double? longitude,
    MealSlot? mealSlot,
  }) {
    return ItineraryStep(
      order: order ?? this.order,
      name: name ?? this.name,
      description: description ?? this.description,
      time: time ?? this.time,
      duration: duration ?? this.duration,
      type: type ?? this.type,
      address: address ?? this.address,
      transport: transport ?? this.transport,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      mealSlot: mealSlot ?? this.mealSlot,
    );
  }

  factory ItineraryStep.fromJson(Map<String, dynamic> json) {
    return ItineraryStep(
      order: (json['order'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      time: json['time'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      type: StepType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => StepType.tour,
      ),
      address: json['address'] as String?,
      transport: json['transport'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      mealSlot: json['mealSlot'] != null
          ? MealSlot.values.firstWhere(
              (m) => m.name == json['mealSlot'],
              orElse: () => MealSlot.lunch,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'order': order,
        'name': name,
        'description': description,
        'time': time,
        'duration': duration,
        'type': type.name,
        'address': address,
        'transport': transport,
        'latitude': latitude,
        'longitude': longitude,
        'mealSlot': mealSlot?.name,
      };
}

class Itinerary {
  final String title;
  final String summary;
  final List<ItineraryStep> steps;

  const Itinerary({
    required this.title,
    required this.summary,
    required this.steps,
  });

  Itinerary copyWith({
    String? title,
    String? summary,
    List<ItineraryStep>? steps,
  }) {
    return Itinerary(
      title: title ?? this.title,
      summary: summary ?? this.summary,
      steps: steps ?? this.steps,
    );
  }

  factory Itinerary.fromJson(Map<String, dynamic> json) {
    return Itinerary(
      title: json['title'] as String? ?? 'Roteiro',
      summary: json['summary'] as String? ?? '',
      steps: (json['steps'] as List)
          .map((s) => ItineraryStep.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'summary': summary,
        'steps': steps.map((s) => s.toJson()).toList(),
      };
}
