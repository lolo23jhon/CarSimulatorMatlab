
% Returns the anti-clockwise angle in degrees of a bidimensional vector
function angle=get2dVectorAngle(t_vec)
if numel(t_vec) == 1
    t_vec(2) = 0;
end

if t_vec(2) == 0
    if t_vec(1)>=0
        angle = 0;
    else
        angle = 180;
    end
    return;
end

if t_vec (1)==0
    if t_vec(2)>0
        angle = 90;
    else
        angle = 270;
    end
    return;
end

a = atand(abs(t_vec(2)/t_vec(1)));
if t_vec(1)>0
    if t_vec(2) > 0
        a=a;
    else
        a=360-a;
    end
else
    if t_vec(2)>0
        a = 180 - a;
    else
        a = a + 180;
    end
end
angle = a;
end