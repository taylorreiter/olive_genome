#!/bin/bash

module use /opt/software/ged-software/modulefiles/
module load anaconda
module unload python
module swap GNU GNU/6.2
source activate 2017-paper-gather

{exec_job}
