% Constructs a vector from an angle and magnitude
function vec = angleToVector(t_angle,t_mag)
if t_angle >= 360
    t_angle = mod(t_angle,360);
end

switch (t_angle)
    case 0
        vec = [1,0];
    case 90
        vec = [0,1];
    case 180
        vec = [-1,0];
    case 270
        vec = [0,-1];
    otherwise
        % Quadrant I: all positive
        vec = [abs(cosd(t_angle)),abs(sind(t_angle))];  
            
        if t_angle > 90 && t_angle < 180
            % Quadrant II: sine positive 
            vec = [-vec(1),vec(2)];
        elseif t_angle > 180 && t_angle < 270
            % Quadrant III: tangent positive
            vec = -vec;
        elseif t_angle > 270 && t_angle < 360
            % Quadtant IV : cosine positive
            vec = [vec(1),-vec(2)];
        end
end
vec = magTimesVector(t_mag,vec);
end