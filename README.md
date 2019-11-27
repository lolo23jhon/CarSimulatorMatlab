# Matbla Car Rigid Body Simulator

The program creates an animation of racing cars based
on motion laws and conservation of energy.

## Getting Started

Put all the files into the same folder.

### Prerequisites

Needs MatLab R2019b


## Functionality desciption

### Euler integration

The program uses simple euler integration to add forces to add
forces to a rigid body system: the car.

The car class manages its position given the properties of 
three 2D vectors (double pairs): acceleration, velocity, and position.

Each frame, the update function of the car class gets a sum of forces
to calculate the acceleration (taken as constant for each delta time).
This acceleration is not accumulative, it's calculated from the sum of 
forces for each axis. This acceleration is then used to get the delta 
velocity, which after added to the current velocity (velocity IS 
accumulative) is used to get the delta position.

Car.m
```
 % Update all the properties of the car, runs each tick
        function updateCar(this,t_dt)
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
```

This is all fine and dandy... when we're going straight. But what happens when 
we steer the wheels? 

There are two main cases which apply for when the car steers:

1. The wheels have perfect traction and don't slip.
2. The wheels slip and the car does't move in the direction they're facing.  
            
To solve this in a simple way, we just define an effective steering value. 
The effective steering angle is equal to the actual steering angle at low 
and cruise speeds. Above a certain threshold we just set the effective steering
coefficient to adjust the resposiveness of the wheel angle. This causes the 
car to loose steering control at high speeds and might cause them to go out
the track at curves.

Car.m
```
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
```
 
 After all the relevant calculi for the displacement in the given time step,
 we just update all the values for them to display on screen:

 Car.m
```           
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
            
        end %  updateCar(this,t_dt)
```

### Artificial Intelligence

The cars have a member by composition of type CarAi which determines the basic behaviours for the
"driver". The ai has three presets: 
1. speeder: Full throtle all the time, brakes when out of the road.
2. cautious: When steering cofficient is below a certain threshold releases the throttle to keep cruising speed. 
3. turtle: Slowest type of driver. 

## Authors

* **Pedro Escoboza** - psebastian01@hotmail.com

See also the list of [contributors](https://github.com/your/project/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

