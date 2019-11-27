% Takes in a slope and returns the equivalent angle in degrees and standart
% notation (anti-clockwise from horizontal axis);
function ang = slopeToAngle(t_m)
    ang = atand(t_m);
    while ang < 0
       ang = ang + 360; 
    end
end