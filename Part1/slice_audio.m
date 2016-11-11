function [song, audio_data, Fs, start, stop] = slice_audio(audio_filepath,time_slice,from_middle)      
    %Extracts T seconds from a given song (as explicitly required in question 1 and 3)

    %Usage: 
    %Inputs: provide path to file, amount of time you want to extract and
    %a boolean value for if you want to take out information from the
    %middle or from the beginning (no other location supported yet)
    
    %Outputs:
    %Song Object, raw audio data, sampling rate, start time, stop time.
 
    %Read audio file
    [audio_data, Fs] = audioread(audio_filepath);
    
    %Form audio object to easily collect data about song
    song = audioplayer(audio_data,Fs);
   
    if not(from_middle)
        %Extract information from beginning to time "time_sample"
        start = 1;                          %Indicates beginning
        stop = song.SampleRate*time_slice;  %Ending time defined by user  
    else
        %Take from the middle
        start = song.TotalSamples/2;
        %End at specified time after middle of song
        stop = start + song.SampleRate*time_slice;
    end    
end