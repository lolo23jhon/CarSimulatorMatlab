% Returns the vector of a magnitude projected onto a vector's direction
% (is doesn't operate on it, just gives the magnitude its direction)
function vec =magTimesVector(t_mag,t_vec)

if t_mag ~= 0
    uniVec = getUnitaryVector(t_vec);
    angle = get2dVectorAngle(uniVec);
    
    vec = t_mag * [cosd(angle),sind(angle)];
else 
    vec = [0,0];
    
end

end