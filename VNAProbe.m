clc
close all
clear

n1500 = 'Probe.exe';

cmdStr = sprintf('taskkill /IM %s /F', n1500);
[status, cmdOutput] = system(cmdStr);

if status == 0
    fprintf('%s was closed successfully.\n', n1500);
else
    fprintf('Failed to close %s. Error: %s\n', n1500, cmdOutput);
end

%% Configuration & Connection for the VNA
resourceStr = 'TCPIP0::172.17.228.250::hislip0::INSTR';


% Create and open a VISA object
fprintf('Connecting to VNA via VISA...\n');
try
    vna = visadev(resourceStr);
    disp('Successfully connected to VNA.');
catch ME
    error('Failed to connect. Check your connection and VISA address. Error: %s', ME.message);
end


% Connect to the running instance of N1500A Suite
fprintf('Connecting to N1500A Application COM server...\n');
try
    n1500 = tcpclient('localhost', 5025);
    disp('Successfully connected to N1500A Application.');
catch ME
    error('Could not connect to N1500A. Ensure the N1500A GUI is running. Error: %s', ME.message);
end


% Instrument Identification
instrumentID = writeread(vna, '*IDN?');
fprintf('Connected to: %s\n', strtrim(instrumentID));

% Instrument Configuration
writeline(vna, '*CLS');



% %% Arduino Configuration and connection
% 
% delete(serialportfind);
% 
% serialObj = serialport("COM3", 115200);
% 
% configureTerminator(serialObj, "LF");
% flush(serialObj);
% 
% pause(2);
% 
% ready = readline(serialObj);
% disp(ready)
% 
% 
% %% Arduino Moving of the Platform - to be added to for loop with all measurements
% 
% stepsPerRev = 2043;
% module = 1;
% numTeeth = 15;
% 
% distances = [57.0/2,57.0/2-2, 2,2,28.5-4,2,2,28.5-4,2,2,28.5-2+30-2,2.5,28.5,2+5.0/2];
% positions = cumsum(distances);
% 
% function step = DistanceToStep(distance, stepsPerRev, module, numTeeth)
%     step = -(stepsPerRev * distance)/(pi * module * numTeeth);
%     step = int32(step);
% end
% 
% steps = DistanceToStep(distances, stepsPerRev, module, numTeeth);
% totalSteps = DistanceToStep(positions(end), stepsPerRev, module, numTeeth);
% 
% %% Loop for phantom movement and data collection
% for i = 1:length(steps)
%     %% Sending step and moving motor
%     writeline(serialObj, string(steps(i)));
%     receivedString = readline(serialObj);
%     disp("Received: " + receivedString);
%     %% Loop for measurements taken
%     for j = 1:3
%         fprintf("Scanning\n");
%         pause(1);
%     end
% 
% end
% fprintf("DONE\n");
% 
% % run this to move back to origin after removing HTP -> writeline(serialObj,'9000')





%% VNA S11 saving - to be added to for loop with all measurements
port = 1;
port = string(port);

tracePort = 'S' + port + '_' + port;
traceName = 'CH1_' + tracePort + '_' + string(port);


% Initialize window
writeline(vna,'DISP:WIND1:STATE OFF');
writeline(vna,'DISP:WIND1:STATE ON');

% Initialize reflection coefficient traces
calcline = append('CALC:PAR:DEF:EXT "', traceName, '", ', tracePort);
displayLine = append('DISP:WIND1:TRAC', string(1), ':FEED "', traceName, '"');

% Display reflection coefficients
writeline(vna, calcline);
writeline(vna, displayLine);


% Make sure VNA is not executing another command
writeline(vna, '*OPC?');
readline(vna);
pause(1)


% Save data to .sNp file
s1p_destination = append(['"C:\Users\Administrator\Documents\SCPI_Test_May_21_2026\' ...
    'S11 data '], string(datetime('now','Format','MM-dd_HH-mm-ss')), '.s1p",');

permittivity_destination = append('"C:\Users\Administrator\Documents\SCPI_Test_May_21_2026\permitivity data', ...
    string(datetime('now','Format','MM-dd_HH-mm-ss')), '.csv",');

% example: MMEM:STOR:DATA:SNP "filename", "1,2,3", "DB", 1.1
paramPort = append(' "',join(port, ","),'",');
paramFormat = append(' "DB",');
paramTouchstoneVersion = append(' 1.1');

scpiSave = append('MMEM:STOR:DATA:SNP ',s1p_destination, paramPort, paramFormat, paramTouchstoneVersion);
writeline(vna, scpiSave);


% Trigger Measurement


% Save the underlying S11 data
s1p_command = append('MMEM:STOR:DATA:SNP ', s1p_destination, '"', string(port), '"', ' "DB" 1.1');
writeline(vna, s1p_command);
writeline(n1500, ':INIT:IMM');
csv_command = sprintf('MMEM:STOR:DATA "%s", "csv"', permittivity_destination);
writeline(n1500, csv_command);
% Save the complex permittivity






