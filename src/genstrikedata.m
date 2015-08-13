% FUNCTION genstrikedata
%  strike_data = genstrikedata( [strike_data] )
%
% This is a helper tool to generate a strike_data structure
%
% strike_data is a structure containing the following elements:
%  - handstroke_gap (in terms inter-bell gap - that is, normally set to 1)
%  - bell (1xN structure)
%   - offset
%    - hand (handstroke offset for this bell)
%    - back (backstroke offset for this bell)
%   - stdev
%    - hand (handstroke deviation for this bell)
%    - back (backstroke deviation for this bell)
%  - error_scale (how are the stdevs interpreted - valid settings are either 'ms' or 'bell')
%  - error_distribution (formation of  - valid settings are either 'ms' or 'bell')
%  - offset_scale (how are the offsets interpreted - valid settings are either 'ms' or 'bell')
%  - stroke_selector (how are sequential strikes chosen from the bellset
%  data)
%

function strike_data = genstrikedata(strike_data)

if ~exist('strike_data', 'var')
    strike_data = getdefaultstrikedata();
end

% Honestly, this is all a bit of a dog
% It's just a bit multi-level menu for editing parts of the structure above
% People who are sufficiently au-fait with MATLAB and structure may just
% prefer to edit the structures directly by hand!!!!



toplevel_options = {
        'Change number of bells', 'editNumberOfBells';
        'Edit bell details', 'editBellDetails';
        'Edit handstroke gap', 'editHStrokeGap';
        'Edit error model', 'editErrorModel';
        'Edit stroke selector', 'editStrokeSelect';
        'Exit', 'timeToSayGoodbye' };


while (1)

    fprintf(' %35s: %.2f\n', 'Handstroke gap', strike_data.handstroke_gap );
    fprintf(' %35s: %d\n', 'Bell offsets/deviations defined', length(strike_data.bell) );
    fprintf(' %35s: Model: %s  Scaling: %s\n', 'Errors', strike_data.error_distribution, strike_data.error_scale );
    fprintf(' %35s: %s\n', 'Offset scale', strike_data.offset_scale );
    fprintf(' %35s: %s\n', 'Stroke select', strike_data.stroke_selector );
    
    
    tl = kmenu('What would you like to do?', toplevel_options(:, 1), 1 );

    thisfunc  =  toplevel_options{tl, 2};
    if ( strcmp(thisfunc, 'timeToSayGoodbye') )
        break
    end
    
    strike_data = feval( thisfunc, strike_data );
end

function strike_data = editNumberOfBells(strike_data)

number_of_bells = input('How many bells would you like now? ');

if (number_of_bells<length(strike_data.bell))
    strike_data.bell = strike_data.bell(1:number_of_bells);
else
    disp('Set your default bell properties for the extra bells');
    default_bell = editBellData( strike_data.bell(1) );
    bell_array = strike_data.bell;
    bell_array(end+1:number_of_bells) = default_bell;
    strike_data.bell = bell_array;
end

function strike_data = editBellDetails(strike_data)

fprintf('          Offset             Stdev\n');
fprintf('Bell#   Hand   Back       Hand   Back\n');
for ind=1:length( strike_data.bell )
    this_bell = strike_data.bell(ind);
    fprintf('%2d     %6.3f %6.3f    %6.3f  %6.3f\n', ind, this_bell.offset.hand, this_bell.offset.back, this_bell.stdev.hand, this_bell.stdev.back );
end

while (1)
    editSel = kmenu('What would you like to do?', { 'Set all bells to the same values', 'Edit a particular bell', 'Finish' } );
    switch editSel
        case 1
            new_bell = editBellData( strike_data.bell(1) );
            bell_array(1:length(strike_data.bell)) = new_bell;
            strike_data.bell = bell_array;
        case 2
            bellSel = input('Which bell would you like to edit? ');
            if (bellSel>0 && bellSel<=length( strike_data.bell) )
                strike_data.bell(bellSel) = editBellData(strike_data.bell(bellSel));
            end
        case 3
            break
    end
end


% Edit the handstroke gap in the current data
function strike_data = editHStrokeGap(strike_data)

strike_data.handstroke_gap = input('Enter the new handstroke gap (0.0 = cartwheel, 1.0 = std ringing): ');

% Update the strike error model
function strike_data = editErrorModel(strike_data)

error_dists = { 'Normal (strike errors follow a gaussian distribution of the specified stdev)', 'normal' };
error_scales = { 'Bell time (figures are relative to the normal gap between bells)', 'bell'; 'Milliseconds (figures are in true milliseconds)', 'ms'  };

err_dist_sel = kmenu( 'Select the new error distribution', error_dists(:,1), 1);
err_scale_sel = kmenu( 'Select the new error scale', error_scales(:,1), 1);

strike_data.error_distribution = error_dists{err_dist_sel, 2};
strike_data.error_scale = error_scales{err_scale_sel, 2};

% Edit the way that strikes are selected to generate the audio data
function strike_data = editStrokeSelect(strike_data)

stroke_selectors = { 'Sequential (strokes are played sequentially)', 'sequential'; 'Random (strokes are selected at random)', 'random'  };
stroke_sel = kmenu( 'Select the stroke selector', stroke_selectors(:,1), 1);

strike_data.stroke_selector = stroke_selectors{stroke_sel, 2};

% Create one bell's worth of striking data
function bell_data = editBellData( bell_data )

if ~exist( 'bell_data', 'var')
    bell_data = [];
end

if isempty(bell_data)
    bell_data.offset.hand = 0;
    bell_data.offset.back = 0;
    bell_data.stdev.hand = 0;
    bell_data.stdev.back = 0;
end

while (1)
    if ( all( abs( [bell_data.offset.hand, bell_data.offset.back]) < 1.0 ) )
        fprintf(' %35s: Hand: %.4f  Back: %.4f\n', 'Offset', bell_data.offset.hand, bell_data.offset.back);
    else
        fprintf(' %35s: Hand: %.2f  Back: %.2f\n', 'Offset', bell_data.offset.hand, bell_data.offset.back);
    end
    
    if ( all( abs( [bell_data.stdev.hand, bell_data.stdev.back]) < 1.0 ) )
        fprintf(' %35s: Hand: %.4f  Back: %.4f\n', 'Standard dev', bell_data.stdev.hand, bell_data.stdev.back);
    else
        fprintf(' %35s: Hand: %.2f  Back: %.2f\n', 'Standard dev', bell_data.stdev.hand, bell_data.stdev.back);
    end
    
    editSel = kmenu('What would you like to do?', {'Set offset', 'Set stdev', 'Done'} , 1 );
    
    switch (editSel)
        case 1
            new_offset = input('New offsets: ');
            switch length(new_offset)
                case 1
                    bell_data.offset.hand = new_offset;
                    bell_data.offset.back = new_offset;
                case 2                    
                    bell_data.offset.hand = new_offset(1);
                    bell_data.offset.back = new_offset(2);
                otherwise
                    disp('Nah - that''s not a thing');
            end
        case 2
            new_stdev = input('New stdevs: ');
            switch length(new_stdev)
                case 1
                    bell_data.stdev.hand = new_stdev;
                    bell_data.stdev.back = new_stdev;
                case 2                    
                    bell_data.stdev.hand = new_stdev(1);
                    bell_data.stdev.back = new_stdev(2);
                otherwise
                    disp('Nah - that''s not a thing');
            end
        case 3
            break
        otherwise
            disp('I have no idea what is happening right now');
    end   
        
end


