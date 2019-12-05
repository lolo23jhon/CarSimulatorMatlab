% PEDRO ESCOBOZA
% Class for simulating a directional actor with rigid body physics in 2D.
classdef Car < handle
    properties
        % Position vector (vector x,y; m)
        m_p;
        
        % Velocity vector (vector x,y; m/s)
        m_v;
        
        % Acceleration vector (vector x,y; m/s^2)
        m_a;
        
        % Direction of the model(degrees with horizontal axis anti-clock-wise)
        m_facingAngle;
        
        % Direction at which the wheels are facing in deegrees
        % Positive for right, negative for left
        % (deegrees with the front vector anti-clock-wise)
        m_steeringAngle;
        
        % How much steering from actual steering participates in
        % directional shift (0 to 1 coeff.)
        m_steerCoeff;
        
        % Degree of activation of accelerator (0 to 1 coefficient)
        m_throttle;
        
        % Degree of activation of breaks (0 to 1 coefficient)
        m_brake;
        
        % Mass of the car (kg)
        m_mass;
        
        % Color of the model polygon shape
        m_color;
        
        % Frontal area of the car for drag calculations
        m_frontalArea;
        
        % Coefficient of friction to get coefficient of drag
        m_cof;
        
        % Rolling resistance coefficient to get coefficient of drag
        % its approximately 30 times the CoF
        m_rr;
        
        % Coefficient of drag for drag force
        m_cod;
        
        % Distance bewteen the rear and front axle (m)
        m_axleDist;
        
        % Polygon shape triangle
        m_model;
        
        % Max speed lock, non limited if 0
        m_speedLimit;
        
        % Ai controller of which this instance is owner
        m_ai;
        
        % Activate or deactivate current AI
        m_hasAi;
        
        % Energy of movement (J)
        m_kineticEnergy;
        
        % Energy given off as heat from friction with environment (J)
        m_lostEnergy;
        
    end
    properties (Constant)
        % Force output by the car's engine (N)
        s_engineForce = 8000;
        
        % Density of atmosphere (kg/m^3)
        s_airDensity = 1.29;
        
        % Coefficient of where is the COM from rear to front axle
        s_axlePosCoeff = 0.5;
        
        % Color of the steering direction line
        s_steeringDirectionColor = 'g';
        
        % Color of velocity vector
        s_velColor = 'r';
        
        % Color of acceleration vector
        s_accelColor = 'b';
        
        % Maximum steering angle (left and right)
        s_maxSteer = 60;
        
        % Used to get momentum threshold after which effective steering angle decreases (m/s)
        s_slipThreshold = 30;
        
        % Length relationship of the axle distande to the width or vehicle
        s_widthMult=0.45;
        
        
        s_drawAABB = true;
        
    end
    
    methods
        
        % Constructor
        function this=Car(t_hasAi,t_ai,t_pos_i,t_angle,t_mass,t_cof,t_frontalArea,t_axleDistance,t_speedLimit,t_color)
            
            this.m_p = t_pos_i;
            this.m_v = [0,0];
            this.m_a = [0,0];
            this.m_facingAngle = t_angle;
            this.m_mass = t_mass;
            this.m_cof = t_cof;
            this.m_rr = 30 * t_cof;
            this.m_frontalArea = t_frontalArea;
            this.m_axleDist = t_axleDistance;
            this.m_speedLimit = t_speedLimit;
            this.m_color = t_color;
            
            % Couple the car with its artificial intelligence
            if t_hasAi
                this.m_ai = t_ai;
                this.m_hasAi = true;
            else
                this.m_hasAi = false;
            end
            
            this.m_throttle = 0;
            this.m_brake = 0;
            this.m_steeringAngle = 0;
            this.m_steerCoeff = 1;
            this.m_cod=0.5*this.m_cof*this.m_frontalArea*this.s_airDensity;
            this.m_kineticEnergy = 0;
            this.m_lostEnergy = 0;
            
            % x = cx + r * cos(a)
            % y = cy + r * sin(a)
            fangle = this.m_facingAngle;
            axDist = this.m_axleDist;
            wMult = this.s_widthMult;
            diagDist = sqrt(axDist^2+(0.5*wMult*axDist)^2);
            angleFromHoriz = atand(0.5*wMult);
            ang = [fangle + angleFromHoriz, fangle+90,fangle + 270, fangle - angleFromHoriz];
            for i = 1:numel(ang)
                while ang(i) > 360
                    ang(i) = ang(i) - 360;
                end
            end
            model_x = [this.m_p(1)+diagDist*cosd(ang(1)),this.m_p(1)+0.5*axDist*wMult*cosd(ang(2)),this.m_p(1)+0.5*axDist*wMult*cosd(ang(3)),this.m_p(1)+ diagDist*cosd(ang(4))];
            model_y = [this.m_p(2)+diagDist*sind(ang(1)),this.m_p(2)+0.5*axDist*wMult*sind(ang(2)),this.m_p(2)+0.5*axDist*wMult*sind(ang(3)),this.m_p(2)+ diagDist*sind(ang(4))];
            this.m_model = polyshape(model_x, model_y);
            
            
        end
        % Input of wheel rotation applied instantly
        function setSteeringAngle(this, t_angle)
            
            this.m_steeringAngle = t_angle;
            
            % Correct the value if over threshold
            if this.m_steeringAngle > this.s_maxSteer
                this.m_steeringAngle = this.s_maxSteer;
            elseif this.m_steeringAngle < -this.s_maxSteer
                this.m_steeringAngle = -this.s_maxSteer;
            end
            
            while this.m_steeringAngle >= 360
                this.m_steeringAngle = this.m_steeringAngle - 360;
            end
            
            while this.m_steeringAngle <= -360
                this.m_steeringAngle = this.m_steeringAngle + 360;
            end
            
        end
        
        
        
        % Apply a force vector to the car and update acceleration
        function applyForce(this,t_forceVec)
            this.m_a =  t_forceVec/this.m_mass;
        end
        
        
        
        % Set the value of the throttle coefficient
        function setThrottle(this,t_coeff)
            this.m_throttle = t_coeff;
        end
        
        
        
        % Set the value of the break coefficient
        function setBrake(this, t_coeff)
            this.m_brake = t_coeff;
        end
        
        
        
        % Set the speed limit value for the car
        function setSpeedLimit(this,t_limit)
            this.m_speedLimit = t_limit;
        end
        
        % This function receives a cell matrix with aabb vertices to decide
        % if a collision occured
        function r_isCollision = checkCollision(this, t_aabb)
            
            car_verts = this.m_model.Vertices;
            
            car_min_x = inf;
            car_max_x = -inf;
            
            car_min_y = inf;
            car_max_y = -inf;
            
            
            % Get the aabb for the car
            for i = 1:4
                
                car_x = car_verts(i,1);
                car_y = car_verts(i,2);
                
                
                if car_x < car_min_x
                    car_min_x = car_verts(i,1);
                end
                if car_x > car_max_x
                    car_max_x = car_x;
                end
                
                
                
                if car_y < car_min_y
                    car_min_y = car_y;
                end
                if car_y > car_max_y
                    car_max_y = car_y;
                end
                
            end % for i = 1:4
            
            if this.s_drawAABB
                pgon_x = [car_min_x, car_max_x, car_max_x, car_min_x];
                pgon_y = [car_min_y, car_min_y, car_max_y, car_max_y];
                aabb = polyshape(pgon_x,pgon_y);
                plot(aabb,"FaceColor",'w');
            end
            
            
            % Interpenetration comparison
            for i = numel(t_aabb)
                
                box = t_aabb{i};
                
                box_min_x = inf;
                box_max_x = -inf;
                
                box_min_y = inf;
                box_max_y = -inf;
                
                % Find min and max for x and y box vertices
                for j = 1:4
                    box_x = box(j,1);
                    box_y = box(j,2);
                    
                    if box_x < box_min_x
                        box_min_x = box_x;
                    end
                    if box_x > box_max_x
                        box_max_x = box_x;
                    end
                    
                    
                    if box_y < box_min_y
                        box_min_y = box_y;
                    end
                    if box_y > box_max_y
                        box_max_y = box_y;
                    end
                    
                end % for j = 1:4
                
                
                
                
                % AABB collision detection
                if car_max_x >= box_min_x && car_min_x <= box_max_x && car_max_y >= box_min_y && car_min_y <= box_max_y
                    r_isCollision = true;
                    return;
                end
                
            end % for i = numel(t_aabb_bodies)
            
            r_isCollision = false;
            
        end % checkCollision()
        
        
        % Update all the properties of the car, runs each tick
        function updateCar(this,t_dt,t_aabb)
            % Get the linear speed used in force calculations
            velMag = vectorMagnitude(this.m_v);
            
            % Update kinetic energy
            this.m_kineticEnergy = 0.5*this.m_mass*velMag^2;
            
            % If static and with brake on, there's no movement
            if velMag < this.m_brake
                this.m_v = [0,0];
                this.m_a = [0,0];
                return;
            end
            
            % Get vector of force applied by the engine
            f_eng_mag =  this.m_throttle * this.s_engineForce;
            
            % Get the force magnitue of the break
            f_brake_mag = this.m_brake * this.s_engineForce;
            
            % Get drag force
            % f_drag = 0.5 * CoeffDrag * Area * AirDensity * vel^2
            f_drag_mag = 0.5*this.m_cod*this.m_frontalArea * this.s_airDensity * velMag^2;
            
            % Get rolling resistance force
            % f_rr = c_rr * vel
            f_rr_mag = this.m_rr * velMag;
            
            % Project each force magnitude into its respective direction
            f_eng = angleToVector(this.m_facingAngle,f_eng_mag);
            f_brake = angleToVector(this.m_facingAngle+180,f_brake_mag);
            f_drag = magTimesVector(-f_drag_mag, this.m_v);
            f_rr = magTimesVector(-f_rr_mag,this.m_v);
            
            % Add up all the force vectors
            f_total = f_eng + f_brake + f_drag + f_rr;
            f_total_mag = vectorMagnitude(f_total);
            
            % Update acceleration by applying forces linearly
            applyForce(this,f_total);
            
            % Update velocity linealry
            this.m_v = this.m_v + this.m_a * t_dt;
            
            % Get the delta position vector
            deltaPos = this.m_v*t_dt;
            
            distanceTravelled = vectorMagnitude(deltaPos);
            
            % If the car is steering
            if this.m_steeringAngle ~= 0
                
                % If speed is above a cerain threshold, decrase the
                % effective steering angle proportionally
                this.m_steerCoeff = 1;
                if velMag > this.s_slipThreshold
                    this.m_steerCoeff = exp(3*(1-velMag/this.s_slipThreshold));
                end
                
                effSteer = this.m_steerCoeff * this.m_steeringAngle;
                
                % Get rotation radius with Ackerman geometry (m)
                radius = this.m_axleDist/sind(effSteer);
                
                % Get the angular velocity magnitude (rad/s)
                angularVel = velMag/radius;
                
                % Get angular displacement (rad -> deg)
                angularDisp = rad2deg(angularVel * t_dt);
                
                % Get the final facing direction
                finalDirection = this.m_facingAngle + angularDisp;
                
                % Add angular displacement to facing angle
                this.m_facingAngle = finalDirection;
                while this.m_facingAngle < 0
                    this.m_facingAngle = this.m_facingAngle + 360;
                end
                
                % Rotate tangential acceleration vector by the delta angle
                this.m_a = rotate2dVector(this.m_a, angularDisp);
                
                % Rotate tangential velocity vector by the delta angle
                this.m_v = rotate2dVector(this.m_v, angularDisp);
                
                % Get cartesian displacement from polar displacement
                deltaPos = velMag*t_dt*[cosd(finalDirection),sind(finalDirection)];
                
                % Get the arc length (actual distance travelled) to get
                % work done by friction
                distanceTravelled = angularDisp * radius;
                
            end % this.m_steeringAngle == 0
            
            % Calculate work done by friction
            if this.m_kineticEnergy ~= 0
                this.m_lostEnergy = -distanceTravelled * abs(f_brake_mag + f_drag_mag + f_rr_mag);
            else
                this.m_lostEnergy = 0;
            end
            % If speed is over speed limit, make it the speedLimit
            if this.m_speedLimit ~= 0 && vectorMagnitude(this.m_v) > this.m_speedLimit
                this.m_v = magTimesVector(this.m_speedLimit,this.m_v);
            end % this.m_speedLimit ~= 0 && vectorMagnitude(this.m_v) > this.m_speedLimit
            
            % Update the position by adding the delta position
            this.m_p = this.m_p + deltaPos;
            
            % Update model position
            
            % x = cx + r * cos(a)
            % y = cy + r * sin(a)
            fangle = this.m_facingAngle;
            axDist = this.m_axleDist;
            wMult = this.s_widthMult;
            diagDist = sqrt(axDist^2+(0.5*wMult*axDist)^2);
            angleFromHoriz = atand(0.5*wMult);
            ang = [fangle + angleFromHoriz, fangle+90,fangle + 270, fangle - angleFromHoriz];
            for i = 1:numel(ang)
                while ang(i) > 360
                    ang(i) = ang(i) - 360;
                end
            end
            model_x = [this.m_p(1)+diagDist*cosd(ang(1)),this.m_p(1)+0.5*axDist*wMult*cosd(ang(2)),this.m_p(1)+0.5*axDist*wMult*cosd(ang(3)),this.m_p(1)+ diagDist*cosd(ang(4))];
            model_y = [this.m_p(2)+diagDist*sind(ang(1)),this.m_p(2)+0.5*axDist*wMult*sind(ang(2)),this.m_p(2)+0.5*axDist*wMult*sind(ang(3)),this.m_p(2)+ diagDist*sind(ang(4))];
            this.m_model = polyshape(model_x, model_y);
            
            
            
            
            
            
            % Check for collisions
            isCol = checkCollision(this,t_aabb);
            if isCol 
               fprintf("COL"); 
            end
            
            
        end %  updateCar(this,t_dt)
        
        
        
        % Plot the car's model and some other artifacts depending on
        % boolean arguments
        function drawCar(this,t_plotCor,t_steering,t_vel, t_accel)
            plot(this.m_model,"FaceColor",this.m_color);
            
            % Draw the velocity vector
            if t_vel && this.m_v(1) ~= 0 && this.m_v(2) ~= 0
                ang = get2dVectorAngle(this.m_v);
                line = angleToVector(ang,this.m_axleDist);
                plot([this.m_p(1), this.m_p(1)+line(1) ],[this.m_p(2),this.m_p(2)+line(2)],this.s_velColor,"LineWidth",2);
            end
            
            % Draw the acceleration vector
            if t_accel && this.m_a(1) ~= 0 && this.m_a(2) ~= 0
                ang = get2dVectorAngle(this.m_a);
                line = angleToVector(ang,this.m_axleDist*0.9);
                plot([this.m_p(1), this.m_p(1)+line(1) ],[this.m_p(2),this.m_p(2)+line(2)],this.s_accelColor,"LineWidth",2);
            end
            
            % Draw the wheel direction vector
            if t_steering
                ang = this.m_facingAngle + this.m_steeringAngle;
                line = angleToVector(ang,this.m_axleDist*0.8);
                plot([this.m_p(1), this.m_p(1)+line(1) ],[this.m_p(2),this.m_p(2)+line(2)],this.s_steeringDirectionColor,"LineWidth" , 2);
            end
            
            % Draw the center of rotation
            if t_plotCor
                plot(this.m_p(1),this.m_p(2),'ob');
            end
            
        end
        
        
        % Print car data on console
        function printCars(t_carVector,t_time,t_useKm)
            msg = num2str(t_time);
            c = 1;
            if t_useKm
                c = 3.6;
            end
            for i = 1:numel(t_carVector)
                msg = append(msg,"  || ID: ",num2str(i)," V: ", num2str(c*vectorMagnitude(t_carVector(i).m_v))," P: (",num2str(t_carVector(i).m_p(1)),", ",num2str(t_carVector(i).m_p(2)),") E_k: ",num2str(t_carVector(i).m_kineticEnergy), " E_q: ",num2str(t_carVector(i).m_lostEnergy));
            end
            fprintf("%s\n",msg);
        end
        
        
        % Sets the plot axis to the car's position +- the zoom value
        function lockCamera(this,t_zoom)
            t_zoom = t_zoom/2;
            axis([this.m_p(1)-t_zoom, this.m_p(1)+t_zoom, this.m_p(2)-t_zoom, this.m_p(2)+t_zoom]);
        end
        
    end
    
end
% PEDRO ESCOBOZA