function [hz] = oct2hz(octs,A440)

if nargin < 2;   
    A440 = 440; 
end

hz = (A440/16).*(2.^octs);

return;
