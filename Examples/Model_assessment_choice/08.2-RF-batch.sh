#!/bin/bash
# -----------------------------------------------
#         _           _       _
#        | |__   __ _| |_ ___| |__
#        | '_ \ / _` | __/ __| '_ \
#        | |_) | (_| | || (__| | | |
#        |_.__/ \__,_|\__\___|_| |_|
#                              Fidle at IDRIS
# -----------------------------------------------
#
# Bash script for SLURM batch submission of pyterk notebooks 
# Jean-Luc Parouty (CNRS/SIMaP) 
#
# Soumission :  sbatch  /(...)/batch_slurm.sh
# Suivi      :  squeue -u $USER

# ==== Job parameters ==============================================

#SBATCH --job-name="pyterk08.2"                        # nom du job
#SBATCH --account="ieq@cpu"                            # compatbilité
#SBATCH --ntasks=1                                     # nombre de tâche (un unique processus ici)
#SBATCH --cpus-per-task=40                             # nombre de coeurs à réserver (un quart du noeud)
#SBATCH --hint=nomultithread                           # on réserve des coeurs physiques et non logiques
#SBATCH --time=05:00:00                                # temps exécution maximum demande (HH:MM:SS)
#SBATCH --output="pyterk_%j.out"                       # nom du fichier de sortie
#SBATCH --error="pyterk_%j.err"                        # nom du fichier d'erreur (ici commun avec la sortie)
#SBATCH --mail-user=elise.garel@grenoble-inp.fr
#SBATCH --mail-type=ALL

umask 007

# ==== Notebooks ===================================================

NOTEBOOK_DIR="$ALL_CCFRWORK/pyterk/Elise/Model_assessment_choice"


NOTEBOOK_SRC1="08.2-RF-run.ipynb"
NOTEBOOK_SRC2="08.2-RF-report.ipynb"

# ---- By default (no need to modify)
#
NOTEBOOK_OUT1="${NOTEBOOK_SRC1%.*}==${SLURM_JOB_ID}==.ipynb"
NOTEBOOK_OUT2="${NOTEBOOK_SRC2%.*}==${SLURM_JOB_ID}==.ipynb"

NOTEBOOK_HTML1="${NOTEBOOK_SRC1%.*}==${SLURM_JOB_ID}==.html"
NOTEBOOK_HTML2="${NOTEBOOK_SRC2%.*}==${SLURM_JOB_ID}==.html"

export TF_CPP_MIN_LOG_LEVEL=2

# ==================================================================

echo '------------------------------------------------------------'
echo "Start : $0"
echo '------------------------------------------------------------'
echo "Job id         : $SLURM_JOB_ID"
echo "Job name       : $SLURM_JOB_NAME"
echo "Job node list  : $SLURM_JOB_NODELIST"
echo '------------------------------------------------------------'
echo "Notebook dir   : $NOTEBOOK_DIR"
echo "Notebook src1  : $NOTEBOOK_SRC1"
echo "Notebook out1  : $NOTEBOOK_OUT1"
echo "Notebook html1 : $NOTEBOOK_HTML2"
echo "Notebook src2  : $NOTEBOOK_SRC2"
echo "Notebook out2  : $NOTEBOOK_OUT2"
echo "Notebook html2 : $NOTEBOOK_HTML2"
echo '------------------------------------------------------------'

# ---- Environment

eval "$(/gpfslocalsup/pub/anaconda-py3/2020.02/bin/conda shell.bash hook)"
conda activate tensorflow-2.4.0-cpu

# ---- Run it...

cd $NOTEBOOK_DIR

jupyter nbconvert --ExecutePreprocessor.timeout=-1 --to notebook --output "$NOTEBOOK_OUT1" --execute "$NOTEBOOK_SRC1"
jupyter nbconvert --ExecutePreprocessor.timeout=-1 --to notebook --output "$NOTEBOOK_OUT2" --execute "$NOTEBOOK_SRC2"

jupyter nbconvert --ExecutePreprocessor.timeout=-1 --to html --output "$NOTEBOOK_HTML1" "$NOTEBOOK_OUT1"
jupyter nbconvert --ExecutePreprocessor.timeout=-1 --to html --output "$NOTEBOOK_HTML2" "$NOTEBOOK_OUT2"

echo 'Done.'
