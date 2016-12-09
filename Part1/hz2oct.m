function [oct] = hz2oct(freq, A440)

if nargin < 2;   
    A440 = 440; 
end
oct = log(freq./(A440/16))./log(2);

return;
