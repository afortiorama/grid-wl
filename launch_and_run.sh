#!/usr/bin/env bash

# Example run:
# ./launch_and_run.sh srm://gridpp09.ecdf.ed.ac.uk/dpm/ecdf.ed.ac.uk/home/gridpp/lsst/zuntz/y1a1-v2-z/software/2016-02-01/im3shape-grid.tar.gz  srm://gridpp09.ecdf.ed.ac.uk/dpm/ecdf.ed.ac.uk/home/lsst/DES0005+0043-z-meds-y1a1-gamma.fits.fz  srm://gridpp09.ecdf.ed.ac.uk/dpm/ecdf.ed.ac.uk/home/gridpp/lsst/zuntz/y1a1-v2-z/results/DES0005+0043-z-meds-y1a1-gamma.fits.fz.0.20  params_bd.ini  all  0  20  blacklist-y1.txt

# Dirac version with cvmfs for the software
# ./launch_and_run.sh <code_path> <data_lfn> <output_lfn> <ini_file_name> <cat> <job_rank> <job_count> <target_storage> 
# ./launch_and_run.sh /cvmfs/lsst.opensciencegrid.org/uk/shape-measurement/im3shape/im3shape-2015-08-05  /lsst/DES0005+0043-z-meds-y1a1-gamma.fits.fz  /lsst/y1a1-v2-z/results/DES0005+0043-z-meds-y1a1-gamma.fits.fz.0.20  params_bd.ini  all  0  20  UKI-NORTHGRID-MAN-HEP-Disk

# This would requires two files along with it - these are specified on the command line above.  The others are downloaded via gfal-copy.
# params_bd.ini
# blacklist-y1.txt


#Echo all commands
set -o xtrace

#Parameters of this run
CODE_REMOTE_PATH=$1
DATA_REMOTE_PATH=$2
OUTPUT_REMOTE_PATH=$3
INI=$4
CAT=$5
JOB_RANK=$6
JOB_COUNT=$7
BLACKLIST=$8
TARGET_STORAGE=$9

CODE_LOCAL_PATH=$(basename $CODE_REMOTE_PATH)
DATA_LOCAL_PATH=$(basename $DATA_REMOTE_PATH)
OUTPUT_LOCAL_PATH=$(basename $OUTPUT_REMOTE_PATH)

echo CODE_LOCAL_PATH $CODE_LOCAL_PATH
#echo DATA_LOCAL_PATH $DATA_LOCAL_PATH
echo OUTPUT_LOCAL_PATH $OUTPUT_LOCAL_PATH

# Download the software to be run, unzip it, and go into the directory

echo Downloading Code `date`
dirac-dms-get-file $CODE_REMOTE_PATH 2>&1

if [ "$?" == "0" ]; then

    tar -xf $CODE_LOCAL_PATH  2>&1
    ls -l $PWD
    cd im3shape-grid 2>&1
    pwd
else
    echo "Couldn't untar. Bye Bye."
fi

echo Downloading data `date`
dirac-dms-get-file $DATA_REMOTE_PATH  2>&1

#Move files into dir. For convenience
mv ../$INI ./
mv ../$BLACKLIST ./

#Run the main code - also sets up environment
echo Running code `date`
ls -l $PWD
echo $PWD/run-im3shape $DATA_LOCAL_PATH $INI $CAT $OUTPUT_LOCAL_PATH $JOB_RANK $JOB_COUNT  2>&1
$PWD/run-im3shape $DATA_LOCAL_PATH $INI $CAT $OUTPUT_LOCAL_PATH $JOB_RANK $JOB_COUNT  2>&1

echo "DONE - WHAT IS HERE"
ls -l $PWD

echo Copying back results  `date`
# Copy results back to SRM. Force copying so we overwrite
dirac-dms-add-file ${OUTPUT_REMOTE_PATH}.main.txt ${OUTPUT_LOCAL_PATH}.main.txt $TARGET_STORAGE 2>&1
dirac-dms-add-file ${OUTPUT_REMOTE_PATH}.epoch.txt ${OUTPUT_LOCAL_PATH}.epoch.txt $TARGET_STORAGE 2>&1
# gfal-copy -f file://$PWD/${OUTPUT_LOCAL_PATH}.main.txt ${OUTPUT_REMOTE_PATH}.main.txt  2>&1
# gfal-copy -f file://$PWD/${OUTPUT_LOCAL_PATH}.epoch.txt ${OUTPUT_REMOTE_PATH}.epoch.txt  2>&1

echo Complete  `date`




#STORAGE_ELEMENT=srm://bohr3226.tier2.hep.manchester.ac.uk/dpm/tier2.hep.manchester.ac.uk/home/lsst/zuntz
#CODE_REMOTE_PATH=srm://gridpp09.ecdf.ed.ac.uk:8446/srm/managerv2?SFN=/dpm/ecdf.ed.ac.uk/home/gridpp/lsst
#CODE_DIR=/cvmfs/lsst.opensciencegrid.org/uk/shape-measurement/im3shape/im3shape-2015-08-03
#INPUT_BASE=meds
#OUTPUT_BASE=results
#RUN_NUMBER=1

