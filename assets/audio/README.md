Place the incoming call ringtone here:

`ringtone.wav`

The current minimal implementation loads this file from `assets/audio/ringtone.wav`
at runtime and plays it through PJSIP's WAV player. Use a 16-bit PCM mono WAV file
for best compatibility with PJSIP.

`ringing_loop.wav` is the shorter outgoing ringback loop used while an outbound
call is waiting to connect.
