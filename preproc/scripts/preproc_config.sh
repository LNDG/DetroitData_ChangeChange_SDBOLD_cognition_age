#!/bin/bash

# Configuration file containing paths and parameter settings for the preprocessing pipeline.

# Project name
ProjectName="Naftali"

# Directory paths
BaseDirectory="/home/mpib/LNDG"
WorkingDirectory="${BaseDirectory}/${ProjectName}"
DataPath="${WorkingDirectory}/data/preproc/mri2"
RawPath="${WorkingDirectory}/RAW/Doug rsMRI"
ScriptsPath="${WorkingDirectory}/data/preproc/scripts/y_GIT_repo"
LogPath="${WorkingDirectory}/data/preproc/log"
SharedFilesPath="${BaseDirectory}/Standards" 				# Toolboxes, Standards, etc

# create log path
if [ ! -d ${LogPath} ]; then
	mkdir -p ${LogPath}
	chmod 770 ${LogPath}
fi

# Subject ID list
SubjectID="1301 1312 1321 1340 1356 1394 1399 1409 1413 1415 1423 1431 1438 1449 1460 1498 1527 1528 1565 1568 1578 1581 1583 1586 1587 1606 1607 1608 1610 1619 1634 1635 1637 1638 1641 1642 1647 1655 1661 1662 1664 1667 1669 1670 1671 1672 1673 1676 1678 1679 1685 1690 1695 1699 1702 1703 1707 1708 1710 1713 1714 1716 1720 1721 1722 1723 1729 1730 1733 1734 1744 1750 1754 1756 1762 1764 1766 1769 1770"

# All subjects:
#"1300 1301 1308 1312 1317 1321 1322 1325 1327 1329 1330 1335 1340 1356 1364 1371 1381 1385 1394 1399 1408 1409 1413 1415 1423 1426 1431 1438 1446 1449 1460 1482 1486 1497 1498 1500 1506 1510 1514 1515 1523 1525 1527 1528 1531 1543 1552 1560 1563 1565 1568 1570 1571 1573 1578 1581 1583 1584 1585 1586 1587 1591 1592 1603 1606 1607 1608 1610 1611 1619 1622 1623 1625 1634 1635 1636 1637 1638 1641 1642 1643 1644 1645 1646 1647 1648 1650 1651 1652 1653 1654 1655 1657 1658 1659 1660 1661 1662 1663 1664 1665 1666 1667 1668 1669 1670 1671 1672 1673 1674 1675 1676 1677 1678 1679 1681 1682 1683 1684 1685 1686 1687 1688 1689 1690 1692 1693 1694 1695 1696 1697 1698 1699 1700 1701 1702 1703 1704 1705 1706 1707 1708 1709 1710 1711 1712 1713 1714 1715 1716 1717 1718 1719 1720 1721 1722 1723 1724 1725 1726 1727 1729 1730 1731 1732 1733 1734 1736 1737 1738 1739 1740 1741 1742 1743 1744 1745 1747 1748 1750 1751 1752 1753 1754 1755 1756 1757 1761 1762 1763 1764 1766 1769 1770 1771 1772 1773 1774 1775 1776 1777 1778 1779 1780 1781"
# 1767 not part of analysis

# Voxel sizes & TR:
VoxelSize="3"
TR="2.500000" # Volume acquisition time
TotalVolumes="200"

# FEAT standard variables
ToggleMCFLIRT="1"								# 0=No, 1=Yes: Default is 1
BETFunc="1" 									# 0=No, 1=Yes: Default is 1
#TotalVolumes="194"	# take directly from nifti
DeleteVolumes="4" # changed from 0 to 4!
HighpassFEAT="0"			# 0=No, 1=Yes
SmoothingKernel="7"
RegisterStructDOF="BBR" 						# Default is BBR, other DOF options: 12, 9, 7, 6, 3
MNIImage="${SharedFilesPath}/MNI152_T1_3mm_brain"

# Secondary FEAT variables (normally unused)
NonLinearReg="0"								# 0=No, 1=Yes: Default is 0
NonLinearWarp="10"								# Default is 10, applied only if NonLinearReg=1
IntensityNormalization="0" 						# 0=No, 1=Yes: Default is 0
SliceTimingCorrection="0"						# Default is 0; 0:None,1:Regular up,2:Regular down,3:Use slice order file,4:Use slice timings

# Other FIELDmap variables
Unwarping="0"
UnwarpDir="y-"
EpiSpacing="0.7"
EpiTE="35" # in ms
SignalLossThresh="10"

# Detrend variables
PolyOrder="2" 									# Default is 3

# Filter variables
HighpassFilterLowCutoff="0.01"					# Default is 0.01, can be set to "off"" if not perforing Highpass
LowpassFilterHighCutoff="0.1" 					# Default is 0.1, can be set to "off" if not performing Lowpass
FilterOrder="8" 								# Default is 8

# ICA variables
dimestVALUE="mdl" 								# Default is mdl
bgthresholdVALUE="3" 							# Default is 3
mmthreshVALUE="0.5" 							# Default is 0.5
dimensionalityVALUE="0" 						# Default is 0
AdditionalParameters="-v --Ostats" 				# Default are '-v --Ostats', verbose and, output thresholded maps and probability maps

# FIX variables

# Accepted FIX Threshold
FixThreshold="60"