% FUNCTION kmenu
%
%  selected_ans = kmenu(header, items [, must_select])
%
% This function is provided with a header string plus a cell array of
% string options
% The function retuns a number between 1 and the number of options, or an
% empty array if the user did not select one of the given options.
% If must_select is true, then the user will continue to be prompted until
% they respond with one of the given options
%
function selected = kmenu( header, items, must_select )
if (~exist('must_select', 'var'))
    must_select = [];
end
if (isempty(must_select))
    must_select = 0;
end


first_loop = 1;

while (first_loop || must_select)
    fprintf('%s:\n', header);
    for itemInd = 1:length(items)
        fprintf(' %d - %s\n', itemInd, items{itemInd});
    end

    fprintf('\nPlease select an option: ');
    selected = input('');
    
    if (~isscalar(selected))
        selected = [];
    else
        if (selected<1 || selected>length(items))
            selected = [];
        else
            break;
        end
    end
    first_loop = 0;
end
