Siplet look mechanics

Siplet is a soft sticker-style SIP communication capsule with a stable lower body, planted feet, headset, microphone boom, top antenna, side network nodes, and expressive physical eyes.

Best natural motion:
- Keep the feet, lower capsule body, and center status button anchored at a stable scale and baseline.
- The eyes lead the gaze as physical eye surfaces: eyelids, pupils, highlights, and eye shape move together without adding replacement eyes.
- The face panel and upper capsule subtly yaw or pitch toward the target direction. This should read as attention, not whole-sprite rotation.
- The headset, microphone boom, top antenna, and side network nodes remain attached and follow the upper body with a tiny lag. They must never detach, float, or become separate effects.
- No direction uses labels, arrows, signal arcs, sound waves, shadows, UI marks, text, or extra props.

Cardinal pose families:
- 000 up: feet stay planted; face remains broadly frontal; pupils and eyelids aim toward the top edge; antenna rises/leans slightly upward; mouth can become smaller with upward attention.
- 090 screen-right: face panel and eyes turn toward the viewer's right edge; the right side of the face becomes slightly more visible; nose/mouth/pupil landmarks shift to screen-right of head center; microphone remains attached and follows the face.
- 180 down: face remains broadly frontal; pupils and eyelids aim toward the bottom edge; head dips slightly; antenna compresses subtly; mouth can soften into focused downward attention.
- 270 screen-left: inverse of 090; face panel and eyes turn toward the viewer's left edge; nose/mouth/pupil landmarks shift to screen-left of head center; headset and microphone stay attached.

Motion budget:
- Each 22.5-degree step should change the same parts by a small, even amount.
- Adjacent directions should not jump in scale, baseline, side-node attachment, headset position, or facial identity.
- Diagonals interpolate the nearest cardinal families: up-right and down-right preserve rightward face turn plus vertical eye aim; down-left and up-left preserve leftward face turn plus vertical eye aim.
