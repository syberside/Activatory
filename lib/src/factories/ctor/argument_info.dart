class ArgumentInfo {
  final Object defaultValue;
  final bool isNamed;
  final Symbol name;
  final Type type;

  ArgumentInfo(
    this.defaultValue,
    this.isNamed,
    this.name,
    this.type,
  );
}
