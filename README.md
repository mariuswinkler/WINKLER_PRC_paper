# Phase Response Curve Modeling – WINKLER_PRC_paper

Welcome!

This repository contains the code to reproduce the figures in our publication:

**Marius Winkler, Grégory Dumont, Eckehard Schoell, and Boris Gutkin (2021):**  
*Phase response approaches to neural activity models with distributed delay*  
Published in *Biological Cybernetics*, December 2021.  
[👉 Read the paper](https://link.springer.com/article/10.1007/s00422-021-00910-9)  
📄 DOI: [10.1007/s00422-021-00910-9](https://doi.org/10.1007/s00422-021-00910-9)

---

## Getting Started

To get everything up and running, follow these steps:

### 1. Clone the repository

```bash
git clone https://github.com/mariuswinkler/WINKLER_PRC_paper.git
cd WINKLER_PRC_paper
```

### 2. Create the Conda environment

```bash
conda env create -f environment.yml
```

### 3. Activate the environment

```bash
conda activate WINKLER_PRC_paper
```

### 4. Register the environment as a Jupyter kernel

```bash
python -m ipykernel install --user --name=WINKLER_PRC_paper --display-name "Python (WINKLER_PRC_paper)"
```

---

## Running the Notebooks

You can run each notebook individually, or use the `main.sh` script in the `scripts/` directory to automate and manage execution — either locally or via SLURM.

### Script: `main.sh`

This script allows for flexible configuration, including cluster submission via SLURM or local execution.

#### Usage

```bash
./main.sh --figures=2,3 --mode=slurm --phase=compute [--debug]
./main.sh --figures=2,3 --mode=local --phase=plotting [--debug]
```

#### 🛠 Options

| Option           | Description                                                                 |
|------------------|-----------------------------------------------------------------------------|
| `--figures=...`  | Comma-separated list of figure numbers to generate                          |
| `--mode=...`     | Execution mode: `local` or `slurm`                                          |
| `--phase=...`    | Workflow phase: `compute` (raw processing) or `plotting` (final figure gen) |
| `--env=...`      | (Optional) Specify a custom conda environment                               |
| `--debug`        | (Optional) Print commands instead of executing them                         |

#### Notes

- For **Figures 5–7**, a *sigma sweep* is performed, and each sigma value is handled in a separate job.
- The sweep is executed only once, even if multiple figures (5–7) are selected at the same time.

---

## Directory Structure

```
├── environment.yml         # Conda environment definition
├── notebooks/              # Jupyter notebooks for each figure and model
├── scripts/
│   └── main.sh             # Main script to run or schedule notebooks
├── data/                   # (Ignored) Folder for input data, if applicable
└── output/                 # (Ignored) Folder for generated outputs
```

---

## Cleaning Up

To remove the Conda environment:

```bash
conda env remove --name WINKLER_PRC_paper
```

---

## Acknowledgements

If you use this code or build on this work, please consider citing the original paper.

Enjoy exploring neural activity with distributed delays!
