## Failure Mode and Effects Analysis (FMEA)

| Component / Function | Failure Mode | Cause | Effect | Severity (S) | Occurrence (O) | Detection (D) | RPN | Mitigation |
|---------------------|-------------|-------|--------|--------------|----------------|----------------|-----|-----------|
| Signal Generation | Unrealistic/Inaccurate waveform | Inaccurate parameter choice, error in generation formula | Non-physiological waveform, misrepresentation of BP | 9 | 3 | 4 | 108
| Signal Noise | Excessive Noise | Improper noise modelling | Signal distortion reducing measurement and simulation accuracy | 6 | 4 | 5 | 120
| Measurement Calculation | Incorrect data input | Typographical or human error during data input | Wrong measurement values for BP | 10 | 3 | 3 | 90
| Sampling | Aliasing | Sampling frequency below Nyquist frequency | Distorted waveform and incorrect data acquisition | 7 | 2 | 4 | 70
| Calibration | Calibration drift | Absence of recalibration and drift over time | Gradual shift from true values | 6 | 4 | 7 | 168
| Sensor Model | Incorrect representation | Inaccurate model construction or oversimplified model | Mismatch between simulation and real-world measurement | 10 | 6 | 6 | 360
| Output Display | Incorrect output | Error in code or scaling errors | Misrepresentation of true measured values | 7 | 3 | 3 | 63
| Variability Model | Missing/Poorly adjusted physiological variation | Inadequate variability introduced or unaccounted natural variability factors | Unrealistic simulation measurements | 6 | 7 | 6 | 252
