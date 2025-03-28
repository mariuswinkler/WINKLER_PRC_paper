import matplotlib.pyplot as plt

def apply_plot_settings():
    """Apply global plot settings for Matplotlib."""
    SIZE = 25
    plt.rcParams['font.family'] = 'serif'
    plt.rcParams['mathtext.fontset'] = 'dejavuserif'  # or 'cm'
    plt.rcParams['mathtext.rm'] = 'serif'

    plt.rcParams['axes.titlesize'] = SIZE
    plt.rcParams['axes.labelsize'] = SIZE
    plt.rcParams['xtick.labelsize'] = SIZE
    plt.rcParams['ytick.labelsize'] = SIZE
    plt.rcParams['legend.fontsize'] = SIZE

    plt.rcParams['axes.spines.top'] = False
    plt.rcParams['axes.spines.right'] = False

    plt.rcParams['xtick.direction'] = 'in'
    plt.rcParams['ytick.direction'] = 'in'
    plt.rcParams['xtick.major.size'] = 10
    plt.rcParams['ytick.major.size'] = 10
    plt.rcParams['xtick.major.width'] = 0.5
    plt.rcParams['ytick.major.width'] = 0.5

    plt.close('all')


# Color definitions
EXC_COLOR = "#ff5000"  # Excitatory cells
INH_COLOR = "#005096"  # Inhibitory cells
