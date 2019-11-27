% Describes a road from polinomial equation
classdef Path < handle
    properties
        
        % With of the track
        m_track_w;
        
        % Color of the plotted line
        m_color = "k";
        
        % Cell with matrices for x and y positions of the central road line
        m_plotLine
        
        % Line of upper road bound
        m_topLine;
        
        % Line of lower road bound
        m_botLine;
        
        % First position of trajectory (coordinate pair in m)
        m_beginPos;
        
        % Last position of trajectory (coordinate pair in m)
        m_endPos;
        
        % Coefficient of holographic stretching of the original function
        m_mult;
        
        % Function of trajectory
        m_y;
        
        % Function of first derivative of trajectory
        m_dy;
    end
    
    methods
        
        % Class constructor
        function this = Path(t_xo,t_xf,t_dx,t_coeffs,t_track_w,t_mult)
            
            % Default values for coefficients
            a = -0.007552929343861*t_mult;
            b = 0.347473792556214*t_mult;
            c = - 4.14992897000649*t_mult;
            d = 33.4303412299605*t_mult;
            
            if numel(t_coeffs) == 4
                
                a = t_coeffs(1)*t_mult;
                b = t_coeffs(2)*t_mult;
                c = t_coeffs(3)*t_mult;
                d = t_coeffs(4)*t_mult;
                
            end
            
            % Assign the function ptrs
            this.m_y = @(x) a*(x/t_mult).^3 + b*(x/t_mult).^2 + c*(x/t_mult) + d;
            this.m_dy = @(x) 3*a*(x/t_mult).^2 + 2*b*(x/t_mult) + c;
            
            % The width of the track
            this.m_track_w = t_track_w;
            
            % Apply the multiplier to the domain
            t_xo = t_xo * t_mult;
            t_xf = t_xf * t_mult;
            
            % Start and finish positions of the track
            this.m_beginPos = [t_xo,this.m_y(t_xo)];
            this.m_endPos = [t_xf,this.m_y(t_xf)];
            
            % Initialize the center plot line of the road
            x_coord = t_xo:t_dx:t_xf;
            y_coord = this.m_y(x_coord);
            this.m_plotLine = {x_coord,y_coord};
            
            
            % Get the top and bottom borders using the perpendicular of the
            % tangent
            bot_x = [];
            bot_y = [];
            top_x = [];
            top_y = [];
            dist = this.m_track_w/2;
            
            for i = 2:numel(x_coord)
                
                % Get the displacement from last point to current point
                dispVec = [x_coord(i),y_coord(i)] - [x_coord(i-1),y_coord(i-1)];
                
                % Make a vector the length of the track/2 in the same direction 
                dispVec = magTimesVector(dist,dispVec);
                
                % Rotate them perpendicularly to get the points of the
                % borders
                bot = rotate2dVector(dispVec,270);
                top = -bot;
                
                bot_x(i-1) = x_coord(i-1) + bot(1);
                bot_y(i-1) = y_coord(i-1) + bot(2);
                top_x(i-1) = x_coord(i-1) + top(1);
                top_y(i-1) = y_coord(i-1) + top(2);
            end
            
            this.m_botLine = {bot_x, bot_y};
            this.m_topLine = {top_x, top_y};
            
        end % Path()
        
        % Plots the equation of the path
        function drawPath(this)
            
            % Plot center line
            plot(this.m_plotLine{1}, this.m_plotLine{2},"Color", this.m_color);
            
            % Plot borders
            plot(this.m_topLine{1}, this.m_topLine{2},"Color", this.m_color);
            plot(this.m_botLine{1}, this.m_botLine{2},"Color", this.m_color);
            
            % Mark start and finish positions
            plot([this.m_beginPos(1),this.m_endPos(1)],[this.m_beginPos(2),this.m_endPos(2)],'or');
            
        end
        
        % Places a point on the given x position of the path
        function hilightXpos(this, t_x,t_marker)
            plot(t_x,this.m_y(t_x),t_plot,t_marker);
        end
        

    end % methods
    
end % Path < handle