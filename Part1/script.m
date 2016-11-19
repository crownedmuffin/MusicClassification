close all

%Put all song names into a cell array
songList = {
            '\audio\track201-classical.wav', ...
            '\audio\track204-classical.wav', ...
            '\audio\track370-electronic.wav', ...
            '\audio\track396-electronic.wav', ...
            '\audio\track437-jazz.wav', ...
            '\audio\track439-jazz.wav', ...
            '\audio\track463-metal.wav', ...
            '\audio\track492-metal.wav', ...
            '\audio\track547-rock.wav', ...
            '\audio\track550-rock.wav', ...
            '\audio\track707-world.wav', ...
            '\audio\track729-world.wav', ...
            '\audio\sample1.wav'
            }; 

%{
--------------------------------------------------------------------------
PART 1:
--------------------------------------------------------------------------
%}
        
%Question 1: 
%Write a MATLAB function that extract T seconds of 
%music from a given track. You will use the MATLAB function audioread to 
%read a track and the function play to listen to the track.


%take_audio input parameters: audio file, amount of time to extract, middle
%or not middle switch

%Choose your song according to the index number given above. 1 corresponds to  track201-classical.wav
%and 13 corresponds to sample1.wav.
songChoice = 1;
 
pathToSong = char(songList(songChoice));

amountOfTime = 3; %seconds
takeFromMiddle = 1; %software switch to enable taking audio from middle

[song_object, audio_data, fs ,start, stop] = slice_audio(pathToSong,...
                                            amountOfTime,takeFromMiddle);

%sound(audio_data,fs) %don't use this, you won't be able to pause the music

play(song_object,[start,stop])



%Question 2:
%Implement the computation of the mfcc coeffcients, as defined in 
%(7). You simply need to add your code in the MATLAB code in the previous pages.

%Note: these are the values extracted from part 1: fs, song_object, 
%audio_data, fs ,start frame, and stop frame

%samples per frame
N = 512;

%want this to be the number of samples per frame (i think)
fftSize = N;

%Create a window
% w = kaiser(N,beta);
w = hann(fftSize);

%Compute mfcc coefficient for one frame of the song that pathToSong points
%to. This should produce a boring graph of the mfcc coefficients of one frame.
y=mfcc(audio_data,fs,fftSize,w,pathToSong);


%Question 3:
%Evaluate your MATLAB function mfcc on the 12 audio tracks, and display the output as
%an image using imagesc. You will use T =24 seconds from the middle of each track and
%compute a matrix of mfcc coefficients of size NB = 40 rows and 24 × 11,025/512 = 517
%columns.

%Generate plots and compute the mfcc coefficients for each of the 12 songs
%given.

for songChoice = 1:12
    pathToSong = char(songList(songChoice));
    [song_object, audio_data, fs ,start, stop] = slice_audio(pathToSong,3,1);
    y=mfcc(audio_data,fs,fftSize,w,pathToSong);
end  

%{
--------------------------------------------------------------------------
PART 2:
--------------------------------------------------------------------------
%}

%Has almost nothing to do with part 1

%Question 4:
%{
Implement the computation of the Normalized Pitch Class Prole, dened by (17). You will compute
a vector of 12 entries for each frame n.
%}

%{
    what is a note: key on the keyboard
    want to find frequencies associated with notes
    
    western classical music: f =f0*2^(sm/12), where sm = semitone =
    distance in logarithmic scale between two succcessive notes

    12 semitones in an octave

    A,
    A# = Bflat,
    B,B#=Cflat, 
    C, 
    C# = DFlat, 
    D,D# = Eflat,
    E,
    E#=Fflat,
    F,
    G
    
    A4 = 440Hz = f0
    A0 = 27.5 Hz, 4 octaves away from A4
    
    A4 = A0*2^(4), 4= 48 semitones away from f0

    want to fold back all frequencies into first octave (see everything as 
    a function of the first octave)
    
    Algorithm:

    take frame n
    window
    fourier transform -> X

    rest of operation is for this particular frame

    |X(e^2pi*jk/N)|^2 = |X(k)|^2
    (multiplying filter against magnitude squared in pt1)

    Find f1,f2....frequencies associated with the piece in the spectrum 
    (Fourier transform) - the magnitude squared of the fourier transform

    |X(f1)|^2 >= |X(f2)|^2 >= ... the dominant note of the sound in that
    frame

    2) compute the semi tone

    sm = round(12*log2(fk/f0)), fk ~= f0*(2^(sm/12))

    compute note/pitch:
    c = sm(mod12) = sm%12

    but this would never work? i.e. what if k was floating between two
    notes


    in general fk is quite different from f0 2^(sm/2)

    so we need to distribute energy measured by |X(fk)|^2
    to the nearest "notes"

    solution: simply bin the notes: build a histogram of the distribution
    of the fourier coefficients

    raised 

             |  |  -|- * _  |
             |  | / |*\_/*\ |
             |  |/ *|     *\|
             | *|*  |      *|\***
             | --------------------  

    * = raised cosine
    / = fourier transform



    

    

%}

%Question 5:
%{
Evaluate and plot the NPCP for the 12 audio tracks found in
http://ecee.colorado.edu/~fmeyer/.private/audio.zip
See Fig. 2 for an example.
%}
 

