%SIM = input ('Input the sim name: ');
%T = input ('Input the sim type: ');
%M = input ('Input the catalog cardinality: ');
%C = input ('Input the cache to catalog ratio: ');
%L = input ('Input the lambda: ');
%A = input ('Input the Zipf Exponent: ');
%R = input ('Input the number of runs: ');

stringOutput = 'DATA_SIM=CCNSIM_T=TANDEM_CACHE_A=06_REQ=100000000.mat';

% STRINGHE 

simulatorStr = cell(1,4);
simulatorStr{1} = 'CCNSIM';
simulatorStr{2} = 'NDNSIM';
simulatorStr{3} = 'ICARUS';
simulatorStr{4} = 'CCNPL';

scenarioStr = cell(1,1);
scenarioStr{1} = 'TANDEM_CACHE';

catalogStr = cell(1,1);
catalogStr{1} = '10000';

ratioStr = cell(1,1);
ratioStr{1} = '0.01';

lambdaStr = cell(1,1);
lambdaStr{1} = '4';

alphaStr = cell(1,4);
alphaStr{1} = '0.6';
alphaStr{2} = '0.8';
alphaStr{3} = '1';
alphaStr{4} = '1.2';

alphaStrCompl = cell(1,4);
alphaStrCompl{1} = 'alpha_06';
alphaStrCompl{2} = 'alpha_08';
alphaStrCompl{3} = 'alpha_1';
alphaStrCompl{4} = 'alpha_12';

alphaValues = [0.6 0.8 1 1.2];

simRuns = 10;
numRequests = 100100000;
officialNumRequests = 100000000;
reqStr = '100000000';
catalog = 10000;
IDs = 1:catalog;
target = 100;

tStudent = [1.2 6.314 2.920 2.353 2.132 2.015 1.943 1.895 1.860 1.833 1.812 1.796];

% Valori effettivi dei parametri simulati (servono a prendere le stringhe

numSimulators = [1];
numScenarios = [1];
numCatalogs = [1];
numRatios = [1];
numLambdas = [1];
%numAlphas = [1 2 3 4];
numAlphas = [1];


% Import Che Approx
fileCheFirstCachePrefix = '/home/tortelli/ndn-simulator-comparison/Results/HitCheTeo_';
fileCheSecondCachePrefix = '/home/tortelli/ndn-simulator-comparison/Results/HitCheTeo_Second_';
fileCheSecondCacheLeoPrefix = '/home/tortelli/ndn-simulator-comparison/Results/HitCheTeo_Second_Leo_';
fileCheSuffix = '.txt';
Che_Approx_1 = struct;

for g=1:length(numAlphas)
    % FIRST CACHE
    fileCheCompl_1 = strcat(fileCheFirstCachePrefix, alphaStr{numAlphas(g)}, fileCheSuffix); 
    disp(sprintf('%s', fileCheCompl_1));
    fileID_1 = fopen(fileCheCompl_1);
    Che_Approx_1.(alphaStrCompl{numAlphas(g)}) = textscan(fileID_1,'%f32');
    fileID_1 = fclose(fileID_1);
    
    % SECOND CACHE
    fileCheCompl_2 = strcat(fileCheSecondCachePrefix, alphaStr{numAlphas(g)}, fileCheSuffix); 
    disp(sprintf('%s', fileCheCompl_2));
    fileID_2 = fopen(fileCheCompl_2);
    Che_Approx_2.(alphaStrCompl{numAlphas(g)}) = textscan(fileID_2,'%f32');
    fileID_2 = fclose(fileID_2);
    
    % SECOND CACHE APPROX LEONARDI
    fileCheCompl_2_Leo = strcat(fileCheSecondCacheLeoPrefix, alphaStr{numAlphas(g)}, fileCheSuffix); 
    disp(sprintf('%s', fileCheCompl_2_Leo));
    fileID_2_Leo = fopen(fileCheCompl_2_Leo);
    Che_Approx_2_Leo.(alphaStrCompl{numAlphas(g)}) = textscan(fileID_2_Leo,'%f32');
    fileID_2_Leo = fclose(fileID_2_Leo);
end


% Dichiarazione STRUCT per import

scenarioImport = struct;
contentID = struct;
hitDistance = struct;
limitRequests = struct;

% Inizializzazione Matrici per ContentID e HitDistance
for g = 1:length(numAlphas)
    for j = 1:length(numSimulators)
        contentID.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}) = zeros(numRequests, simRuns);
        hitDistance.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}) = zeros(numRequests, simRuns);
        limitRequests.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}) = zeros(simRuns,1);
    end
end


folder='/home/tortelli/ndn-simulator-comparison/Results/logs/';
ext='.out';

minLimit = struct;

for g=1:length(numAlphas)
    minLimit.(alphaStrCompl{numAlphas(g)}) = officialNumRequests;
end

for g = 1:length(numAlphas)
    for j = 1:length(numSimulators)
        for i=0:simRuns-1
            run = int2str(i);
            disp(sprintf('%s',strcat(simulatorStr{numSimulators(j)}, ' ' ,run)));
            nome_file=strcat(folder,'SIM=',simulatorStr{numSimulators(j)},'_T=',scenarioStr{numScenarios(1)},'_REQ=',reqStr,'_M=',catalogStr{numCatalogs(1)},'_C=',ratioStr{numRatios(1)},'_L=',lambdaStr{numLambdas(1)},'_A=',alphaStr{numAlphas(g)},'_R=',run,ext);
            disp(sprintf('%s', nome_file));
            fileID = fopen(nome_file);
            scenarioImport.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}) = textscan(fileID,'%d32 %d8');
            fileID = fclose(fileID);
            limit = length(scenarioImport.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}){1});
            limitRequests.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(i+1,1) = limit;
            if (limitRequests.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(i+1,1) < minLimit.(alphaStrCompl{numAlphas(g)}))
                minLimit.(alphaStrCompl{numAlphas(g)}) = limitRequests.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(i+1,1);
            end
            contentID.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(1:limit,i+1) = scenarioImport.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}){1}(1:limit,1);
            hitDistance.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(1:limit,i+1) = scenarioImport.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}){2}(1:limit,1);
            clear scenarioImport;
        end
    end
end

clear scenarioImport;
clear limitRequests;

% minLimit = struct;
% 
% for g=1:length(numAlphas)
%     minLimit.(alphaStrCompl{numAlphas(g)}) = officialNumRequests;
% end

% Search the minimum number of requests between the simulated scenarios, and reduce the dimension of the matrices accordingly 

% for g=1:length(numAlphas)
%     for j = 1:length(numSimulators)
%         for i=0:simRuns-1
%             if (limitRequests.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(i+1,1) < minLimit.(alphaStrCompl{numAlphas(g)}))
%                 minLimit.(alphaStrCompl{numAlphas(g)}) = limitRequests.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(i+1,1);
%             end
%         end
%     end
% end


for g=1:length(numAlphas)
    for j = 1:length(numSimulators)
        contentID.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(minLimit.(alphaStrCompl{numAlphas(g)})+1:numRequests,:) = [];
        hitDistance.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(minLimit.(alphaStrCompl{numAlphas(g)})+1:numRequests,:) = [];
    end
end

% Calculate the Theoretical number of request per each content
%alphaValue = 1;

zipfLimit = struct;
zipf = struct;
normFactor = struct;
freqZipf = struct;

for g=1:length(numAlphas)
    normFactor.(alphaStrCompl{numAlphas(g)}) = 0;
    zipf.(alphaStrCompl{numAlphas(g)}) = zeros(1, catalog);
end

for g=1:length(numAlphas)
    for z=1:catalog
        normFactor.(alphaStrCompl{numAlphas(g)}) = normFactor.(alphaStrCompl{numAlphas(g)}) + (1/z^alphaValues((numAlphas(g))));
    end
end

for g=1:length(numAlphas)
    normFactor.(alphaStrCompl{numAlphas(g)}) = 1 / normFactor.(alphaStrCompl{numAlphas(g)});
end

for g=1:length(numAlphas)
    for z=1:catalog
        zipf.(alphaStrCompl{numAlphas(g)})(1,z) = normFactor.(alphaStrCompl{numAlphas(g)}) * (1/z^alphaValues((numAlphas(g))));
        freqZipf.(alphaStrCompl{numAlphas(g)}) = minLimit.(alphaStrCompl{numAlphas(g)}) * zipf.(alphaStrCompl{numAlphas(g)});
    end
end


%zipf = alphaValue./(1:catalog);
%zipf = zipf/sum(zipf);
%freqZipf = minLimit * zipf;

% Find the Content ID that correspond to the X-th percentile
czipf = struct;
cont50 = struct;
cont75 = struct;
cont90 = struct;
cont95 = struct;

for g = 1:length(numAlphas)
    czipf.(alphaStrCompl{numAlphas(g)}) = cumsum(zipf.(alphaStrCompl{numAlphas(g)}));
    cont50.(alphaStrCompl{numAlphas(g)}) = find(czipf.(alphaStrCompl{numAlphas(g)})>=.50,1);
    cont75.(alphaStrCompl{numAlphas(g)}) = find(czipf.(alphaStrCompl{numAlphas(g)})>=.75,1);
    cont90.(alphaStrCompl{numAlphas(g)}) = find(czipf.(alphaStrCompl{numAlphas(g)})>=.90,1);
    cont95.(alphaStrCompl{numAlphas(g)}) = find(czipf.(alphaStrCompl{numAlphas(g)})>=.95,1);
end

%czipf = cumsum(zipf);
%cont50 = find(czipf>=.50,1);
%cont75 = find(czipf>=.75,1);
%cont90 = find(czipf>=.90,1);
%cont95 = find(czipf>=.95,1);


% Struct to accomodate the total probability of hit ratio and the Phit for
% each content

% FIRST CACHE
pHitTotalRuns_1 = struct;
pHitContentsRuns_1 = struct; 
pMissContentsRuns_1 = struct;

% SECOND CACHE
pHitTotalRuns_2 = struct;
pHitContentsRuns_2 = struct; 
pMissContentsRuns_2 = struct;
pHitContentsNEW_2 = struct;

% FIRST CACHE
frequencyHitContents_1 = struct;
frequencyMissContents_1 = struct;
frequencyRequestsContents_1 = struct;

% SECOND CACHE
frequencyHitContents_2 = struct;
frequencyMissContents_2 = struct;
frequencyRequestsContents_2 = struct;


for g=1:length(numAlphas)
    for j = 1:length(numSimulators)
        pHitTotalRuns_1.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}) = zeros(simRuns,1);
        pHitContentsRuns_1.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}) = zeros(catalog, simRuns);
        pMissContentsRuns_1.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}) = zeros(catalog, simRuns);
        frequencyHitContents_1.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}) = zeros(catalog, 1);
        frequencyMissContents_1.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}) = zeros(catalog, 1);
        frequencyRequestsContents_1.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}) = zeros(catalog, 1);
        
        pHitTotalRuns_2.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}) = zeros(simRuns,1);
        pHitContentsRuns_2.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}) = zeros(catalog, simRuns);
        pMissContentsRuns_2.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}) = zeros(catalog, simRuns);
        frequencyHitContents_2.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}) = zeros(catalog, 1);
        frequencyMissContents_2.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}) = zeros(catalog, 1);
        frequencyRequestsContents_2.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}) = zeros(catalog, 1);

    end
end

for g=1:length(numAlphas)
    for j = 1:length(numSimulators)
        for i = 0:simRuns-1
            for z = 1:minLimit.(alphaStrCompl{numAlphas(g)})
                
                switch (hitDistance.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(z,i+1))
                    case 0   % Local Hit (i.e. hit on the first cache)
                        pHitTotalRuns_1.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(i+1,1) = pHitTotalRuns_1.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(i+1,1) + 1;
                        w = contentID.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(z,i+1);  % Keep the correspondent content ID
                        pHitContentsRuns_1.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(w,i+1) = pHitContentsRuns_1.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(w,i+1) + 1;
                    case 1   % Hit on the Second Cache (so there was a Miss on the first cache)
                        pHitTotalRuns_2.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(i+1,1) = pHitTotalRuns_2.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(i+1,1) + 1;
                        m = contentID.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(z,i+1);  % Keep the correspondent content ID
                        pHitContentsRuns_2.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(m,i+1) = pHitContentsRuns_2.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(m,i+1) + 1;
                        pMissContentsRuns_1.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(m,i+1) = pMissContentsRuns_1.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(m,i+1) + 1;
                    case 2   % Hit on the Repo (so there was a miss both on the First and on the Second Cache).
                        n = contentID.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(z,i+1);  % Keep the correspondent content ID
                        pMissContentsRuns_1.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(n,i+1) = pMissContentsRuns_1.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(n,i+1) + 1;
                        pMissContentsRuns_2.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(n,i+1) = pMissContentsRuns_2.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(n,i+1) + 1;
                    otherwise 
                        disp(sprintf('Wrong Distance!'));
                end
            end
        end
    end
end

clear contentID;
clear hitDistance;

for g=1:length(numAlphas)
    for j = 1:length(numSimulators)
        for z = 1:catalog
            frequencyHitContents_1.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(z,1) = mean(pHitContentsRuns_1.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(z,:));
            frequencyMissContents_1.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(z,1) = mean(pMissContentsRuns_1.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(z,:));
            frequencyRequestsContents_1.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(z,1) = frequencyHitContents_1.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(z,1) + frequencyMissContents_1.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(z,1);

            frequencyHitContents_2.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(z,1) = mean(pHitContentsRuns_2.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(z,:));
            frequencyMissContents_2.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(z,1) = mean(pMissContentsRuns_2.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(z,:));
            frequencyRequestsContents_2.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(z,1) = frequencyHitContents_2.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(z,1) + frequencyMissContents_2.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(z,1);
        end
    end
end

%%%%%%%%%%%%%%%%     BINNING  %%%%%%%%%%%%%%%%%%%%%%%%%%

% for g=1:length(numAlphas)
%     for j = 1:length(numSimulators)
%         [xAxesBIN.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}), frequencyRequestsContentsBIN.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})] = variableBINS(IDs, frequencyRequestsContents.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}), target);
%         [xAxesZipfBIN.(alphaStrCompl{numAlphas(g)}), frequencyRequestsZipfBIN.(alphaStrCompl{numAlphas(g)})] = variableBINS(IDs, freqZipf.(alphaStrCompl{numAlphas(g)})', target);
%     end
% end
% 
% minBinMax = struct;
% for g=1:length(numAlphas)
%     minBinMax.(alphaStrCompl{numAlphas(g)}) = catalog;
% end
% 
% for g=1:length(numAlphas)
%     for j = 1:length(numSimulators)
%         if length(frequencyRequestsContentsBIN.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(:,1)) < minBinMax.(alphaStrCompl{numAlphas(g)})
%             minBinMax.(alphaStrCompl{numAlphas(g)}) = length(frequencyRequestsContentsBIN.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(:,1));
%         end
%     end
% end
% for g=1:length(numAlphas)
%     if length(frequencyRequestsZipfBIN.(alphaStrCompl{numAlphas(g)})(:,1)) < minBinMax.(alphaStrCompl{numAlphas(g)})
%         minBinMax.(alphaStrCompl{numAlphas(g)}) = length(frequencyRequestsZipfBIN.(alphaStrCompl{numAlphas(g)})(:,1));
%     end
% end
% 
% for g=1:length(numAlphas)
%     for j = 1:length(numSimulators)
%         frequencyRequestsContentsBIN.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}) = frequencyRequestsContentsBIN.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(1:minBinMax.(alphaStrCompl{numAlphas(g)}),1);
%         xAxesBIN.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}) = xAxesBIN.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(1:minBinMax.(alphaStrCompl{numAlphas(g)}),1);
%     end
% end
% 
% for g=1:length(numAlphas)
%     frequencyRequestsZipfBIN.(alphaStrCompl{numAlphas(g)}) = frequencyRequestsZipfBIN.(alphaStrCompl{numAlphas(g)})(1:minBinMax.(alphaStrCompl{numAlphas(g)}),1);
%     xAxesZipfBIN.(alphaStrCompl{numAlphas(g)}) = xAxesZipfBIN.(alphaStrCompl{numAlphas(g)})(1:minBinMax.(alphaStrCompl{numAlphas(g)}),1);
% end
% 
% frequencyHitContentsBIN = struct;
% pHitContentsBIN = struct;
% 
% for g=1:length(numAlphas)
%     for j = 1:length(numSimulators)
%         frequencyHitContentsBIN.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}) = zeros(minBinMax.(alphaStrCompl{numAlphas(g)}),1);
%         pHitContentsBIN.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}) = zeros(minBinMax.(alphaStrCompl{numAlphas(g)}),1);
%     end
% end
% 
% % Average the Hit Events according to the BIN calculated before, and
% % calculating the Hit Probability accordingly.
% 
% %start = 1;
% for g=1:length(numAlphas)
%     for j = 1:length(numSimulators)
%         start = 1;
%         for i = 1:minBinMax.(alphaStrCompl{numAlphas(g)})
%             p = xAxesBIN.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(i,1);
%             frequencyHitContentsBIN.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(i,1) = mean(frequencyHitContents.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(start:p,1));
%             pHitContentsBIN.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(i,1) = frequencyHitContentsBIN.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(i,1) / frequencyRequestsContentsBIN.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(i,1);
%             start = p+1;
%         end
%     end
% end
% 
% pHitCheBIN = struct;
% 
% for g=1:length(numAlphas)
%     pHitCheBIN.(alphaStrCompl{numAlphas(g)}) = zeros(minBinMax.(alphaStrCompl{numAlphas(g)}),1);
% end
% 
% %start = 1;
% for g=1:length(numAlphas)
%     start = 1;
%     for i = 1:minBinMax.(alphaStrCompl{numAlphas(g)})
%         p = xAxesZipfBIN.(alphaStrCompl{numAlphas(g)})(i,1);
%         pHitCheBIN.(alphaStrCompl{numAlphas(g)})(i,1) = mean(Che_Approx.(alphaStrCompl{numAlphas(g)}){1}(start:p,1));
%         start = p+1;
%     end
% end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for g=1:length(numAlphas)
    for j = 1:length(numSimulators)
        for i = 0:simRuns-1
            for z = 1:catalog
                pHitContentsRuns_1.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(z,i+1) = pHitContentsRuns_1.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(z,i+1) /(pHitContentsRuns_1.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(z,i+1) + pMissContentsRuns_1.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(z,i+1));
                pHitContentsRuns_2.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(z,i+1) = pHitContentsRuns_2.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(z,i+1) /(pHitContentsRuns_2.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(z,i+1) + pMissContentsRuns_2.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(z,i+1));
            end
        end
    end
end

% for j = 1:length(numSimulators)
%     for i = 0:simRuns-1
%         for z = 1:catalog
%             pHitContentsRuns.(simulatorStr{numSimulators(j)})(z,i+1) = pHitContentsRuns.(simulatorStr{numSimulators(j)})(z,i+1) /(pHitContentsRuns.(simulatorStr{numSimulators(j)})(z,i+1) + pMissContentsRuns.(simulatorStr{numSimulators(j)})(z,i+1));
%             if z==1
%                 cdfHitContentsNEW.(simulatorStr{numSimulators(j)})(z,i+1) =  pHitContentsRuns.(simulatorStr{numSimulators(j)})(z,i+1);
%             else
%                 cdfHitContentsNEW.(simulatorStr{numSimulators(j)})(z,i+1) =  pHitContentsRuns.(simulatorStr{numSimulators(j)})(z,i+1) - pHitContentsRuns.(simulatorStr{numSimulators(j)})(z-1,i+1);
%             end
%             pHitContentsNEW.(simulatorStr{numSimulators(j)})(z,i+1) = 1 - cdfHitContentsNEW.(simulatorStr{numSimulators(j)})(z,i+1);
%         end
%     end
% end

for g=1:length(numAlphas)
    for j = 1:length(numSimulators)
        for i = 0:simRuns-1
            pHitTotalRuns_1.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(i+1,1) = pHitTotalRuns_1.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(i+1,1) / minLimit.(alphaStrCompl{numAlphas(g)});
            pHitTotalRuns_2.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(i+1,1) = pHitTotalRuns_2.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(i+1,1) / minLimit.(alphaStrCompl{numAlphas(g)});
        end
    end
end

% FIRST CACHE
pHitTotalMean_1 = struct;
pHitContentsMean_1 = struct;

% SECOND CACHE
pHitTotalMean_2 = struct;
pHitContentsMean_2 = struct;

for g=1:length(numAlphas)
    for j = 1:length(numSimulators)
        pHitTotalMean_1.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}) = mean(pHitTotalRuns_1.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(:,1));
        pHitTotalMean_2.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}) = mean(pHitTotalRuns_2.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(:,1));
    end
end

for g=1:length(numAlphas)
    for j = 1:length(numSimulators)
        pHitContentsMean_1.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).('mean') = zeros(catalog, 1);
        pHitContentsMean_1.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).('std') = zeros(catalog, 1);
        pHitContentsMean_1.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).('conf') = zeros(catalog, 1);
        
        pHitContentsMean_2.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).('mean') = zeros(catalog, 1);
        pHitContentsMean_2.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).('std') = zeros(catalog, 1);
        pHitContentsMean_2.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).('conf') = zeros(catalog, 1);
    end
end

for g=1:length(numAlphas)
    for j = 1:length(numSimulators)
        for z = 1:catalog
            pHitContentsMean_1.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).('mean')(z,1) = mean(pHitContentsRuns_1.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(z,:));
            pHitContentsMean_1.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).('std')(z,1) = std(pHitContentsRuns_1.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(z,:));
            pHitContentsMean_1.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).('conf')(z,1) = tStudent(1, simRuns-1) * ( pHitContentsMean_1.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).('std')(z,1) / sqrt(simRuns));

            pHitContentsMean_2.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).('mean')(z,1) = mean(pHitContentsRuns_2.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(z,:));
            pHitContentsMean_2.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).('std')(z,1) = std(pHitContentsRuns_2.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)})(z,:));
            pHitContentsMean_2.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).('conf')(z,1) = tStudent(1, simRuns-1) * ( pHitContentsMean_2.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).('std')(z,1) / sqrt(simRuns));
        end
    end
end

%clear scenarioImport;
clear pHitContentsRuns_1;
clear pHitContentsRuns_2;

%clear contentID;
%clear hitDistance;

% Plot Phit per each content

% FIRST CACHE
pHit_1 = struct;
% SECOND CACHE
pHit_2 = struct;
% SECOND CACHE
pHit_2_Leo = struct;

for g=1:length(numAlphas)
    pHit_1.(alphaStrCompl{numAlphas(g)}) = zeros(catalog, 2);
    pHit_2.(alphaStrCompl{numAlphas(g)}) = zeros(catalog, 2);
    pHit_2_Leo.(alphaStrCompl{numAlphas(g)}) = zeros(catalog, 2);
end
for g=1:length(numAlphas)
    pHit_1.(alphaStrCompl{numAlphas(g)})(:,1) = pHitContentsMean_1.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(1)}).('mean')(:,1);
    %pHit_1.(alphaStrCompl{numAlphas(g)})(:,2) = pHitContentsMean_1.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(2)}).('mean')(:,1);    
    %pHit_1.(alphaStrCompl{numAlphas(g)})(:,3) = pHitContentsMean_1.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(3)}).('mean')(:,1);
    pHit_1.(alphaStrCompl{numAlphas(g)})(:,2) = Che_Approx_1.(alphaStrCompl{numAlphas(g)}){1}(:,1);

    pHit_2.(alphaStrCompl{numAlphas(g)})(:,1) = pHitContentsMean_2.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(1)}).('mean')(:,1);
    %pHit_2.(alphaStrCompl{numAlphas(g)})(:,2) = pHitContentsMean_2.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(2)}).('mean')(:,1);    
    %pHit_2.(alphaStrCompl{numAlphas(g)})(:,3) = pHitContentsMean_2.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(3)}).('mean')(:,1);
    pHit_2.(alphaStrCompl{numAlphas(g)})(:,2) = Che_Approx_2.(alphaStrCompl{numAlphas(g)}){1}(:,1);
    
    pHit_2_Leo.(alphaStrCompl{numAlphas(g)})(:,1) = pHitContentsMean_2.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(1)}).('mean')(:,1);
    %pHit_2_Leo.(alphaStrCompl{numAlphas(g)})(:,2) = pHitContentsMean_2.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(2)}).('mean')(:,1);    
    %pHit_2_Leo.(alphaStrCompl{numAlphas(g)})(:,3) = pHitContentsMean_2.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(3)}).('mean')(:,1);
    pHit_2_Leo.(alphaStrCompl{numAlphas(g)})(:,2) = Che_Approx_2_Leo.(alphaStrCompl{numAlphas(g)}){1}(:,1);

    %createHitLogPlot(IDs, pHit_1.(alphaStrCompl{numAlphas(g)}), 1, numAlphas(g));
    %createHitLogPlot(IDs, pHit_2.(alphaStrCompl{numAlphas(g)}), 1, numAlphas(g));
    %createHitLogPlot(IDs, pHit_2.(alphaStrCompl{numAlphas(g)}), 1, numAlphas(g));
end

% Build pHit normalized to Che_Approx

% FIRST CACHE
norm_1 = struct;
pHitNormalized_1 = struct;

% SECOND CACHE
norm_2 = struct;
pHitNormalized_2 = struct;

% SECOND CACHE LEO
norm_2_Leo = struct;
pHitNormalized_2_Leo = struct;

for g=1:length(numAlphas)
    norm_1.(alphaStrCompl{numAlphas(g)}) = [pHit_1.(alphaStrCompl{numAlphas(g)})(:,2), pHit_1.(alphaStrCompl{numAlphas(g)})(:,2)];
    pHitNormalized_1.(alphaStrCompl{numAlphas(g)}) = zeros(catalog,2);
    
    norm_2.(alphaStrCompl{numAlphas(g)}) = [pHit_2.(alphaStrCompl{numAlphas(g)})(:,2), pHit_2.(alphaStrCompl{numAlphas(g)})(:,2)];
    pHitNormalized_2.(alphaStrCompl{numAlphas(g)}) = zeros(catalog,2);
    
    norm_2_Leo.(alphaStrCompl{numAlphas(g)}) = [pHit_2_Leo.(alphaStrCompl{numAlphas(g)})(:,2), pHit_2_Leo.(alphaStrCompl{numAlphas(g)})(:,2)];
    pHitNormalized_2_Leo.(alphaStrCompl{numAlphas(g)}) = zeros(catalog,2);
end
for g=1:length(numAlphas)
    pHitNormalized_1.(alphaStrCompl{numAlphas(g)}) = pHit_1.(alphaStrCompl{numAlphas(g)})./norm_1.(alphaStrCompl{numAlphas(g)});
    %createHitLogPlot(IDs, pHitNormalized_1.(alphaStrCompl{numAlphas(g)}), 2, numAlphas(g));

    pHitNormalized_2.(alphaStrCompl{numAlphas(g)}) = pHit_2.(alphaStrCompl{numAlphas(g)})./norm_2.(alphaStrCompl{numAlphas(g)});
    %createHitLogPlot(IDs, pHitNormalized_2.(alphaStrCompl{numAlphas(g)}), 2, numAlphas(g));
    
    pHitNormalized_2_Leo.(alphaStrCompl{numAlphas(g)}) = pHit_2_Leo.(alphaStrCompl{numAlphas(g)})./norm_2_Leo.(alphaStrCompl{numAlphas(g)});
    %createHitLogPlot(IDs, pHitNormalized_2_Leo.(alphaStrCompl{numAlphas(g)}), 2, numAlphas(g));
end

% Plot Phit per each content
% IDsBIN = struct;
% pHitBinning = struct;
% for g=1:length(numAlphas)
%     IDsBIN.(alphaStrCompl{numAlphas(g)}) = 1:minBinMax.(alphaStrCompl{numAlphas(g)});
%     pHitBINNING.(alphaStrCompl{numAlphas(g)}) = zeros(minBinMax.(alphaStrCompl{numAlphas(g)}), 4);
% end
% for g=1:length(numAlphas)
%     pHitBINNING.(alphaStrCompl{numAlphas(g)})(:,1) = pHitContentsBIN.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(1)})(:,1);
%     pHitBINNING.(alphaStrCompl{numAlphas(g)})(:,2) = pHitContentsBIN.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(2)})(:,1);
%     pHitBINNING.(alphaStrCompl{numAlphas(g)})(:,3) = pHitContentsBIN.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(3)})(:,1);
%     pHitBINNING.(alphaStrCompl{numAlphas(g)})(:,4) = pHitCheBIN.(alphaStrCompl{numAlphas(g)})(:,1);
%     createHitLogPlot(IDsBIN.(alphaStrCompl{numAlphas(g)}), pHitBINNING.(alphaStrCompl{numAlphas(g)}), 3, numAlphas(g));
% end

% Build pHit BIN normalized to Che_Approx
% normBIN = struct;
% pHitNormalizedBINNING = struct;
% for g=1:length(numAlphas)
%     normBIN.(alphaStrCompl{numAlphas(g)}) = [pHitBINNING.(alphaStrCompl{numAlphas(g)})(:,4), pHitBINNING.(alphaStrCompl{numAlphas(g)})(:,4), pHitBINNING.(alphaStrCompl{numAlphas(g)})(:,4), pHitBINNING.(alphaStrCompl{numAlphas(g)})(:,4)];
%     pHitNormalizedBINNING.(alphaStrCompl{numAlphas(g)}) = zeros(catalog,4);
% end
% for g=1:length(numAlphas)
%     pHitNormalizedBINNING.(alphaStrCompl{numAlphas(g)}) = pHitBINNING.(alphaStrCompl{numAlphas(g)})./normBIN.(alphaStrCompl{numAlphas(g)});
%     createHitLogPlot(IDsBIN.(alphaStrCompl{numAlphas(g)}), pHitNormalizedBINNING.(alphaStrCompl{numAlphas(g)}), 4, numAlphas(g));
% end


% Calculating the function f(x,che) = (che - x)/che, both for pHit and for
% pHitNormalized

% FIRST CACHE
fForPhit_1 = struct;
fForPhitNormalized_1 = struct;

% SECOND CACHE
fForPhit_2 = struct;
fForPhitNormalized_2 = struct;

% SECOND CACHE LEO
fForPhit_2_Leo = struct;
fForPhitNormalized_2_Leo = struct;

for g=1:length(numAlphas)
    fForPhit_1.(alphaStrCompl{numAlphas(g)}) = zeros(catalog, 1);
    fForPhitNormalized_1.(alphaStrCompl{numAlphas(g)}) = zeros(catalog, 1);
    
    fForPhit_2.(alphaStrCompl{numAlphas(g)}) = zeros(catalog, 1);
    fForPhitNormalized_2.(alphaStrCompl{numAlphas(g)}) = zeros(catalog, 1);
    
    fForPhit_2_Leo.(alphaStrCompl{numAlphas(g)}) = zeros(catalog, 1);
    fForPhitNormalized_2_Leo.(alphaStrCompl{numAlphas(g)}) = zeros(catalog, 1);
end

for g=1:length(numAlphas)
    for j = 1:length(numSimulators)
        for z = 1:catalog
            fForPhit_1.(alphaStrCompl{numAlphas(g)})(z,j) = (pHit_1.(alphaStrCompl{numAlphas(g)})(z,2) - pHit_1.(alphaStrCompl{numAlphas(g)})(z,j)) / pHit_1.(alphaStrCompl{numAlphas(g)})(z,2);
            fForPhitNormalized_1.(alphaStrCompl{numAlphas(g)})(z,j) = (pHitNormalized_1.(alphaStrCompl{numAlphas(g)})(z,2) - pHitNormalized_1.(alphaStrCompl{numAlphas(g)})(z,j)) / pHitNormalized_1.(alphaStrCompl{numAlphas(g)})(z,2);
            
            fForPhit_2.(alphaStrCompl{numAlphas(g)})(z,j) = (pHit_2.(alphaStrCompl{numAlphas(g)})(z,2) - pHit_2.(alphaStrCompl{numAlphas(g)})(z,j)) / pHit_2.(alphaStrCompl{numAlphas(g)})(z,2);
            fForPhitNormalized_2.(alphaStrCompl{numAlphas(g)})(z,j) = (pHitNormalized_2.(alphaStrCompl{numAlphas(g)})(z,2) - pHitNormalized_2.(alphaStrCompl{numAlphas(g)})(z,j)) / pHitNormalized_2.(alphaStrCompl{numAlphas(g)})(z,2);
            
            fForPhit_2_Leo.(alphaStrCompl{numAlphas(g)})(z,j) = (pHit_2_Leo.(alphaStrCompl{numAlphas(g)})(z,2) - pHit_2_Leo.(alphaStrCompl{numAlphas(g)})(z,j)) / pHit_2_Leo.(alphaStrCompl{numAlphas(g)})(z,2);
            fForPhitNormalized_2_Leo.(alphaStrCompl{numAlphas(g)})(z,j) = (pHitNormalized_2_Leo.(alphaStrCompl{numAlphas(g)})(z,2) - pHitNormalized_2_Leo.(alphaStrCompl{numAlphas(g)})(z,j)) / pHitNormalized_2_Leo.(alphaStrCompl{numAlphas(g)})(z,2);
        end
    end
end


expectFforPhit_1 = struct;
expectFforPhit_2 = struct;
expectFforPhit_2_Leo = struct;
for g=1:length(numAlphas)
   % expectFforPhit.(alphaStrCompl{numAlphas(g)}) = zeros(catalog, 3);
   % expectFforPhitNormalized.(alphaStrCompl{numAlphas(g)}) = zeros(catalog, 3);
    expectFforPhit_1.(alphaStrCompl{numAlphas(g)}) = zeros(catalog, 1);
    expectFforPhit_2.(alphaStrCompl{numAlphas(g)}) = zeros(catalog, 1);
    expectFforPhit_2_Leo.(alphaStrCompl{numAlphas(g)}) = zeros(catalog, 1);
end

for g=1:length(numAlphas)
    for j = 1:length(numSimulators)
        for z = 1:catalog
            if z < catalog
                expectFforPhit_1.(alphaStrCompl{numAlphas(g)})(z,j) = mean(fForPhit_1.(alphaStrCompl{numAlphas(g)})(z+1:catalog,j));
                expectFforPhit_2.(alphaStrCompl{numAlphas(g)})(z,j) = mean(fForPhit_2.(alphaStrCompl{numAlphas(g)})(z+1:catalog,j));
                expectFforPhit_2_Leo.(alphaStrCompl{numAlphas(g)})(z,j) = mean(fForPhit_2_Leo.(alphaStrCompl{numAlphas(g)})(z+1:catalog,j));
            else
                expectFforPhit_1.(alphaStrCompl{numAlphas(g)})(z,j) = fForPhit_1.(alphaStrCompl{numAlphas(g)})(z,j);
                expectFforPhit_2.(alphaStrCompl{numAlphas(g)})(z,j) = fForPhit_2.(alphaStrCompl{numAlphas(g)})(z,j);
                expectFforPhit_2_Leo.(alphaStrCompl{numAlphas(g)})(z,j) = fForPhit_2_Leo.(alphaStrCompl{numAlphas(g)})(z,j);
            end
        end
    end
end


% Expected F for ABS Phit E[|ei|]

expectAbsFforPhit_1 = struct;
expectAbsFforPhit_2 = struct;
expectAbsFforPhit_2_Leo = struct;
for g=1:length(numAlphas)
    %expectAbsFforPhit.(alphaStrCompl{numAlphas(g)}) = zeros(catalog, 3);
    %expectAbsFforPhitNormalized.(alphaStrCompl{numAlphas(g)}) = zeros(catalog, 3);
    expectAbsFforPhit_1.(alphaStrCompl{numAlphas(g)}) = zeros(catalog, 1);
    expectAbsFforPhit_2.(alphaStrCompl{numAlphas(g)}) = zeros(catalog, 1);
    expectAbsFforPhit_2_Leo.(alphaStrCompl{numAlphas(g)}) = zeros(catalog, 1);
end

for g=1:length(numAlphas)
    for j = 1:length(numSimulators)
        for z = 1:catalog
            if z < catalog
                expectAbsFforPhit_1.(alphaStrCompl{numAlphas(g)})(z,j) = mean(abs(fForPhit_1.(alphaStrCompl{numAlphas(g)})(z+1:catalog,j)));
                expectAbsFforPhit_2.(alphaStrCompl{numAlphas(g)})(z,j) = mean(abs(fForPhit_2.(alphaStrCompl{numAlphas(g)})(z+1:catalog,j)));
                expectAbsFforPhit_2_Leo.(alphaStrCompl{numAlphas(g)})(z,j) = mean(abs(fForPhit_2_Leo.(alphaStrCompl{numAlphas(g)})(z+1:catalog,j)));       
            else
                expectAbsFforPhit_1.(alphaStrCompl{numAlphas(g)})(z,j) = abs(fForPhit_1.(alphaStrCompl{numAlphas(g)})(z,j));
                expectAbsFforPhit_2.(alphaStrCompl{numAlphas(g)})(z,j) = abs(fForPhit_2.(alphaStrCompl{numAlphas(g)})(z,j));
                expectAbsFforPhit_2_Leo.(alphaStrCompl{numAlphas(g)})(z,j) = abs(fForPhit_2_Leo.(alphaStrCompl{numAlphas(g)})(z,j));
            end
        end
    end
end




% Calculating the function f() for significative contents, i.e., p50, p75,
% p90, p95

% FIRST CACHE
f50_1_REQ_100mln = struct;

% SECOND CACHE
f50_2_REQ_100mln = struct;

% SECOND CACHE LEO
f50_2_Leo_REQ_100mln = struct;

for g=1:length(numAlphas)
    for j = 1:length(numSimulators)
        f50_1_REQ_100mln.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}) = expectAbsFforPhit_1.(alphaStrCompl{numAlphas(g)})(cont50.(alphaStrCompl{numAlphas(g)}),j);
        
        f50_2_REQ_100mln.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}) = expectAbsFforPhit_2.(alphaStrCompl{numAlphas(g)})(cont50.(alphaStrCompl{numAlphas(g)}),j);
        
        f50_2_Leo_REQ_100mln.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}) = expectAbsFforPhit_2_Leo.(alphaStrCompl{numAlphas(g)})(cont50.(alphaStrCompl{numAlphas(g)}),j);
    end
end

f75_1_REQ_100mln = struct;

f75_2_REQ_100mln = struct;

f75_2_Leo_REQ_100mln = struct;

for g=1:length(numAlphas)
    for j = 1:length(numSimulators)
        f75_1_REQ_100mln.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}) = expectAbsFforPhit_1.(alphaStrCompl{numAlphas(g)})(cont75.(alphaStrCompl{numAlphas(g)}),j);

        f75_2_REQ_100mln.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}) = expectAbsFforPhit_2.(alphaStrCompl{numAlphas(g)})(cont75.(alphaStrCompl{numAlphas(g)}),j);
        
        f75_2_Leo_REQ_100mln.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}) = expectAbsFforPhit_2_Leo.(alphaStrCompl{numAlphas(g)})(cont75.(alphaStrCompl{numAlphas(g)}),j);
    end
end

f90_1_REQ_100mln = struct;

f90_2_REQ_100mln = struct;

f90_2_Leo_REQ_100mln = struct;

for g=1:length(numAlphas)
    for j = 1:length(numSimulators)
        f90_1_REQ_100mln.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}) = expectAbsFforPhit_1.(alphaStrCompl{numAlphas(g)})(cont90.(alphaStrCompl{numAlphas(g)}),j);

        f90_2_REQ_100mln.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}) = expectAbsFforPhit_2.(alphaStrCompl{numAlphas(g)})(cont90.(alphaStrCompl{numAlphas(g)}),j);
        
        f90_2_Leo_REQ_100mln.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}) = expectAbsFforPhit_2_Leo.(alphaStrCompl{numAlphas(g)})(cont90.(alphaStrCompl{numAlphas(g)}),j);
    end
end

f95_1_REQ_100mln = struct;

f95_2_REQ_100mln = struct;

f95_2_Leo_REQ_100mln = struct;

for g=1:length(numAlphas)
    for j = 1:length(numSimulators)
        f95_1_REQ_100mln.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}) = expectAbsFforPhit_1.(alphaStrCompl{numAlphas(g)})(cont95.(alphaStrCompl{numAlphas(g)}),j);
      
        f95_2_REQ_100mln.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}) = expectAbsFforPhit_2.(alphaStrCompl{numAlphas(g)})(cont95.(alphaStrCompl{numAlphas(g)}),j);
        
        f95_2_Leo_REQ_100mln.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}) = expectAbsFforPhit_2_Leo.(alphaStrCompl{numAlphas(g)})(cont95.(alphaStrCompl{numAlphas(g)}),j);
    end
end

save(stringOutput);
