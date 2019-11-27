function vec = incrementVector(t_vec,t_mag)
    uniVec = getUnitaryVector(t_vec);
    
    angle = atand(uniVec(2)/uniVec(1));
    
    deltaVec = t_mag*[sind(angle),cosd(angle)];

    vec = t_vec + deltaVec;
end