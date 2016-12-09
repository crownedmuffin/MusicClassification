function demochrom (filename)

BasePath = ['/Users/francois/class/4532/tracks/'];

[x,fs] = audioread([BasePath '/' filename '.wav']);

x = x';

fftlen= 2048;

[C] = mychroma (x, fs, fftlen);

figure;

tt = [1:size(C,2)]*fftlen/4/fs;

imagesc(tt,[1:12],20*log10(C+eps));

axis xy
set (gca, 'YTick', [1:12]);
set (gca, 'YTickLabel', {'A', 'A#','B','C','C#','D','D#','E','F','F#','G','G#'});
set (gca, 'XTick', [0:60:ceil(tt(end))]);
caxis(max(caxis)+[-60 0])

title(['Chroma of ' filename]);
colormap('jet');hold on;colorbar;

return;