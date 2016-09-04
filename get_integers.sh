#!/bin/bash
declare -r g_num=5 g_min=-1024 g_max=1024 g_file=rnd_integers.dat g_trigger=create_integers
#
## Check for trigger file, if it exist clear it else create it ...
#
if [ -f $g_file ]; then
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
  ## if it is kill 'tail' and empty the file ...
  #
  ( tail -f -n0 $g_trigger & ) | grep -q 'start' && pkill tail && > $g_trigger
  #
  ## If an older data file exist, clear it ...
  #
  [ -f $g_file ] && > $g_file
  #
  ## Perform GET request, with a timeout of 3s (standard is 3m)
  ## the execution of the 'GET' command could be determinated with
  ## '$ time GET "<uri>"'
  #
  integers=$(GET -t 3s "https://www.random.org/integers/?num=$g_num&min=$g_min&max=$g_max&col=1&base=10&format=plain&rnd=new")
  #
  ## print to file if no 'Error' and no timeout occured ...
  #
  if [[ $integers != *"Error:"* ]] && \
  	 [[ $integers != *"Connection timed out"* ]] && \
  	 [[ $integers != *"Can't connect to"* ]]
  then
    for nmbr in $integers; do
      printf '%5d ' $nmbr >> $g_file
    done
  fi
done