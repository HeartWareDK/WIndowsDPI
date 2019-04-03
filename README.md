# WIndowsDPI
Read Windows DPI Scaling from a Non-HighDPI Aware application

Usage:
  TWindowsDPI contains 2x3 static functions.
  The GetTrueDPI functions executes the GetDPI functions in a newly created thread that has been made HighDPI Aware
  and thus circumvents the Windows limitation that only HighDPI Aware applications can read the true value.
  
TWindowsDPI.GetTrueDPI             : Returns the system-level DPI scaling
TWIndowsDPI.GetTrueDPI(TMonitor)   : Returns the monitor-level DPI scaling for the given monitor
TWindowsDPI.GetTrueDPI(TForm)      : Returns the monitor-level DPI scaling for the monitor on which the Form is
