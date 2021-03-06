clc; clear all; clear global; clear variables; close all;
color = 'kbgrcmy'; colorVal = 1;
figure; hold on;

TIMESTEP = 0.1;
TOTALTIME = 50;
DRAWCOUNT = 1;
t = TIMESTEP:TIMESTEP:TOTALTIME;

subplot(2,2,1); grid on; title('Robot Trajectory'); axis([-25 25 -15 15]);
robotTrajectory = animatedline('Color',color(colorVal),'LineWidth',1);colorVal=colorVal+1;

subplot(2,2,2); title('Heading vs t');    grid on; axis([0 TOTALTIME -pi pi]); 
Heading   = animatedline('Color',color(colorVal),'LineWidth',1);colorVal=colorVal+1;

subplot(2,2,3); title('X Position vs t'); grid on; axis([0 TOTALTIME -20 20]);
xPosition = animatedline('Color',color(colorVal),'LineWidth',1);colorVal=colorVal+1;

subplot(2,2,4); title('Y Position vs t'); grid on; axis([0 TOTALTIME -20 20]);
yPosition = animatedline('Color',color(colorVal),'LineWidth',1);colorVal=colorVal+1;

robot = [([0, 0])];
x   = zeros(TOTALTIME/TIMESTEP,1);
y   = zeros(TOTALTIME/TIMESTEP,1);
psi = zeros(TOTALTIME/TIMESTEP,1);

vLeft  = zeros(TOTALTIME/TIMESTEP,1);
vRight = zeros(TOTALTIME/TIMESTEP,1);

u1 = zeros(TOTALTIME/TIMESTEP,1); % derivative of vRight
u2 = zeros(TOTALTIME/TIMESTEP,1); % derivative of vLeft

W = 1; % WheelBase
L = 2; % Axle to Axle Length of Robot - NOT USED here in differential drive model

scenario = input('Enter 1, 2 or 3\n1= Same velocities\n2=right speed is 10% high\n3=left speed is 10% low.\n');
if(scenario==1)
    vLeft(1,1)  = input('\nEnter Velocity: ');
    vRight(1,1) = vLeft(1,1);
elseif(scenario==2)
    vLeft(1,1)  = input('\nEnter LEFT  Wheel Velocity: ');
    vRight(1,1) = input('\nEnter RIGHT Wheel Velocity: ');
    vRight(1,1) = ((vLeft(1,1)+vRight(1,1))/2)*1.1;
elseif(scenario==3)
    vLeft(1,1)  = input('\nEnter LEFT  Wheel Velocity: ');
    vRight(1,1) = input('\nEnter RIGHT Wheel Velocity: ');
    vRight(1,1) = ((vLeft(1,1)+vRight(1,1))/2)*0.9;
else
    fprintf('INVALID INPUT\n')
    return
end

%Main Loop
zed = 0;
while zed<((TOTALTIME/TIMESTEP)-1)
    zed = zed+1;
    if(zed==1)
        %FIRST RUN
        x(zed,1) = robot(1,1);
        y(zed,1) = robot(1,2);
    end
    
    x(zed+1,1) = x(zed,1) - TIMESTEP * ((vRight(zed,1) + vLeft(zed,1)) /2) * sin(psi(zed,1));
    y(zed+1,1) = y(zed,1) + TIMESTEP * ((vRight(zed,1) + vLeft(zed,1)) /2) * cos(psi(zed,1));

    psi(zed+1,1) = psi(zed,1) + TIMESTEP * ((vRight(zed,1) - vLeft(zed,1))/W);
    psi(zed+1,1) = atan2(sin(psi(zed+1,1)), cos(psi(zed+1,1)));
    
    vRight(zed+1,1) = vRight(zed,1) + TIMESTEP*u1(zed,1);
    vLeft(zed+1,1)  = vLeft(zed,1)  + TIMESTEP*u2(zed,1);
    
    addpoints(robotTrajectory,x(zed,1),y(zed,1));
    addpoints(Heading,zed*TIMESTEP,psi(zed,1));
    addpoints(xPosition,zed*TIMESTEP,x(zed,1));
    addpoints(yPosition,zed*TIMESTEP,y(zed,1));
    
    if(mod(zed,round((TOTALTIME/TIMESTEP)/DRAWCOUNT)) == 0)
        drawnow
    end
end


% numberOfRobots = 4;
% circle(robot(i,1),robot(i,2),0.2,2);
% rectangle('Position',[obstacle(1,1)-v1 obstacle(1,2)-v2 v1*2 v2*2]);
% ellipse(obstacle(1,1),obstacle(1,2),1/A,1/B);
% border(robot(1:numberOfRobots,1),robot(1:numberOfRobots,2));
% robotTrajectory = animatedline('Color',color(colorVal),'LineWidth',1);colorVal=colorVal+1;
% addpoints(robotTrajectory,X,Y);