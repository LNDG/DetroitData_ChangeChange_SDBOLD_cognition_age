#!/bin/bash

# this script replaces data in the sessiondata.mat file for SD BOLD in the common gray matter mask

PLSPATH='/home/mpib/LNDG/Naftali/data/analysis/PLS/'
DATAPATH='/home/mpib/LNDG/Naftali/data/preproc/'

# Subject list 

#N79
IDs='1301 1312 1321 1340 1356 1394 1399 1409 1413 1415 1423 1431 1438 1449 1460 1498 1527 1528 1565 1568 1578 1581 1583 1586 1587 1606 1607 1608 1610 1619 1634 1635 1637 1638 1641 1642 1647 1655 1661 1662 1664 1667 1669 1670 1671 1672 1673 1676 1678 1679 1685 1690 1695 1699 1702 1703 1707 1708 1710 1713 1714 1716 1720 1721 1722 1723 1729 1730 1733 1734 1744 1750 1754 1756 1762 1764 1766 1769 1770'

for subjID in $IDs
do
	
	# cluster job
	echo "#PBS -N prePLS_SD_12ONLY_${subjID}" 		>> job # job name 
	echo "#PBS -l walltime=1:0:0" 					>> job # time until job is killed
	echo "#PBS -l mem=4gb" 							>> job # books 10gb RAM for the job --> 1 CPU hat normalerweise 4gb
	echo "#PBS -j oe"								>> job 
	echo "#PBS -o /home/mpib/LNDG/Naftali/data/analysis/PLS/log/"	>> job # write (error) log to log folder 
	echo "#PBS -e /home/mpib/LNDG/Naftali/data/analysis/PLS/log/" 	>> job 

	echo "cd ${PLSPATH}/mean/"				 		>> job
	echo "${PLSPATH}/scripts/run_SDBOLD_filecreation.sh /opt/matlab/R2014b/ ${subjID} mean_12ONLY_ SD_12ONLY_" 			>> job 
		
	# submit job
	qsub job  
	rm job # clean up temporary file 

done
