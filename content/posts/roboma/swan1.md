---
title: "RoBoMa - Part 1: "
date: 2019-04-30T19:25:16-03:00
description: "My new music project: I play The Swan with a really bad synth"
Tags: []
Categories: [RoBoMa]
draft: true
---

After going away for a weekend and seeing a live string quartet, I came home feeling pretty inspired and ready to jump
into a new music programming project. The goal is to play Camille Saint Saens' The
Swan as beautifully as I can by writing C++ code! As a point of reference, here's Yo-Yo Ma playing it!

{{% includeMP3 "yoyoma1.mp3" %}}

[Last time] (/posts/roboma/swan0) I set up a new C++ project with the
bare basics to play some audio and export wave files. Let's actually play some music!
Rather than a sine wave or square wave like last time, we're going to start with a sawtooth wave instead. 

{{% figure src="/img/sawtooth.png" %}}
{{% includeMP3 "sawTone.mp3" %}}
{{% includeMP3 "sawScale.mp3" %}}

This doesn't sound a lot like a cello. It'll be nice to try to get a nicer richer sounding instrument,
but for now it'll have to do. There's a lot of really great sound tracks in old video games! Good music
can be made with synthesizers using simple tones like this! 

Now that I have things coded up so that I can play multiple piches in a row, 
that's really all we need to *really* **really** badly play a song. 

{{< code >}}
  SetBPM(Player, QUARTER, 80);

  f32 BeatTime = 0.0;
  SequenceNote(Player, MIDI_G4, QUARTER, &BeatTime);
  SequenceNote(Player, MIDI_Fs4, QUARTER, &BeatTime);
  SequenceNote(Player, MIDI_B3, QUARTER, &BeatTime);
  SequenceNote(Player, MIDI_E4, QUARTER, &BeatTime);
  SequenceNote(Player, MIDI_D4, QUARTER, &BeatTime);
  SequenceNote(Player, MIDI_G3, QUARTER, &BeatTime);

  SequenceNote(Player, MIDI_A3, HALF + EIGHTH, &BeatTime);
  SequenceNote(Player, MIDI_B3, EIGHTH, &BeatTime);
  SequenceNote(Player, MIDI_C4, HALF, &BeatTime);
  SequenceNote(Player, REST, QUARTER, &BeatTime);

  SequenceNote(Player, MIDI_E3, HALF, &BeatTime);
  SequenceNote(Player, MIDI_Fs3, EIGHTH, &BeatTime);
  SequenceNote(Player, MIDI_G3, EIGHTH, &BeatTime);
  SequenceNote(Player, MIDI_A3, EIGHTH, &BeatTime);
  SequenceNote(Player, MIDI_B3, EIGHTH, &BeatTime);
  SequenceNote(Player, MIDI_C4, EIGHTH, &BeatTime);
  SequenceNote(Player, MIDI_D4, EIGHTH, &BeatTime);
  SequenceNote(Player, MIDI_E4, EIGHTH, &BeatTime);
  SequenceNote(Player, MIDI_Fs4, EIGHTH, &BeatTime);

  SequenceNote(Player, MIDI_B4, HALF + QUARTER + EIGHTH, &BeatTime);
{{</ code >}}

{{% includeMP3 "swan01.mp3" %}}

Okay, not great, but it's a start! There's so much that can be done to
improve this. Each post I'll try to add some new feature and get a better sounding version of the piece. There are a few broad categories of things to work on:

# Improving the Synth Instrument

At the moment, we're just turning sawtooth waves on and off. We don't even have an evelope for the sound yet. The plan was to have a simple ADSRenvelope in for this post, but in the interest of starting with the worst possible version, here we are.

Instead using a sawtooth wave, we can try some additive synthesis where
we add up a bunch of sine waves. This, at first, might not be any
better than a sawtooth, but once we start varying the strength of the
overtones throughout the note, then hopefully we'll hear some
improvement. 

# Play the Synth Better

There's so much more to capture than *just* the notes and durations. Phrasing and dynamics will go a long way towards making things sound more musical. Some vibrato on the notes will be really good too! 

# Fun with Filters

At some point we'll have to look at adding in some reverb! I'm not sure if there are any other filters we'll need, but 100% we'll need to add in some reverb!

# Data Entry!

I still have to enter in the rest of the song. There's also an accompaniment part for piano that I can add. That'll add a lot!

# See Ya!

That's a lot to work on! Each post will hopefully add something new and get things sounding closer to a good performance of this piece! Wish me luck!


