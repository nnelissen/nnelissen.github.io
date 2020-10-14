close all
clear all

total_nr_asteroids = 100;
nr_asteroids_screen = 5;
nr_collisions = 100;

radius_planet = 50;
radius_asteroid = 10;

x_planet = 400;
y_planet = 300;

x_screen_range = [0 800];
y_screen_range = [0 600];

framesPerSecond = 30;

asteroid_speeds = [1:1:10];

asteroid_spawning_jitter = [1:15]; % in frames delay in onset




% create all starting points

start_left_x = zeros(1,y_screen_range(2)+1);
start_left_y = [y_screen_range(1):1:y_screen_range(2)];

start_right_x = zeros(1,y_screen_range(2)+1)+x_screen_range(2);
start_right_y = [y_screen_range(1):1:y_screen_range(2)];

start_top_x = [1+x_screen_range(1):1:x_screen_range(2)-1];
start_top_y = zeros(1,x_screen_range(2)-1);

start_bottom_x = [1+x_screen_range(1):1:x_screen_range(2)-1];
start_bottom_y = zeros(1,x_screen_range(2)-1)+y_screen_range(2);

%start_xy = [start_left_x' start_left_y'; start_right_x' start_right_y'; start_top_x' start_top_y'; start_bottom_x' start_bottom_y'];





% % calculate all points for collision on planet surface (adding diameter of
% % asteroid)
% 
% r = radius_planet + radius_asteroid; % radius collision circle
% circle_points_xy = [];
% for a = 0:0.01:2*pi % angles between 0 & 2pi
%     x = r*cos(a) + x_planet;
%     y = r*sin(a) + y_planet;
%     circle_points_xy = [circle_points_xy;x y];
% end;
% circle_points_xy = round(circle_points_xy);
% % remove duplicate entries
% [C,IA,IC] = unique(circle_points_xy,'rows','stable');
% circle_points_xy = circle_points_xy(IA,:);


% calculate average time asteroid is in canvas in quick approximation
avg_speed = mean(asteroid_speeds);
avg_path = (sqrt(x_screen_range(2)^2 + y_screen_range(2)^2) + min([x_screen_range(2) y_screen_range(2)])) / 2; % mean of diagonal and shortest side
avg_frames = avg_path/avg_speed;
spawning_rate = avg_frames/nr_asteroids_screen; % how much time between generating new asteroids, in frames
spawning_interval_frames = [spawning_rate - asteroid_spawning_jitter  spawning_rate + asteroid_spawning_jitter];
spawning_interval_seconds = 1000*spawning_interval_frames / framesPerSecond;


asteroidx = [];
asteroidy = [];
angle = [];
speed = [];
time = [];

tracking_time = 0;

% loop around asteroids
for asteroid = 1%:total_nr_asteroids
    
    % pick a random starting point

    tmp = randperm(size(start_xy,1));
    ind = tmp(1);
    %start_xy_i = start_xy(ind,:);
    
    
    start_xy_i = [800 0];
    
    R = sqrt((start_xy_i(1) - x_planet)^2 + (start_xy_i(2) - y_planet)^2);
    theta = asin((radius_planet + radius_asteroid) / R);
    alpha = acos((y_planet-start_xy_i(2)) / R);
    alpha_max = alpha + abs(theta);
    alpha_min = alpha - abs(theta);
    
    alpha + 2*(pi/2-alpha)
    pi/2 + alpha
    pi/2 - alpha
    pi + alpha
    2*pi - (alpha - pi/2)
    5*pi/2 - alpha
    
    asteroidx = [asteroidx; start_xy_i(1)];
    asteroidy = [asteroidy; start_xy_i(2)];   
    
    
    
    
    


%     % calculate all angles from the point above to the circle_points
%     % i.e. find the slope of the line connecting both
%     slopes = [];
%     for c = 1:size(circle_points_xy,1)
%         x_circle = circle_points_xy(c,1);
%         y_circle = circle_points_xy(c,2);
% 
%         x_circle = 350;
%         y_circle = 333;
% 
%         if start_xy_i(1) < x_circle
%             slopes = [slopes; (y_circle - start_xy_i(2)) / (x_circle - start_xy_i(1))];
%         elseif start_xy_i(1) > x_circle
%             slopes = [slopes; (start_xy_i(2) - y_circle) / (start_xy_i(1) - x_circle)];
%         else % straight
%             
%         end;   
%     end;
% 
%     % turn slopes into angles
%     % https://www.math.washington.edu/~greenber/slope.html
%     angles = atan(slopes); % in radians
%     % the angles are only correct when inside canvas, otherwise we need to
%     % add 180 degrees

    % for collision course, pick a number between min and max angle

    possible_angles = [min(angles):0.0001:max(angles)];
    ind = randperm(size(possible_angles,2));
    angle = [angle; possible_angles(ind(1))];
    
    % pick random asteroid speed
    ind = randperm(size(asteroid_speeds,2));
    speed = [speed; asteroid_speeds(ind(1))];
    
    % calculate onset
    % first, pick a delay, jittered
    tmp = randperm(size(spawning_interval_seconds,2));
    tracking_time = tracking_time + spawning_interval_seconds(tmp(1));
    time = [time tracking_time];
    
end;



% write to matlab command window

% fprintf('\n\nvar asteroidsX = [');
% for asteroid = 1:total_nr_asteroids
%     fprintf('%.0f',asteroidx(asteroid));
%     if asteroid == total_nr_asteroids
%         fprintf('];\n');
%     else
%         fprintf(',');
%     end;
% end;
% 
% fprintf('var asteroidsY = [');
% for asteroid = 1:total_nr_asteroids
%     fprintf('%.0f',asteroidy(asteroid));
%     if asteroid == total_nr_asteroids
%         fprintf('];\n');
%     else
%         fprintf(',');
%     end;
% end;
% 
% fprintf('var asteroidsAngle = [');
% for asteroid = 1:total_nr_asteroids
%     fprintf('%.4f',angle(asteroid));
%     if asteroid == total_nr_asteroids
%         fprintf('];\n');
%     else
%         fprintf(',');
%     end;
% end;
% 
% fprintf('var asteroidsSpeed = [');
% for asteroid = 1:total_nr_asteroids
%     fprintf('%.0f',speed(asteroid));
%     if asteroid == total_nr_asteroids
%         fprintf('];\n');
%     else
%         fprintf(',');
%     end;
% end;
% 
% fprintf('var asteroidOnset = [');
% for asteroid = 1:total_nr_asteroids
%     fprintf('%.0f',time(asteroid));
%     if asteroid == total_nr_asteroids
%         fprintf('];\n');
%     else
%         fprintf(',');
%     end;
% end;
