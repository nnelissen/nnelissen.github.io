close all
clear all

total_nr_asteroids = 20;
nr_asteroids_screen = 2;
nr_satellites_screen = 1;
nr_collisions = 20;

radius_planet = 50;
radius_asteroid = 10;

x_planet = 400;
y_planet = 300;

x_screen_range = [0 800];
y_screen_range = [0 600];

%framesPerSecond = 30;

asteroid_speeds = [100:50:300]; % in pixels per second
asteroid_spawning_jitter = [100:50:500]; % in ms delay in onset




% create all starting points

start_left_x = zeros(1,y_screen_range(2)+1);
start_left_y = [y_screen_range(1):1:y_screen_range(2)];
left = 1+zeros(1,size(start_left_x,2));

start_right_x = zeros(1,y_screen_range(2)+1)+x_screen_range(2);
start_right_y = [y_screen_range(1):1:y_screen_range(2)];
right = 2+zeros(1,size(start_right_x,2));

start_top_x = [1+x_screen_range(1):1:x_screen_range(2)-1];
start_top_y = zeros(1,x_screen_range(2)-1);
top = 3+zeros(1,size(start_top_x,2));

start_bottom_x = [1+x_screen_range(1):1:x_screen_range(2)-1];
start_bottom_y = zeros(1,x_screen_range(2)-1)+y_screen_range(2);
bottom = 4+zeros(1,size(start_bottom_x,2));

start_xy = [start_left_x' start_left_y' left'; start_right_x' start_right_y' right'; start_top_x' start_top_y' top'; start_bottom_x' start_bottom_y' bottom'];



    



% calculate average time asteroid is in canvas in quick approximation
avg_speed = mean(asteroid_speeds);
avg_path = (sqrt(x_screen_range(2)^2 + y_screen_range(2)^2) + min([x_screen_range(2) y_screen_range(2)])) / 2; % mean of diagonal and shortest side
avg_dwell = avg_path / avg_speed % how many seconds is asteroid visible?

spawning_rate = 1000*avg_dwell/nr_asteroids_screen; % how much time between generating new asteroids, in ms
spawning_interval = [spawning_rate - asteroid_spawning_jitter  spawning_rate + asteroid_spawning_jitter]; % in ms


asteroidx = [];
asteroidy = [];
angle = [];
speed = [];
time = [];

tracking_time = 0;

% loop around asteroids
for asteroid = 1:total_nr_asteroids
    
    % pick a random starting point

    tmp = randperm(size(start_xy,1));
    ind = tmp(1);
    start_xy_i = start_xy(ind,:);
    
    asteroidx = [asteroidx; start_xy_i(1)];
    asteroidy = [asteroidy; start_xy_i(2)];
    
    
            %start_xy_i = [600 0];
    
    % calculate  angle
    R = sqrt((start_xy_i(1) - x_planet)^2 + (start_xy_i(2) - y_planet)^2);
    theta = asin((radius_planet + radius_asteroid) / R);
    alpha = acos((y_planet-start_xy_i(2)) / R);
    

    % correct angle
    if (start_xy_i(3) == 2) || (start_xy_i(3) == 3 && start_xy_i(1) > x_planet) || (start_xy_i(3) == 4 && start_xy_i(1) > x_planet)
        alpha = alpha + pi/2;
    elseif (start_xy_i(3) == 1 && start_xy_i(2) <= y_planet) || (start_xy_i(3) == 3 && start_xy_i(1) < x_planet)
        alpha = pi/2 - alpha;
    elseif (start_xy_i(3) == 1 && start_xy_i(2) > y_planet) || (start_xy_i(3) == 4 && start_xy_i(1) < x_planet)
        alpha = 5*pi/2 - alpha;
    elseif start_xy_i(3) == 3 && start_xy_i(1) == x_planet
        alpha = pi/2;
    elseif start_xy_i(3) == 4 && start_xy_i(1) == x_planet
        alpha = 3*pi/2;
    end;
        
    
    alpha_max = alpha + abs(theta);
    alpha_min = alpha - abs(theta);

    possible_angles = [alpha_min:0.0001:alpha_max];
    ind = randperm(size(possible_angles,2));
    angle = [angle; possible_angles(ind(1))];
    %angle = [angle; alpha];
    
    % pick random asteroid speed
    ind = randperm(size(asteroid_speeds,2));
    speed = [speed; asteroid_speeds(ind(1))];
    
    % calculate onset
    % first, pick a delay, jittered
    tmp = randperm(size(spawning_interval,2));
    tracking_time = tracking_time + spawning_interval(tmp(1));
    time = [time tracking_time];
    
end;



% write to matlab command window

fprintf('\n\nvar asteroidsX = [');
for asteroid = 1:total_nr_asteroids
    fprintf('%.0f',asteroidx(asteroid));
    if asteroid == total_nr_asteroids
        fprintf('];\n');
    else
        fprintf(',');
    end;
end;

fprintf('var asteroidsY = [');
for asteroid = 1:total_nr_asteroids
    fprintf('%.0f',asteroidy(asteroid));
    if asteroid == total_nr_asteroids
        fprintf('];\n');
    else
        fprintf(',');
    end;
end;

fprintf('var asteroidsAngle = [');
for asteroid = 1:total_nr_asteroids
    fprintf('%.4f',angle(asteroid));
    if asteroid == total_nr_asteroids
        fprintf('];\n');
    else
        fprintf(',');
    end;
end;

fprintf('var asteroidsSpeed = [');
for asteroid = 1:total_nr_asteroids
    fprintf('%.0f',speed(asteroid));
    if asteroid == total_nr_asteroids
        fprintf('];\n');
    else
        fprintf(',');
    end;
end;

fprintf('var asteroidOnset = [');
for asteroid = 1:total_nr_asteroids
    fprintf('%.0f',time(asteroid));
    if asteroid == total_nr_asteroids
        fprintf('];\n');
    else
        fprintf(',');
    end;
end;





fprintf('\n\nvar satellitesX = [');
for asteroid = 1:total_nr_asteroids
    fprintf('%.0f',asteroidx(asteroid));
    if asteroid == total_nr_asteroids
        fprintf('];\n');
    else
        fprintf(',');
    end;
end;

fprintf('var satellitesY = [');
for asteroid = 1:total_nr_asteroids
    fprintf('%.0f',asteroidy(asteroid));
    if asteroid == total_nr_asteroids
        fprintf('];\n');
    else
        fprintf(',');
    end;
end;

fprintf('var satellitesAngle = [');
for asteroid = 1:total_nr_asteroids
    fprintf('%.4f',angle(asteroid));
    if asteroid == total_nr_asteroids
        fprintf('];\n');
    else
        fprintf(',');
    end;
end;

fprintf('var satellitesSpeed = [');
for asteroid = 1:total_nr_asteroids
    fprintf('%.0f',speed(asteroid));
    if asteroid == total_nr_asteroids
        fprintf('];\n');
    else
        fprintf(',');
    end;
end;

fprintf('var satelliteOnset = [');
for asteroid = 1:total_nr_asteroids
    fprintf('%.0f',time(asteroid));
    if asteroid == total_nr_asteroids
        fprintf('];\n');
    else
        fprintf(',');
    end;
end;

