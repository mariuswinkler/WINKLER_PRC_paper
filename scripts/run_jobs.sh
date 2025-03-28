#!/usr/bin/env bash
#SBATCH --partition=compute
#SBATCH --account=mh0731
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=64
#SBATCH --time=4:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=marius.winkler@mpimet.mpg.de
#SBATCH --output=../logs/%x.%j.log
#SBATCH --error=../logs/%x.%j.log

# ===================================================================
# Script: run_jobs.sh
# Purpose: Run one or more Jupyter notebooks on the SLURM cluster
# Usage:
#   sbatch run_jobs.sh <notebook_or_figure> <sigma> <itr>
# Parameters:
#   <notebook_or_figure>: Either a single notebook filename or a figure number
#                         that maps to a predefined list of notebooks.
#   <sigma>: A float representing the sigma value to pass to the notebook
#   <itr>: An integer representing the number of iterations to pass
# Description:
#   This script activates a Conda environment, determines the list of notebooks
#   (based on a figure number or notebook name), and then executes them
#   sequentially using nbconvert. Environment variables `sig` and `itr`
#   are exported for use within the notebooks.
# ===================================================================

# === Conda Environment Initialization ===

if ! command -v conda &> /dev/null; then
    echo "🔧 Conda not found in PATH, attempting 'module load python3'..."
    module load python3 2>/dev/null
fi

if ! command -v conda &> /dev/null; then
    echo "❌ Conda still not available. Please load it manually or fix module setup."
    exit 1
fi

CONDA_BASE=$(conda info --base)
source "$CONDA_BASE/etc/profile.d/conda.sh"

ENV_NAME="WINKLER_PRC_paper"
if ! conda info --envs | grep -q "^$ENV_NAME[[:space:]]"; then
    echo "❌ Conda environment '$ENV_NAME' not found."
    conda info --envs
    exit 1
fi

echo "✅ Activating Conda environment: $ENV_NAME"
conda activate "$ENV_NAME"

# === Job Parameters ===
INPUT="$1"
SIGMA="$2"
ITR="$3"

export sig=$SIGMA
export itr=$ITR

# Get notebook list either directly or by figure name
case $INPUT in
    2) NOTEBOOKS="
    Coupled_WCM_discrete_delay.ipynb \
    Coupled_WCM_gaussian_delay.ipynb \
    Coupled_WCM_lognormal_delay.ipynb
    " ;;
    3) NOTEBOOKS="
    Direct_PRC_WCM_direct_delay.ipynb \
    Direct_PRC_WCM_gaussian_delay.ipynb \
    Direct_PRC_WCM_lognormal_delay.ipynb \
    WCM_discrete_delay.ipynb \
    WCM_gaussian_delay.ipynb \
    WCM_lognormal_delay.ipynb \
    PRC_WCM_discrete_delay.ipynb \
    PRC_WCM_gaussian_delay.ipynb \
    PRC_WCM_lognormal_delay.ipynb
    " ;;
    4) NOTEBOOKS="
    WCM_discrete_delay.ipynb \
    WCM_gaussian_delay.ipynb \
    WCM_lognormal_delay.ipynb \
    PRC_WCM_discrete_delay.ipynb \
    PRC_WCM_gaussian_delay.ipynb \
    PRC_WCM_lognormal_delay.ipynb \
    Normalized_PRC_discrete_delay.ipynb \
    Normalized_PRC_gaussian_delay.ipynb \
    Normalized_PRC_lognormal_delay.ipynb \
    Interaction_Function_discrete_delay.ipynb \
    Interaction_Function_gaussian_delay.ipynb \
    Interaction_Function_lognormal_delay.ipynb
    " ;;
    5|6|7) NOTEBOOKS="
    Direct_PRC_WCM_direct_delay.ipynb \
    Direct_PRC_WCM_gaussian_delay.ipynb \
    Direct_PRC_WCM_lognormal_delay.ipynb \
    WCM_discrete_delay.ipynb \
    WCM_gaussian_delay.ipynb \
    WCM_lognormal_delay.ipynb \
    PRC_WCM_discrete_delay.ipynb \
    PRC_WCM_gaussian_delay.ipynb \
    PRC_WCM_lognormal_delay.ipynb \
    Normalized_PRC_discrete_delay.ipynb \
    Normalized_PRC_gaussian_delay.ipynb \
    Normalized_PRC_lognormal_delay.ipynb \
    Interaction_Function_discrete_delay.ipynb \
    Interaction_Function_gaussian_delay.ipynb \
    Interaction_Function_lognormal_delay.ipynb
    " ;;
    *) NOTEBOOKS="$INPUT" ;; 
esac

# === Execute all notebooks ===

for NB in $NOTEBOOKS; do
    echo "📓 Running notebook: $NB with sig=$SIGMA, itr=$ITR"
    jupyter nbconvert --to notebook --inplace --execute "../notebooks/${NB}" \
        --ExecutePreprocessor.timeout=-1 \
        > "../logs/${NB}_sig_${SIGMA}_itr_${ITR}.txt"
done