class StateModel {
  const StateModel(this.name, this.code);
  final String code;
  final String name;

  @override
  String toString() => name;
}