% FUNCTION getdefaultstrikedata
% This is a helper tool to which gives the default strike_data
% (usually set for 'good ringing')

function strike_data = getdefaultstrikedata( number_of_bells )

if ~exist('number_of_bells', 'var')
    number_of_bells = [];
end
if isempty( number_of_bells )
    number_of_bells = 12;
end


strike_data.handstroke_gap = 1;
strike_data.stroke_selector = 'sequential';
strike_data.error_scale = 'ms';
strike_data.error_distribution = 'normal';
strike_data.offset_scale = 'ms';
bell.offset.hand = 0;
bell.offset.back = 0;
bell.stdev.hand = 0;
bell.stdev.back = 0;
strike_data.bell(1:number_of_bells) = bell;

