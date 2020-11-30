clear all;

%% Variables

% Globals
t_step = 0.1;
grav = 9.8;

% Battery Info
bat_amps = 48;
bat_volt = 518.4;
bat_kwh = 10.88;

% Efficiency
motor_eff = 0.95; % From data sheet
gear_eff = 0.97; % From internet source
sys_eff = motor_eff * gear_eff;

% Bike weight
wheel_mass = 7; %kg
frame_mass = 36; %kg
motor_mass = 12; %kg
bat_mass = 43.2; %kg
elec_mass = 15; %kg
rider_mass = 84; %kg
total_mass = rider_mass + elec_mass + bat_mass + motor_mass + ...
    frame_mass + (2*wheel_mass);

% Bike wheel information
w_diam = 23.92; %inches
w_diam_m = w_diam * 0.0254; %meters
w_circ = w_diam * 3.141 / 12;  %feet
g_ratio = 2.5;

% Torque info from excel table
torque = readtable('torque.xlsx');
int_rpm = 0:20:5500;
rpm = table2array(torque(:,1)).';
cont = table2array(torque(:,2)).';
peak = table2array(torque(:,3)).';

% Interpolated torque values 
cont_t = interp1(rpm, cont, int_rpm);
peak_t = interp1(rpm, peak, int_rpm);


 
% Rolling Resistance
coeff_rr = 0.005;
rr = coeff_rr * grav * total_mass;

%% Calculations

% Initialize values for acceleration, velocity, and distance
total_dist = 0;
vel(1) = 0;
dist(1) = 0;
ac(1) = 0;
tor_info(1) = peak_t(1);
drag_info(1) = 0;
iteration = 1;

% Loop for calculating instantaneous values and storing them
while total_dist < 402.336
    % determine index of current rpm and store in index
    fpm = vel(iteration) * 196.85;
    motor_rpm = (fpm / (w_diam / 12))*g_ratio;
    [val, index] = min(abs(rpm - motor_rpm));
    
    % Use index of current rpm to find current peak torque
    tor = peak_t(index);
    tor_info(iteration+1) = tor;
    
    % Find the net force on the bike
    f_motor = ((g_ratio * tor) / w_diam_m)*sys_eff;
    dra = drag(vel(iteration));
    drag_info(iteration+1) = dra;
    f_net =  f_motor - dra - rr;
    accel = f_net / total_mass;
    
    % Store the current acceleration, velocity, and Distance
    ac(iteration+1) = accel;
    vel(iteration+1) = vel(iteration) + accel*t_step;
    dist(iteration+1) = trapz(t_step, vel);
    
    % Keep running tally of total distance for loop duration
    total_dist = trapz(t_step, vel);
    iteration = iteration + 1;
end

% Clean up acceleration graph
ac(1) = ac(2);

% Determine total run time and the amount of power used
% via finding total available battery power for kw used 
% by the motor and creating a multiplier for the time
% for one run compared to the total time that could be run.
run_time_s = size(ac, 2)/10;
fprintf('Quarter Mile Time (sec): %.2f.\n', run_time_s);
run_time = size(ac, 2)/10 / 3600;
kw = bat_amps * bat_volt / 1000;
fprintf('Motor Max kW: %.2f.\n', kw);
total_time = bat_kwh/kw;
fprintf('Total Available Run Time (min): %.2f.\n', total_time*60);
run_diff = run_time/total_time;
kwh_used = kw * run_diff;
fprintf('Total kWh Available: %.2f.\n', bat_kwh);
fprintf('kWh used: %.2f.\n', kwh_used);
fprintf('kWh used as percent of total: %.2f%%.\n', (kwh_used/bat_kwh)*100);

% Plot results
time = 0:t_step:(size(dist,2)*t_step)-t_step;
tiledlayout(3,1);
nexttile
plot(time, ac, 'Linewidth', 3, 'color', 'r');
title('Acceleration', 'FontSize', 16);
ylabel('m/s^2');
xlabel('seconds');
ax = gca;
ax.XAxis.FontSize = 14;
ax.YAxis.FontSize = 14;

nexttile
plot(time, vel*2.23694, 'Linewidth', 3, 'color', 'r');
title('Velocity', 'FontSize', 16);
ylabel('mph');
xlabel('seconds');
ax = gca;
ax.XAxis.FontSize = 14;
ax.YAxis.FontSize = 14;

nexttile
plot(time, dist*3.28084, 'Linewidth', 3, 'color', 'r');
title('Distance', 'FontSize', 16);
ylabel('ft');
xlabel('seconds');
ax = gca;
ax.XAxis.FontSize = 14;
ax.YAxis.FontSize = 14;

figure;
plot(dist, tor_info, 'Linewidth', 3);
title('Torque Information', 'FontSize', 16);
xlabel('distance (m)');
ylabel('torque (Nm)');
ax = gca;
ax.XAxis.FontSize = 14;
ax.YAxis.FontSize = 14;

figure;
plot(vel, drag_info, 'color', 'b', 'Linewidth', 3);
title('Drag Force Information', 'FontSize', 16);
xlabel('velocity (m/s)');
ylabel('drag force (N)');
ax = gca;
ax.XAxis.FontSize = 14;
ax.YAxis.FontSize = 14;

figure;
plot(rpm, cont, 'color', '#FF8800', 'Linewidth', 3);
hold on;
plot(rpm, peak, 'color', '#FF0088', 'Linewidth', 3);
xlabel('RPM');
ylabel('Torque (Nm)');
title('Continuous & Peak Torque');
ax = gca;
ax.XAxis.FontSize = 14;
ax.YAxis.FontSize = 14;
hold off;


%% Functions

function drag_force = drag(vel)
    rho = 1.3;
    cd = 0.25;
    af = 0.5;
    drag_force = 0.5 * rho * cd * af * (vel ^2);
end







