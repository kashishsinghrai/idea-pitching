class FounderProfile {
  final String name;
  final String title;
  final String bio;
  final String initial;

  const FounderProfile({
    required this.name,
    required this.title,
    required this.bio,
    required this.initial,
  });

  factory FounderProfile.fromApi(Map<String, dynamic> json) {
    final Map<String, dynamic> profile = json['profile'] != null 
        ? Map<String, dynamic>.from(json['profile'] as Map) 
        : <String, dynamic>{};
    final firstName = profile['firstName'] ?? 'Founder';
    final lastName = profile['lastName'] ?? '';
    final fullName = '$firstName $lastName'.trim();
    
    return FounderProfile(
      name: fullName,
      title: 'Founder',
      bio: '', // Bio isn't in backend yet
      initial: fullName.isNotEmpty ? fullName[0].toUpperCase() : 'F',
    );
  }
}

class StartupDeal {
  final String id;
  final String name;
  final String tagline;
  final String industry;
  final String stage;
  final String location;
  final double askAmount; 
  final double valuation; 
  final String logoInitial;
  final String description;
  final String status;
  final FounderProfile founder;

  const StartupDeal({
    required this.id,
    required this.name,
    required this.tagline,
    required this.industry,
    required this.stage,
    required this.location,
    required this.askAmount,
    required this.valuation,
    required this.logoInitial,
    required this.description,
    required this.status,
    required this.founder,
  });

  factory StartupDeal.fromApi(Map<String, dynamic> json) {
    final Map<String, dynamic> founderData = json['founder'] != null 
        ? Map<String, dynamic>.from(json['founder'] as Map) 
        : <String, dynamic>{};
    final name = json['startupName'] ?? 'Unknown Startup';

    return StartupDeal(
      id: json['id']?.toString() ?? '',
      name: name,
      tagline: json['tagline'] ?? '',
      industry: json['industry'] ?? '',
      stage: json['stage'] ?? '',
      location: 'Remote', // Add this to backend later if needed
      askAmount: (json['askAmount'] as num?)?.toDouble() ?? 0.0,
      valuation: (json['valuation'] as num?)?.toDouble() ?? 0.0,
      logoInitial: name.isNotEmpty ? name[0].toUpperCase() : 'U',
      description: json['description'] ?? '',
      status: json['status'] ?? 'PENDING',
      founder: FounderProfile.fromApi(founderData),
    );
  }
}
