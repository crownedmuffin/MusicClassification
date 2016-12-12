%--------------------------------------------------------------------------
%                       VARIABLE/MATRIX INITIALIZATION
%--------------------------------------------------------------------------


numberOfSongs = 150;
numberOfSongsInFolder = 25;
numberOfGenres = 6;


%IMPORTANT: Matlab must be operating in the folder containing for the
%following two lines to work. Will need to eliminate this dependency sometime.
datasetSubfolder = './data/';
genreSubfolders = dir(datasetSubfolder);

%Ad-hoc solution to get rid of source controlled remnants detected in 
%the folder. These are added as the first contents in the struct
genreSubfolders(1:2) = []; 

%Amount of seconds in two minutes
twoMinutes = 2*60;

%frame size shall be 512 as described in part 3
frameSize_N = 512;
window = hann(frameSize_N);

%Matrix to contain info of average distance from genreX to genreY
avgGenreDistanceUsingMFCC = zeros(numberOfGenres,numberOfGenres);
avgGenreDistanceUsingChroma = zeros(numberOfGenres,numberOfGenres);

%Matrix to contain info of distance of songX from songY
songDistancesUsingMFCC = zeros(numberOfSongs,numberOfSongs);
songDistancesUsingChroma = zeros(numberOfSongs,numberOfSongs);

%Data structure to hold all precomputed mfcc values
precomputed_mfcc_values = struct('result',[]);

%Data structure to hold all precomputed chroma values
precomputed_chroma_values = struct('result',[]);

%Data structure holding the filepaths to all songs to be analyzed
song = struct('filepath',[]);

%--------------------------------------------------------------------------
%                               COMPUTATIONS
%--------------------------------------------------------------------------
%Catalog the filepaths to each song

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

%Pre-load MFCC coefficients 
try
    load('precomputed_mfcc_values.mat')
    need_to_compute_mfcc = 0;
catch
    warning('File: precomputed_mfcc_values.mat not present.')
    need_to_compute_mfcc = 1;
end


%Pre-Compute MFCC coefficients if no values can be preloaded 
%(1.5 minutes using a i7-6700U dual core laptop) 
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

%Pre-load chroma coefficients 
try
    load('precomputed_chroma_values.mat')
    need_to_compute_chroma = 0;
catch
    warning('File: precomputed_chroma_values.mat not present.')
    need_to_compute_chroma = 1;
end


%Pre-Compute Chroma values if no values can be preloaded
if need_to_compute_chroma
    tic
    for i = 1:numberOfGenres
        for j = 1:numberOfSongsInFolder
           [song_signal, song_sampleRate] = slice_audio(song(songIndex).filepath,twoMinutes,1); 

           songIndex = ((i-1)*25) + j;

           %chroma_result = NormPitchClassProfile(song_signal);
           chroma_result = mychroma(song_signal,song_sampleRate,512);
           precomputed_chroma_values(songIndex).result = chroma_result;
        end
    end
    toc
end


%--------------------------------------------------------------------------
%Computing the Individial and Average Distance Matrices
%--------------------------------------------------------------------------
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
                
                %Code used for debugging
                %fprintf('genreX = %d, songX = %d, genreY = %d, songY = %d\n',genreX,songX, genreY, songY)
                %fprintf('distance(%d,%d)\n\n',songXIndex,songYIndex)
                
                %----------------------------------------------------------
                %Compute Distances using MFCC coefficients
                %----------------------------------------------------------
                try
                 songDistancesUsingMFCC(songXIndex,songYIndex) = ...
                 distanceBetweenSongs(precomputed_mfcc_values(songXIndex).result, ...
                                      precomputed_mfcc_values(songYIndex).result);
                                  
                 %Map values to other side of diagonol to complete the matrix
                 songDistancesUsingMFCC(songYIndex,songXIndex) = songDistancesUsingMFCC(songXIndex,songYIndex);
                catch
                    warning('Something is wrong.')
                    fprintf('Trouble computing songX = %d, songY = %d',songXIndex,songYIndex);
                end
                avgGenreDistanceUsingMFCC(genreX,genreY) = songDistancesUsingMFCC(songXIndex,songYIndex)...
                                                  + avgGenreDistanceUsingMFCC(genreX,genreY);
                %Map values to it's reflection across the matrix's diagonol                              
                avgGenreDistanceUsingMFCC(genreY,genreX) = avgGenreDistanceUsingMFCC(genreX,genreY);
               
                %----------------------------------------------------------
                %Compute Distances using chroma
                %----------------------------------------------------------
                 try
                 songDistancesUsingChroma(songXIndex,songYIndex) = ...
                 distanceBetweenSongs(precomputed_chroma_values(songXIndex).result, ...
                                      precomputed_chroma_values(songYIndex).result,0);
                                  
                 %Map values to other side of diagonol to complete the matrix
                 songDistancesUsingChroma(songYIndex,songXIndex) = songDistancesUsingChroma(songXIndex,songYIndex);
                catch
                    warning('Something is wrong.')
                    fprintf('Trouble computing songX = %d, songY = %d',songXIndex,songYIndex);
                end
                avgGenreDistanceUsingChroma(genreX,genreY) = songDistancesUsingChroma(songXIndex,songYIndex)...
                                                  + avgGenreDistanceUsingChroma(genreX,genreY);
                %Map values to it's reflection across the matrix's diagonol                              
                avgGenreDistanceUsingChroma(genreY,genreX) = avgGenreDistanceUsingChroma(genreX,genreY);
            end
        end
     end
end  
toc

%Compute the average distance: divide by number of data points used to 
%compute the total distances (625)
avgGenreDistanceUsingMFCC = (1/(25^2))*avgGenreDistanceUsingMFCC;
avgGenreDistanceUsingChroma = (1/(25^2))*avgGenreDistanceUsingChroma;


figure
fig1 = imagesc(max_values_chroma)
colormap('jet')
title('Maximized Average Genre Distance Matrix Using Chroma Values');
ylabel('Genre by Genre Number');
xlabel('Genre by Genre Number')
colorbar

figure
fig2 = imagesc(songDistancesUsingChroma);
title('Song Distance Matrix Using Chroma Values');
ylabel('Songs by Index Number');
xlabel('Songs by Index Number')
colormap('jet')
colorbar

figure
fig3 = imagesc(avgGenreDistanceUsingChroma);
title('Average Genre Distance Matrix Using Chroma Values');
ylabel('Genre by Genre Number');
xlabel('Genre by Genre Number');
colormap('jet')
colorbar

figure
fig4 = imagesc(songDistancesUsingMFCC);
title('Song Distance Matrix Using MFCC Values');
ylabel('Songs by Index Number');
xlabel('Songs by Index Number')
colormap('jet')
colorbar

figure
fig5 = imagesc(avgGenreDistanceUsingMFCC);
title('Average Genre Distance Matrix Using MFCC Values');
ylabel('Genre by Genre Number');
xlabel('Genre by Genre Number');
colormap('jet')
colorbar