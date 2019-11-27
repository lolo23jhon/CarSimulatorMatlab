classdef Camera < handle
    properties
        
        % Current central position the camera is viewing
        m_pos;
        
        % Size of the axis
        m_axisSize;
        
    end
    
    
    properties (Constant)
        
    end
    methods
        
        % Class constructor
        function this = Camera(t_pos,t_axisSize)
            this.m_pos = t_pos;
            this.m_axisSize = t_axisSize;
        end
        
        % Gets the index of the righmost car given a car vector
        function carNum = getRightmostCar(~,t_cars)
            carNum = NaN;
            x_pos = -inf;
            for i = 1:numel(t_cars)
               if t_cars(i).m_p(1) > x_pos 
                  x_pos =  t_cars(i).m_p(1);
                  carNum = i;
               end
            end            
        end
        
        
        
        % Updates the position and axisSize of the camera
        function updateCamera(this,t_cars)
           this.m_pos = t_cars(getRightmostCar(this,t_cars)).m_p;
           
           axS = this.m_axisSize/2;
           c = this.m_pos;
           x_ax = c(1)+[-axS,axS];
           y_ax = c(2)+[-axS,axS];
           
           axis equal;
           axis([x_ax(1),x_ax(2),y_ax(1),y_ax(2)]);
        end
    end
end