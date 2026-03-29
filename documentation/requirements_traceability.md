| Requirement ID | Description                                                             | Design Implementation | Testing method | Expected outcome | Status |
|----------------|-------------------------------------------------------------------------|-----------------------|----------------|------------------|--------|
| R1             | Generate realistic BP waveform                                          | Utilization of reliable models such as WindKessel for parametric waveform generation |  
| R2             | Include Signal variability                                              | Variability factors considered and introduced on a beat to beat scale |              
| R3             | Pre-process to remove noise                                             |                       |  
| R4             | Anti-aliasing                                                           | Ensure sampling frequency is greater than Nyquist frequency | 
| R5             | Graphical output for simulated waveform                                 | Time-series plotting using MATLAB |
| R6             | Ensure separation between simulation ground truth and measurement path  | Isolate simulation values from measurement inputs |
| R7             | Extract BP systolic/diastolic values from signal                        | Peak (systolic) and trough (diastolic) value detection utilizing signal processing |
| R8             | Measure BP using MAP formula and BP values                              |                       
| R9             | Threshold for false outcomes                                            |                      
| R10            | Display simulated and measured outputs                                  |                      
