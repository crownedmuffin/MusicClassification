function [npcp] = npcp(wav, fs, fftSize, window)
%
% USAGE
%   [npcp] = npcp(wav, fs, fftSize, window)
%
% INPUT
%      vector of wav samples
%      fs : sampling frequency
%      fftSize: size of fft
%      window: a window of size fftSize
%
% OUTPUT
%   normalized pitch class profile

N = fftSize;
w = window;
K = fftSize/2 + 1;
f0 = 27.5;

totalSamples = length(wav);
duration = floor(totalSamples/fs);
nframes = floor(duration*fs/N);

npcp = zeros(12,duration);

% loop through each frame and compute npcp
for n=1:nframes,
    startFrame = 1+(n-1)*N;
    endFrame = startFrame + 511;
    
    % fourier transform audio signal
    xn = wav(startFrame:endFrame);
    Y = fft(w.*xn);
    Xn = Y(1:K);
    
    %----------------------------------------------------------------------
    %   Step 1: Spectral Analysis and Peak Detection
    %----------------------------------------------------------------------
    magXn = abs(Xn);
    [pks,locs] = findpeaks(magXn);
    npeaks = length(pks);
    
    % peak frequencies
    fk = zeros(npeaks,1);
    for m=1:npeaks,
        fk(m,1) = locs(m,1);
    end
    
    % peak values
    peaks = zeros(npeaks,1);
    for m=1:npeaks,
        peaks(m,1) = pks(m,1);
    end
    
    %----------------------------------------------------------------------
    %   Step 2: Assignment of the peak frequencies to semitones
    %----------------------------------------------------------------------
    sm = zeros(npeaks,1);
    c = zeros(npeaks,1);
    r = zeros(npeaks,1);
    
    for m=1:npeaks,
        sm(m,1) = round(12*log2(fk(m,1)/f0));
        c(m,1) = mod(sm(m,1),12);
        r(m,1) = 12*log2(fk(m,1)/f0) - sm(m,1);
    end
    
    %----------------------------------------------------------------------
    %   Step 3: Pitch Class Profile: weighted sum of the semitones
    %----------------------------------------------------------------------
    weight = zeros(npeaks,12);
    pcp = zeros(12,1);
    
    for m=1:npeaks,
        if -1<r(m,1) && r(m,1)<1
            weight(m,c(m,1)+1) = cos(pi*r(m,1)/2)^2;
        else
            weight(m,c(m,1)+1) = 0;
        end
    end
    
    % pitch class profile
    for m=1:12,
        for l=1:npeaks,
            pcp(m) = weight(l,m)*(peaks(l,1)^2) + pcp(m);
        end
    end
    
    %----------------------------------------------------------------------
    %   Step 4: Normalizing the Pitch Class Profile
    %----------------------------------------------------------------------
    pcpQ = 0;
    for m=1:12,
        pcpQ = pcp(m) + pcpQ;
    end
    
    for m=1:12,
        for l=1:12,
            npcp(m,n) = pcp(m)/pcpQ;
        end
    end
        
end

imagesc(10*log10(npcp))
set(gca,'Ydir','Normal')
colormap('jet')
colorbar

end




