#!/usr/bin/env python3
"""Generate short local keypad feedback WAV files.

The numeric keys use standard DTMF frequency pairs. The plus key is not a
DTMF symbol, so it uses a short single-frequency UI beep instead.
"""

import math
import struct
import wave
from pathlib import Path


SAMPLE_RATE = 8000
DTMF_DURATION_SECONDS = 0.105
PLUS_DURATION_SECONDS = 0.065
FADE_SECONDS = 0.006
DTMF_GAIN = 0.34
PLUS_GAIN = 0.26

DTMF_FREQUENCIES = {
    "1": (697, 1209),
    "2": (697, 1336),
    "3": (697, 1477),
    "4": (770, 1209),
    "5": (770, 1336),
    "6": (770, 1477),
    "7": (852, 1209),
    "8": (852, 1336),
    "9": (852, 1477),
    "*": (941, 1209),
    "0": (941, 1336),
    "#": (941, 1477),
}

FILE_NAMES = {
    "*": "star",
    "#": "hash",
    "+": "plus",
}


def envelope(index: int, total_samples: int) -> float:
    fade_samples = max(1, int(SAMPLE_RATE * FADE_SECONDS))
    if index < fade_samples:
        return index / fade_samples
    remaining = total_samples - index - 1
    if remaining < fade_samples:
        return max(0.0, remaining / fade_samples)
    return 1.0


def write_wav(path: Path, samples: list[int]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(path), "wb") as wav:
        wav.setnchannels(1)
        wav.setsampwidth(2)
        wav.setframerate(SAMPLE_RATE)
        wav.writeframes(b"".join(struct.pack("<h", sample) for sample in samples))


def generate_dtmf(low_freq: int, high_freq: int) -> list[int]:
    total_samples = int(SAMPLE_RATE * DTMF_DURATION_SECONDS)
    samples: list[int] = []
    for index in range(total_samples):
        t = index / SAMPLE_RATE
        value = (
            math.sin(2 * math.pi * low_freq * t)
            + math.sin(2 * math.pi * high_freq * t)
        ) * 0.5
        value *= DTMF_GAIN * envelope(index, total_samples)
        samples.append(round(value * 32767))
    return samples


def generate_plus_beep() -> list[int]:
    total_samples = int(SAMPLE_RATE * PLUS_DURATION_SECONDS)
    samples: list[int] = []
    for index in range(total_samples):
        t = index / SAMPLE_RATE
        # A short UI-only confirmation tone. It intentionally is not DTMF.
        value = math.sin(2 * math.pi * 880 * t)
        value *= PLUS_GAIN * envelope(index, total_samples)
        samples.append(round(value * 32767))
    return samples


def main() -> None:
    root = Path(__file__).resolve().parents[1]
    out_dir = root / "assets" / "audio" / "dtmf_keys"

    for key, (low_freq, high_freq) in DTMF_FREQUENCIES.items():
        name = FILE_NAMES.get(key, key)
        write_wav(out_dir / f"key_{name}.wav", generate_dtmf(low_freq, high_freq))

    write_wav(out_dir / "key_plus.wav", generate_plus_beep())

    print(f"Generated {len(DTMF_FREQUENCIES) + 1} WAV files in {out_dir}")


if __name__ == "__main__":
    main()
