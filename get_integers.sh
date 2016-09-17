#!/bin/bash
declare -i g_num=5 g_min=0 g_max=6
declare -r g_file=rnd_integers.dat g_trigger=create_integers g_settings=set_integers
#
## Check for trigger file, if it exist clear it else create it ...
#
if [ -f $g_file ]
then
  > $g_trigger
else
  touch $g_trigger
fi
#
## Infinite outer loop ...
#
while :
do
  #
  ## Wait until 'start' is written to the trigger file,
  ## if it is kill 'tail' and proceed ...
  #
  ( tail -f -n0 $g_trigger & ) | grep -q 'start' && pkill tail && echo -n 'running' > $g_trigger
  #
  ## Check for settings file, if it exist read it and replace default values ...
  #
  if [[ -f $g_settings ]]
  then
    g_defines=(`cat "$g_settings"`)
    if [[ 3 -eq ${#g_defines[@]} ]] && \
       [[ 3 -eq $(printf '%s\n' "${g_defines[@]}" | grep -Poc '[-,0-9]{1,7}') ]]
    then
      g_num=${g_defines[0]}; g_min=${g_defines[1]}; g_max=${g_defines[2]}
    fi
  fi
  #
  ## Perform GET request, with a timeout of 3s (standard is 3m)
  ## the execution of the 'GET' command could be determinated with
  ## '$ time GET "<uri>"'
  #
  integers=$(GET -t 3s "https://www.random.org/integers/?num=$g_num&min=$g_min&max=$g_max&col=1&base=10&format=plain&rnd=new")
  #
  ## Print to file if no 'Error' and no timeout occured ...
  #
  if [[ $integers != *"Error:"* ]] && \
     [[ $integers != *"Connection timed out"* ]] && \
     [[ $integers != *"Can't connect to"* ]]
  then
    #
    ## If an older data file exist, clear it ...
    #
    [ -f $g_file ] > $g_file
    for nmbr in $integers; do
      printf '%5d ' $nmbr >> $g_file
    done
  fi
  #
  ## Empty the trigger file ...
  #
  > $g_trigger
done