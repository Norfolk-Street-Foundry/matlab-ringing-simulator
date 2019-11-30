% FUNCTION genringingfromlowndes
%  genringingfromlowndes( bellset, lowndes_file, wave_file)
%
% bellset is a structure containing the following elements:
%  - bells (1xN structure)
%    - handstroke (cell array of wav data, representing different handstrokes of this bell)
%    - backstroke (... backstrokes)
%  - fs (sampling frequency of the WAV data)
%  - channel (number of channels in the WAV data, typically one or two)
%  - nominal_peal_time (used if no other speed is provided)
%
% lowndes_file is a handle to a Lowndes format file containing strike times
%
% wave_file is the filename to use as output

function genringingfromlowndes( bellset, lowndes_file, wave_file)

VERSION = '0.1';

lowndes_data = lowndes.read(lowndes_file);

% Next is to generate the audio given these settings
audio_data = genAudioData( bellset, lowndes_data);

audiowrite( wave_file, audio_data, bellset.fs);

% This function converts rows into audio data given the selected
% strike_data and bellset
function audio = genAudioData( bellset, lowndes_data)

% How much silence (in seconds) do we want at the start and end of the
% touch?
presilence = 2;
postsilence = 2;

fs = bellset.fs;
postsilence_samples = round(fs*postsilence);

lastStrike = max([lowndes_data.strike.actual_time]); % in seconds

% The total length of the touch is expected to be the length of the
% pre-silence, the length of the piece plus a bit of silence after
% This is only an estimte to pre-allocate an array of *about* the right
% size - certain factors (such as considerable hum on the training sample)
% will cause the actual length to be longer than this, but that is taken
% care of later!
total_length = presilence + lastStrike + postsilence;
audio = zeros( round(total_length * fs), bellset.channels);

audio_data_internals = [];

% All the preamble is over
for writeBlows = 1:length(lowndes_data.strike)
   thisStrike = lowndes_data.strike(writeBlows);
      
   % Set a couple of convenience variables
   thisBell = thisStrike.bell;
   handstroke = thisStrike.handstroke;

   % Get the actual audio data for the bell note which about to sounded
   [bell_audio_data, audio_offset_samples, audio_data_internals] = getAudioData( thisBell, handstroke, bellset, 'random', audio_data_internals);

   strike_position = presilence+thisStrike.actual_time;

   % Convert all of this into a sample position to start writing at
   % taking into account any offset that was present in the original
   % audio data
   strike_sample = round(strike_position * fs + audio_offset_samples);

   % If the strike is before the beginning of the file, clip it into
   % the file
   if (strike_sample<1)
       strike_sample=1;
       warning('Attempting to write audio before start of file')
   end


   last_write_loc = strike_sample + size(bell_audio_data,1);
   % Check that the last location to be writte is still within the file
   % If not, then make the audio longer to accommodate
   if ( (size(audio,1)-postsilence_samples) < last_write_loc)
       audio(last_write_loc+postsilence_samples, :) = 0;
   end

   audio_indexer = (1:size(bell_audio_data,1))-1;

   % Add the audio strike into the output
   audio( strike_sample + audio_indexer, :) = audio( strike_sample + audio_indexer, :) + bell_audio_data;
end



    
% This function returns the audio data for a given strike
% thisBell is the bell number which is about to strike
%  handstroke is a boolean (0 or 1) indicating whether this is a handstroke
%  or not
%  bellset is the structure containing the bell samples
%  strike_data contains data about the synthesis techniques
%  audio_data_internals is a structure (initially empty) which
%  algorithms can use to store persistent information
function [bell_audio_data, audio_offset_samples, audio_data_internals] = getAudioData( thisBell, handstroke, bellset, stroke_selector, audio_data_internals)

% The 'sequential' strike selector literally just cycles through candidate
% strikes of the handstroke and backstroke in order
if (strcmpi(stroke_selector, 'sequential'))
    
    % This algorithm requires persistant information
    % If we find our data store empty, then we'll initialise it to say
    % we're taking our first sample from each available bin
    if isempty(audio_data_internals)
        audio_data_internals.hand = ones( 1, length(bellset.bells));
        audio_data_internals.back = ones( 1, length(bellset.bells));
    end
    
    if handstroke
        selectedStrike = bellset.bells(thisBell).handstroke( audio_data_internals.hand(thisBell) );
        audio_data_internals.hand(thisBell) = mod( audio_data_internals.hand(thisBell), length( bellset.bells(thisBell).handstroke ) ) + 1;
    else
        selectedStrike = bellset.bells(thisBell).backstroke( audio_data_internals.back(thisBell) );
        audio_data_internals.back(thisBell) = mod( audio_data_internals.back(thisBell), length( bellset.bells(thisBell).backstroke ) ) + 1;
    end
elseif (strcmpi(stroke_selector, 'random'))    
    % Random just selects an audio sample at random for the chosen bell
    if handstroke
        selectedStrike = bellset.bells(thisBell).handstroke( randi( [1, length( bellset.bells(thisBell).handstroke)] ) );
    else
        selectedStrike = bellset.bells(thisBell).backstroke( randi( [1, length( bellset.bells(thisBell).backstroke)] ) );
    end
else
    error(['Unrecognised audio selector technique: ' strike_data.stroke_selector]);
end
bell_audio_data = selectedStrike.audio;
audio_offset_samples = selectedStrike.offset;



