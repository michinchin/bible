extension TecExtOnIterableInt on Iterable<int> {
  ///
  /// With a sorted list of ints, returns an Iterable of the ints that are missing from the list.
  ///
  /// Why an Iterable instead of a List? Because with an Iterable, each element is not calculated 
  /// until it is needed, making it faster if only the first or first few elements are needed.
  ///
  Iterable<int> missingValues() {
    int prevValue;
    return expand((e) {
      // Save the current value of `prevValue` for use in the generator block. This must be done
      // because `Iterable<int>.generate` generates its elements dynamically, which means that
      // its generator function is not called now, it is called later, when, and if, needed. So,
      // if we used `prevValue` in the generator block, it would be using the future value
      // of `prevValue`, not the current value, which would make the block return the wrong value.
      final bakedPrevValue = prevValue;
      final values = Iterable<int>.generate(
        e - (prevValue ?? e) - 1,
        (i) => i + bakedPrevValue + 1,
      );
      prevValue = e;
      return values;
    });
  }
}
