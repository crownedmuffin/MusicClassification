function [mfcc] = mfcc(wav, fs, fftSize, window,song_path)
%
% USAGE
% [mfcc] = mfcc(wav, fs, fftSize,window)
%
% INPUT
% vector of wav samples
% fs : sampling frequency
% fftSize: size of fft
% window: a window of size fftSize
%
% OUTPUT
% mfcc (matrix) size coefficients x nFrames
% hardwired parameters

hopSize = fftSize/2;
nBanks = 40;

% minimum and maximum frequencies for the analysis
fMin = 20;
fMax = fs/2;
%_____________________________________________________________________
%
% PART 1 : construction of the filters in the frequency domain
%_____________________________________________________________________
% generate the linear frequency scale of equally spaced frequencies from 0 to fs/2.
linearFreq = linspace(0,fs/2,hopSize+1);
fRange = fMin:fMax;
% map the linear frequency scale of equally spaced frequencies from 0 to fs/2
% to an unequally spaced mel scale.
melRange = log(1+fRange/700)*1127.01048;

% The goal of the next coming lines is to resample the mel scale to create uniformly
% spaced mel frequency bins, and then map this equally spaced mel scale to the linear
%& scale.
% divide the mel frequency range in equal bins
melEqui = linspace (1,max(melRange),nBanks+2);
fIndex = zeros(nBanks+2,1);
% for each mel frequency on the equally spaces grid, find the closest frequency on the
% unequally spaced mel scale
for i=1:nBanks+2,
    [dummy fIndex(i)] = min(abs(melRange - melEqui(i)));
end
% Now, we have the indices of the equally-spaced mel scale that match the unequally-spaced
% mel grid. These indices match the linear frequency, so we can assign a linear frequency
% for each equally-spaced mel frequency
fEquiMel = fRange(fIndex);
% Finally, we design of the hat filters. We build two arrays that correspond to the center,
% left and right ends of each triangle.
fLeft = fEquiMel(1:nBanks);
fCentre = fEquiMel(2:nBanks+1);
fRight = fEquiMel(3:nBanks+2);
% clip filters that leak beyond the Nyquist frequency
[dummy, tmp.idx] = max(find(fCentre <= fs/2));
nBanks = min(tmp.idx,nBanks);
% this array contains the frequency response of the nBanks hat filters.
freqResponse = zeros(nBanks,fftSize/2+1);
hatHeight = 2./(fRight-fLeft);

% for each filter, we build the left and right edge of the hat.
for i=1:nBanks,
    freqResponse(i,:) = ...
        (linearFreq > fLeft(i) & linearFreq <= fCentre(i)).* ...
        hatHeight(i).*(linearFreq-fLeft(i))/(fCentre(i)-fLeft(i)) + ...
        (linearFreq > fCentre(i) & linearFreq < fRight(i)).* ...
        hatHeight(i).*(fRight(i)-linearFreq)/(fRight(i)-fCentre(i));
end
%
% plot a pretty figure of the frequency response of the filters.
figure;set(gca,'fontsize',14);semilogx(linearFreq,freqResponse');
axis([0 fRight(nBanks) 0 max(freqResponse(:))]);title('FilterbankS');



%_________________________________________________________
%
% PART 2 : processing of the audio vector In the Fourier domain.
%_________________________________________________________
%
% YOU NEED TO ADD YOUR CODE HERE

%need to take a 512 sized chunk from wav (audio data from user)

%Finding first nonzero sample of song (used for part 1)
%first_nonzero_index = min(find(wav ~= 0));

%take 512 samples starting from the first non-zero point (add 512 samples to this )
%xn = wav(first_nonzero_index:first_nonzero_index+511);


N = 512; %number of samples in frame



question2 = 0;

    
%Form audio object to easily collect data about song
song = audioplayer(wav,fs);

if question2
    numFrames = 1;
    
    %Finding first nonzero sample of song (used for part 1)
    first_nonzero_index = min(find(wav ~= 0));

    %take 512 samples starting from the first non-zero point (add 512 samples to this )
    xn = wav(first_nonzero_index:first_nonzero_index+511);
     
    %Just set K to the maximum size of freqResponse. The coefficients of the
    %filterbanks are positioned in the freqResponse matrix such that values 
    %will only exist near the values you see in the filterbank plot. Look at the value of 
    %freqResponse if you need that to make sense. The filter bank at Nb = 1 is small, and there
    %are a limited number of nonzero values there, as we would expect. Whereas the
    %filterbank size at the last filter bank is large.
    K = size(freqResponse,2);
    
    %Compute Fourier transform of audio signal with window of size N = 512
    Y = fft (window.*xn);
    K = N/2 + 1;
    Xn = Y(1:K);
    
    %Just want to generate the mfcc coefficient for one frame (resulting in a 40 x 1 matrix, 
    %40 rows for each of the filter banks, 1 for the single frame being processed)
    mfcc = zeros(nBanks,numFrames);
    
    for p=1:nBanks 
        %Implement equation (7)
        %k runs from 1 to 257 because there are 257 columns in the
        %freqResponse matrix, which carries the coefficients of the filter.
     
        for k = 1:K
            mfcc(p) = (abs(freqResponse(p,k)*Xn(k))^2)+mfcc(p);
        end
    end 
else
    %number of frames in 24 seconds at sampling rate fs and frame size N
    numFrames = ceil(24*(fs/N));
    
    %initialize matrix to hold all mfcc values
    mfcc = zeros(nBanks, numFrames);
    
    %Get all audio samples from .wav file
    
    %Precondition: Audio file has been passed through audioread() prior to
    %passing anything to this functon. So audio samples have been extracted

    %Form audio object to easily collect data about song
    song = audioplayer(wav,fs);
    
    %Want to start in middle of the song. Gather this data before entering loop
    middleIndex = song.TotalSamples/2;
    
    %Just set K to the maximum size of freqResponse. The coefficients of the
    %filterbanks are positioned in the freqResponse matrix such that values 
    %will only exist near the values you see in the filterbank plot. Look at the value of 
    %freqResponse if you need that to make sense. The filter bank at Nb = 1 is small, and there
    %are a limited number of nonzero values there, as we would expect. Whereas the
    %filterbank size at the last filter bank is large.
    K = size(freqResponse,2);
    
    %pull in new frames and process the next 517 frames
    for frameNumber = 1:numFrames
       
        %Take 512 samples. Need to get the start and end of the individual
        %frames we're currently analyzing. Increment beginning of frame by
        %512 after processing previous frame.
        frameStart = ceil(middleIndex+((frameNumber-1)*N)); %needs to be an integer
        frameEnd   = frameStart+511;

        %extract samples from current frame of interest
        try 
            extracted_audio = wav(frameStart:frameEnd);
        catch
            %This will only trigger if we go over the total amount of
            %samples. i.e. sample1.wav, is less than 24 seconds, so we
            %cannot process 24 seconds worth of frames.
            warning('Total Samples: ' + song.TotalSamples + 'frame end: ' + frameEnd + 'frame start: ' + frameStart)
        end
        
        %Just want to make this explicitly clear for my future self.
        xn = extracted_audio;

        Y = fft (window.*xn);
        K = N/2 + 1;
        Xn = Y(1:K);

        %Generate mfcc coefficient matrix for each frame and filter bank
        for p=1:nBanks 
            %k is essentially the size of the filterbanks. 
            for k = 1:K
                mfcc(p,frameNumber) = (abs(freqResponse(p,k)*Xn(k))^2)+mfcc(p,frameNumber); %k from 1 to 257           
            end    
        end
    end 
end %end of if statement
           
 %imagesc(mfcc);

 %As requested, flipping the matrix upside down
 mfcc_flipped = flipud(mfcc);
 %mfcc_flipped = mfcc; %for debugging purposes
 
 fig = imagesc(10*log10(mfcc_flipped));
 title(song_path);
 xlabel('MFCC Coefficients per Frame'); 
 ylabel('Filterbank Number');
 colorbar;
 colormap('jet');
 

