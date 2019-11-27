% Returns the delta angle from one point to another
function ang = angleToPnt(t_from,t_to)

disp = t_to-t_from;
ang = get2dVectorAngle(disp);

end