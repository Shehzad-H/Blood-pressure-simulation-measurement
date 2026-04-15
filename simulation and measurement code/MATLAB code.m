%%Simulation Section
%%Arterial Pressure Model

clear; clc; close all;

%% Parameter choice
fs = 200;                                                   % sampling freq
T = 20;                                                     % period
t = 0:1/fs:T;

HR = 75;
f_hr = HR/60;
MAP = 93;
pulse_amp = 28;

arterial_shape = sin(2*pi*f_hr*t);                          % cardiac cycle waveform
arterial_shape(arterial_shape < -0.15) = -0.15;             % clip waveform
arterial_shape = arterial_shape - mean(arterial_shape);     
arterial_shape = arterial_shape / max(abs(arterial_shape)); % normalize

P_artery = MAP + pulse_amp * arterial_shape;                % primary arteraial pressure construction

%% Small physiological variability (arterial)

arterial_noise_amp = 0.3;                                   % noise modifier

arterial_noise = arterial_noise_amp * randn(size(P_artery));

P_artery = P_artery + arterial_noise;

slow_var = 0.4 * sin(2*pi*0.1*t);                           % low frequency drift
P_artery = P_artery + slow_var;

figure;
plot(t, P_artery, 'LineWidth', 1.5);
hold on;


%%Cuff Pressure Simulation
P_cuff_base = linspace(160, 50, length(t)) + 0.5*randn(size(t));   % decreasing cuff pressure + variation

P_tm = P_artery - P_cuff_base;                                     % pressure difference between artery and cuff

osc_gain = zeros(size(P_cuff_base));                               % cuff-blood flow oscillation relationship modelling

left_side = P_cuff_base >= MAP;
right_side = P_cuff_base < MAP;

osc_gain(left_side) = exp(-((P_cuff_base(left_side) - MAP)/30).^2);
osc_gain(right_side) = exp(-((P_cuff_base(right_side) - MAP)/18).^2);

osc_component = 6 * osc_gain .* max(arterial_shape,0);             % scale oscillations to bell curve, peaks at cuff pressure ~= artery

P_cuff_total = P_cuff_base + osc_component;     

%% Cuff noise

cuff_noise_amp = 0.1;                                              % noise modifier

cuff_noise = cuff_noise_amp * randn(size(P_cuff_total));

P_cuff_real = P_cuff_total + cuff_noise;                           % final cuff pressure (simulation output)

figure;
plot(t, P_cuff_real, 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Pressure (mmHg)');
legend('Cuff Pressure (post-noise)')
title('Arterial Pressure and Cuff Pressure Interaction');
grid on;

figure;
plot(t, P_tm, 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Transmural Pressure (mmHg)');
title('Transmural Pressure: P_{artery} - P_{cuff}');
grid on;

%%Measurement Section
%%Sensor Model (Piezoelectric sensing)
k = 0.02;                                               % sensor sensitivity
c = 0.5;                                                % baseline voltage offset
V_signal = k * P_cuff_real + c;                         % Voltage sensing general equation

sensor_noise_amp = 0.005;                               % voltage sensor(transducer) noise modifier
V_noise = sensor_noise_amp * randn(size(V_signal));

V_measured = V_signal + V_noise;                        % final voltage output

window = 50;                                            % smoothing

V_baseline = movmean(V_measured, window);               % state voltage baseline 
V_detrended = V_measured - V_baseline;                  % isolate oscillations from signal

figure;
subplot(2,1,1);
plot(t, V_measured, 'LineWidth', 1.2); hold on;         
plot(t, V_baseline, '--', 'LineWidth', 1.2);
xlabel('Time (s)');
ylabel('Voltage (V)');
title('Raw Voltage Signal with Baseline');
legend('Measured Voltage', 'Baseline');
grid on;

subplot(2,1,2);
plot(t, V_detrended, 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Voltage (V)');
title('Detrended Voltage (Oscillations Only)');
grid on;

%%Calibration (Voltage to Pressure)
lowcut = 0.5;
highcut = 5;

[b,a] = butter(2, [lowcut highcut]/(fs/2), 'bandpass');

V_filtered = filtfilt(b, a, V_measured);

V_rect = abs(V_filtered);
env = movmean(V_rect, 80);         % smooth oscillation envelope

[~, locs] = findpeaks(V_rect);

amps = env(locs);
P_peaks = P_cuff_real(locs);                      % full cuff pressure signal

figure;
scatter(P_peaks, amps, 10, 'filled');
xlabel('Cuff Pressure (mmHg)');
ylabel('Oscillation Amplitude (V)');
title('Corrected Oscillation Envelope');
grid on;

%%Signal Processing (SBP/DBP extraction)
amps = movmean(amps, 20);                               % smooth aplitudes using moving average


[P_sorted, sort_idx] = sort(P_peaks);                   % sort pressure in increasing order
amps_sorted = amps(sort_idx);                           % reorder amplitudes to match sorted pressure
amps_sorted = movmean(amps_sorted, 20);

[map_amp, map_idx] = max(amps_sorted);                  % locate max amplitude
MAP_pressure = P_sorted(map_idx)                        % specify MAP location from max amplitude (reporting)

sbp_thresh = 0.5 * map_amp;
dbp_thresh = 0.8 * map_amp;

%%
%% LEFT = LOW PRESSURE = DBP
left_amps = amps_sorted(1:map_idx);
left_pressures = P_sorted(1:map_idx);

dbp_index = find(left_amps >= dbp_thresh, 1, 'first');
DBP = left_pressures(dbp_index);

%% RIGHT = HIGH PRESSURE = SBP
right_amps = amps_sorted(map_idx:end);
right_pressures = P_sorted(map_idx:end);

sbp_index = find(right_amps <= sbp_thresh, 1, 'first');
SBP = right_pressures(sbp_index);

figure;
plot(P_sorted, amps_sorted, 'b', 'LineWidth', 2); hold on;

plot(MAP_pressure, map_amp, 'ro', 'MarkerSize', 8, 'LineWidth', 2);
plot(SBP, sbp_thresh, 'go', 'MarkerSize', 8, 'LineWidth', 2);
plot(DBP, dbp_thresh, 'mo', 'MarkerSize', 8, 'LineWidth', 2);

xlabel('Cuff Pressure (mmHg)');
ylabel('Oscillation Amplitude (V)');
title('Oscillation Envelope with SBP, MAP, DBP');
legend('Envelope', 'MAP', 'SBP', 'DBP');
grid on;

% Display pressures

fprintf('Systolic Blood Pressure (SBP): %.2f mmHg\n', SBP);
fprintf('Diastolic Blood Pressure (DBP): %.2f mmHg\n', DBP);
fprintf('Mean Arterial Pressure (MAP): %.2f mmHg\n', MAP_pressure);
