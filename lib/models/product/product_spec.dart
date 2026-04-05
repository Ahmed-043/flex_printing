/// A single specification entry for a product (e.g. Size = 100 cm).
class ProductSpec {
  String key;
  String value;
  String unit;

  ProductSpec({
    this.key = '',
    this.value = '',
    this.unit = '',
  });
}
