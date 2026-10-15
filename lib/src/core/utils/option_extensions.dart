import 'package:fpdart/fpdart.dart';

extension IterableOptionX<T> on Iterable<T> {
  Option<T> firstWhereOption(final bool Function(T element) test) {
    for (final T element in this) {
      if (test(element)) return some(element);
    }
    return const None();
  }
}

extension OptionX<T> on Option<T> {
  bool exists(final bool Function(T value) test) => match(() => false, test);
}

extension StringOptionX on String {
  Option<String> get nonEmpty => isEmpty ? const None() : some(this);
}
