


%% SPECS

fill_factor = 1.2;
side_area = 117.7446; %inches from CAD

% Motor
rpm_max = 5500;
cont_power = 24.88; %kW
motor_weight = 12; %kg

% Battery
% Samsung 35E 18650
len = 65 * 0.0393701;
circ = 18 * 0.0393701;
voltage = 3.6;
amp_hours = 3.5;
watt_hours = voltage * amp_hours;
bat_price = 3.45; %USD
bat_weight = 50; %grams

%% CELL PACK 
cell_len = circ * 12;
cell_width = len * 4;
cell_height = circ * 3;
cell_vol = cell_len * cell_width * cell_height;
cell_vol_fill = cell_vol * fill_factor;
cell_count = 3 * 4 * 12;
cell_wh = watt_hours * cell_count;


%% BATTERY PACK
num_cells = 6;
pack_vol = cell_vol_fill * num_cells;
pack_width = cell_width;
pack_len = cell_len;
pack_height = cell_height * num_cells;
pack_count = cell_count * num_cells;
pack_kwh = pack_count * watt_hours / 1000;
pack_voltage = cell_count * voltage;
pack_amps = num_cells * 8;

%% PERFORMANCE CHARACTERISTICS
op_time = (pack_kwh/cont_power) * 60;
price = pack_count * bat_price;
weight = pack_count * bat_weight / 1000; %kg

fprintf('Pack kWh (kWh)        : %.2f.\n', pack_kwh);
fprintf('Pack Voltage (v)      : %.2f.\n', pack_voltage);
fprintf('Pack Amperage (A)     : %.2f.\n', pack_amps);
fprintf('Pack Length (in)      : %.2f.\n', pack_len);
fprintf('Pack Width (in)       : %.2f.\n', pack_width);
fprintf('Pack Height (in)      : %.2f.\n', pack_height);
fprintf('Pack Volume (in^3)    : %.2f.\n', pack_vol);
fprintf('Pack Count (num cells): %.2f.\n', pack_count);
fprintf('Pack Weight (kg)      : %.2f.\n', weight);
fprintf('Pack Cost (USD)       : %.2f.\n', price);
fprintf('Pack Op Duration (min): %.2f.\n', op_time);






