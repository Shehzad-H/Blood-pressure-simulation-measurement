clear all; close all;

fsample = 200;                 % Hz
duration = 20;            % seconds
t = 0:1/fsample:duration;

pressure = zeros(size(t));

current_index = 1;

while current_index < length(t)

    % Random physiological parameters based on average physiological values
    % for systolic, diastolic and heart rate
    SBP = 120 + randn*0.1;
    DBP = 75 + randn*0.1;
    HR  = 70 + randn*0.05;

    beat_period = 60/HR;
    beat_samples = round(beat_period * fsample);

    if current_index + beat_samples - 1 > length(t)
        beat_samples = length(t) - current_index + 1;
    end

    beat_t = linspace(0, beat_period, beat_samples);

    % arterial pulse shape with systolic fraction of 30%
    rise_fraction = 0.3;

    rise_samples = round(beat_samples * rise_fraction);
    decay_samples = beat_samples - rise_samples;

    % time vectors
    rise_t = linspace(0,1,rise_samples);
    decay_t = linspace(0,1,decay_samples);

    % fast systolic rise
    rise_wave = DBP + (SBP-DBP)*(rise_t.^2);

    % slow diastolic decay
    decay_wave = DBP + (SBP-DBP)*exp(-4*decay_t);
    
    beat_wave = [rise_wave decay_wave];

    pressure(current_index:current_index + beat_samples - 1) = beat_wave;

    current_index = current_index + beat_samples;

end


% respiratory modulation
resp_mod = 3 * sin(2*pi*0.25*t);
pressure = pressure + resp_mod;


% physiological noise to simulate real life constraints
noise = randn(size(pressure));
pressure = pressure + noise;


% plot waveform
figure
plot(t, pressure)
xlabel('Time (s)')
ylabel('Pressure (mmHg)')
title('Simulated Arterial Blood Pressure Waveform')
grid on
