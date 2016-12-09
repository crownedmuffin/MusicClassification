function [C] = mychroma (signal,samplingRate,lengthFFT)
%
%
%  Computes the 12 x nframes chroma representation
%
%  The computation procedes in two steps: 
%    1) an estimate of the instantaneous frequency is computed using the derivative of the
%    phase. This idea relies on the concept of the analytical signal.
%    2) the energy associated with the instantaneous frequency is folded back into the octave
%    defined by A0.


A0    = 27.5; 

frameSize   = lengthFFT/2;
frameSize2 = lengthFFT/4;

nchr = 12;

s = length(signal);
nFrames = 1 + floor((s - (frameSize))/(frameSize2));

T = (frameSize)/samplingRate;

win = 0.5*(1-cos([0:((frameSize)-1)]/(frameSize)*2*pi));
dwin = -pi / T * sin([0:((frameSize)-1)]/(frameSize)*2*pi);

norm = 2/sum(win);

iF = zeros(1 + frameSize, nFrames);
S = zeros(1 + frameSize, nFrames);

nmw1 = floor(frameSize2);
nmw2 = frameSize - nmw1;

ww = 2*pi*[0:(lengthFFT-1)]*samplingRate/lengthFFT;

%
% computation of the instantaneous frequency, using the analytical expression of the derivative of the phase

for ifrm = 1:nFrames
    
    u = signal((ifrm-1)*(frameSize2) + [1:(frameSize)]);

    wu = win.*u;
    du = dwin.*u;

    wu = [zeros(1,nmw1),wu,zeros(1,nmw2)];
    du = [zeros(1,nmw1),du,zeros(1,nmw2)];

    t1 = fft(fftshift(du));
    t2 = fft(fftshift(wu));

    S(:,ifrm) = t2(1:(1 + frameSize))'*norm;

    t = t1 + j*(ww.*t2);
    a = real(t2);
    b = imag(t2);
    da = real(t);
    db = imag(t);

    instf = (1/(2*pi))*(a.*db - b.*da)./((a.*a + b.*b)+(abs(t2)==0));

    iF(:,ifrm) = instf(1:(1 + frameSize))';
end;


%
% now we find the local maxima of the instantaneous frequency

f_ctr = 1000;
f_sd = 1; 

f_ctr_log = log2(f_ctr/A0);
fminl   = oct2hz(hz2oct(f_ctr)-2*f_sd);
fminu  = oct2hz(hz2oct(f_ctr)-f_sd);
fmaxl  = oct2hz(hz2oct(f_ctr)+f_sd);
fmaxu = oct2hz(hz2oct(f_ctr)+2*f_sd);

minbin  = round(fminl * (lengthFFT/samplingRate) );
maxbin = round(fmaxu * (lengthFFT/samplingRate) );

%
% compute the second order derivative of the instantaneous frequency to detect the peaks

ddif    = [iF(2:maxbin, :);iF(maxbin,:)] - [iF(1,:);iF(1:(maxbin-1),:)];

% clean a bit

dgood = abs(ddif) < .75*samplingRate/lengthFFT;

dgood = dgood .* ([dgood(2:maxbin,:);dgood(maxbin,:)] >  0 | [dgood(1,:);dgood(1:(maxbin-1),:)] > 0);

p  = zeros(size(dgood));
m = zeros(size(dgood));

%
%  try to fit a second order polynomial locally

for t = 1:size(iF,2)
    ds = dgood(:,t)';
    lds = length(ds);

    st = find(([0,ds(1:(lds-1))]==0) & (ds > 0));
    en = find((ds > 0) & ([ds(2:lds),0] == 0));
    npks = length(st);
    frqs = zeros(1,npks);
    mags = zeros(1,npks);

    for i = 1:length(st)
        bump = abs(S(st(i):en(i),t));
        frqs(i) = (bump'*iF(st(i):en(i),t))/(sum(bump)+(sum(bump)==0));
        mags(i) = sum(bump);

        if frqs(i) > fmaxu
            mags(i) = 0;
            frqs(i) = 0;
        elseif frqs(i) > fmaxl
            mags(i) = mags(i) * max(0, (fmaxu - frqs(i))/(fmaxu-fmaxl));
        end

        if frqs(i) < fminl
            mags(i) = 0;
            frqs(i) = 0;
        elseif frqs(i) < fminu
            mags(i) = mags(i) * (frqs(i) - fminl)/(fminu-fminl);
        end
        if frqs(i) < 0 
            mags(i) = 0;
            frqs(i) = 0;
        end
    end

    bin = round((st+en)/2);
    p(bin,t) = frqs;
    m(bin,t) = mags;
end

ncols = size (p,2);

%
% clean up

Pocts = hz2oct(p+(p==0));
Pocts(p(:)==0) = 0;

nzp = find(p(:)>0);

[hn,hx]  = hist(nchr*Pocts(nzp)-round(nchr*Pocts(nzp)),100);
centsoff = hx(find(hn == max(hn)));

Pocts(nzp) = Pocts(nzp) - centsoff(1)/nchr;

PoctsQ = Pocts;
PoctsQ(nzp) = round(nchr*Pocts(nzp))/nchr;

Pmapc = round(nchr*(PoctsQ - floor(PoctsQ)));
Pmapc(p(:) == 0) = -1; 
Pmapc(Pmapc(:) == nchr) = 0;

C = zeros(nchr,ncols);
for t = 1:ncols;
    C(:,t)=(repmat([0:(nchr-1)]',1,size(Pmapc,1))==repmat(Pmapc(:,t)',nchr,1))*m(:,t);
end

return;