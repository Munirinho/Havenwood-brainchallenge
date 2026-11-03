import 'package:flutter/material.dart';

import '../audio/soundtrack.dart';
import '../theme/haven_theme.dart';
import 'haven_widgets.dart';

class SoundtrackToggleButton extends StatelessWidget {
  final double size;
  final Color? color;

  const SoundtrackToggleButton({super.key, this.size = 44, this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: SoundtrackPlayer.instance,
      builder: (context, _) {
        final player = SoundtrackPlayer.instance;
        return HavenIconButton(
          icon: player.muted
              ? Icons.music_off_rounded
              : Icons.music_note_rounded,
          color: player.muted ? HavenColors.mist : (color ?? HavenColors.mint),
          size: size,
          tooltip: player.muted
              ? 'Soundscape off'
              : 'Soundscape · ${player.currentName}',
          onPressed: player.toggleMute,
        );
      },
    );
  }
}
