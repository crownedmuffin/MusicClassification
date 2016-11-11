%Question 1: 
%Write a MATLAB function that extract T seconds of 
%music from a given track. You will use the MATLAB function audioread to 
%read a track and the function play to listen to the track.

%Solution:

%random shit was going to use to keep track of ea
global allTrackInfo allTrackDirectories;

%assuming all tracks are in the same folder
allTrackInfo = dir('');
allTrackDirectories = {allTrackInfo.folder + '\' + allTrackInfo.name};

fs = 11025;
N = 512;
fftSize = N;
beta = 0.5;
samples = [60*fs,84*fs];
[song,fs]= audioread('audio\track201-classical.wav', samples);

%Finding first point where it's not 0 and sampling xn to N-1

% window setup
w = kaiser(N,beta);
%
s = min(find(song ~= 0));
xn = song(s:s+511);

Y = fft (w.*xn);
K = N/2 + 1;
Xn = Y(1:K);

[blah1, blah2, blah3] = take_audio('track201-classical.wav',3,0);

%playblocking(song,[start,stop])

[x,fs]=audioread('track201-classical.wav');
fftSize=512;
w = hann(fftSize);
y=mfcc(x,fs,512,w);


%Question 2:
%Implement the computation of the mfcc coecients, as defined in 
%(7). You simply need to add your code in the MATLAB code in the previous pages.



%Question 3:
%Evaluate your MATLAB function mfcc on the 12 audio tracks, and display the output as
%an image using imagesc. You will use T =24 seconds from the middle of each track and
%compute a matrix of mfcc coecients of size NB = 40 rows and 24 × 11, 025/512 = 517
%columns.


   
   
 
%take_audio input parameters: wav file, amount of time to extract, middle
%or not middle switch

