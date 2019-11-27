% Simple polyshape wrapper for drawing boxes on screen
classdef Box < handle
    properties
        % Polyshape of the model of the box object
        m_poly;
        
        % Color of the polyshape
        m_color;
    end
    methods
        
        % Class constructor
        function this = Box(t_x,t_y,t_scale,t_color)
            this.m_color = t_color;    
            this.m_poly = scale(polyshape(t_x,t_y),t_scale);
           end
        
        % Displays the graphic on the plot
        function drawBox(this)
            plot(this.m_poly,"FaceColor",this.m_color)
        end
        
        % Draws all the boxes in a box vector
        function drawBoxes(t_boxVector)
           for i = 1:numel(t_boxVector)
              drawBox(t_boxVector(i));
           end
        end
    end
end