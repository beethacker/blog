---
title: "RoBoMa - Part 1: "
date: 2019-04-30T19:25:16-03:00
description: "My new music project: I play The Swan with a really bad synth"
Tags: []
Categories: [RoBoMa]
draft: true
---

My new music programming project is to play Camille Saint Saens' The
Swan as beautifully as I can... by writing C++ code! As a point of reference, here's Yo-Yo Ma playing it!

(yoyoma.mp3)

[Last time] (/posts/RoBoMa/swan0.html) I set up a new project with the
bare basics to play audio or export audio to a wave file. This week,
let's actually play some music!

Rather than a sine wave or square wave like last time, we're going to start with a sawtooth wave instead.

(diagram)

This doesn't sound a lot like a cello, but certainly a lot closer than a sine or square wave. Also, since last time, I've coded it up so I can give it a list of notes and durations to play.

(scale)

And with that, that's all we need to *really* **really** badly play a song. Here's the first phrase of The Swan.

(code)

(swan.ogg)

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


