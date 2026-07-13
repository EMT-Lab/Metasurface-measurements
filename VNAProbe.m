clc
close all
clear



%% Configuration & Connection for the VNA
resourceStr = 'TCPIP0::172.17.229.244::hislip0::INSTR';


% Create and open a VISA object
try
    vna = visadev(resourceStr);
    disp('Successfully connected to VNA.');
catch ME
    disp('Failed to connect. Check your connection and VISA address.');
    rethrow(ME);
end


% Instrument Identification
instrumentID = writeread(vna, '*IDN?');
fprintf('Connected to: %s\n', strtrim(instrumentID));

% Instrument Configuration
writeline(vna, '*CLS');



%% Arduino Configuration and connection

% To be written




%% Arduino Moving of the Platform - to be added to for loop with all measurements

% To be written






%% VNA S11 saving - to be added to for loop with all measurements
port = 1;
port = string(port);

tracePort = 'S' + port + '_' + port;
traceName = 'CH1_' + tracePort + '_' + string(traceNum); 


% Initialize window
writeline(vna,'DISP:WIND1:STATE OFF');
writeline(vna,'DISP:WIND1:STATE ON');

% Initialize reflection coefficient traces
calcline = append('CALC:PAR:DEF:EXT "', traceName, '", ', tracePort);
displayLine = append('DISP:WIND1:TRAC', string(reflectionTrace'), ':FEED "', reflectionName, '"');

% Display reflection coefficients
writeline(vna, calcline);
writeline(vna, displayLine);


% Make sure VNA is not executing another command
writeline(vna, '*OPC?');
readline(vna);
pause(1)


% Save data to .sNp file
paramFileName = append('"C:\Users\Administrator\Documents\SCPI_Test_May_21_2026\', ...
    string(fileName),'_', ...
    string(datetime('now','Format','MM-dd_HH-mm-ss')), '.s', string(numAntennas), 'p",');


% example: MMEM:STOR:DATA:SNP "filename", "1,2,3", "DB", 1.1
paramPort = append(' "',join(ports, ","),'",');
paramFormat = append(' "DB",');
paramTouchstoneVersion = append(' 1.1');

scpiSave = append('MMEM:STOR:DATA:SNP ',paramFileName, paramPort, paramFormat, paramTouchstoneVersion);
writeline(vna, scpiSave);














