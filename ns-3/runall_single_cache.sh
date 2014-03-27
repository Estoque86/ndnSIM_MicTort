#!/bin/sh
main=./waf

SCRIPTPATH=`pwd`
sim="NDNSIM"

runs=9
logDir=logs
infoDir=infoSim
#net=`grep 'net=' $iniFile | awk '{print $3}' | awk -F '=' '{print $2}' | awk -F '}' '{print $1}'`

net=single_cache
T=SINGLE_CACHE
A=1
plateau=0
C=0.01
M=10000
L=4
simDuration=250000
req=1000000

#runs=`$main -x General $1 | awk '/runs/{print $4}'`
#echo $a
#for ((i=0; i<(runs-1); i++))
#let j=$runs-1
for i in `seq 0 $runs`
do
   j=`expr $i + 1`
   #echo $i
   #$main -u Cmdenv -f $iniFile -r $i > $resultdir/${net}/F-${F}/D-${D}/R-${R}/alpha-${a}/ccn-id-${i}.out 2>&1
   #echo 'Time\tNode\tEvent\tContentID\t#Hops' >> $logDir/SIM\=${sim}_T\=${net}_M\=${M}_C\=${C}_L\=${L}_A\=${A}_R\=${i}.out
  # /usr/bin/time -f "\n%E \t elapsed real time \n%U \t total CPU seconds used (user mode) \n%S \t total CPU seconds used by the system on behalf of the process \n%M \t memory (max resident set size) [kBytes] \n%x \t exit status" -o ${infoDir}/Info_SIM\=${sim}_T\=${net}_M\=${M}_C\=${C}_L\=${L}_A\=${A}_R\=${i}.txt $main -u Cmdenv -f $iniFile -r $i > $logDir/SIM\=${sim}_T\=${net}_M\=${M}_C\=${C}_L\=${L}_A\=${A}_R\=${i}-temp.out 2>&1   
   /usr/bin/time -f "\n%E \t elapsed real time \n%U \t total CPU seconds used (user mode) \n%S \t total CPU seconds used by the system on behalf of the process \n%M \t memory (max resident set size) [kBytes] \n%x \t exit status" -o ${infoDir}/Info_SIM\=${sim}_T\=${T}_REQ\=${req}_M\=${M}_C\=${C}_L\=${L}_A\=${A}_R\=${i}.txt $main --run "scratch/ndn-single-cache-cs-tracers_NEW --catalogCardinality\=${M} --numReqTot\=${req} --cacheToCatalogRatio\=${C} --lambda\=${L} --alpha\=${A} --plateau\=${plateau} --simType\=${T} --simDuration\=${simDuration} --RngSeed\=1 --RngRun\=${j}" > $logDir/stdout/SIM\=${sim}_T\=${T}_REQ\=${req}_M\=${M}_C\=${C}_L\=${L}_A\=${A}_R\=${i}.out 2>&1   

  # grep 'Hit_Event' $logDir/SIM\=${sim}_T\=${T}_M\=${M}_C\=${C}_L\=${L}_A\=${A}_R\=${i}-temp.out > $logDir/SIM\=${sim}_T\=${T}_M\=${M}_C\=${C}_L\=${L}_A\=${A}_R\=${i}.out
   
  # rm $logDir/SIM\=${sim}_T\=${T}_M\=${M}_C\=${C}_L\=${L}_A\=${A}_R\=${i}-temp.out 
done

#opp_runall -j4 $main -u Cmdenv -f $iniFile -r 0..$((runs-1)) > $resultdir/$net/F-$F/D-$D/R-$R/alpha-$a/
