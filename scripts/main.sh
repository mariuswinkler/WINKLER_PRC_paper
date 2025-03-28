#!/usr/bin/env bash

# ===================================================================
# Script: main.sh
# Purpose: Run a selected set of Jupyter notebooks locally or via SLURM
# Usage:
#   ./main.sh --figures=2,3 --mode=slurm --phase=compute [--debug]
#   ./main.sh --figures=2,3 --mode=local --phase=plotting [--debug]
# Options:
#   --figures=1,2,...         Comma-separated list of figures to generate
#   --mode=local|slurm        Choose between local execution or SLURM jobs
#   --phase=compute|plotting  Split runs into computation and plotting phases
#   --env=ENV_NAME            (Optional) Specify a conda environment name
#   --debug                   (Optional) Print commands instead of executing them
# Description:
#   This script activates a specified conda environment, determines
#   which notebooks to execute for the requested figures, and runs
#   either compute or plotting notebooks depending on the selected phase.
#   Figures 5–7 trigger a sigma sweep where each sigma is submitted as a separate job
#   that runs all relevant notebooks in one go. The sweep is only executed once.
# ===================================================================

# === Conda Environment Initialization ===

if ! command -v conda &> /dev/null; then
    echo "Conda not found in PATH, attempting 'module load python3'..."
    module load python3 2>/dev/null
fi

if ! command -v conda &> /dev/null; then
    echo "Conda not available. Please load it manually or activate your environment."
    exit 1
fi

CONDA_BASE=$(conda info --base)
source "$CONDA_BASE/etc/profile.d/conda.sh"

ENV_NAME="WINKLER_PRC_paper"
DEBUG=false
DEBUG_LOG=""

for arg in "$@"; do
    case $arg in
        --env=*) ENV_NAME="${arg#*=}" ;;
        --debug) 
            DEBUG=true
            DEBUG_LOG="main_debug_output.txt"
            > "$DEBUG_LOG"
            ;;
    esac
done


for arg in "$@"; do
    case $arg in
        --env=*) ENV_NAME="${arg#*=}" ;;
        --debug) DEBUG=true ;;
    esac
done

if ! conda info --envs | grep -q "^$ENV_NAME[[:space:]]"; then
    echo "Conda environment '$ENV_NAME' not found."
    conda info --envs
    exit 1
fi

echo "✅ Activating Conda environment: $ENV_NAME"
conda activate "$ENV_NAME"

# === Script Parameters ===
MODE="local"
PHASE="compute"
FIGURES=""
SIG_RANGE=$(seq 0.01 0.01 1.01)
SIGMA_SWEEP_DONE=false

# Parse CLI
for arg in "$@"; do
    case $arg in
        --mode=*) MODE="${arg#*=}" ;;
        --figures=*) FIGURES="${arg#*=}" ;;
        --phase=*) PHASE="${arg#*=}" ;;
    esac
done

# === Define notebooks and parameters per figure ===
get_notebooks_for_figure() {
    case $1 in
        1) echo "
        00_Figure_01.ipynb
        s" ;;
        2) echo "
        Coupled_WCM_discrete_delay.ipynb \
        Coupled_WCM_gaussian_delay.ipynb \
        Coupled_WCM_lognormal_delay.ipynb
        " ;;
        3) echo "
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
        4) echo "
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
        5|6|7) echo "
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
    esac
}

get_plot_notebook() {
    case $1 in
        1) echo "00_Figure_01.ipynb" ;;
        2) echo "00_Figure_02.ipynb" ;;
        3) echo "00_Figure_03.ipynb" ;;
        4) echo "00_Figure_04.ipynb" ;;
        5) echo "00_Figure_05.ipynb" ;;
        6) echo "00_Figure_06.ipynb" ;;
        7) echo "00_Figure_07.ipynb" ;;
    esac
}

get_params_for_figure() {
    case $1 in
        2) echo "180000 0.1" ;;
        3) echo "20000 0.1" ;;
        4) echo "20000 0.2" ;;
        5|6|7) echo "20000 sweep" ;;
        *) echo "20000 0.1" ;;
    esac
}

IFS=',' read -ra FIG_ARRAY <<< "$FIGURES"

for FIG in "${FIG_ARRAY[@]}"; do
    NOTEBOOKS=$(get_notebooks_for_figure $FIG)
    PLOT_NOTEBOOK=$(get_plot_notebook $FIG)
    read -r ITR SIG_RAW <<< $(get_params_for_figure $FIG)

    if [[ "$PHASE" == "compute" ]]; then
        if [[ "$SIG_RAW" == "sweep" && "$SIGMA_SWEEP_DONE" == false ]]; then
            SIGMA_SWEEP_DONE=true
            for SIGMA in $SIG_RANGE; do
                CMD="sbatch run_jobs.sh \"$NOTEBOOKS\" $SIGMA $ITR"
                if [[ "$MODE" == "slurm" ]]; then
                    if $DEBUG; then echo "[DEBUG] $CMD" | tee -a "$DEBUG_LOG"; else eval $CMD; fi
                else
                    echo "🔧 Local sweep: Figure $FIG, sig=$SIGMA"
                    for NB in $NOTEBOOKS; do
                        CMD="jupyter-nbconvert --to notebook --inplace --execute ../notebooks/${NB} --ExecutePreprocessor.timeout=-1 > ../logs/${NB}_sig_${SIGMA}_itr_${ITR}.txt"
                        if $DEBUG; then echo "[DEBUG] $CMD" | tee -a "$DEBUG_LOG"; else export sig=$SIGMA; export itr=$ITR; eval $CMD & fi
                    done
                    wait
                fi
            done
        elif [[ "$SIG_RAW" != "sweep" ]]; then
            if [[ "$MODE" == "slurm" ]]; then
                CMD="sbatch run_jobs.sh \"$NOTEBOOKS\" $SIG_RAW $ITR"
                if $DEBUG; then echo "[DEBUG] $CMD" | tee -a "$DEBUG_LOG"; else eval $CMD; fi
            else
                for NB in $NOTEBOOKS; do
                    CMD="jupyter-nbconvert --to notebook --inplace --execute ../notebooks/${NB} --ExecutePreprocessor.timeout=-1 > ../logs/${NB}_sig_${SIG_RAW}_itr_${ITR}.txt"
                    if $DEBUG; then echo "[DEBUG] $CMD" | tee -a "$DEBUG_LOG"; else export sig=$SIG_RAW; export itr=$ITR; eval $CMD & fi
                done
                wait
            fi
        fi

    elif [[ "$PHASE" == "plotting" ]]; then
        CMD="jupyter-nbconvert --to notebook --inplace --execute ../notebooks/${PLOT_NOTEBOOK} --ExecutePreprocessor.timeout=-1 > ../logs/${PLOT_NOTEBOOK}_sig_${SIG_RAW}_itr_${ITR}.txt"
        if [[ "$MODE" == "slurm" ]]; then
            CMD="sbatch run_jobs.sh $PLOT_NOTEBOOK $SIG_RAW $ITR"
        fi
        if $DEBUG; then echo "[DEBUG] $CMD" | tee -a "$DEBUG_LOG"; else export sig=$SIG_RAW; export itr=$ITR; eval $CMD; fi
    fi

done
