import '../models/class_model.dart';

/// Abstraction over "how do I join/host a live class". Today only
/// [zoom] and [googleMeet] are implemented (open an external URL).
/// [liveKit] is defined but not yet wired to a real SDK — flip the
/// `liveclass.livekit` feature flag on and implement [LiveClassAdapter]
/// once LiveKit credentials are available. No UI code needs to change.
abstract class LiveClassAdapter {
  Future<void> join(ClassSession session);
  Future<void> host(ClassSession session);
}

class ExternalLinkLiveClassAdapter implements LiveClassAdapter {
  @override
  Future<void> join(ClassSession session) async {
    // Implemented in the UI layer via url_launcher for the external link.
  }

  @override
  Future<void> host(ClassSession session) async {
    // Implemented in the UI layer via url_launcher for the external link.
  }
}

class LiveKitAdapter implements LiveClassAdapter {
  @override
  Future<void> join(ClassSession session) async {
    throw UnimplementedError(
      'LiveKit native video is not yet configured. Add LiveKit server '
      'credentials and implement this adapter, then flip the '
      '"liveclass.livekit" feature flag to Beta/Public.',
    );
  }

  @override
  Future<void> host(ClassSession session) async {
    throw UnimplementedError('LiveKit hosting not yet configured.');
  }
}
