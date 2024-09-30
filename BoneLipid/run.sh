#!/bin/bash

helpFunction()
{
   echo ""
   echo "Usage: $0 -p projectName"
   echo -e "\t-p Description of what is parameterA"
   exit 1 # Exit script after printing help
}

while getopts "p:" opt
do
   case "$opt" in
      p ) projectName="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$projectName" ]
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi

# Begin script in case all parameters are correct
echo "$projectName"

# matlab
matlab -nodisplay -r "clear all; close all; lcm_batch('${projectName}'); quit;"
