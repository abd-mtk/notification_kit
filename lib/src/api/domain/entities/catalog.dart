import '../../../core/kits/domain_kit.dart';
import 'enums.dart';

final class CategoryEntity extends Equatable {
  const CategoryEntity({
    required this.key,
    required this.name,
    required this.lane,
    required this.locked,
    required this.defaultEnabled,
    this.androidChannelId = const None(),
    this.description = const None(),
  });

  final String key;

  final Option<String> androidChannelId;

  final String name;

  final Option<String> description;

  final Lane lane;

  final bool locked;

  final bool defaultEnabled;

  String get channelId => androidChannelId.getOrElse(() => key);

  @override
  List<Object> get props => <Object>[key, androidChannelId, name, description, lane, locked, defaultEnabled];
}
