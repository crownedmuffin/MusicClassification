numberOfSongs = 150;
numberOfSongsInFolder = 25;
numberOfGenres = 6;


%NOTE: Matlab must be operating in the folder containing this script for the
%code below to work. Will need to eliminate this dependency sometime.
datasetSubfolder = './data/';
genreSubfolders = dir(datasetSubfolder);

%Ad-hoc solution to get rid of source controlled remnants detected in the folder
%These are added as the first contents in the struct
genreSubfolders(1:2) = []; 

%Amount of seconds in two minutes
twoMinutes = 2*60;

%frame size shall be 512 as described in project
frameSize_N = 512;
window = hann(frameSize_N);

%Switch indicating that we need to compute mfcc values 
need_to_compute_mfcc = 1;


song = struct('filepath',[]);
for i = 1:numberOfGenres
    %Get path to genre subfolder
    path_to_genre_subfolders = [datasetSubfolder genreSubfolders(i).name '/'];
    songs_in_subfolder = dir(path_to_genre_subfolders);
    
    %Get rid of source controlled remnants (usuallyy first two files listed)
    songs_in_subfolder(1:2) = [];
    
    for j = 1:25
       
        %Create an index for each song. 
        songIndex = ((i-1)*25) + j;
        
         %Catalog song path in a struct
        song(songIndex).filepath = [path_to_genre_subfolders songs_in_subfolder(j).name];
    end
end

precomputed_mfcc_values = struct('result',[]);

try
    load('precomputed_mfcc_values.mat')
    need_to_compute_mfcc = 0;
catch
    warning('File: precomputed_mfcc_values.mat not present.')
    need_to_compute_mfcc = 1;
end


%Compute mfcc values if we don't have pre-loaded values. Should take about 1.5 minutes on a dual core laptop.
if need_to_compute_mfcc
    tic
    for i = 1:numberOfGenres
        for j = 1:numberOfSongsInFolder
           [song_signal, song_sampleRate] = slice_audio(song(songIndex).filepath,twoMinutes,1); 


           songIndex = ((i-1)*25) + j;

           mfcc_result = mfcc(song_signal,song_sampleRate,frameSize_N,window);
           precomputed_mfcc_values(songIndex).result = mfcc_result;
        end
    end
    toc
end

%Average distance across genres
avgGenreDistance = zeros(numberOfGenres,numberOfGenres);

%Matrix containing the distance each song is from each other
songDistances = zeros(numberOfSongs,numberOfSongs);

currentCompare = [0 0 0 0];
prevCompare = [0 0 0 0];


%Computing distance(songX,songY)

tic
for genreX = 1:6
    for songX = 1:25
        songXIndexOffset = ((genreX-1)*25);
        songXIndex = songXIndexOffset + songX;
        for genreY = genreX:6
            for songY = 1:25
                %Computing index (song number) for songY
                songYIndexOffset = ((genreY-1)*25);
                songYIndex = songYIndexOffset + songY;
                
                %fprintf('genreX = %d, songX = %d, genreY = %d, songY = %d\n',genreX,songX, genreY, songY)
                %fprintf('distance(%d,%d)\n\n',songXIndex,songYIndex)
                try
                 songDistances(songXIndex,songYIndex) = distanceBetweenSongs(precomputed_mfcc_values(songXIndex).result, ...
                                                                             precomputed_mfcc_values(songYIndex).result);
                 %Map values to other side of diagonol for a completed
                 %matrix
                 songDistances(songYIndex,songXIndex) = songDistances(songXIndex,songYIndex);
                catch
                    warning('Something is wrong.')
                    fprintf('Trouble computing songX = %d, songY = %d',songXIndex,songYIndex);
                end
                
                avgGenreDistance(genreX,genreY) = songDistances(songXIndex,songYIndex)...
                                                  + avgGenreDistance(genreX,genreY);
                                              
                avgGenreDistance(genreY,genreX) = avgGenreDistance(genreX,genreY);
               
            end
        end
     end
end  
toc

%Compute the average distance: divide by number of data points used to 
%compute the total distances (625)
avgGenreDistance = (1/(25^2))*avgGenreDistance;


figure
fig1 = imagesc(songDistances);
colormap('jet')
colorbar

figure
fig2 = imagesc(avgGenreDistance);
colormap('jet')
colorbar
