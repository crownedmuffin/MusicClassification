function NPCP = NormPitchClassProfile(wav)
    
    %[wav]= audioread(song_path);

    %Number of notes in an octave
    notes_in_an_octave = 12;

    %Sampling rate of songs in Hz
    fs = 11025;

    %Frame size. Want a frame of size 2048. 512 for part 3
    frameSize_N = 512;

    songSize = size(wav,1);

    %Create a window of size frameSize_N
    w = hann(frameSize_N);

    %Reference note in Hz
    f0=27.5;


    %jump = songSize/256;
    step_size = frameSize_N/2;

    %Software switch used to evaluate question 4, question 5, or neither
    question4 = 1;
    question5 = 1;

    %Determining the number of frames in a song
    framesInSong =  2*floor(songSize/frameSize_N)-1;

    %Finding first nonzero sample of song (used for part 1)
    first_nonzero_index = min(find(wav ~= 0));

    %take frameSize_N samples starting from the first non-zero point (add 512 samples to this )
    %xn = wav(first_nonzero_index:first_nonzero_index+(frameSize_N-1));

    %Begin counting frames
    %frameNumber = 0;

    %Index of the last full frame of the song (to prevent overflow)
    startingIndexOfLastFullFrame = framesInSong*step_size;

    %PCP information gets stored inside NPCP matrix after evaluating each frame
    NPCP = zeros(notes_in_an_octave,framesInSong);

    %Process the whole song
    for frameStart=1:step_size:startingIndexOfLastFullFrame

        %Compute frame number from start frame
        %divide start frame by step size, add 1
        frameNumber = ((frameStart -1)/step_size) + 1;

        %determine the end sample index
        frameEnd = frameStart + (frameSize_N-1);

        %Extract one frame
        xn = wav(frameStart:frameEnd);

        %Take Fourier transform of signal using hann window, w
        Y = fft(w.*xn);
        K = frameSize_N/2 + 1;
        Xn = Y(1:K);


        %Finding peaks in fourier transform
        %length(pks) -> number of peaks detected
        %length(peakLocations) -> length(pks) 
        [peakMagnitudes,peakLocations] = findpeaks(abs(Xn));

        %Use a threshold
        %What's a decibel: https://en.wikipedia.org/wiki/Decibel
        attenuation = 20; %decibels
        threshold = max(peakMagnitudes)*10^(-attenuation/20);

        %reevaluate where peaks occur (if we have peaks)
        if peakLocations
            [peakMagnitudes,peakLocations] = findpeaks(abs(Xn),fs,'MinPeakHeight',threshold);
        end


        %Number of peaks = number of peak points detected
        numberOfPeaks = length(peakLocations);

        %Vector containing the value of the frequencies that the peaks occur at
        peakFrequencies_f = zeros(numberOfPeaks,1);

        %Matrix containing semitone values computed using the frequencies that the peaks
        %occur at
        semitone_sm = zeros(numberOfPeaks,1); 

        %PCP is reset at beginning of every frame
        PCP  = zeros(notes_in_an_octave,1);


        %Computing the frequency at the peaks
        %indexed according to peak number
        for k=1:1:numberOfPeaks
            %frequency = (index that peak occurs at * sampling rate)/frameSize_N

            %{

                Example Fourier Transform of Audio Signal (not to scale!)

                        Magnitude
                         |                        x
                         |             x          |
                         |             |          |
                         |    x        |     x    |
                         |    |   x    |     |    |
                        _|____|___|____|_____|____|___ Index i
                         |                          |
                        i=0                        i_max=frameSize_N=2048
            %}

            peakFrequencies_f(k)=((peakLocations(k)*fs)/frameSize_N);
        end

        %Matrix containing the note (aka chroma) evaluated at each peak detected
        if numberOfPeaks
            note_c = zeros(numberOfPeaks,1);
        else
            %Sometimes there will be no peaks due to there being no sound in
            %segments of the song
            note_c = zeros(1,1);
        end


        %computing the octave for each peak we have
        octave = zeros(numberOfPeaks,1);  

        %Matrix holding weighted sum of semitones
        weight = zeros(numberOfPeaks,notes_in_an_octave);

        %Computing the semitone, note, octave, and weight as required and described 
        %in eqns 15 and 16 for each peak frequency at 
        for peakNumber=1:1:numberOfPeaks
            try  
                %Computing semitone (sm) for each peak

                %peakFrequencies_f(peakNumber) gives frequency at peak
                %number, k
                semitone_sm(peakNumber)= round(12*log2(peakFrequencies_f(peakNumber)./f0));
            catch
                warning('Could not compute semitone. Self-destruct sequence initiated.')
            end


            try
                note_c(peakNumber) = mod(semitone_sm(peakNumber),12);
            catch
                warning('Could not compute note. Self-destruct sequence initiated.')
            end

            %Need to perform integer division to obtain the octave
            octave(peakNumber) = floor(semitone_sm(peakNumber)/12);



            try
                %Computing the weight as defined by equation 19

                r = 12*log2(peakFrequencies_f(peakNumber)./f0) - semitone_sm(peakNumber);

                if (r>-1) && (r<1)
                    weight(peakNumber,note_c(peakNumber)+1) = cos(pi*r/2)^2;
                else
                    weight(peakNumber,note_c(peakNumber)+1) = 0;
                end  
            catch
                warning('Could not compute weight. Self-destruct sequence initiated.')
            end

        end





        for note=1:1:12
            %Implementing the Pitch Class Profile (Equation 21)
            for peakNumber=1:numberOfPeaks
               try
                   PCP(note) = PCP(note) + weight(peakNumber,note)*(peakMagnitudes(peakNumber,1)^2);
               catch
                   warning('Could not compute the Pitch Class Profile. Self-destruct sequence initiated.')
               end
            end

            try
            %For efficiency's sake, we can just explicitly carry out the summation...

                if numberOfPeaks
                    NPCP(note,frameNumber) =  PCP(note)/...
                                                        (PCP(1)+...
                                                         PCP(2)+...
                                                         PCP(3)+...
                                                         PCP(4)+...
                                                         PCP(5)+...
                                                         PCP(6)+...
                                                         PCP(7)+...
                                                         PCP(8)+...
                                                         PCP(9)+...
                                                         PCP(10)+...
                                                         PCP(11)+...
                                                         PCP(12));
                else
                    %If no peaks detected, nothing is in this frame
                    NPCP(note,frameNumber) = 0; 
                end
            catch
                       warning('Could not compute the Normalized Pitch Class Profile. Self-destruct sequence initiated.')
            end
        end

    %   syms l;
    %   PCP(c(j)+1)=symsum(m(l,c(j)+1)*abs(Y(peakFrequencies_f(locs(l))))^2,l,1,numberOfPeaks);


    end


   %Plot result
   %%{
    NPCP_flipped = flipud(NPCP);
    fig = imagesc(10*log10(NPCP_flipped))
    %fig = imagesc(10*log10(NPCP))
    %plot(weight)
    
    %Labels
    title(song_path);
    ylabel('Note');
    set(gca,'YTick',1:1:12)
    set(gca,'YTickLabel',{'G#','G','F#','F','E','D#','D','C#','C','B','A#','A'})
    xlabel('Frame Number');
    colorbar;
    colormap('jet');
    
    %Conditioning file name to properly save figure
    song_path(1:7)='';
    song_path(length(song_path)-3:length(song_path))='';
    
    fileLocation = [song_path '.png'];
    saveas(fig,fileLocation)
  %%}
   
end