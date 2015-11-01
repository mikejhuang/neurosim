#Importing parameters from neurosim.sh
line=1 #start line of parameters
paramload=true
date >> paramlog
while [ $paramload != done ]; do
sed -n "$line"p parameters.txt >> paramlog
eval `sed -n "$line"p parameters.txt`
(( line++ ))
done

#Set number of nodes
nbsynapses=`grep -c \<Synapse\> $MASTERCONF`
nbnodes=`expr $nbsynapses + 2` 
echo $nbsynapses'synapses' >> paramlog
#Create Filename 
date=`date +"Date%m%d%yTime%H%M%S"`
#if [ "$probaRelease" -eq 1 ];then
#filename=$date'nbAMPAR'$nbAMPA'nbNMDAR'$nbNMDA'ProbRelease'$initialReleaseProba #Edit this line to change #filename format for when probaRelease is true
#else 
filename=$date'nbAMPAR'$nbAMPA'nbNMDAR'$nbNMDA'ProbRelease'$probaRelease
#fi
echo $filename >> queue
echo $filename >> nodequeue
echo $filename >> nodequeue2    
sed -i "s/filenameMem/$filename/g" paramsync.sh
cp paramlog $NEURON_HOME/$filename'.log'
rm paramlog                    

#Search and replace parameters in files
sed -i "s%SYNAPSECONF%$SYNAPSECONF%g" $MASTERCONF
sed -i "s%MASTERCONF%$MASTERCONF%g" $NEURONPY
sed -i "s%MASTERCONF%$MASTERCONF%g" $MPJLAUNCH
sed -i 's/"NRN"+time.strftime("%y%m%d%H%M",now)/"searchandreplace"/g' $NEURONPY
sed -i "s/searchandreplace/$filename/g" $NEURONPY
grep filename= $NEURONPY
sed -i "s/-np [0-9]\+ -/-np $nbnodes -/g" $MPJLAUNCH
sed -i "s/>[0-9]\+<\/nbAMPA/>$nbAMPA<\/nbAMPA/g" $SYNAPSECONF
sed -i "s/>[0-9]\+.[0-9]\+<\/nbAMPA/>$nbAMPA<\/nbAMPA/g" $SYNAPSECONF  
grep nbAMPAR $SYNAPSECONF
sed -i "s/>[0-9]\+<\/nbNMDA/>$nbNMDA<\/nbNMDA/g" $SYNAPSECONF
sed -i "s/>[0-9]\+.[0-9]\+<\/nbNMDA/>$nbNMDA<\/nbNMDA/g" $SYNAPSECONF
grep nbNMDAR $SYNAPSECONF
sed -i "s/>[0-9].[0-9]<\/proba/>$probaRelease<\/proba/g" $SYNAPSECONF
sed -i "s/>[0-9]<\/proba/>$probaRelease<\/proba/g" $SYNAPSECONF
sed -n '181'p $SYNAPSECONF
sed -i "s/[0-9].[0-9]\+<\/initialReleaseProba/$initialReleaseProba<\/initialReleaseProba/g" $SYNAPSECONF
sed -n '184'p $SYNAPSECONF
sed -i "s/<Duration>[0-9]\+/<Duration>$duration/g" $MASTERCONF
sed -i "s/<Duration>[0-9]\+/<Duration>$duration/g" $SYNAPSECONF
sed -n '1074'p $SYNAPSECONF
sed -n '3'p $MASTERCONF
#sed -i "s/a[i]*.0[0-9]\+/a[i]*.0$clusterFactor/g" $NEURONPY


