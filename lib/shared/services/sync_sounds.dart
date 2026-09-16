import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

enum SyncSoundEffect { select, action, complete, restore, delete }

enum SyncSoundLoop { receiptPrinting }

abstract class SyncSoundAssetPlayer {
  Future<void> playAsset(String assetPath, {required double volume});

  SyncSoundLoopHandle startLoopAsset(
    String assetPath, {
    required double volume,
  });
}

abstract class SyncSoundLoopHandle {
  void stop();
}

class AudioplayersSyncSoundAssetPlayer implements SyncSoundAssetPlayer {
  const AudioplayersSyncSoundAssetPlayer();

  @override
  Future<void> playAsset(String assetPath, {required double volume}) async {
    final player = AudioPlayer();
    await player.setReleaseMode(ReleaseMode.release);
    await player.play(AssetSource(assetPath), volume: volume);
  }

  @override
  SyncSoundLoopHandle startLoopAsset(
    String assetPath, {
    required double volume,
  }) {
    final player = AudioPlayer();
    final handle = _AudioplayersSyncSoundLoopHandle(player);
    unawaited(
      () async {
        await player.setReleaseMode(ReleaseMode.loop);
        await player.play(AssetSource(assetPath), volume: volume);
      }().catchError((Object _) {}),
    );
    return handle;
  }
}

class _AudioplayersSyncSoundLoopHandle implements SyncSoundLoopHandle {
  _AudioplayersSyncSoundLoopHandle(this._player);

  final AudioPlayer _player;
  var _stopped = false;

  @override
  void stop() {
    if (_stopped) {
      return;
    }
    _stopped = true;
    unawaited(
      () async {
        await _player.stop();
        await _player.dispose();
      }().catchError((Object _) {}),
    );
  }
}

class _NoopSyncSoundLoopHandle implements SyncSoundLoopHandle {
  const _NoopSyncSoundLoopHandle();

  @override
  void stop() {}
}

class SyncSounds {
  const SyncSounds._();

  static const _minimumSoundGap = Duration(milliseconds: 90);
  static const _effectVolume = 0.32;
  static const _loopVolume = 0.18;

  static bool enabled = true;
  static SyncSoundAssetPlayer _player =
      const AudioplayersSyncSoundAssetPlayer();
  static DateTime Function() _now = DateTime.now;
  static final Map<SyncSoundEffect, DateTime> _lastPlayedAt = {};

  static void play(SyncSoundEffect effect) {
    if (!enabled) {
      return;
    }
    final now = _now();
    final lastPlayedAt = _lastPlayedAt[effect];
    if (lastPlayedAt != null &&
        now.difference(lastPlayedAt) < _minimumSoundGap) {
      return;
    }
    _lastPlayedAt[effect] = now;
    try {
      unawaited(
        _player
            .playAsset(_assetForEffect(effect), volume: _effectVolume)
            .catchError((Object _) {}),
      );
    } catch (_) {
      return;
    }
  }

  static SyncSoundLoopHandle startLoop(SyncSoundLoop loop) {
    if (!enabled) {
      return const _NoopSyncSoundLoopHandle();
    }
    try {
      return _player.startLoopAsset(_assetForLoop(loop), volume: _loopVolume);
    } catch (_) {
      return const _NoopSyncSoundLoopHandle();
    }
  }

  static String _assetForEffect(SyncSoundEffect effect) {
    return switch (effect) {
      SyncSoundEffect.select => 'sounds/select.wav',
      SyncSoundEffect.action => 'sounds/action.wav',
      SyncSoundEffect.complete => 'sounds/complete.wav',
      SyncSoundEffect.restore => 'sounds/restore.wav',
      SyncSoundEffect.delete => 'sounds/delete.wav',
    };
  }

  static String _assetForLoop(SyncSoundLoop loop) {
    return switch (loop) {
      SyncSoundLoop.receiptPrinting => 'sounds/print_loop.wav',
    };
  }

  @visibleForTesting
  static void configureForTesting({
    SyncSoundAssetPlayer? player,
    DateTime Function()? now,
    bool? enabled,
  }) {
    if (player != null) {
      _player = player;
    }
    if (now != null) {
      _now = now;
    }
    if (enabled != null) {
      SyncSounds.enabled = enabled;
    }
    _lastPlayedAt.clear();
  }

  @visibleForTesting
  static void resetForTesting() {
    enabled = true;
    _player = const AudioplayersSyncSoundAssetPlayer();
    _now = DateTime.now;
    _lastPlayedAt.clear();
  }
}
