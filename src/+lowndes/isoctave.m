% FUNCTION ret = isoctave()
% 
% Returns boolean value, true if the current host environment is Octave, false if it is MATLAB
function iso = isoctave()
  persistent x;
  if isempty(x)
    x = exist('OCTAVE_VERSION', 'builtin');
  end
  iso = x;

end
