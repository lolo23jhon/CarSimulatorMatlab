% Changes the direction of the vector from a delta angle value
function vec = rotate2dVector(t_vec, t_deltaAngle)
    while t_deltaAngle < 0
        t_deltaAngle = t_deltaAngle + 360; 
    end

    i = t_vec(1) * cosd(t_deltaAngle) - t_vec(2) * sind(t_deltaAngle);
    j = t_vec(1) * sind(t_deltaAngle) + t_vec(2) * cosd(t_deltaAngle);
    vec = [i,j];
end