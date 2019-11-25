subj = input('Please subject ID:', 's');

flag_cond = 1;
while flag_cond
    visit = input('Test visit number (visit-1 to visit-4): ', 's');
    switch visit
        case {'visit-1', 'visit-2', 'visit-3', 'visit-4'}
            flag_cond = 0;
        otherwise
            fprintf(2, 'Unrecognized visit type! Try again!\n');
    end
end

% Make directory to save results
paraDir = strcat('C:\Experiments\Agudemu\stimulus-TFS\stage-2\speech\results\', visit, '\');
if(~exist(strcat(paraDir,'\',subj),'dir'))
    mkdir(strcat(paraDir,'\',subj));
end

startflag = input('Start from the beginning? Y/N:', 's');
if (startflag == 'Y' || startflag == 'y')
    startBlock = 1;
else
    startBlock = input('Enter the block number at which to start (1-10):');
end
currentDir = 'C:\Experiments\Agudemu\stimulus-TFS\stage-2\speech';
respDir = strcat(paraDir,'\',subj,'\');
save(strcat(currentDir,'\currsubj'), 'subj', 'respDir', 'startBlock', 'visit');

%% Call app
pause(1);
WiN6AFC_Agudemu;