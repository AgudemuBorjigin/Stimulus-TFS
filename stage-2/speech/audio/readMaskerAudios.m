function stim_temp = readMaskerAudios(root_audios, audio_name, masker, maskers_female, maskers_male)
        speaker_name = masker; 
        dir_temp = strcat(root_audios, '/harvard_sentences/', speaker_name,...
            '/audio/', audio_name);
        counter = 0;
        while ~exist(dir_temp, 'file') % not every speaker recorded every sentence
            counter = counter + 1;
            if strcmp(audio_name(3), 'F')
                speaker_temp = maskers_female{counter};
                dir_temp = strcat(root_audios, '/harvard_sentences/', speaker_temp,...
                    '/audio/', speaker_temp, audio_name(7:end));
            else
                speaker_temp = maskers_male{counter};
                dir_temp = strcat(root_audios, '/harvard_sentences/', speaker_temp,...
                    '/audio/', speaker_temp, audio_name(7:end));
            end
            speaker_name = speaker_temp; %#ok<NASGU>
        end
        stim_temp = resample(audioread(dir_temp), 692, 625);
        stim_temp = scaleSound(stim_temp);
end