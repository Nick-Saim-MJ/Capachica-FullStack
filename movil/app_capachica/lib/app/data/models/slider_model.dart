class Slider {
  final int id;
  final String title;
  final String? description;
  final String imageUrl;
  final String? linkUrl;
  final bool isActive;
  final int? order;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? urlCompleta;

  Slider({
    required this.id,
    required this.title,
    this.description,
    required this.imageUrl,
    this.linkUrl,
    required this.isActive,
    this.order,
    this.createdAt,
    this.updatedAt,
    this.urlCompleta,
  });

  factory Slider.fromJson(Map<String, dynamic> json) {
    return Slider(
      id: json['id'],
      title: json['nombre'] ?? json['title'] ?? '',
      description: json['descripcion'] ?? json['description'],
      imageUrl: json['image_url'] ?? json['url'] ?? json['imageUrl'] ?? '',
      linkUrl: json['link_url'] ?? json['linkUrl'],
      isActive: json['is_active'] ?? json['activo'] ?? json['isActive'] ?? true,
      order: json['order'] ?? json['orden'],
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at']) 
          : null,
      urlCompleta: json['url_completa'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'link_url': linkUrl,
      'is_active': isActive,
      'order': order,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'url_completa': urlCompleta,
    };
  }
} 