import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

const _workerScriptPath = 'image_compression_worker.js';
const _workerTimeout = Duration(seconds: 20);

html.Worker? _worker;
int _requestId = 0;
final Map<int, Completer<Uint8List?>> _pending = <int, Completer<Uint8List?>>{};
bool _isInitialized = false;

Future<Uint8List?> compressImageBytesInWorker(Uint8List imageBytes) async {
  if (!html.Worker.supported) return null;

  final worker = _getOrCreateWorker();
  if (worker == null) return null;

  final id = ++_requestId;
  final completer = Completer<Uint8List?>();
  _pending[id] = completer;

  try {
    worker.postMessage(<String, Object?>{
      'id': id,
      'bytes': imageBytes,
    });
  } catch (_) {
    _pending.remove(id);
    return null;
  }

  try {
    return await completer.future.timeout(_workerTimeout, onTimeout: () {
      _pending.remove(id);
      return null;
    });
  } catch (_) {
    _pending.remove(id);
    return null;
  }
}

html.Worker? _getOrCreateWorker() {
  if (_worker != null) return _worker;

  try {
    _worker = html.Worker(_workerScriptPath);
    _wireWorkerListeners(_worker!);
    _isInitialized = true;
    return _worker;
  } catch (_) {
    _worker = null;
    return null;
  }
}

void _wireWorkerListeners(html.Worker worker) {
  if (_isInitialized) return;

  worker.onMessage.listen((event) {
    final data = event.data;
    if (data is! List || data.length < 3) return;

    final rawId = data[0];
    final id = switch (rawId) {
      int value => value,
      num value => value.toInt(),
      _ => null,
    };
    if (id == null) return;

    final completer = _pending.remove(id);
    if (completer == null || completer.isCompleted) return;

    if (data[2] != null) {
      completer.complete(null);
      return;
    }

    final bytes = data[1];
    if (bytes is Uint8List) {
      completer.complete(bytes);
      return;
    }
    if (bytes is ByteBuffer) {
      completer.complete(bytes.asUint8List());
      return;
    }
    if (bytes is List<int>) {
      completer.complete(Uint8List.fromList(bytes));
      return;
    }

    completer.complete(null);
  });

  worker.onError.listen((_) {
    for (final entry in _pending.entries.toList()) {
      final completer = entry.value;
      if (!completer.isCompleted) {
        completer.complete(null);
      }
    }
    _pending.clear();
    _worker = null;
    _isInitialized = false;
  });
}
