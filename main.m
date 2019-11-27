% PEDRO ESCOBOZA
function main()
clf;
clear;
clc;

% Simulation properties ---------------------------------------------------
dt = double(0.1);
numTicks = 10000;
secsToStart = 2;
isPrintToConsole = true;

% Plot properties ---------------------------------------------------------
pbaspect([1,1,1]);
drawCom = false;
drawSteeringDirection = true;
drawVelDirection = true;
drawAccelDirection = true;
useKm = false;
spacer = 1.5;
hold on;
axis equal;

% Road properties ---------------------------------------------------------
trackWidth = 12;
xo = 3;
xf = 28;
deltaStep = 0.01;
equation = [];
sizeMultiplier = 100; 
path = Path(xo,xf,deltaStep,equation,trackWidth,sizeMultiplier);


% Stands' properties ------------------------------------------------------
st_a_x = [6.942793367788718,6.930312676823302,7.724345026131775,7.736825717097165];
st_a_y = [16.576319433156552,16.47710132819063,16.37721963450534,16.47643773947104];
st_b_x = [22.165643373085214,22.96292376315273,22.954406979089807,22.157126589022177];
st_b_y = [31.920682861700996,31.852532596604785,31.752895934731825,31.82104619982668];
stands = [Box(st_a_x,st_a_y,sizeMultiplier,'k'),Box(st_b_x,st_b_y,sizeMultiplier,'k')];


% Camera properties -------------------------------------------------------
camAxisSize = 100;
isUpdateCamera = true;
cameraStaticAxis = [path.m_beginPos(1)-50,path.m_endPos(1)+50,1550,3300];
camera = Camera(path.m_beginPos,camAxisSize);


% Car properties ----------------------------------------------------------
numCars = 1;
arr = ones(1,numCars);
pos_x = (5+path.m_beginPos(1)).*arr;
pos_y = path.m_endPos(2).*arr;
for i = 2:numCars
    pos_x(i) = pos_x(i-1) - spacer;
    pos_y(i) = pos_y(i-1) + spacer;
end
axleDist = 5;
ai = ["cautious","cautious","cautious","cautious","speeder"];
ang = 290.*arr; %(deg)
mass = [660,660,660,660,660]; %(kg)
cof = 0.35.*arr; %(coefficient of friction)
frontalArea = 2.2.*arr; %(m^2)
axle = axleDist.*arr; %(m)
speedLimit = 0; %(m/s)
color = ['r','g','b','y','k'];


% Initialize cars
for i = 1:numCars
    car(i) = Car(true,CarAi(path,ai(i)),[pos_x(i),pos_y(i)],ang(i),mass(i),cof(i),frontalArea(i),axle(i),speedLimit,color(i));
end

% Draw the road
drawPath(path);

% Draw the cars in place
for n =1: numCars
    drawCar(car(n),drawCom,drawSteeringDirection,drawVelDirection, drawVelDirection);
end

% Draw the stands
drawBoxes(stands);
axis equal;
pause(secsToStart);

for i = 1:numTicks
    clf;
    axis equal;
    hold on;
    drawPath(path);
    % Draw the stands
    drawBoxes(stands);
    for n = 1:numCars
        
        % Update each car instance
        updateCar(car(n),dt);
        
        % Change car inputs
        drive(car(n).m_ai,car(n));
        
    end
    
    % Graphics separated from calculations to manage plot properties
    % independently
    for n = 1:numCars
        
        % Display the cars' graphics
        drawCar(car(n),drawCom,drawSteeringDirection,drawVelDirection, drawVelDirection);
        
        
    end
    
    % Update the camera position to follow the rightmost car
    if isUpdateCamera
        updateCamera(camera,car)
    else
        axis(cameraStaticAxis);
    end
    drawnow;
        
    
    if isPrintToConsole
        % Print car information to console
        printCars(car,i*dt,useKm);
    end
end

fprintf("\n===== End of simulation =====\n\n Number of ticks: %d\n",numTicks);

end
% PEDRO ESCOBOZA