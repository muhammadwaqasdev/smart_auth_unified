typedef OfflineTask = Future<void> Function();

class OfflineQueue {
  final List<OfflineTask> _queue = <OfflineTask>[];
  bool _isReplaying = false;

  void enqueue(OfflineTask task) {
    _queue.add(task);
  }

  bool get hasPending => _queue.isNotEmpty;

  Future<void> replay() async {
    if (_isReplaying) return;
    _isReplaying = true;
    try {
      while (_queue.isNotEmpty) {
        final task = _queue.removeAt(0);
        await task();
      }
    } finally {
      _isReplaying = false;
    }
  }
}
