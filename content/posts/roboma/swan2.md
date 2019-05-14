---
title: "RoBoMa Part 2: Envelopes"
date: 2019-05-13T23:09:58-03:00
description: "I take a baby step towards a real synthesizer by adding amplitude envelopes for each note"
draft: true
Tags: []
Categories: []
---

## Amplitude Envelopes ##

Up until now, I've just been turning a tone generator on and off for each note to played.
The tone plays at a constant volume. Not only is each note the same volume as every other
note, but each note stays at the same volume for its entire duration. This isn't how
notes played on real instruments sound.

((piano note))

This is a note played on a piano. If we zoom in, we see a repeating wave form.

((piano note zoomed))

Zoomed out though, we can see how the amplitude of the waves change over the course of the 
note. It starts

In constrast, here is our

((tone note))

A basic feature of synthesizers is to provide some kind of envelope for notes. The most
basic and common being an ASDR (Attack, Sustain, Decay, Release). This looks roughly like

((asdr))

If we apply such an envelope to our. 

## Piano Accompaniment ##

The piano accompaniment for The Swan begins with this repeating pattern for the first N bars.

((sheet music))

Coding this in and playing it with square waves, gives us

((tones))

After adding an ASDR envelope for each note, we get

((accompaniment))

Finally, adding the cello part back in gives

((swan2final))

And there we have it! A much improved performance of The Swan! 

