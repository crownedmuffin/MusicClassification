%Question 1: 
%Write a MATLAB function that extract T seconds of 
%music from a given track. You will use the MATLAB function audioread to 
%read a track and the function play to listen to the track.

%Solution for Question 1:

%{
%trying to keep track of each file in the folder
global audioFiles audioFileNames;

%assuming all tracks are in the same subfolder \audio
audioFiles = dir('audio'); %name info

%get the name of all the audio files, convert cell array to strings
audioFileNames = cellstr({audioFiles.name});

%for i = 1:length(audioFileNames)
%   audioFileNames(i) = strcat('\audio\',audioFileNames(i));
%end

%currentAudioFile = audioFileNames(4);
%}

%take_audio input parameters: audio file, amount of time to extract, middle
%or not middle switch

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
            '\audio\track492-metal', ...
            '\audio\track547-rock.wav', ...
            '\audio\track550-rock.wav', ...
            '\audio\track707-world.wav', ...
            '\audio\track729-world.wav', ...
            '\audio\sample1.wav'
            };

%Song number x 
songChoice = 11;
 
 pathToSong = char(songList(songChoice))

[song_object, audio_data, fs ,start, stop] = slice_audio(pathToSong,3,1);
%sound(audio_data,fs) %don't use this, you won't be able to pause the music
%play(song_object,[start,stop])



%Question 2:
%Implement the computation of the mfcc coeffcients, as defined in 
%(7). You simply need to add your code in the MATLAB code in the previous pages.

%Values extracted from part 1: fs, song_object, audio_data, fs ,start, stop

%samples per frame
N = 512;

%want this to be the number of samples per frame (i think)
fftSize = N;

% create a window
% w = kaiser(N,beta);
w = hann(fftSize);

%playblocking(song,[start,stop])

y=mfcc(audio_data,fs,fftSize,w);



%Question 3:
%Evaluate your MATLAB function mfcc on the 12 audio tracks, and display the output as
%an image using imagesc. You will use T =24 seconds from the middle of each track and
%compute a matrix of mfcc coefficients of size NB = 40 rows and 24 × 11,025/512 = 517
%columns.


   
   
 

