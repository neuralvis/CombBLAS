#!/bin/bash

module load perftools-base perftools

DATA_DIR=$1
APP_BINARY=$2 

# generic report informing nid placement for the application
pat_report -v \
	   -i $APP_BINARY \
	   -d ni \
	   -b ni \
	   -s table.total=hide,show_data='csv' \
	   -f rpt \
	   -o $DATA_DIR/NIDS.rpt $DATA_DIR

# extract csv from report
grep  -oE "(nid\.[[:alnum:]]{3,6})" $DATA_DIR/NIDS.rpt > $DATA_DIR/NIDS.csv  
rm $DATA_DIR/NIDS.rpt 

# generic report informing profiling for function groups
pat_report -v \
	   -i $APP_BINARY \
	   -f rpt \
	   -o $DATA_DIR/REPORT.rpt $DATA_DIR 

# generate overall report for all groups
pat_report -v \
	   -i $APP_BINARY \
	   -d ti%@0.95,ti,max_ti,min_ti,tr,Tc \
	   -b gr,ni,pe=HIDE  \
	   -s table.min_sa_pct=0.95 \
	   -f rpt -o $DATA_DIR/ALL_GROUPS.rpt $DATA_DIR

# generate report in csv table, for MPI function group
# timings for processes per node are averaged up to a nid
pat_report -v \
   	   -i $APP_BINARY \
	   -d ti%@0.95,ti,max_ti,min_ti,tr,Tc \
	   -b gr=MPI,ni,pe=HIDE  \
	   -s table.min_sa_pct=0.95,table.total=hide,show_data='csv' \
	   -f rpt -o $DATA_DIR/MPI.rpt $DATA_DIR

# extract csv from report
grep -ri "MPI/" $DATA_DIR/MPI.rpt > $DATA_DIR/MPI.csv 
rm $DATA_DIR/MPI.rpt 

# generate report in csv table, for MPI_SYNC function group
# timings for processes per node are averaged up to a nid
pat_report -v \
	   -i $APP_BINARY \
	   -d ti%@0.95,ti,max_ti,min_ti,tr,Tc \
	   -b gr=MPI_SYNC,ni,pe=HIDE  \
	   -s table.min_sa_pct=0.95,table.total=hide,show_data='csv' \
	   -f rpt -o $DATA_DIR/MPI_SYNC.rpt $DATA_DIR

# extract csv from report
grep -ri "MPI_SYNC/" $DATA_DIR/MPI_SYNC.rpt > $DATA_DIR/MPI_SYNC.csv 
rm $DATA_DIR/MPI_SYNC.rpt 

# generate report in csv table, for USER function group
# timings for processes per node are averaged up to a nid
pat_report -v \
	   -i $APP_BINARY \
	   -d ti%@0.95,ti,max_ti,min_ti,tr,Tc \
	   -b gr=USER,ni,pe=HIDE  \
	   -s table.min_sa_pct=0.95,table.total=hide,show_data='csv' \
	   -f rpt -o $DATA_DIR/USER.rpt $DATA_DIR

# extract csv from report
grep -ri "USER/" $DATA_DIR/USER.rpt > $DATA_DIR/USER.csv 
rm $DATA_DIR/USER.rpt 
