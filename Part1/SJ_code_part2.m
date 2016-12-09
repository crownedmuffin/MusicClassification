[wav]= audioread('track201-classical.wav');
newwav = Tsecond(wav,24);
fs = 11025;
N = 512;
%Size of the T-seconds of song
songsize = size(newwav,1);
w = hann(N);
fo=27.5;
fk = zeros(512,1);
jump = songsize/256;
loop = 1;
for n=1:jump:songsize
    %xn is sampled from n to n+511
    xn = newwav(n:n+511);
    %xn is Fourier transformed with hann window, w
    Y = fft(w.*xn);
    Y = abs(Y);
    
    [pks,locs] = findpeaks(abs(Y));
    peaksize = size(locs,1);
    sm = zeros(peaksize,1);
    c = zeros(peaksize,1);
    PCP = zeros(12,256);
    NPCP = zeros(12,256);
    octave = zeros(peaksize,1);

    for i=1:1:512
        fk(i)=((i*fs)/N)+(n-1);
    end
    
 

   
    for j=1:1:peaksize
        sm(j)= round(12*log2(fk(locs(j))./fo));
        c(j) = mod(sm(j),12);
%        octave(j) = floor(sm(j)/12);
        r = 12*log2(fk(locs(j))./fo)-sm(j);
        
        if r>-1&&r<1
            m(j,c(j)+1) = cos(3.14*r/2);
        else
            m(j,c(j)+1) = 0;
        end
        
    end

    for f=1:1:11
        for q=1:1:peaksize
            PCP(c(f)+1,loop)= PCP(c(f)+1)+m(q,c(f)+1)*abs(Y(locs(q)))^2;
        end 
        NPCP(c(f)+1,loop) = PCP(c(f)+1)/(PCP(1)+PCP(2)+PCP(3)+PCP(4)+PCP(5)+PCP(6)+PCP(7)+PCP(8)+PCP(9)+PCP(10)+PCP(11)+PCP(12));
           
    end

%        syms l;
%       PCP(c(j)+1)=symsum(m(l,c(j)+1)*abs(Y(fk(locs(l))))^2,l,1,peaksize);
        
        loop = loop+1;
end
    imagesc(NPCP)
    plot(m)
%sm = round(12 log2(f /f0))
%[result] = mfcc(newwav, fs, fftSize,w);    
%imagesc(result) 
%imagesc(flipud(log(result)));
%colorbar;