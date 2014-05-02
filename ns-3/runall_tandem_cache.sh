#!/bin/sh
main=./waf

SCRIPTPATH=`pwd`
sim="NDNSIM"

runs=9
logDir=logs
infoDir=infoSim
#net=`grep 'net=' $iniFile | awk '{print $3}' | awk -F '=' '{print $2}' | awk -F '}' '{print $1}'`

net=tandem_cache
T=TANDEM_CACHE
#A=1.2
plateau=0
C=0.01
M=10000
L=4
simDuration=2500000
req=100000000

#runs=`$main -x General $1 | awk '/runs/{print $4}'`
#echo $a
#for ((i=0; i<(runs-1); i++))
#let j=$runs-1

for k in 0.6 0.8 1 1.2
do
   for i in `seq 0 $runs`
   do
      j=`expr $i + 1`
   
      /usr/bin/time -f "\n%E \t elapsed real time \n%U \t total CPU seconds used (user mode) \n%S \t total CPU seconds used by the system on behalf of the process \n%M \t memory (max resident set size) [kBytes] \n%x \t exit status" -o ${infoDir}/Info_SIM\=${sim}_T\=${T}_REQ\=${req}_M\=${M}_C\=${C}_L\=${L}_A\=${k}_R\=${i}.txt sudo $main --run "scratch/ndn-tandem-cache --catalogCardinality\=${M} --numReqTot\=${req} --cacheToCatalogRatio\=${C} --lambda\=${L} --alpha\=${k} --plateau\=${plateau} --simType\=${T} --simDuration\=${simDuration} --RngSeed\=1 --RngRun\=${j}" > $logDir/stdout/SIM\=${sim}_T\=${T}_REQ\=${req}_M\=${M}_C\=${C}_L\=${L}_A\=${k}_R\=${i}.out 2>&1   

     # grep 'Hit_Event' $logDir/SIM\=${sim}_T\=${T}_M\=${M}_C\=${C}_L\=${L}_A\=${A}_R\=${i}-temp.out > $logDir/SIM\=${sim}_T\=${T}_M\=${M}_C\=${C}_L\=${L}_A\=${A}_R\=${i}.out
   
     # rm $logDir/SIM\=${sim}_T\=${T}_M\=${M}_C\=${C}_L\=${L}_A\=${A}_R\=${i}-temp.out 
   done

   tar -zcvf $logDir/log_${req}_req_SIM\=${sim}_T\=${T}_M\=${M}_C\=${C}_L\=${L}_A\=${k}.tar.gz $logDir/SIM\=${sim}_T\=${T}_REQ\=${req}_M\=${M}_C\=${C}_L\=${L}_A\=${k}_R*
   rm $logDir/SIM\=${sim}_T\=${T}_REQ\=${req}_M\=${M}_C\=${C}_L\=${L}_A\=${k}_R*

   tar -zcvf $infoDir/Info_${req}_req_SIM\=${sim}_T\=${T}_M\=${M}_C\=${C}_L\=${L}_A\=${k}.tar.gz $infoDir/Info_SIM\=${sim}_T\=${T}_REQ\=${req}_M\=${M}_C\=${C}_L\=${L}_A\=${k}_R*
   rm $infoDir/Info_SIM\=${sim}_T\=${T}_REQ\=${req}_M\=${M}_C\=${C}_L\=${L}_A\=${k}_R*

done
