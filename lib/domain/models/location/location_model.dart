class LocationModel {
  final int? id;
  final String name;
  final String description;
  final bool? hasRules;

  LocationModel({
    required this.id,
    required this.name,
    required this.description,
    this.hasRules
  });
}