classdef CarAi < handle
    properties
        % Pointer to road
        m_path;
        
        % Distance from a checkpoint needed to be cleared
        m_ckpntDist;
        
        % The point at which the car is currently trying to get
        m_currCkpnt;
        
        % Whether the car has crossed the finish line or not
        m_isDone;
        
        % String value that determines behavior of the driver
        % Possible values: "speeder", "cautious"
        m_drivingStyle;
        
        
    end % properties
    properties (Constant)
        s_currDispDeco = 'bo';
        
        s_wpCol = [0.2,0.8,0.8];
        
        s_styles = ["speeder","cautious","turtle"];
        
        s_outOfTrackBrake = 3;
    end
    methods
        
        % Constructor
        function this = CarAi(t_path,t_style)
            this.m_path = t_path;
            
            isIn = false;
            for i = this.s_styles
                if  t_style == i
                    isIn = true;
                    break;
                end
            end
            if isIn
                this.m_drivingStyle = t_style;
            else
                this.m_drivingStyle = "speeder";
            end
            
            this.m_ckpntDist = 3;
        end
        
        % Returns whether the car is still on the asphalt
        function onTrack = isOnTrack(this,t_pos)
            dist = dist2Pts(t_pos,[t_pos(1),this.m_path.m_y(t_pos(1))]);
            onTrack =  dist < this.m_path.m_track_w;
        end
        
        
        % Tells the car to go to given position
        function goTo(this,t_owner,t_pos)
            
            carAng = t_owner.m_facingAngle;
            carPos = t_owner.m_p;
            carDirVec = angleToVector(carAng,1);
            
            % Calculate the steer magnitude
            deltaAngle = abs(carAng - get2dVectorAngle(t_pos-carPos));
            if deltaAngle > 180
                deltaAngle = abs(deltaAngle-360);
            end
            
            
            % Find whether the point is to the left or right
            b = carDirVec ;
            p = t_pos - carPos;
            crossProd = b(1)*p(2)-b(2)*p(1);
            
            if crossProd < 0
                deltaAngle = -deltaAngle;
            end
            
            
            setSteeringAngle(t_owner, deltaAngle);
            
            plot([t_owner.m_p(1),t_pos(1)],[t_owner.m_p(2),t_pos(2)],"Color",this.s_wpCol);
            %plot(t_pos(1),t_pos(2),'or');
            
        end
        
        % Driving style: full throttle all time
        function speeder(this,t_owner)
            setThrottle(t_owner,1);
            onTrack = isOnTrack(this,t_owner.m_p);
            if ~onTrack
                setBrake(t_owner,this.s_outOfTrackBrake);
            else
                setBrake(t_owner,0);
            end
        end
        
        % Driving style: cruises and brakes when too fast
        function cautious(this,t_owner)
            
            setThrottle(t_owner,1);
            onTrack = isOnTrack(this,t_owner.m_p);
            if ~onTrack
                setBrake(t_owner,this.s_outOfTrackBrake);
            else
                setBrake(t_owner,0);
            end
            
            if t_owner.m_steerCoeff < 0.2
                setThrottle(t_owner,0);
            end
            
            if t_owner.m_steerCoeff < 0.1
                setBrake(t_owner, 0.5)
            else
                setBrake(t_owner,0);
            end
        end
        
        % Driving style: the slower the better
        function turtle(this,t_owner)
            
            setThrottle(t_owner,0.4);
            onTrack = isOnTrack(this,t_owner.m_p);
            if ~onTrack
                setBrake(t_owner,this.s_outOfTrackBrake);
            else
                setBrake(t_owner,0);
            end
            if t_owner.m_steerCoeff < 0.5
                setThrottle(t_owner,0);
            end
            
            if t_owner.m_steerCoeff < 0.3
                setBrake(t_owner,1);
            else
                setBrake(t_owner,0);
            end
            
        end
        
        % Controls the car
        function drive(this,t_owner)
            
            if this.m_isDone
                setThrottle(t_owner,0);
                setBrake(t_owner,1);
                setSteeringAngle(t_owner,0);
                return;
            end
            
            this.m_currCkpnt = [t_owner.m_p(1)+this.m_ckpntDist,this.m_path.m_y(t_owner.m_p(1)+this.m_ckpntDist)];
            goTo(this,t_owner,this.m_currCkpnt);
            
            switch (this.m_drivingStyle)
                case "speeder"
                    speeder(this,t_owner);
                case "cautious"
                    cautious(this,t_owner);
                case "turtle"
                    turtle(this,t_owner);
            end
            
            
            distFromFinish = dist2Pts(t_owner.m_p,this.m_path.m_endPos);
            this.m_isDone = distFromFinish <= this.m_path.m_track_w;
            
        end
    end % methods
end