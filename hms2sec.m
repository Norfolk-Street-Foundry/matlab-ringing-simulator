% FUNCTION hms2sec
%   Convert hours, minutes and seconds to seconds
%
%     seconds = hms2sec( hours, minutes, seconds)
%
% Omitted trailing arguments will be assumed to be equal to zero
%  (e.g.  hms2sec( 3, 22 ) will be assumed to mean 3 hours, 22 minutes)
function sec = hms2sec( hours, minutes, seconds)

if (nargin<2)
    minutes = 0;
end
if (nargin<3)
    seconds = 0;
end


sec = seconds + 60*( minutes + 60*hours );
