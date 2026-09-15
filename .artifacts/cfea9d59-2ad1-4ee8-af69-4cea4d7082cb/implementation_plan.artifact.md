# خطة تنفيذ التصميم المتجاوب (Responsive Design) الشامل

تهدف هذه الخطة إلى جعل جميع شاشات التطبيق متجاوبة تماماً مع مختلف أحجام الشاشات (هواتف، أجهزة لوحية) باستخدام مكتبة `responsive_framework` مع الحفاظ على تناسق العناصر دون تغيير مقاساتها الأصلية يدوياً في كل مكان.

## ما الذي سيتم تغييره
سنقوم بتحويل التصميم من تصميم ثابت (Static) إلى تصميم مرن (Adaptive/Responsive) من خلال:
1. **توسيع نظام التحجيم**: التأكد من أن جميع الشاشات تتبع نظام `ResponsiveScaledBox` العالمي.
2. **تكييف الشبكات (Grids)**: جعل عدد الأعمدة في قوائم المنتجات يتغير تلقائياً حسب عرض الشاشة.
3. **إزالة المقاسات الثابتة المعيقة**: استبدال العروض (Widths) الثابتة بـ `double.infinity` أو `Expanded` لتملأ المساحة المتاحة بمرونة.

## المقترحات التقنية

### [Core]
#### [MODIFY] [app.dart](file:///C:/Users/Taher/StudioProjects/ecommerce/lib/app.dart)
* ضبط نقاط التوقف (Breakpoints) بدقة لدعم الأجهزة اللوحية بشكل أفضل.

### [Presentation - Home]
#### [MODIFY] [home_view.dart](file:///C:/Users/Taher/StudioProjects/ecommerce/lib/presentation/home/view/home_view.dart)
* تحديث `GridView` لزيادة عدد الأعمدة على الشاشات الكبيرة.
* جعل البانر (Banner) متجاوباً في الارتفاع.

### [Presentation - Categories]
#### [MODIFY] [categories_view.dart](file:///C:/Users/Taher/StudioProjects/ecommerce/lib/presentation/categories/view/categories_view.dart)
* إزالة المقاسات الثابتة من بطاقات الأقسام (Category Cards).
* جعل الشبكة (Grid) متجاوبة.

### [Presentation - Product Details]
#### [MODIFY] [all_products_view.dart](file:///C:/Users/Taher/StudioProjects/ecommerce/lib/presentation/product_details/view/all_products_view.dart)
* تحديث عدد أعمدة المنتجات ليكون 2 في الموبايل و 3-4 في التابلت.
#### [MODIFY] [product_details_view.dart](file:///C:/Users/Taher/StudioProjects/ecommerce/lib/presentation/product_details/view/product_details_view.dart)
* ضبط ارتفاع صورة المنتج لتكون متناسبة (Proportional) بدلاً من قيمة ثابتة كبيرة جداً على التابلت.

### [Presentation - Cart]
#### [MODIFY] [cart_view.dart](file:///C:/Users/Taher/StudioProjects/ecommerce/lib/presentation/cart/view/cart_view.dart)
* ضمان مرونة عناصر السلة (Cart Items) عند تغيير عرض الشاشة.

### [Presentation - Widgets]
#### [MODIFY] [product_card.dart](file:///C:/Users/Taher/StudioProjects/ecommerce/lib/presentation/home/widgets/product_card.dart)
* جعل عرض البطاقة مرناً عند استخدامه داخل Grid.

## خطة التحقق (Verification Plan)
1. **التحقق البصري**: اختبار الشاشات على مقاسات محاكاة (Phone & Tablet) في IDE.
2. **فحص الـ Overflow**: التأكد من عدم ظهور خطوط صفراء وسوداء (Layout Overflow) عند تدوير الشاشة.
