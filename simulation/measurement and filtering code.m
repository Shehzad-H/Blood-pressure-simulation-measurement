% parameters to simulate measurement constraints in sensor model
gain = 1.03;
offset = -2;
sensor_noise = 0.5 * randn(size(pressure));

% calculation
measured_pressure = pressure * gain + offset + sensor_noise

% passing through butterworth filter
fsample = 200;     % reiterating from simulation sampling frequency
fc = 20;

[b,a] = butter(2, fc/(fsample/2));
measured_pressure = filtfilt(b,a,measured_pressure);
