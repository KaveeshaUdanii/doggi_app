class DogBreed {
  final String name;
  final String imageUrl;
  final String temperament;
  final String lifeSpan;

  DogBreed({
    required this.name,
    required this.imageUrl,
    required this.temperament,
    required this.lifeSpan,
  });

  factory DogBreed.fromJson(Map<String, dynamic> json) {
    return DogBreed(
      name: json['name'],
      imageUrl: json['image'] != null ? json['image']['url'] : '',
      temperament: json['temperament'] ?? 'Unknown',
      lifeSpan: json['life_span'] ?? 'Unknown',
    );
  }
}
