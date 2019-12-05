% Banner.m
% Object that plots text and shows data on plot
classdef Banner
   properties 
       
      % Reference x and y vector
      m_pos;
      
      % Text message formatted string
      m_str;
      
      % Distance from reference position
      m_disp_xy;
      
   end
   properties (Constant)
       
      
      s_lineColor = 'k';
      
   end
   methods
       % Class constructor
       function this = Banner(t_pos,t_str,t_disp_xy)
           this.m_pos = t_pos;
           this.m_str = t_str;
           this.m_disp_xy = t_disp_xy;
       end
       
       % Update the banner on screen
       function updateBanner(this,t_pos,t_disp_xy, t_vars)
          this.m_pos = t_pos;
          this.m_disp_xy = t_disp_xy;
          textPos = t_pos + this.m_disp_xy;
          msg = sprintf(this.m_str,t_vars(:));          
          text(textPos(1),textPos(2),msg );
          line_x = [t_pos(1),textPos(1)];
          line_y = [t_pos(2), textPos(2)];
          plot(line_x,line_y,"Color", this.s_lineColor);
       end
             
       
   end
    
    
    
end