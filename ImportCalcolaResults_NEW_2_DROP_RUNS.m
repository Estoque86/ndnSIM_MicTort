%SIM = input ('Input the sim name: ');
%T = input ('Input the sim type: ');
%M = input ('Input the catalog cardinality: ');
%C = input ('Input the cache to catalog ratio: ');
%L = input ('Input the lambda: ');
%A = input ('Input the Zipf Exponent: ');
%R = input ('Input the number of runs: ');

% STRINGHE 

stringOutput = 'DATA_SIM=NDNSIM_T=SINGLE_CACHE_A=1_L=25_250_DROP_BUF_5_REQ_=10000000.mat';

simulatorStr = cell(1,4);
simulatorStr{1} = 'CCNSIM';
simulatorStr{2} = 'NDNSIM';
simulatorStr{3} = 'ICARUS';
simulatorStr{4} = 'CCNPL';

scenarioStr = cell(1,1);
scenarioStr{1} = 'SINGLE_CACHE';

catalogStr = cell(1,1);
catalogStr{1} = '10000';

ratioStr = cell(1,1);
ratioStr{1} = '0.01';

lambdaStr = cell(1,17);
lambdaStr{1} = '25';
lambdaStr{2} = '50';
lambdaStr{3} = '75';
lambdaStr{4} = '100';
lambdaStr{5} = '110';
lambdaStr{6} = '112';
lambdaStr{7} = '114';
lambdaStr{8} = '116';
lambdaStr{9} = '118';
lambdaStr{10} = '120';
lambdaStr{11} = '122';
lambdaStr{12} = '124';
lambdaStr{13} = '150';
lambdaStr{14} = '175';
lambdaStr{15} = '200';
lambdaStr{16} = '225';
lambdaStr{17} = '250';

lambdaStrCompl = cell(1,17);
lambdaStrCompl{1} = 'L_25';
lambdaStrCompl{2} = 'L_50';
lambdaStrCompl{3} = 'L_75';
lambdaStrCompl{4} = 'L_100';
lambdaStrCompl{5} = 'L_110';
lambdaStrCompl{6} = 'L_112';
lambdaStrCompl{7} = 'L_114';
lambdaStrCompl{8} = 'L_116';
lambdaStrCompl{9} = 'L_118';
lambdaStrCompl{10} = 'L_120';
lambdaStrCompl{11} = 'L_122';
lambdaStrCompl{12} = 'L_124';
lambdaStrCompl{13} = 'L_150';
lambdaStrCompl{14} = 'L_175';
lambdaStrCompl{15} = 'L_200';
lambdaStrCompl{16} = 'L_225';
lambdaStrCompl{17} = 'L_250';

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
numRequests = 10100000;
officialNumRequests = 10000000;
reqStr = '10000000';
catalog = 10000;
IDs = 1:catalog;
target = 100;

tStudent = [1.2 6.314 2.920 2.353 2.132 2.015 1.943 1.895 1.860 1.833 1.812 1.796];

% Valori effettivi dei parametri simulati (servono a prendere le stringhe

numSimulators = [2];
numScenarios = [1];
numCatalogs = [1];
numRatios = [1];
numLambdas = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17];
%numAlphas = [1 2 3 4];
numAlphas = [3];


% Import Che Approx
fileChePrefix = '/home/tortelli/ndn-simulator-comparison/Results/HitCheTeo_';
fileCheSuffix = '.txt';
Che_Approx = struct;

for g=1:length(numAlphas)
    fileCheCompl = strcat(fileChePrefix, alphaStr{numAlphas(g)}, fileCheSuffix); 
    fileID = fopen(fileCheCompl);
    fileCheCompl
    Che_Approx.(alphaStrCompl{numAlphas(g)}) = textscan(fileID,'%f32');
    fileID = fclose(fileID);
end


% Dichiarazione STRUCT per import

scenarioImport = struct;
contentID = struct;
hitDistance = struct;
limitRequests = struct;

% Inizializzazione Matrici per ContentID e HitDistance
for g = 1:length(numAlphas)
    for j = 1:length(numSimulators)
	for v = 1:length(numLambdas)
	        contentID.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).(lambdaStrCompl{numLambdas(v)}) = zeros(numRequests, simRuns);
	        hitDistance.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).(lambdaStrCompl{numLambdas(v)}) = zeros(numRequests, simRuns);
	        limitRequests.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).(lambdaStrCompl{numLambdas(v)}) = zeros(simRuns,1);
	end
    end
end


folder='/home/tortelli/ndn-simulator-comparison/ndnSIM_Drop/ns-3/logs/logs/';
ext='.out';

minLimit = struct;

for g=1:length(numAlphas)
    minLimit.(alphaStrCompl{numAlphas(g)}) = officialNumRequests;
end

for g = 1:length(numAlphas)
    for j = 1:length(numSimulators)
        for v = 1:length(numLambdas)
            for i=0:simRuns-1
            	run = int2str(i);
                disp(sprintf('%s',strcat(simulatorStr{numSimulators(j)}, ' ' ,run)));
                nome_file=strcat(folder,'SIM=',simulatorStr{numSimulators(j)},'_T=',scenarioStr{numScenarios(1)},'_REQ=',reqStr,'_M=',catalogStr{numCatalogs(1)},'_C=',ratioStr{numRatios(1)},'_L=',lambdaStr{numLambdas(v)},'_A=',alphaStr{numAlphas(g)},'_R=',run,ext);
            %nome_file=strcat(folder,'SIM=',simulatorStr{numSimulators(j)},'_T=',scenarioStr{numScenarios(1)},'_M=',catalogStr{numCatalogs(1)},'_C=',ratioStr{numRatios(1)},'_L=',lambdaStr{numLambdas(1)},'_A=',alphaStr{numAlphas(g)},'_R=',run,ext);
            %nome_file
	        disp(sprintf('%s', nome_file));
	        fileID = fopen(nome_file);
                scenarioImport.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).(lambdaStrCompl{numLambdas(v)}) = textscan(fileID,'%f32 %s %s %d32 %d8');
                fileID = fclose(fileID);
                limit = length(scenarioImport.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).(lambdaStrCompl{numLambdas(v)}){4});
                limitRequests.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).(lambdaStrCompl{numLambdas(v)})(i+1,1) = limit;
                if (limitRequests.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).(lambdaStrCompl{numLambdas(v)})(i+1,1) < minLimit.(alphaStrCompl{numAlphas(g)}))
                    minLimit.(alphaStrCompl{numAlphas(g)}) = limitRequests.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).(lambdaStrCompl{numLambdas(v)})(i+1,1);
                end
                contentID.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).(lambdaStrCompl{numLambdas(v)})(1:limit,i+1) = scenarioImport.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).(lambdaStrCompl{numLambdas(v)}){4}(1:limit,1);
                hitDistance.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).(lambdaStrCompl{numLambdas(v)})(1:limit,i+1) = scenarioImport.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).(lambdaStrCompl{numLambdas(v)}){5}(1:limit,1);
               clear scenarioImport;
           end
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
        for v = 1:length(numLambdas)
            contentID.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).(lambdaStrCompl{numLambdas(v)})(minLimit.(alphaStrCompl{numAlphas(g)})+1:numRequests,:) = [];
            hitDistance.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).(lambdaStrCompl{numLambdas(v)})(minLimit.(alphaStrCompl{numAlphas(g)})+1:numRequests,:) = [];
        end
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

pHitTotalRuns = struct;
pHitContentsRuns = struct; 
pMissContentsRuns = struct;
%pHitContentsNEW = struct;
%cdfHitContentsNEW = struct;

frequencyHitContents = struct;
frequencyMissContents = struct;
frequencyRequestsContents = struct;
%frequencyRequestsContentsBIN = struct;
%xAxesBIN = struct;

for g=1:length(numAlphas)
    for j = 1:length(numSimulators)
        for v = 1:length(numLambdas)
            pHitTotalRuns.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).(lambdaStrCompl{numLambdas(v)}) = zeros(simRuns,1);
            pHitContentsRuns.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).(lambdaStrCompl{numLambdas(v)}) = zeros(catalog, simRuns);
            pMissContentsRuns.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).(lambdaStrCompl{numLambdas(v)}) = zeros(catalog, simRuns);
            %pHitContentsNEW.(simulatorStr{numSimulators(j)}) = zeros(catalog, simRuns);
            %cdfHitContentsNEW.(simulatorStr{numSimulators(j)}) = zeros(catalog, simRuns);
            frequencyHitContents.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).(lambdaStrCompl{numLambdas(v)}) = zeros(catalog, 1);
            frequencyMissContents.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).(lambdaStrCompl{numLambdas(v)}) = zeros(catalog, 1);
            frequencyRequestsContents.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).(lambdaStrCompl{numLambdas(v)}) = zeros(catalog, 1);
        end 
    end
end

for g=1:length(numAlphas)
    for j = 1:length(numSimulators)
        for v = 1:length(numLambdas)
            for i = 0:simRuns-1
                for z = 1:minLimit.(alphaStrCompl{numAlphas(g)})
                    if (hitDistance.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).(lambdaStrCompl{numLambdas(v)})(z,i+1) == 0)    % It means a Cache Hit
                        pHitTotalRuns.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).(lambdaStrCompl{numLambdas(v)})(i+1,1) = pHitTotalRuns.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).(lambdaStrCompl{numLambdas(v)})(i+1,1) + 1;
                        w = contentID.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).(lambdaStrCompl{numLambdas(v)})(z,i+1);  % Keep the correspondent content ID
                        pHitContentsRuns.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).(lambdaStrCompl{numLambdas(v)})(w,i+1) = pHitContentsRuns.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).(lambdaStrCompl{numLambdas(v)})(w,i+1) + 1;
                    else
                        m = contentID.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).(lambdaStrCompl{numLambdas(v)})(z,i+1);  % Keep the correspondent content ID
                        pMissContentsRuns.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).(lambdaStrCompl{numLambdas(v)})(m,i+1) = pMissContentsRuns.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).(lambdaStrCompl{numLambdas(v)})(m,i+1) + 1;
                    end
                end
            end
        end
    end
end

clear contentID;
clear hitDistance;

for g=1:length(numAlphas)
    for j = 1:length(numSimulators)
        for v = 1:length(numLambdas)
            for z = 1:catalog
                frequencyHitContents.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).(lambdaStrCompl{numLambdas(v)})(z,1) = mean(pHitContentsRuns.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).(lambdaStrCompl{numLambdas(v)})(z,:));
                frequencyMissContents.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).(lambdaStrCompl{numLambdas(v)})(z,1) = mean(pMissContentsRuns.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).(lambdaStrCompl{numLambdas(v)})(z,:));
                frequencyRequestsContents.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).(lambdaStrCompl{numLambdas(v)})(z,1) = frequencyHitContents.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).(lambdaStrCompl{numLambdas(v)})(z,1) + frequencyMissContents.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).(lambdaStrCompl{numLambdas(v)})(z,1);
            end
        end
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for g=1:length(numAlphas)
    for j = 1:length(numSimulators)
        for v = 1:length(numLambdas)
            for i = 0:simRuns-1
                for z = 1:catalog
                    pHitContentsRuns.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).(lambdaStrCompl{numLambdas(v)})(z,i+1) = pHitContentsRuns.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).(lambdaStrCompl{numLambdas(v)})(z,i+1) /(pHitContentsRuns.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).(lambdaStrCompl{numLambdas(v)})(z,i+1) + pMissContentsRuns.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).(lambdaStrCompl{numLambdas(v)})(z,i+1));
                end
            end
        end
    end
end


for g=1:length(numAlphas)
    for j = 1:length(numSimulators)
        for v = 1:length(numLambdas)
            for i = 0:simRuns-1
                pHitTotalRuns.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).(lambdaStrCompl{numLambdas(v)})(i+1,1) = pHitTotalRuns.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).(lambdaStrCompl{numLambdas(v)})(i+1,1) / minLimit.(alphaStrCompl{numAlphas(g)});
            end
        end
    end
end
pHitTotalMean = struct;
pHitContentsMean = struct;

for g=1:length(numAlphas)
    for j = 1:length(numSimulators)
        for v = 1:length(numLambdas)
            pHitTotalMean.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).(lambdaStrCompl{numLambdas(v)}) = mean(pHitTotalRuns.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).(lambdaStrCompl{numLambdas(v)})(:,1));
        end
    end
end

for g=1:length(numAlphas)
    for j = 1:length(numSimulators)
        for v = 1:length(numLambdas)
            pHitContentsMean.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).(lambdaStrCompl{numLambdas(v)}).('mean') = zeros(catalog, 1);
            pHitContentsMean.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).(lambdaStrCompl{numLambdas(v)}).('std') = zeros(catalog, 1);
            pHitContentsMean.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).(lambdaStrCompl{numLambdas(v)}).('conf') = zeros(catalog, 1);
        end
    end
end

for g=1:length(numAlphas)
    for j = 1:length(numSimulators)
        for v = 1:length(numLambdas)
            for z = 1:catalog
                pHitContentsMean.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).(lambdaStrCompl{numLambdas(v)}).('mean')(z,1) = mean(pHitContentsRuns.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).(lambdaStrCompl{numLambdas(v)})(z,:));
                pHitContentsMean.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).(lambdaStrCompl{numLambdas(v)}).('std')(z,1) = std(pHitContentsRuns.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).(lambdaStrCompl{numLambdas(v)})(z,:));
                pHitContentsMean.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).(lambdaStrCompl{numLambdas(v)}).('conf')(z,1) = tStudent(1, simRuns-1) * ( pHitContentsMean.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(j)}).(lambdaStrCompl{numLambdas(v)}).('std')(z,1) / sqrt(simRuns));
            end
        end
    end
end

%clear scenarioImport;
%clear pHitContentsRuns;

%clear contentID;
%clear hitDistance;

% Plot Phit per each content
pHit = struct;
for g=1:length(numAlphas)
    pHit.(alphaStrCompl{numAlphas(g)}) = zeros(catalog, 18);
end

for g=1:length(numAlphas)
    pHit.(alphaStrCompl{numAlphas(g)})(:,1) = pHitContentsMean.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(1)}).(lambdaStrCompl{numLambdas(1)}).('mean')(:,1);
    pHit.(alphaStrCompl{numAlphas(g)})(:,2) = pHitContentsMean.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(1)}).(lambdaStrCompl{numLambdas(2)}).('mean')(:,1);
    pHit.(alphaStrCompl{numAlphas(g)})(:,3) = pHitContentsMean.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(1)}).(lambdaStrCompl{numLambdas(3)}).('mean')(:,1);
    pHit.(alphaStrCompl{numAlphas(g)})(:,4) = pHitContentsMean.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(1)}).(lambdaStrCompl{numLambdas(4)}).('mean')(:,1);
    pHit.(alphaStrCompl{numAlphas(g)})(:,5) = pHitContentsMean.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(1)}).(lambdaStrCompl{numLambdas(5)}).('mean')(:,1);
    pHit.(alphaStrCompl{numAlphas(g)})(:,6) = pHitContentsMean.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(1)}).(lambdaStrCompl{numLambdas(6)}).('mean')(:,1);
    pHit.(alphaStrCompl{numAlphas(g)})(:,7) = pHitContentsMean.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(1)}).(lambdaStrCompl{numLambdas(7)}).('mean')(:,1);
    pHit.(alphaStrCompl{numAlphas(g)})(:,8) = pHitContentsMean.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(1)}).(lambdaStrCompl{numLambdas(8)}).('mean')(:,1);
    pHit.(alphaStrCompl{numAlphas(g)})(:,9) = pHitContentsMean.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(1)}).(lambdaStrCompl{numLambdas(9)}).('mean')(:,1);
    pHit.(alphaStrCompl{numAlphas(g)})(:,10) = pHitContentsMean.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(1)}).(lambdaStrCompl{numLambdas(10)}).('mean')(:,1);
    pHit.(alphaStrCompl{numAlphas(g)})(:,11) = pHitContentsMean.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(1)}).(lambdaStrCompl{numLambdas(11)}).('mean')(:,1);
    pHit.(alphaStrCompl{numAlphas(g)})(:,12) = pHitContentsMean.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(1)}).(lambdaStrCompl{numLambdas(12)}).('mean')(:,1);
    pHit.(alphaStrCompl{numAlphas(g)})(:,13) = pHitContentsMean.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(1)}).(lambdaStrCompl{numLambdas(13)}).('mean')(:,1);
    pHit.(alphaStrCompl{numAlphas(g)})(:,14) = pHitContentsMean.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(1)}).(lambdaStrCompl{numLambdas(14)}).('mean')(:,1);
    pHit.(alphaStrCompl{numAlphas(g)})(:,15) = pHitContentsMean.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(1)}).(lambdaStrCompl{numLambdas(15)}).('mean')(:,1);
    pHit.(alphaStrCompl{numAlphas(g)})(:,16) = pHitContentsMean.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(1)}).(lambdaStrCompl{numLambdas(16)}).('mean')(:,1);
    pHit.(alphaStrCompl{numAlphas(g)})(:,17) = pHitContentsMean.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(1)}).(lambdaStrCompl{numLambdas(17)}).('mean')(:,1);
  
    pHit.(alphaStrCompl{numAlphas(g)})(:,18) = Che_Approx.(alphaStrCompl{numAlphas(g)}){1}(:,1);
    %createHitLogPlot(IDs, pHit.(alphaStrCompl{numAlphas(g)}), 1, numAlphas(g));
end

% Build pHit normalized to Che_Approx
norm = struct;
pHitNormalized = struct;
for g=1:length(numAlphas)
    %norm.(alphaStrCompl{numAlphas(g)}) = [pHit.(alphaStrCompl{numAlphas(g)})(:,4), pHit.(alphaStrCompl{numAlphas(g)})(:,4), pHit.(alphaStrCompl{numAlphas(g)})(:,4), pHit.(alphaStrCompl{numAlphas(g)})(:,4)];
    norm.(alphaStrCompl{numAlphas(g)}) = [pHit.(alphaStrCompl{numAlphas(g)})(:,18), pHit.(alphaStrCompl{numAlphas(g)})(:,18), pHit.(alphaStrCompl{numAlphas(g)})(:,18), pHit.(alphaStrCompl{numAlphas(g)})(:,18), pHit.(alphaStrCompl{numAlphas(g)})(:,18), pHit.(alphaStrCompl{numAlphas(g)})(:,18), pHit.(alphaStrCompl{numAlphas(g)})(:,18), pHit.(alphaStrCompl{numAlphas(g)})(:,18), pHit.(alphaStrCompl{numAlphas(g)})(:,18), pHit.(alphaStrCompl{numAlphas(g)})(:,18), pHit.(alphaStrCompl{numAlphas(g)})(:,18), pHit.(alphaStrCompl{numAlphas(g)})(:,18), pHit.(alphaStrCompl{numAlphas(g)})(:,18), pHit.(alphaStrCompl{numAlphas(g)})(:,18), pHit.(alphaStrCompl{numAlphas(g)})(:,18), pHit.(alphaStrCompl{numAlphas(g)})(:,18), pHit.(alphaStrCompl{numAlphas(g)})(:,18), pHit.(alphaStrCompl{numAlphas(g)})(:,18)];
   
    pHitNormalized.(alphaStrCompl{numAlphas(g)}) = zeros(catalog,18);
end

for g=1:length(numAlphas)
    pHitNormalized.(alphaStrCompl{numAlphas(g)}) = pHit.(alphaStrCompl{numAlphas(g)})./norm.(alphaStrCompl{numAlphas(g)});
    %createHitLogPlot(IDs, pHitNormalized.(alphaStrCompl{numAlphas(g)}), 2, numAlphas(g));
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
fForPhit = struct;
for g=1:length(numAlphas)
    %fForPhit.(alphaStrCompl{numAlphas(g)}) = zeros(catalog, 3);
    %fForPhitNormalized.(alphaStrCompl{numAlphas(g)}) = zeros(catalog, 3);
    fForPhit.(alphaStrCompl{numAlphas(g)}) = zeros(catalog, 17);
end

for g=1:length(numAlphas)
    for j = 1:length(numLambdas)
        for z = 1:catalog
            fForPhit.(alphaStrCompl{numAlphas(g)})(z,j) = (pHit.(alphaStrCompl{numAlphas(g)})(z,18) - pHit.(alphaStrCompl{numAlphas(g)})(z,j)) / pHit.(alphaStrCompl{numAlphas(g)})(z,18);
        end
    end
end

% ***** RUNS ******
fForPhit_RUNS = struct;
for g=1:length(numAlphas)
    for j = 1:length(numLambdas)
        fForPhit.(alphaStrCompl{numAlphas(g)}).(lambdaStrCompl{numLambdas(j)}) = zeros(catalog, simRuns);
    end
end

for g=1:length(numAlphas)
    for v=1:length(numSimulators)
        for j = 1:length(numLambdas)
            for k = 1:simRuns
                for z = 1:catalog
                    fForPhit_RUNS.(alphaStrCompl{numAlphas(g)}).(lambdaStrCompl{numLambdas(j)})(z,k) = (pHit.(alphaStrCompl{numAlphas(g)})(z,18) - pHitContentsRuns.(alphaStrCompl{numAlphas(g)}).(simulatorStr{numSimulators(v)}).(lambdaStrCompl{numLambdas(j)})(z,k)) / pHit.(alphaStrCompl{numAlphas(g)})(z,18);
                end
            end
        end
    end
end



%% NEW ERROR PLOT


% Expected F for Phit E[ei]

expectFforPhit = struct;
for g=1:length(numAlphas)
    expectFforPhit.(alphaStrCompl{numAlphas(g)}) = zeros(catalog, 17);
end

for g=1:length(numAlphas)
    for j = 1:length(numLambdas)
        for z = 1:catalog
            if z < catalog
                expectFforPhit.(alphaStrCompl{numAlphas(g)})(z,j) = mean(fForPhit.(alphaStrCompl{numAlphas(g)})(z+1:catalog,j));
            else
                expectFforPhit.(alphaStrCompl{numAlphas(g)})(z,j) = fForPhit.(alphaStrCompl{numAlphas(g)})(z,j);
            end
        end
    end
end

expectFforPhit_HEAD = struct;
for g=1:length(numAlphas)
    expectFforPhit_HEAD.(alphaStrCompl{numAlphas(g)}) = zeros(catalog, 17);
end

for g=1:length(numAlphas)
    for j = 1:length(numLambdas)
        for z = 1:catalog
            expectFforPhit_HEAD.(alphaStrCompl{numAlphas(g)})(z,j) = mean(fForPhit.(alphaStrCompl{numAlphas(g)})(1:z,j));
        end
    end
end

% ***** RUNS ******


expectFforPhit_RUNS = struct;
for g=1:length(numAlphas)
    for j = 1:length(numLambdas)
        expectFforPhit_RUNS.(alphaStrCompl{numAlphas(g)}).(lambdaStrCompl{numLambdas(j)}) = zeros(catalog, simRuns);
    end
end

for g=1:length(numAlphas)
    for j = 1:length(numLambdas)
        for k = 1:simRuns
            for z = 1:catalog
                if z < catalog
                    expectFforPhit_RUNS.(alphaStrCompl{numAlphas(g)}).(lambdaStrCompl{numLambdas(j)})(z,k) = mean(fForPhit_RUNS.(alphaStrCompl{numAlphas(g)}).(lambdaStrCompl{numLambdas(j)})(z+1:catalog,k));
                else
                    expectFforPhit_RUNS.(alphaStrCompl{numAlphas(g)})(z,j) = fForPhit_RUNS.(alphaStrCompl{numAlphas(g)}).(lambdaStrCompl{numLambdas(j)})(z,k);
                end
            end
        end
    end
end

expectFforPhit_RUNS_HEAD = struct;
for g=1:length(numAlphas)
    for j = 1:length(numLambdas)
        expectFforPhit_RUNS_HEAD.(alphaStrCompl{numAlphas(g)}).(lambdaStrCompl{numLambdas(j)}) = zeros(catalog, simRuns);
    end
end

for g=1:length(numAlphas)
    for j = 1:length(numLambdas)
        for k = 1:simRuns
            for z = 1:catalog
                expectFforPhit_RUNS_HEAD.(alphaStrCompl{numAlphas(g)}).(lambdaStrCompl{numLambdas(j)})(z,k) = mean(fForPhit_RUNS.(alphaStrCompl{numAlphas(g)}).(lambdaStrCompl{numLambdas(j)})(1:z,k));
            end
        end
    end
end


% Expected F for ABS Phit E[|ei|]

expectAbsFforPhit = struct;
for g=1:length(numAlphas)
    expectAbsFforPhit.(alphaStrCompl{numAlphas(g)}) = zeros(catalog, 17);
end

for g=1:length(numAlphas)
    for j = 1:length(numLambdas)
        for z = 1:catalog
            if z < catalog
                expectAbsFforPhit.(alphaStrCompl{numAlphas(g)})(z,j) = mean(abs(fForPhit.(alphaStrCompl{numAlphas(g)})(z+1:catalog,j)));
            else
                expectAbsFforPhit.(alphaStrCompl{numAlphas(g)})(z,j) = abs(fForPhit.(alphaStrCompl{numAlphas(g)})(z,j));
            end
        end
    end
end

expectAbsFforPhit_HEAD = struct;
for g=1:length(numAlphas)
    expectAbsFforPhit_HEAD.(alphaStrCompl{numAlphas(g)}) = zeros(catalog, 17);
end

for g=1:length(numAlphas)
    for j = 1:length(numLambdas)
        for z = 1:catalog
            expectAbsFforPhit_HEAD.(alphaStrCompl{numAlphas(g)})(z,j) = mean(abs(fForPhit.(alphaStrCompl{numAlphas(g)})(1:z,j)));
        end
    end
end

% ***** RUNS ******


expectAbsFforPhit_RUNS = struct;
for g=1:length(numAlphas)
    for j = 1:length(numLambdas)
        expectAbsFforPhit_RUNS.(alphaStrCompl{numAlphas(g)}).(lambdaStrCompl{numLambdas(j)}) = zeros(catalog, simRuns);
    end
end

for g=1:length(numAlphas)
    for j = 1:length(numLambdas)
        for k = 1:simRuns
            for z = 1:catalog
                if z < catalog
                    expectAbsFforPhit_RUNS.(alphaStrCompl{numAlphas(g)}).(lambdaStrCompl{numLambdas(j)})(z,k) = mean(abs(fForPhit_RUNS.(alphaStrCompl{numAlphas(g)}).(lambdaStrCompl{numLambdas(j)})(z+1:catalog,k)));
                else
                    expectAbsFforPhit_RUNS.(alphaStrCompl{numAlphas(g)})(z,j) = fForPhit_RUNS.(alphaStrCompl{numAlphas(g)}).(lambdaStrCompl{numLambdas(j)})(z,k);
                end
            end
        end
    end
end

expectAbsFforPhit_RUNS_HEAD = struct;
for g=1:length(numAlphas)
    for j = 1:length(numLambdas)
        expectAbsFforPhit_RUNS_HEAD.(alphaStrCompl{numAlphas(g)}).(lambdaStrCompl{numLambdas(j)}) = zeros(catalog, simRuns);
    end
end

for g=1:length(numAlphas)
    for j = 1:length(numLambdas)
        for k = 1:simRuns
            for z = 1:catalog
                expectAbsFforPhit_RUNS_HEAD.(alphaStrCompl{numAlphas(g)}).(lambdaStrCompl{numLambdas(j)})(z,k) = mean(abs(fForPhit_RUNS.(alphaStrCompl{numAlphas(g)}).(lambdaStrCompl{numLambdas(j)})(1:z,k)));
            end
        end
    end
end



% Calculating the function f() for significative contents, i.e., p50, p75,
% p90, p95

f50_REQ_10mln_DROP = struct;
f50_REQ_10mln_DROP_HEAD = struct;
f50_REQ_10mln_DROP_CONF = struct;
f50_REQ_10mln_DROP_HEAD_CONF = struct;
for g=1:length(numAlphas)
    for j = 1:length(numLambdas)
        f50_REQ_10mln_DROP.(alphaStrCompl{numAlphas(g)}).(lambdaStrCompl{numLambdas(j)}) = expectAbsFforPhit.(alphaStrCompl{numAlphas(g)})(cont50.(alphaStrCompl{numAlphas(g)}),j);
        f50_REQ_10mln_DROP_HEAD.(alphaStrCompl{numAlphas(g)}).(lambdaStrCompl{numLambdas(j)}) = expectAbsFforPhit_HEAD.(alphaStrCompl{numAlphas(g)})(cont50.(alphaStrCompl{numAlphas(g)}),j);
        
        f50_REQ_10mln_DROP_CONF.(alphaStrCompl{numAlphas(g)}).(lambdaStrCompl{numLambdas(j)}) = tStudent(1, simRuns-1) * (std(expectAbsFforPhit_RUNS.(alphaStrCompl{numAlphas(g)}).(lambdaStrCompl{numLambdas(j)})(cont50.(alphaStrCompl{numAlphas(g)}),:))/sqrt(simRuns));
        f50_REQ_10mln_DROP_HEAD_CONF.(alphaStrCompl{numAlphas(g)}).(lambdaStrCompl{numLambdas(j)}) = tStudent(1, simRuns-1) * (std(expectAbsFforPhit_RUNS_HEAD.(alphaStrCompl{numAlphas(g)}).(lambdaStrCompl{numLambdas(j)})(cont50.(alphaStrCompl{numAlphas(g)}),:))/sqrt(simRuns));
    end
end



f75_REQ_10mln_DROP = struct;
f75_REQ_10mln_DROP_HEAD = struct;
f75_REQ_10mln_DROP_CONF = struct;
f75_REQ_10mln_DROP_HEAD_CONF = struct;
for g=1:length(numAlphas)
    for j = 1:length(numLambdas)
        f75_REQ_10mln_DROP.(alphaStrCompl{numAlphas(g)}).(lambdaStrCompl{numLambdas(j)}) = expectAbsFforPhit.(alphaStrCompl{numAlphas(g)})(cont75.(alphaStrCompl{numAlphas(g)}),j);
        f75_REQ_10mln_DROP_HEAD.(alphaStrCompl{numAlphas(g)}).(lambdaStrCompl{numLambdas(j)}) = expectAbsFforPhit_HEAD.(alphaStrCompl{numAlphas(g)})(cont75.(alphaStrCompl{numAlphas(g)}),j);

        f75_REQ_10mln_DROP_CONF.(alphaStrCompl{numAlphas(g)}).(lambdaStrCompl{numLambdas(j)}) = tStudent(1, simRuns-1) * (std(expectAbsFforPhit_RUNS.(alphaStrCompl{numAlphas(g)}).(lambdaStrCompl{numLambdas(j)})(cont75.(alphaStrCompl{numAlphas(g)}),:))/sqrt(simRuns));
        f75_REQ_10mln_DROP_HEAD_CONF.(alphaStrCompl{numAlphas(g)}).(lambdaStrCompl{numLambdas(j)}) = tStudent(1, simRuns-1) * (std(expectAbsFforPhit_RUNS_HEAD.(alphaStrCompl{numAlphas(g)}).(lambdaStrCompl{numLambdas(j)})(cont75.(alphaStrCompl{numAlphas(g)}),:))/sqrt(simRuns));
    end
end

f90_REQ_10mln_DROP = struct;
f90_REQ_10mln_DROP_HEAD = struct;
f90_REQ_10mln_DROP_CONF = struct;
f90_REQ_10mln_DROP_HEAD_CONF = struct;

for g=1:length(numAlphas)
    for j = 1:length(numLambdas)
        f90_REQ_10mln_DROP.(alphaStrCompl{numAlphas(g)}).(lambdaStrCompl{numLambdas(j)}) = expectAbsFforPhit.(alphaStrCompl{numAlphas(g)})(cont90.(alphaStrCompl{numAlphas(g)}),j);
        f90_REQ_10mln_DROP_HEAD.(alphaStrCompl{numAlphas(g)}).(lambdaStrCompl{numLambdas(j)}) = expectAbsFforPhit_HEAD.(alphaStrCompl{numAlphas(g)})(cont90.(alphaStrCompl{numAlphas(g)}),j);
        
        f90_REQ_10mln_DROP_CONF.(alphaStrCompl{numAlphas(g)}).(lambdaStrCompl{numLambdas(j)}) = tStudent(1, simRuns-1) * (std(expectAbsFforPhit_RUNS.(alphaStrCompl{numAlphas(g)}).(lambdaStrCompl{numLambdas(j)})(cont90.(alphaStrCompl{numAlphas(g)}),:))/sqrt(simRuns));
        f90_REQ_10mln_DROP_HEAD_CONF.(alphaStrCompl{numAlphas(g)}).(lambdaStrCompl{numLambdas(j)}) = tStudent(1, simRuns-1) * (std(expectAbsFforPhit_RUNS_HEAD.(alphaStrCompl{numAlphas(g)}).(lambdaStrCompl{numLambdas(j)})(cont90.(alphaStrCompl{numAlphas(g)}),:))/sqrt(simRuns));
    end
end

f95_REQ_10mln_DROP = struct;
f95_REQ_10mln_DROP_HEAD = struct;
f95_REQ_10mln_DROP_CONF = struct;
f95_REQ_10mln_DROP_HEAD_CONF = struct;
for g=1:length(numAlphas)
    for j = 1:length(numLambdas)
        f95_REQ_10mln_DROP.(alphaStrCompl{numAlphas(g)}).(lambdaStrCompl{numLambdas(j)}) = expectAbsFforPhit.(alphaStrCompl{numAlphas(g)})(cont95.(alphaStrCompl{numAlphas(g)}),j);
        f95_REQ_10mln_DROP_HEAD.(alphaStrCompl{numAlphas(g)}).(lambdaStrCompl{numLambdas(j)}) = expectAbsFforPhit_HEAD.(alphaStrCompl{numAlphas(g)})(cont95.(alphaStrCompl{numAlphas(g)}),j);
        
        f95_REQ_10mln_DROP_CONF.(alphaStrCompl{numAlphas(g)}).(lambdaStrCompl{numLambdas(j)}) = tStudent(1, simRuns-1) * (std(expectAbsFforPhit_RUNS.(alphaStrCompl{numAlphas(g)}).(lambdaStrCompl{numLambdas(j)})(cont95.(alphaStrCompl{numAlphas(g)}),:))/sqrt(simRuns));
        f95_REQ_10mln_DROP_HEAD_CONF.(alphaStrCompl{numAlphas(g)}).(lambdaStrCompl{numLambdas(j)}) = tStudent(1, simRuns-1) * (std(expectAbsFforPhit_RUNS_HEAD.(alphaStrCompl{numAlphas(g)}).(lambdaStrCompl{numLambdas(j)})(cont95.(alphaStrCompl{numAlphas(g)}),:))/sqrt(simRuns));
    end
end


f50_REQ_10mln_DROP_VECT_MEAN = zeros(1, length(numLambdas));
f50_REQ_10mln_DROP_HEAD_VECT_MEAN = zeros(1, length(numLambdas));
f75_REQ_10mln_DROP_VECT_MEAN = zeros(1, length(numLambdas));
f75_REQ_10mln_DROP_HEAD_VECT_MEAN = zeros(1, length(numLambdas));
f90_REQ_10mln_DROP_VECT_MEAN = zeros(1, length(numLambdas));
f90_REQ_10mln_DROP_HEAD_VECT_MEAN = zeros(1, length(numLambdas));
f95_REQ_10mln_DROP_VECT_MEAN = zeros(1, length(numLambdas));
f95_REQ_10mln_DROP_HEAD_VECT_MEAN = zeros(1, length(numLambdas));

f50_REQ_10mln_DROP_VECT_CONF = zeros(1, length(numLambdas));
f50_REQ_10mln_DROP_HEAD_VECT_CONF = zeros(1, length(numLambdas));
f75_REQ_10mln_DROP_VECT_CONF = zeros(1, length(numLambdas));
f75_REQ_10mln_DROP_HEAD_VECT_CONF = zeros(1, length(numLambdas));
f90_REQ_10mln_DROP_VECT_CONF = zeros(1, length(numLambdas));
f90_REQ_10mln_DROP_HEAD_VECT_CONF = zeros(1, length(numLambdas));
f95_REQ_10mln_DROP_VECT_CONF = zeros(1, length(numLambdas));
f95_REQ_10mln_DROP_HEAD_VECT_CONF = zeros(1, length(numLambdas));

for g=1:length(numAlphas)
    for j = 1:length(numLambdas)
        f50_REQ_10mln_DROP_VECT_MEAN(1,j) = f50_REQ_10mln_DROP.(alphaStrCompl{numAlphas(g)}).(lambdaStrCompl{numLambdas(j)});
        f50_REQ_10mln_DROP_VECT_CONF(1,j) = f50_REQ_10mln_DROP_CONF.(alphaStrCompl{numAlphas(g)}).(lambdaStrCompl{numLambdas(j)});
        f50_REQ_10mln_DROP_HEAD_VECT_MEAN(1,j) = f50_REQ_10mln_DROP_HEAD.(alphaStrCompl{numAlphas(g)}).(lambdaStrCompl{numLambdas(j)});
        f50_REQ_10mln_DROP_HEAD_VECT_CONF(1,j) = f50_REQ_10mln_DROP_HEAD_CONF.(alphaStrCompl{numAlphas(g)}).(lambdaStrCompl{numLambdas(j)});

        f75_REQ_10mln_DROP_VECT_MEAN(1,j) = f75_REQ_10mln_DROP.(alphaStrCompl{numAlphas(g)}).(lambdaStrCompl{numLambdas(j)});
        f75_REQ_10mln_DROP_VECT_CONF(1,j) = f75_REQ_10mln_DROP_CONF.(alphaStrCompl{numAlphas(g)}).(lambdaStrCompl{numLambdas(j)});
        f75_REQ_10mln_DROP_HEAD_VECT_MEAN(1,j) = f75_REQ_10mln_DROP_HEAD.(alphaStrCompl{numAlphas(g)}).(lambdaStrCompl{numLambdas(j)});
        f75_REQ_10mln_DROP_HEAD_VECT_CONF(1,j) = f75_REQ_10mln_DROP_HEAD_CONF.(alphaStrCompl{numAlphas(g)}).(lambdaStrCompl{numLambdas(j)});

        f90_REQ_10mln_DROP_VECT_MEAN(1,j) = f90_REQ_10mln_DROP.(alphaStrCompl{numAlphas(g)}).(lambdaStrCompl{numLambdas(j)});
        f90_REQ_10mln_DROP_VECT_CONF(1,j) = f90_REQ_10mln_DROP_CONF.(alphaStrCompl{numAlphas(g)}).(lambdaStrCompl{numLambdas(j)});
        f90_REQ_10mln_DROP_HEAD_VECT_MEAN(1,j) = f90_REQ_10mln_DROP_HEAD.(alphaStrCompl{numAlphas(g)}).(lambdaStrCompl{numLambdas(j)});
        f90_REQ_10mln_DROP_HEAD_VECT_CONF(1,j) = f90_REQ_10mln_DROP_HEAD_CONF.(alphaStrCompl{numAlphas(g)}).(lambdaStrCompl{numLambdas(j)});

        f95_REQ_10mln_DROP_VECT_MEAN(1,j) = f95_REQ_10mln_DROP.(alphaStrCompl{numAlphas(g)}).(lambdaStrCompl{numLambdas(j)});
        f95_REQ_10mln_DROP_VECT_CONF(1,j) = f95_REQ_10mln_DROP_CONF.(alphaStrCompl{numAlphas(g)}).(lambdaStrCompl{numLambdas(j)});
        f95_REQ_10mln_DROP_HEAD_VECT_MEAN(1,j) = f95_REQ_10mln_DROP_HEAD.(alphaStrCompl{numAlphas(g)}).(lambdaStrCompl{numLambdas(j)});
        f95_REQ_10mln_DROP_HEAD_VECT_CONF(1,j) = f95_REQ_10mln_DROP_HEAD_CONF.(alphaStrCompl{numAlphas(g)}).(lambdaStrCompl{numLambdas(j)});
    end
end




save(stringOutput);
