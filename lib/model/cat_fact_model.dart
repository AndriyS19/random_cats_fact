class CatFactModel {
  final int? id;
  final String fact;
  final String imageUrl;
  final String savedAt;

  CatFactModel({
    this.id,
    required this.fact,
    required this.imageUrl,
    required this.savedAt,
  });

  String get localImagePath {
    final fileName = imageUrl.split('/').last;
    return '/data/user/0/com.example.random_cat_facts/app_flutter/$fileName';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fact': fact,
      'imageUrl': imageUrl,
      'savedAt': savedAt,
    };
  }

  factory CatFactModel.fromMap(Map<String, dynamic> map) {
    return CatFactModel(
      id: map['id'],
      fact: map['fact'],
      imageUrl: map['imageUrl'],
      savedAt: map['savedAt'],
    );
  }

  CatFactModel copyWith({
    int? id,
    String? fact,
    String? imageUrl,
    String? savedAt,
  }) {
    return CatFactModel(
      id: id ?? this.id,
      fact: fact ?? this.fact,
      imageUrl: imageUrl ?? this.imageUrl,
      savedAt: savedAt ?? this.savedAt,
    );
  }
}

class CatApiResponse {
  final String fact;
  final String imageUrl;

  CatApiResponse({
    required this.fact,
    required this.imageUrl,
  });

  factory CatApiResponse.fromMap(Map<String, dynamic> map) {
    return CatApiResponse(
      fact: map['fact'] as String,
      imageUrl: map['imageUrl'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fact': fact,
      'imageUrl': imageUrl,
    };
  }
}
