+++
title = "From Sound Waves to Spectrograms: The Physics & Signal Processing of Speech AI"
date = '2026-09-12T20:30:00+05:30'
slug = "physics-of-sound-to-spectrograms-speech-ai"
draft = false
author = "Siva Madhavan"
description = "Understanding how continuous acoustic pressure waves become discrete Mel-frequency spectrograms before feeding into Whisper and real-time speech models."
tags = ["Science", "Physics", "Acoustics", "Signal Processing", "Speech Recognition", "Fourier Transform"]
categories = ["Science"]
showToc = true
TocOpen = false
+++

When a clinician speaks during a telehealth consultation, the microphone diaphragm converts vibrating air molecules into a continuous electrical voltage signal.

Yet neural networks (like Whisper or Azure Speech Services) do not operate on raw 1D audio waveforms. Instead, they "look" at audio as 2D images called **Mel Spectrograms**.

How does physical sound transform into a frequency visual? Here is the journey through acoustic physics and signal processing.

---

## 1. The Physics of Sound: Pressure Perturbations

Sound is a mechanical longitudinal wave. When vocal cords vibrate, they compress and rarify surrounding air molecules, producing periodic fluctuations in atmospheric pressure:

$$P(t) = P_0 + \Delta P \sin(2\pi f t + \phi)$$

Where:
- $f$ is frequency (pitch), measured in Hertz (Hz).
- $\Delta P$ is pressure amplitude (perceived volume).
- Human speech contains a fundamental frequency $F_0$ (typically 85 Hz to 255 Hz) and dozens of harmonic overtones (formants) extending up to 8 kHz.

---

## 2. Analog-to-Digital Conversion: The Nyquist-Shannon Theorem

To process sound digitally, we sample the continuous wave at discrete time intervals:
- **Sampling Rate ($F_s$)**: Typically 16,000 samples per second (16 kHz) for telephony and speech recognition.
- **Bit Depth**: 16-bit PCM (Pulse Code Modulation), providing $2^{16} = 65,536$ discrete amplitude levels.

According to the **Nyquist-Shannon Sampling Theorem**, to capture frequencies up to $f_{\max}$, the sampling rate must satisfy:

$$F_s \ge 2 f_{\max}$$

At 16 kHz sampling, our system can accurately represent frequencies up to 8,000 Hz, which comfortably encompasses the entire audible speech formant spectrum.

---

## 3. Short-Time Fourier Transform (STFT)

A raw audio waveform tells us *how loud* the sound is at any instant, but reveals nothing about *which frequencies* are present.

The **Fourier Transform** decomposes a signal into its constituent sinusoidal frequencies:

$$\hat{x}(f) = \int_{-\infty}^{\infty} x(t) e^{-i 2\pi f t} dt$$

However, a standard Fourier Transform computes frequencies across the entire recording, losing all temporal timing. To know *when* a specific syllable was uttered, we apply the **Short-Time Fourier Transform (STFT)**:

1. Slide a short window (e.g., 25ms, called a Hann Window) across the audio with a 10ms hop step.
2. Apply the Fast Fourier Transform (FFT) on each individual chunk.
3. Stack the resulting frequency spectra vertically across time to produce a 2D **Spectrogram**.

---

## 4. The Mel Scale: Modeling Human Auditory Perception

Human ears do not perceive pitch linearly. We are exquisitely sensitive to small pitch differences at low frequencies (below 1 kHz), but comparatively insensitive to changes above 4 kHz.

In 1937, Stevens, Volkmann, and Newman developed the **Mel Scale** to map physical Hertz to perceived pitch:

$$m = 2595 \log_{10}\left(1 + \frac{f}{700}\right)$$

By passing the raw STFT spectrogram through a bank of overlapping triangular **Mel filters**, we produce the **Mel Spectrogram** (typically 80 or 128 channels high).

---

## Why Modern AI Loves Spectrograms

A Mel Spectrogram turns an acoustic signal into an image where:
- Horizontal axis = Time
- Vertical axis = Frequency (perceptually weighted)
- Pixel intensity = Energy in decibels (dB)

Convolutional layers and Vision Transformers can now process speech using the exact same attention mechanics used in computer vision, enabling models like Whisper to transcribe speech with superhuman noise tolerance.

