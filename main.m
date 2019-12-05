% PEDRO ESCOBOZA
function main()
clf;
clear;
clc;

% Information display properties ------------------------------------------
SHOW_BANNERS = true;
PRINT_TO_CONSOLE = false;
USE_KM = false;
DRAW_CENTER_OF_ROTATION = false;
DRAW_STEERING_DIRECTION = true;
DRAW_ACCELERATION_DIRECTION = true;
DRAW_VELOCITY_DIRECTION = true;
DRAW_AABB = false;

% Simulation properties ---------------------------------------------------
dt = double(0.1);
NUM_TICKS = 10000;
SECONDS_TO_START = 2;


% Plot properties ---------------------------------------------------------
pbaspect([1,1,1]);
spacer = 1.5;
hold on;
axis equal;

% Road properties ---------------------------------------------------------
SIZE_MULTIPLIER = 100;
TRACK_WIDTH = 12;
equation = [];

xo = 3;
xf = 28;

BORDER_LINES_DRAWING_DELTA_STEP = 0.01;
path = Path(xo,xf,BORDER_LINES_DRAWING_DELTA_STEP,equation,TRACK_WIDTH,SIZE_MULTIPLIER);


% Stands' properties ------------------------------------------------------
st_a_x = [22.160389436299898,22.9603894363001,22.9603894363001,22.160389436299898];
st_a_y = [30.13829615269992,30.13829615269992,30.238296152700443,30.238296152699306];
st_b_x = [7.721288267899989,8.521288267900013,8.521288267900013,7.721288267899989];
st_b_y = [18.294650411299987,18.294650411299703,18.394650411299942,18.394650411299942];
stands = [Box(st_a_x,st_a_y,SIZE_MULTIPLIER,'k'),Box(st_b_x,st_b_y,SIZE_MULTIPLIER,'k')];


for i = 1:numel(stands)
    AABB{i} = stands(i).m_poly.Vertices;
end
   

% Camera properties -------------------------------------------------------
CAM_AXIS_SIZE = 100;
CAMERA_FOLLOW_FIRST = true;

cameraStaticAxis = [path.m_beginPos(1)-50,path.m_endPos(1)+50,1550,3300];
camera = Camera(path.m_beginPos,CAM_AXIS_SIZE);


% Car properties ----------------------------------------------------------
NUM_CARS = 5;
AXLE_DISTANCE = 5;
ALL_SAME_MASS = false;
MASS = 700; % (kg)

arr = ones(1,NUM_CARS);
pos_x = (5+path.m_beginPos(1)).*arr;
pos_y = path.m_endPos(2).*arr;

for i = 2:NUM_CARS
    pos_x(i) = pos_x(i-1) - spacer;
    pos_y(i) = pos_y(i-1) + spacer;
end


ai = ["crasher","cautious","cautious","turtle","speer"];
ang = 290.*arr; %(deg)
mass = [660,700,660,665,1200]; %(kg)
if ALL_SAME_MASS
    mass = MASS.*arr;
end
cof = 0.35.*arr; %(coefficient of friction)
frontalArea = 2.2.*arr; %(m^2)
axle = AXLE_DISTANCE.*arr; %(m)
speedLimit = 0; %(m/s)
color = ['r','g','b','y','k'];

% Car initialization
for i = 1:NUM_CARS
    cars(i) = Car(true,CarAi(path,ai(i)),[pos_x(i),pos_y(i)],ang(i),mass(i),cof(i),frontalArea(i),axle(i),speedLimit,color(i),DRAW_AABB);
end


% Banner properties -------------------------------------------------------
BANNER_DISP = [15,15];
if ~CAMERA_FOLLOW_FIRST
    BANNER_DISP = 10.*BANNER_DISP;
end
BANNER_SPACER = BANNER_DISP./NUM_CARS;
if SHOW_BANNERS
    for i = 1:NUM_CARS
        banners(i) = Banner(cars(i).m_p,"P:(%.1f,\t%.1f) m | V: %.2f m/s;",BANNER_DISP);
    end
end


% Draw the road
drawPath(path);

% Draw the cars in place
for n =1: NUM_CARS
    drawCar(cars(n),DRAW_CENTER_OF_ROTATION,DRAW_STEERING_DIRECTION,DRAW_VELOCITY_DIRECTION, DRAW_VELOCITY_DIRECTION);
end

% Draw the stands
drawBoxes(stands);
axis equal;
pause(SECONDS_TO_START);

for i = 1:NUM_TICKS
    clf;
    axis equal;
    hold on;
    drawPath(path);
    % Draw the stands
    drawBoxes(stands);
    for n = 1:NUM_CARS
        
        % Update each car instance
        updateCar(cars(n),dt,stands);
        
        % Change car inputs
        drive(cars(n).m_ai,cars(n));
        
    end
    
    % Graphics separated from calculations to manage plot properties
    % independently
    for n = 1:NUM_CARS
        
        % Display the cars' graphics
        drawCar(cars(n),DRAW_CENTER_OF_ROTATION,DRAW_STEERING_DIRECTION,DRAW_VELOCITY_DIRECTION, DRAW_VELOCITY_DIRECTION);
        
        
    end
    
    % Update the camera position to follow the rightmost car
    if CAMERA_FOLLOW_FIRST
        updateCamera(camera,cars)
    else
        axis(cameraStaticAxis);
    end
    
    % Update the banners
    if SHOW_BANNERS
        for i = 1:NUM_CARS
            disp = BANNER_DISP + (i*BANNER_SPACER).*[1,1];
            %if ~mod(i,2)
             %   disp = -disp;
            %end
            updateBanner(banners(i),cars(i).m_p,disp,[cars(i).m_p,vectorMagnitude(cars(i).m_v)]);
        end
    end
    
    drawnow;
    
    % Print car information to console
    if PRINT_TO_CONSOLE
        printCars(cars,i*dt,useKm);
    end
    
end

fprintf("\n===== End of simulation =====\n\n Number of ticks: %d\n",NUM_TICKS);

end
% PEDRO ESCOBOZA