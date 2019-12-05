% Banner.m
% Object that plots text and shows data on plot
classdef Banner
   properties 
       
      % Reference x and y vector
      m_pos;
      
      % Text message formatted string
      m_str;
      
      % Distance from reference position
      m_distFromPos;
      
   end
   properties (Constant)
       
      
      s_lineColor = 'k';
      
   end
   methods
       % Class constructor
       function this = Banner(t_pos,t_str)
           this.m_pos = t_pos;
           this.m_str = t_str;
       end
       
       % Update the banner on screen
       function updateBanner(this,t_pos,t_xyTrans, t_vars)
          this.m_pos = t_pos;
          this.m_distFromPos = t_xyTrans;
          textPos = t_pos + this.m_distFromPos;
          msg = sprintf(this.m_str,t_vars(:));          
          text(textPos(1),textPos(2),msg );
          line_x = [t_pos(1),textPos(1)];
          line_y = [t_pos(2), textPos(2)];
          plot(line_x,line_y,"Color", this.s_lineColor);
           
       end
       
       
   end
    
    
    
end