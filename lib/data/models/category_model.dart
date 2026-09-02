class CategoryModel {
  final String id;
  final String name;
  final String imagePath;
  final int productCount;
  final bool isNew;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.imagePath,
    this.productCount = 0,
    this.isNew = false,
  });
}
