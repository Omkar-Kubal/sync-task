import 'package:flutter_test/flutter_test.dart';
import 'package:synctasks/shared/services/sync_sounds.dart';

void main() {
  tearDown(SyncSounds.resetForTesting);

  test('routes sound effects to bundled assets', () {
    final player = _FakeSyncSoundAssetPlayer();
    SyncSounds.configureForTesting(player: player);

    SyncSounds.play(SyncSoundEffect.select);
    SyncSounds.play(SyncSoundEffect.action);
    SyncSounds.play(SyncSoundEffect.complete);
    SyncSounds.play(SyncSoundEffect.restore);
    SyncSounds.play(SyncSoundEffect.delete);

    expect(player.plays, [
      'sounds/select.wav',
      'sounds/action.wav',
      'sounds/complete.wav',
      'sounds/restore.wav',
      'sounds/delete.wav',
    ]);
  });

  test('does not play when disabled', () {
    final player = _FakeSyncSoundAssetPlayer();
    SyncSounds.configureForTesting(player: player, enabled: false);

    SyncSounds.play(SyncSoundEffect.complete);

    expect(player.plays, isEmpty);
  });

  test('debounces repeated sound effects', () {
    final player = _FakeSyncSoundAssetPlayer();
    var now = DateTime(2026, 9, 11, 10);
    SyncSounds.configureForTesting(player: player, now: () => now);

    SyncSounds.play(SyncSoundEffect.select);
    now = now.add(const Duration(milliseconds: 20));
    SyncSounds.play(SyncSoundEffect.select);
    now = now.add(const Duration(milliseconds: 120));
    SyncSounds.play(SyncSoundEffect.select);

    expect(player.plays, ['sounds/select.wav', 'sounds/select.wav']);
  });

  test('playback errors do not escape UI flows', () async {
    SyncSounds.configureForTesting(player: _ThrowingSyncSoundAssetPlayer());

    SyncSounds.play(SyncSoundEffect.action);
    await Future<void>.delayed(Duration.zero);
  });

  test('starts receipt printing loop through bundled asset', () {
    final player = _FakeSyncSoundAssetPlayer();
    SyncSounds.configureForTesting(player: player);

    final handle = SyncSounds.startLoop(SyncSoundLoop.receiptPrinting);
    handle.stop();

    expect(player.loops, ['sounds/print_loop.wav']);
    expect(player.loopHandles.single.stopped, isTrue);
  });
}

class _FakeSyncSoundAssetPlayer implements SyncSoundAssetPlayer {
  final plays = <String>[];
  final loops = <String>[];
  final loopHandles = <_FakeSyncSoundLoopHandle>[];

  @override
  Future<void> playAsset(String assetPath, {required double volume}) async {
    plays.add(assetPath);
  }

  @override
  SyncSoundLoopHandle startLoopAsset(
    String assetPath, {
    required double volume,
  }) {
    loops.add(assetPath);
    final handle = _FakeSyncSoundLoopHandle();
    loopHandles.add(handle);
    return handle;
  }
}

class _ThrowingSyncSoundAssetPlayer implements SyncSoundAssetPlayer {
  @override
  Future<void> playAsset(String assetPath, {required double volume}) {
    throw StateError('audio failed');
  }

  @override
  SyncSoundLoopHandle startLoopAsset(
    String assetPath, {
    required double volume,
  }) {
    throw StateError('loop failed');
  }
}

class _FakeSyncSoundLoopHandle implements SyncSoundLoopHandle {
  var stopped = false;

  @override
  void stop() {
    stopped = true;
  }
}
