function [Tsecond] = Tsecond(wav,second)
fs = 11025;
%Finding first point where it's not 0 and sampling xn to N-1
S = min(find(wav ~= 0));
Tsecond = wav(S:S+second*fs , 1);
end