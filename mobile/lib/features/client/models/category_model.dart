/// Modèle de catégorie d'appareil pour TechSOS (ex: Smartphones, Ordinateurs...)
class CategoryModel {
  final String id;
  final String name;
  final String? code;
  final String? icon;
  final List<IssueTypeModel> issueTypes;

  const CategoryModel({
    required this.id,
    required this.name,
    this.code,
    this.icon,
    this.issueTypes = const [],
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    List<IssueTypeModel> issues = [];
    if (json['issueTypes'] is List) {
      issues = (json['issueTypes'] as List)
          .whereType<Map<String, dynamic>>()
          .map((i) => IssueTypeModel.fromJson(i))
          .toList();
    }

    return CategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString(),
      icon: json['icon']?.toString(),
      issueTypes: issues,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (code != null) 'code': code,
      if (icon != null) 'icon': icon,
      'issueTypes': issueTypes.map((i) => i.toJson()).toList(),
    };
  }
}

/// Modèle d'un type de panne associé à une catégorie
class IssueTypeModel {
  final String id;
  final String? categoryId;
  final String name;
  final bool isOfficial;

  const IssueTypeModel({
    required this.id,
    this.categoryId,
    required this.name,
    this.isOfficial = true,
  });

  factory IssueTypeModel.fromJson(Map<String, dynamic> json) {
    return IssueTypeModel(
      id: json['id']?.toString() ?? '',
      categoryId: json['categoryId']?.toString(),
      name: json['name']?.toString() ?? '',
      isOfficial: json['isOfficial'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (categoryId != null) 'categoryId': categoryId,
      'name': name,
      'isOfficial': isOfficial,
    };
  }
}
