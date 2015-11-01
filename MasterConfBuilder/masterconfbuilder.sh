#!/bin/bash
echo "Enter neuron session file path"
read input
echo "Enter filename to save as"
read output
grep 'dend' $input > temp
sed -i 's/execute("dend/<Synapse><file>SYNAPSECONF<\/file><input>Internal<\/input><Position Section="dend/g' temp
sed -i 's/] ocbox_.move(/]">/g' temp
sed -i 's/)")/<\/Position><\/Synapse>/g' temp
cat masterconfhead temp masterconftail > $output
