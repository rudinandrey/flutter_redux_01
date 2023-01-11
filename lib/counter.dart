class Counter {
  final int count;

  const Counter({required this.count});

  Counter withCopy() => Counter(count: count + 1);
}
