subj = input('Please subject ID:', 's');
% Make directory to save results
paraDir = 'C:\Experiments\Agudemu\stimulus_TFS\stage-2\results\';
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
save('currsubj', 'subj', 'respDir', 'startBlock');

%% Call app
pause(1);
WiN6AFC;