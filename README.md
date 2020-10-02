# autoshred
An automatic disk shredding utility


When added to cron this script will shred any drives placed into a linux machine, besides whatever / is mounted on as well as log progress and completion. Useful for when you have a high volume of drives to wipe. 

You may need to adjust the pci bus listed in `for d in $(ls /dev/disk/by-path/pci-0000\:01\:00.0-sas-phy* | grep -v part)` near the top of the script. You can find that by doing `ls /dev/disk/by-path`

### to do
add smarctl checks

drive bay led control based on results

# WARNING
This script is very dangerous. It may shred data you care about if you are not careful and lack understanding on how to adjust the script to your environment. Run at your own risk. 
