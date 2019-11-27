% Returns the distancd bewteen two points in cartesian coordinates
function d = dist2Pts(t_p1, t_p2)
    d = sqrt((t_p1(1)-t_p2(1))^2+(t_p1(2)-t_p2(2))^2);
end