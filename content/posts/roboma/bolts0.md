---
title: "Nuts and Bolts - Part 0: Audio Playback Setup"
date: 2019-04-26T00:21:38-03:00
description: "Run Through of Starting Code for My New Coding Project :|"
draft: true
Tags: [Programming]
Categories: [RoBoMa]
---

In preparation of my fun new music programming project, I've got things set up
so that I'm outputting a sine wave. It's set to build either an exe that will
play the tone through direct sound, OR, an exe thatwill write the tone to a
wave file. Here's a hopefully quick tour of the code so far.

## includeAll.cpp
First off, it's a unity build. includeAll.cpp includes all source files for the project.

{{< code >}}

#include "src/brocli_prelude.cpp"
#include "src/application_api.cpp"
#include "src/application_main.cpp"


#if defined(SWAN_DIRECT_SOUND)
  #include "src/win_main.cpp"

#elif defined(SWAN_WAVE_EXPORT)
  #include "src/wave_export_main.cpp"

#endif

{{</ code >}}

Putting all the includes and *only* the includes feels pretty tidy. The only
reason I started doing it, however, was a small concession to vim. When I
run make from vim and try to jump to errors, it can't seem to find the main
file that I'm compiling. It does find source files that have been #included 
though, so now I just have a dedicated .cpp file for organizing the build. Sure!
Depending on what I define in the build script, I either #include the DirectSound 
backend, or the .wav export backend.

## brocli_prelude.cpp

This file was grabbed from an older project. It mostly just renames some types 
and provides a few generic things - min, max, etc.

{{< code >}}
#include &ltstddef.h&gt
#include &ltlimits.h&gt
#include &ltfloat.h&gt
#include &ltstdio.h&gt
#include &ltstdarg.h&gt
#include &ltmemory.h&gt
#include &ltstdint.h&gt
typedef int8_t s8;
typedef int16_t s16;
typedef int32_t s32;
typedef int64_t s64;
typedef int32_t b32;

typedef uint8_t u8;
typedef uint16_t u16;
typedef uint32_t u32;
typedef uint64_t u64;

typedef float f32;
typedef double f64;
typedef intptr_t intptr;
typedef uintptr_t uintptr;

typedef uintptr_t umi;  //"unsigned memory index"
typedef intptr_t smi;   //"signed memory index"

#define U16Maximum 65535
#define S16Maximum 32767
#define S16Minimum -32768
#define U32Maximum ((u32)-1)
#define F32Maximum FLT_MAX
#define F32Minimum -FLT_MAX

#define TAU32 6.28318530718f
#define PI32  3.14159265360f

... etc.
{{</ code >}}


## application_api.cpp

{{< code >}}
//
// application_api.cpp
//
// Defines the structs and prototypes for functions which govern 
// how the application will interact with the main loop in the backend. 
//
struct application_audio
{
  u64 RunningSampleIndex;    // Count of total number of samples written so far

  //Format
  u16 SamplesPerSecond;  //Usually 44100
  u16 NumChannels;       //Always 2?
};


//
// Describe the audio format we want to use, and 
// initialize any variables we're going to use
// in the synth.
//
void InitializeAudio(application_audio* Audio);

//
// Fill in audio to be played in Audio.Samples.
// Return the number of samples actually written.
//
// If we're out of audio, then set *Running=false.
//
// Running is the check to use to see if we should stop. If this
// is not set, but we write fewer than Audio.NumSamplesRequested
// samples, then the audio is likely to be messed up!
//
int UpdateAudio(application_audio* Audio, s16 *Samples, u16 NumSamplesRequested,  b32* Running);


{{</ code >}}

## application_main.cpp

This sets up the audio format to use (16-bit stereo, 44100hz), and defines the main function
that generates the audio. This will be the heart of the program, but for now is just a silly
stub that generates two seconds of a sine wave followed by two seconds of a square wave.

* After 4 seconds worth of samples have passed, mark that we've finished.
* Until then, generate the requested number of samples.
** The current time in seconds t, is the running sample count divided by sample rate.
** A floating point y-value is obtained from either a sine wave in the first two
 seconds, or a square wave for the final two seconds.
** Then we convert y to a 16 bit integer (s16 for signed 16 bit), and output it twice,
   once for each stereo channel.

{{< code >}}
int 
UpdateAudio(application_audio* Audio, s16* Output, u16 NumSamplesRequested, b32* Running)
{
   if (Audio->RunningSampleIndex > 4*Audio->SamplesPerSecond)
   {
     *Running = false;
     return 0;
   }
  
   for (int i = 0; i < NumSamplesRequested; i++) 
   {
     f32 y = 0;
     f32 t = 1.0*Audio->RunningSampleIndex / Audio->SamplesPerSecond;

     if (Audio->RunningSampleIndex < 2*Audio->SamplesPerSecond)
     {
       y = 0.4*Sine(440, t);
     }
     else 
     {
       y = 0.045*Square(220, t);
     }

     s16 A = (s16)(S16Maximum*y);
     *Output++ = A;
     *Output++ = A;

     Audio->RunningSampleIndex++;
   }

   return NumSamplesRequested;
}
{{</ code >}}

## win_main.cpp

This file sets up a basic win32 application with an empty window, sets up DirectSound, and 
feeds data from application_main.cpp into DirectSound. It's about 450 lines of mostly boiler plate, but let's look at the sound parts at least.

Here's the main entry point program! FrameTimer handles the logic for keeping the loop running at 30fps. GlobalRunning is a global flag that gets set when we exit the window or when the main audio function is done feeding us audio and wants to tell us to quit. And of course, we make calls to get audio set up, and to play the audio.

*application_audio* is the nice high level struct that the main application will use. win32_sound_system handles our interface to DirectSound and has all the gross stuff.

{{< code >}}
int CALLBACK
WinMain(HINSTANCE Instance,
        HINSTANCE PrevInstance,
        LPSTR CommandLine,
        int ShowCode)
{
  HWND WindowHandle = Win32CreateWindow(Instance, WINDOW_TITLE);

  win32_frame_timer FrameTimer = {};
  Win32InitFrameTimer(&FrameTimer, 30);
  
  application_audio AppAudio = {};
  InitializeAudio(&AppAudio);

  win32_sound_system SoundSystem = {};
  Win32InitSoundSystem(WindowHandle, &SoundSystem, &AppAudio, FrameTimer.TargetSecondsPerFrame);

  Win32PreloadBuffer(&SoundSystem, 28222, &AppAudio);
  SoundSystem.PlaybackBuffer->Play(0, 0, DSBPLAY_LOOPING);

  GlobalRunning = true;
  while(GlobalRunning) 
  {
    Win32BeginFrame(&FrameTimer);
    Win32ProcessPendingMessages();

    Win32FillSoundBuffer(&SoundSystem, &AppAudio);

    Win32WaitUntilNextFrame(&FrameTimer);
  }
}

{{</ code >}}

The following code sets up DirectSound. It's a ton of ugly boiler plate. It does the following

* Makes a copy of some audio format variables, as specified in application_main.cpp
* Fills out a WAVEFORMATEX struct with this information, so we can request that format
from DirectSound.
* Loads the dll containing the DirectSound library
* Creates a DirectSound object
* Creates a Primary Buffer and sets its audio format. We can't touch this one, but I hear in the old days we could. 
This is where audio data gets communicated from DirectSound to our audio hardware. 
* Creates a Secondary Buffer. This is where we write audio so DirectSound can use it. We can have a few of these and DirectSound will 
mix them into the Primary Buffer. We'll do all our own mixing though, so we'll only ever have one of these.
* If anything goes wrong, we fire up a message box and quit the program.

{{< code >}}
struct win32_sound_system
{
  u32 SamplesPerSecond;
  u32 LatencySampleCount;
  u32 BytesPerSample;
  u32 TargetSamplesPerFrame;

  u32 BufferSizeInBytes;

  //NOTE Redundant, but convenient
  u32 BytesPerSecond;
  u32 NumChannels;

  //Track other quantities so we know where
  //and how many samples to write.
  u32 NumSamplesPlayed;
  u32 NumSamplesWritten;

  u32 LastPlayCursor;
  u32 SafeWriteCursor;

  //Handles to direct sound
  HMODULE DirectSoundLibrary;
  WAVEFORMATEX WaveFormat;

  LPDIRECTSOUND DirectSound;
  LPDIRECTSOUNDBUFFER PlaybackBuffer;
};

internal void
Win32InitSoundSystem(HWND WindowHandle, win32_sound_system *SoundSystem, application_audio* AppAudio, f32 TargetSecondsPerFrame)
{    
  // Copy audio format setting specified by application layer.
  SoundSystem->SamplesPerSecond = AppAudio->SamplesPerSecond;
  SoundSystem->NumChannels = AppAudio->NumChannels;
  SoundSystem->BytesPerSample = SoundSystem->NumChannels*sizeof(s16);
  SoundSystem->BufferSizeInBytes = 3*AppAudio->SamplesPerSecond*sizeof(s16);
  SoundSystem->NumSamplesPlayed = 0;
  SoundSystem->NumSamplesWritten = 0;
  SoundSystem->BytesPerSecond = SoundSystem->SamplesPerSecond * SoundSystem->BytesPerSample;
  SoundSystem->TargetSamplesPerFrame = 2*AppAudio->SamplesPerSecond*TargetSecondsPerFrame;

  // Create format struct to pass to DirectSound
  WAVEFORMATEX WaveFormat = {};
  WaveFormat.wFormatTag = WAVE_FORMAT_PCM;
  WaveFormat.nChannels = 2;
  WaveFormat.nSamplesPerSec = SoundSystem->SamplesPerSecond;
  WaveFormat.wBitsPerSample = 16;
  WaveFormat.cbSize = 0;
  WaveFormat.nBlockAlign = (WaveFormat.nChannels * WaveFormat.wBitsPerSample) / 8;
  WaveFormat.nAvgBytesPerSec = (SoundSystem->SamplesPerSecond * WaveFormat.nBlockAlign);
  SoundSystem->WaveFormat = WaveFormat;

  // Load DirectSound dll
  SoundSystem->DirectSoundLibrary = LoadLibraryA("dsound.dll");
  if (!SoundSystem->DirectSoundLibrary)
  {
    LOG(MsgBoxAndExit, "DSound", LOG_ERROR, "LoadLibrary() failed: Cannot load direct sound");
    return;
  }

  direct_sound_create *DirectSoundCreate = (direct_sound_create*)
    GetProcAddress(SoundSystem->DirectSoundLibrary, "DirectSoundCreate");

  // Create the DirectSound object and save a handle to it.
  LPDIRECTSOUND DirectSound;
  if (!DirectSoundCreate || !SUCCEEDED(DirectSoundCreate(0, &DirectSound, 0)))
  {
    LOG(MsgBoxAndExit, "DSound", LOG_ERROR, "DirectSound object could not be created");
    return;
  }

  if (!SUCCEEDED(DirectSound->SetCooperativeLevel(WindowHandle, DSSCL_PRIORITY))) 
  {
    LOG(MsgBoxAndExit, "DSound", LOG_ERROR, "SetCooperativeLevel() failed: Cannot set cooperative level");
    return;
  }
  SoundSystem->DirectSound = DirectSound;

  // Set up the DirectSound primary buffer and set its format
  LPDIRECTSOUNDBUFFER PrimaryBuffer;
  DSBUFFERDESC BufferDescription = {};
  BufferDescription.dwSize = sizeof(DSBUFFERDESC);
  BufferDescription.dwFlags = DSBCAPS_PRIMARYBUFFER;
  //NOTE: Always 0 for primary buffer
  BufferDescription.dwBufferBytes = 0;

  if (!SUCCEEDED(DirectSound->CreateSoundBuffer(&BufferDescription, &PrimaryBuffer, 0)))
  {
    LOG(MsgBoxAndExit, "DSound", LOG_ERROR, "Can't create primary direct sound buffer");
    return;
  }

  if (!SUCCEEDED(PrimaryBuffer->SetFormat(&SoundSystem->WaveFormat)))
  {
    LOG(MsgBoxAndExit, "DSound", LOG_ERROR, "Can't set the format of the sound buffer");
    return;
  }

  // Set up the DirectSound secondary buffer. We store this in SoundSystem and this is where 
  // will be writing data to!
  BufferDescription = {};
  BufferDescription.dwSize = sizeof(DSBUFFERDESC);
  BufferDescription.dwFlags = DSBCAPS_GLOBALFOCUS | DSBCAPS_GETCURRENTPOSITION2;
  BufferDescription.dwBufferBytes = SoundSystem->BufferSizeInBytes;
  BufferDescription.lpwfxFormat = &SoundSystem->WaveFormat;

  if (!SUCCEEDED(DirectSound->CreateSoundBuffer(&BufferDescription, &SoundSystem->PlaybackBuffer, 0)))
  {
    LOG(MsgBoxAndExit, "DSound", LOG_ERROR, "Can't create the secondary buffer");
    return;
  }
}

{{</ code >}}

The main loop calls Win32FillSoundBuffer to generate about a frames worth of
samples and fill them into a DirectSound buffer. The DirectSound buffer is a
ring buffer - it will play audio from a buffer, and when it gets to the end,
it will loop and keep playing from the beginning.

We can ask DirectSound for where it's play cursor currently is, as well as
a write cursor. The goal is to keep filling the buffer, staying ahead of the write cursor. Otherwise the 
section between the play cursor and write cursor is locked for playback, so we won't be able to write the
new samples, and we'll be stuck playing old data. 

((Diagram?))

We're also going to need
our own cursor to keep track of where in the buffer we're currently writing to. We store this in
win32_sound_system.SafeCursor. We want to keep it a "safe" distance ahead of DirectSound's write cursor.
Since we're not reacting to input or anything (yet, at least), we can afford to stay a really generous distance ahead.

Each time through the program's main loop,
* Get the DirectSound PlayCursor and WriteCursor, note how many samples the WriteCursor is ahead of the PlayCursor (LatencySamples)
* Compare the position of PlayCursor to its position last time through the loop, this tells us how many samples have been played!
* Decide how many samples we want to write. Currently, we write enough samples so our "SafeCursor" is one frame + 2*LatencySamples 
ahead of the play cursor

((Diagram?))

* Lock the corresponing part of the DirectSound buffer. 
* Ask the main application UpdateAudio function to fill samples into this buffer.
* Since we're writing into a ring buffer, we might be writing past the end of the buffer and back into the start of the buffer, 
so DirectSound will sometimes give us *two* regions of memory to fill samples into.


{{< code >}}
internal void
Win32FillSoundBuffer(win32_sound_system* SoundSystem, application_audio* AppAudio)
{
  DWORD PlayCursor;
  DWORD WriteCursor;
  if (!SUCCEEDED(SoundSystem->PlaybackBuffer->GetCurrentPosition(&PlayCursor, &WriteCursor)))
  {
    LOG(MsgBoxAndExit, "DSound", LOG_ERROR, "Failed to get direct sound position!");
  }
  s32 LatencyBytes = WriteCursor-PlayCursor;
  if (LatencyBytes < 0)
  {
    LatencyBytes += SoundSystem->BufferSizeInBytes;
  }
  s32 LatencySamples = LatencyBytes / SoundSystem->BytesPerSample;

  LOG(DebugPrintFn, "DSound", LOG_INFO, "Play=%d, Write=%d, SafeWrite=%d\n", PlayCursor, WriteCursor, SoundSystem->SafeWriteCursor);


  //Note how many samples have been played since last time!
  s32 PlayCursorDiff = PlayCursor - SoundSystem->LastPlayCursor;
  SoundSystem->LastPlayCursor = PlayCursor;
  if (PlayCursorDiff < 0)
  {
    PlayCursorDiff = PlayCursorDiff + SoundSystem->BufferSizeInBytes;
  }
  SoundSystem->NumSamplesPlayed += PlayCursorDiff/SoundSystem->BytesPerSample;

 
  //Decide how much we want to write!
  u32 ByteToLock = SoundSystem->SafeWriteCursor;
  if (Between(PlayCursor, ByteToLock, WriteCursor))
  {
    LOG(DebugPrintFn, "DSound", LOG_ERROR, "Uh oh! Handle lag!");
  }

  s32 SamplesToWrite = ((s32)(SoundSystem->NumSamplesPlayed - SoundSystem->NumSamplesWritten)) + SoundSystem->TargetSamplesPerFrame + 2*LatencySamples;
  s32 BytesToWrite = SamplesToWrite * SoundSystem->BytesPerSample;

  if (SamplesToWrite > 0)
  {
    VOID *Region[2];
    DWORD RegionSize[2];

    if (SUCCEEDED(SoundSystem->PlaybackBuffer->Lock(
            ByteToLock, BytesToWrite,
            &Region[0], &RegionSize[0],
            &Region[1], &RegionSize[1],
            0)))
    {
      for (int RegionIndex = 0; RegionIndex < 2; RegionIndex++)
      {
        //NOTE Only support 16-bit samples at the moment!
        s16 *SampleOut = (s16*)Region[RegionIndex];
        u16 NumSamplesRequested = RegionSize[RegionIndex]/SoundSystem->BytesPerSample;

        SoundSystem->NumSamplesWritten += UpdateAudio(AppAudio, SampleOut, NumSamplesRequested, &GlobalRunning);
      }  

      SoundSystem->PlaybackBuffer->Unlock(Region[0], RegionSize[0], Region[1], RegionSize[1]); 
    }

    SoundSystem->SafeWriteCursor = (SoundSystem->SafeWriteCursor + BytesToWrite) % SoundSystem->BufferSizeInBytes;
  }
}

{{</ code >}}

And that's mostly it! *Win32PreloadBuffer* is nearly the same as Win32FillSoundBuffer. The only difference is that it fills in data before we start DirectSound playing, so
it fills in a much larger chunk and doesn't have to worry about any regions of the buffer being locked for playback. Maybe I don't need a separate function for this, but if all goes well, I'll never have to come back down into this level of the code anyway. * Fingers crossed! *




