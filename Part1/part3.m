%{
-----------------------Compute the 6 x 6 average distance matrix between the genres-----------------------
%} 

%NOTE: Matlab must be operating in the folder containing this script for the
%code below to work. Will need to eliminate this dependency sometime.
datasetSubfolder = './data/';
genreSubfolders = dir(datasetSubfolder);

numberOfSongs = 150;
numberOfGenres = 6;

%Ad-hoc solution to get rid of source controlled remnants detected in the folder
%These are added as the first contents in the struct
genreSubfolders(1:2) = []; 
avgGenreDistance = zeros(numberOfGenres,numberOfGenres);
songDistances = zeros(numberOfSongs,numberOfSongs);

twoMinutes = 2*60;

 %frame size shall be 512 as described in project
frameSize_N = 512;
window = hann(frameSize_N);

songCount = 1;

tic
for genre1 = 1:6
    
    %Get names of all songs in genre 1
    path_to_genre1_songs = [datasetSubfolder genreSubfolders(genre1).name '/'];
    genre1_songs = dir(path_to_genre1_songs);
    
    %Ad-hoc solution to get rid of source controlled remnants detected in the folder
    genre1_songs(1:2) = []; 
    
    for genre1_song = 1:25
        %Load genre songs
        song1_filepath = [path_to_genre1_songs genre1_songs(genre1_song).name];
        [song1_signal, song1_sampleRate] = slice_audio(song1_filepath,twoMinutes,1);

        mfcc1 = mfcc(song1_signal,song1_sampleRate,frameSize_N,window);

        %Only perform computations on left side of distance matrix for
        %efficiency.
        for genre2 = genre1:6
            %{
            
            %Skip computation over similar genres
            
            if genre1 == genre2
                %For computing average distance matrix
                %If same genre, distance is 0
                avgGenreDistance(genre1,genre2) = 0;
                %Move to next genre
                continue;
            end
            %}
            
            
            %Get names of all songs in genre2
            path_to_genre2_songs = [datasetSubfolder genreSubfolders(genre2).name '/'];
            genre2_songs = dir(path_to_genre2_songs);

            %Ad-hoc solution to get rid of source controlled remnants detected in the folder
            genre2_songs(1:2) = []; 

            for genre2_song = 1:25
                
                songCount = songCount + 1

                %Read audio file
                song2_filepath = [path_to_genre2_songs genre2_songs(genre2_song).name];
                [song2_signal, song2_sampleRate] = slice_audio(song2_filepath,twoMinutes,1); 

                %Compute mfcc coefficients for genre2's song
                mfcc2 = mfcc(song2_signal,song2_sampleRate,frameSize_N,window);

                %Capture individual song distance data.
                
                %NOTE: 
                %Compute data under left side of diagonol first, then copy
                %values over to other side.
                
                %Assigning a 'song index' to each song (1 through 150).
                song1Index = genre1*genre1_song;
                song2Index = genre2*genre2_song;
                
                %Calculating distance between songs
                songDistance(song1Index,song2Index) = distanceBetweenSongs(mfcc1,mfcc2);
                songDistances(song2Index,song1Index) = songDistances(song1Index,song2Index);
                
                %EQUATION 26 (part 1 of 2): 
                %Iteratively add distances between genres below.
                
                %tic and toc were used to time this function
                %tic
                    avgGenreDistance(genre1,genre2) = (songDistances(song1Index,song2Index)...
                                                + avgGenreDistance(genre1,genre2));
                %toc      
            end
            
            %EQUATION 26 (part 2 of 2): 
            %Finally, to obtain the average genre distance, we divide by
            %the number of data points, (1/25)^2, used to compute the total distance from
            %the above for loop.
            avgGenreDistance(genre1,genre2) = (1/(25^2))*avgGenreDistance(genre1,genre2);
            
            %Matrix is symmetric. After computing half of the values on left side of the diagonol, 
            %copy values to other half of diagonol on the 6x6 avg distance matrix.
            avgGenreDistance(genre2,genre1) = avgGenreDistance(genre1,genre2);
        end
     end
end  
toc

imagesc(avgGenreDistance);
imagesc(songDistances);
colorbar;
colormap('jet');