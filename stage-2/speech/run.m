subj = input('Please subject ID:', 's');

flag_cond = 1;
while flag_cond
    condition = input('Test condition (anechoic, echo, space, pitch, or sum): ', 's');
    switch condition
        case {'anechoic', 'echo', 'space', 'pitch', 'sum'}
            flag_cond = 0;
        otherwise
            fprintf(2, 'Unrecognized stimulus type! Try again!\n');
    end
end

% Make directory to save results
paraDir = strcat('C:\Experiments\Agudemu\stimulus-TFS\stage-2\speech\results\', condition, '\');
if(~exist(strcat(paraDir,'\',subj),'dir'))
    mkdir(strcat(paraDir,'\',subj));
end

startflag = input('Start from the beginning? Y/N:', 's');
if (startflag == 'Y' || startflag == 'y')
    startBlock = 1;
else
    startBlock = input('Enter the block number at which to start (1-10):');
end
respDir = strcat(paraDir,'\',subj,'\');
save('currsubj', 'subj', 'respDir', 'startBlock', 'condition');

%% Call app
pause(1);
WiN6AFC;