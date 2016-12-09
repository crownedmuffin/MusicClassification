%{
-----------------------Compute the 6 x 6 average distance matrix between the genres-----------------------
%} 



%NOTE: Matlab must be operating in the folder containing this script for the
%code below to work. Will need to eliminate this dependency sometime.
datasetSubfolder = './data/';
genreSubfolders = dir(datasetSubfolder);

%Ad-hoc solution to get rid of source controlled remnants detected in the folder
%These are added as the first contents in the struct
genreSubfolders(1:2) = []; 
genreDistance = zeros(6,6);

twoMinutes = 2*60;

for genre1 = 1:6
    
    %Get names of all songs in genre 1
    path_to_genre1_songs = [datasetSubfolder genreSubfolders(genre1).name '/'];
    genre1_songs = dir(path_to_genre1_songs);
    
    %Ad-hoc solution to get rid of source controlled remnants detected in the folder
    genre1_songs(1:2) = []; 
    
    for genre2 = 1:6
        
        %Get names of all songs in genre 2
        path_to_genre2_songs = [datasetSubfolder genreSubfolders(genre2).name '/'];
        genre2_songs = dir(path_to_genre2_songs);
        
        %Ad-hoc solution to get rid of source controlled remnants detected in the folder
        genre2_songs(1:2) = []; 
        
        for genre1_song = 1:25
            
            %Read audio file
            song1_filepath = [path_to_genre1_songs genre1_songs(genre1_song).name];
            [song1_signal, song1_fs] = slice_audio(song1_filepath,twoMinutes,1);
            
            
            for genre2_song = 1:25
                
                %Read audio file
                song2_filepath = [path_to_genre2_songs genre2_songs(genre2_song).name];
                [song2_signal, song2_fs] = slice_audio(song2_filepath,twoMinutes,1);     
                
                %Iteratively add to get distance between genres
                
                genreDistance(genre1,genre2) =  (1/(25^2))*distanceBetweenSongs(song1_signal,song1_fs,song2_signal,song2_fs)...
                                                + genreDistance(genre1,genre2);
            end
        end
    end
    
    imagesc(genreDistance);
    colorbar;
    colormap('jet');

end  