class LocationModel {
  final int? id;
  final String? ownerUsername;
  final String name;
  final String description;
  final bool? hasRules;

  LocationModel({
    required this.id,
    this.ownerUsername,
    required this.name,
    required this.description,
    this.hasRules
  });
}