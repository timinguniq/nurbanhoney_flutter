import 'package:freezed_annotation/freezed_annotation.dart';

// part 'data_fetch_status.freezed.dart';
part 'data_fetch_status.g.dart';

abstract class DataFetchStatus {}

class DataFetchError extends DataFetchStatus {
  DataFetchError(this.error);

  final String error;
}

class DataFetching extends DataFetchStatus {}

@JsonSerializable(genericArgumentFactories: true, explicitToJson: true)
class DataFetchSuccess<T> extends DataFetchStatus {
  DataFetchSuccess({
    this.data,
  });

  factory DataFetchSuccess.fromJson(Map<String, dynamic> json, T Function(Object? json) fromJsonT) =>
      _$DataFetchSuccessFromJson(json, fromJsonT);

  final T? data;

  Map<String, dynamic> toJson(Object Function(T) toJsonT) => _$DataFetchSuccessToJson<T>(this, toJsonT);
}

class DataRefetching<T> extends DataFetchSuccess<T> {
  DataRefetching({super.data});
}

class DataFetchingMore<T> extends DataFetchSuccess<T> {
  DataFetchingMore({super.data});
}
