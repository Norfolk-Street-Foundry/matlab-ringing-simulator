% Function LOWNDES.READ(infile)
% Argument:
%  infile - string with location
%
% Returns:
%  Structure with .info for metadata and .strike for strike information
function lowndes_data = read( infile )

fid = fopen( infile, 'rt');

if ~lowndes.isoctave
% Make sure that the Lowndes input is always closed in MATLAB
c = onCleanup(@()fclose(fid));
end

strike_count = 0;
base_offset = 0;
last_timestamp = 0;

bell_identifiers = { '1', '2', '3', '4', '5', '6', '7', '8', '9', 'O', 'E', 'T' };

[pathstr, basename] = fileparts( infile );

lowndes_data.info.basename = basename;

while ~feof(fid)
    nextline = strtrim(fgets(fid));
    
    if ~isempty(strfind(nextline, '#.'))
        if ~isempty( strfind(nextline, 'Lowndes:'))
            lowndes_data.info.version = nextline( 12:end );
        elseif ~isempty( strfind(nextline, 'Creator:'))
            lowndes_data.info.creator = nextline( 12:end );
        elseif ~isempty( strfind(nextline, 'TranscriptionDate:'))
            lowndes_data.info.transcription_date = nextline( 22:end );
        elseif ~isempty( strfind(nextline, 'FirstBlowMs:'))
            lowndes_data.info.first_blow = sscanf(nextline, '#. FirstBlowMs: %i');
        end
    else
        [data, conversion] = sscanf( nextline, '%c %c %i');
        if conversion==3
            handstroke = (data(1) == 'H');
            bell = strmatch( char(data(2)),  bell_identifiers);
            if isempty(bell)
                ME = MException('LoadLowndes:Cnv', sprintf('Cannot recognise bell %s', char(data(2)) ) );
                throw(ME);
            end
            timestamp = data(3);
            if (timestamp < last_timestamp)
                base_offset = base_offset + 65536;
            end
            strike_time = (timestamp + base_offset)/1000;
            strike_count = strike_count + 1;
            
            last_timestamp = timestamp;
            
            lowndes_data.strike(strike_count).handstroke = handstroke;
            lowndes_data.strike(strike_count).bell = bell;
            lowndes_data.strike(strike_count).actual_time = strike_time;
        end
    end
end

lowndes_data.info.bells_present = unique( [ lowndes_data.strike.bell ] );
if all( lowndes_data.info.bells_present  == 1:length(lowndes_data.info.bells_present) )
    lowndes_data.info.bell_count = length(lowndes_data.info.bells_present);
else
    lowndes_data.info.bell_count = NaN;
end

if lowndes.isoctave
    fclose(fid);
end

