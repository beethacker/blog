---
title: "RoBoMa - Part 0: New Project"
date: 2019-04-26T00:01:38-03:00
description: "I go away for a weekend and come back with ANOTHER hobby project to work on."
draft: true
Tags: []
Categories: [RoBoMa]
---

Back in February, Lauralee and I were staying in Wolfville for the weekend, and
went to a performance by the Rolston String Quartet.  I don't remeber for sure
what they played, maybe a Hadyn, a Beethoven, and a modern piece that was
really ambient and water themed.  Almost any time I've ever been at a classical
music concert, I get *REEEAAAALLY* amped up about fun programming projects -
usually crazy audio programming and synthesis things. Literally. Every. Time. I
can still recall being riled up for hours at after a show at UPEI somewhere
around 10 years ago. 

Wow. Come to think of it, I should really go to more concerts.

The AirBnB where we stayed had an old timey pump organ! It felt super hard to
play. That might have just been me, or maybe it was more decorative and not in
amazing playing condition anymore. I gave up on that and spent a bit of time
goofing around with [SonicPi] (https://www.youtube.com/watch?v=ENfyOndcvP0) and
[Super Collider] (https://supercollider.github.io/) instead. All in all, it was an unexpectedly delightful
weekend music and music inspiration-wise. 

# New Project!

The new project is going to be to take piece of music, I've decided on Camille
Saint-Saëns' The Swan, and see how convincingly I can perform it with a
synthesizer.. that I code myself? I think I originally I was satisfied to just
do my best in SonicPi or Super Collider, but somehow I've gotten back to just coding
my own C++ synthesizer. *Whoops!* This is fine! I swear! It's going to be fine!
It's going to be a lot more fun and interesting of a journey this way, if I
manage to keep going with it.

# Progress So Far

The very first hurdle was just getting the computer to play a sound.  I more or
less had code for getting this set up in some older projects. I've pulled it out, 
polished it up a bit, and now I have a simple tone generator.

{{% includeMP3 "brokenSine.mp3" %}}

Wait, that's not right! In rescuing my old code, I managed to goof up a few details
here and there. When I ask my code to fill in the next N samples of a sine wave, 
is that N stereo samples, so I need 2*N values filled in? Okay, that's an easy one
to figure out!

{{% includeMP3 "clickSine.mp3" %}}

Oh, still not right. There's an occasional click. Darn! Whyyyyy am I not just
using Super Collider again?  The way things are working is that every time through the
main loop in the program, I fill in about a frame's worth of audio. At 60
frames per second, that'd be about 17 milliseconds per frame. At a usual sample rate of
44100 samples / second that gives us 44100 hz * 17 ms ~= 750 samples. Every 17
ms, we hand off the next 750 samples or so to Window's DirectSound API. We stay a little
bit ahead while it plays out the speakers.

I also have a second setup in order to genenrate .wav files. To keep things consistent, it
works in mostly the same way. I generate the samples a chunk at a time, write
them to a file, and repeat.  For the wave files I was grabbing chunks of about
12k samples at a time.

{{% figure src="/img/outOfSyncSine.png" %}}

The sine wave just doesn't quite line up at the boundary!  It turns out I was
stepping through sample points on a sine wave twice as fast as I should have
been. Whoops. So, not only was it clicking, but it would have been twice the
pitch, so an octave higher. Darn! Then, for the next chunk of samples I started
back at the sample I *should* have been on way earlier. We get a little out of
phase one in every 12000 samples, and that produces the clicking. **How are our ears so good?** 

{{% includeMP3 "sineAndSquare.mp3" %}}

All is good now! Oh, but check out how tiny this square wave is in that recording!

{{% figure src="/img/sineVsSquare.png" %}}

They sound about the same volume to me! 

# Here Goes!

Well, this has been one of the longest blog posts I've ever written. Not to jinx things, but this 
is already a lot farther than I take most whimsical project ideas. So here's hoping! **Let's go! Let's do this!**

