% FUNCTION rows_from_gsiril
%  Convert gsiril touch file into rows to be rung
%
% Usage:
%   output_rows = rows_from_gsiril( touch_file )
%
% The Gsiril executable is assumed to be in an immediate subdirectory
% called 'gsiril' and all the touch files are assumed to be stored in
% 'gsiril/touches'
function output_rows = rows_from_gsiril( touch_file )

[result, rowout] = system([fullfile('gsiril', 'gsiril') ' -E < ' fullfile('gsiril', 'touches', touch_file)]);

partial_row = [];
output_rows = [];

for nxtChr = rowout
    switch (nxtChr)
        case '1'
            partial_row(end+1) = 1;
        case '2'
            partial_row(end+1) = 2;
        case '3'
            partial_row(end+1) = 3;
        case '4'
            partial_row(end+1) = 4;
        case '5'
            partial_row(end+1) = 5;
        case '6'
            partial_row(end+1) = 6;
        case '7'
            partial_row(end+1) = 7;
        case '8'
            partial_row(end+1) = 8;
        case '9'
            partial_row(end+1) = 9;
        case '0'
            partial_row(end+1) = 10;
        case 'E'
            partial_row(end+1) = 11;
        case 'T'
            partial_row(end+1) = 12;
        case {' '}
        case {10, 13}
            output_rows = [output_rows; partial_row];
            partial_row = [];
        otherwise
            disp( 'Gsiril output: ');
            disp( rowout );
            error(['I have no idea which bell ''' nxtChr ''' is']);
    end
end

