# Simulation time settings
itr = 20000  # Number of iterations
dt = 0.005   # Time step

# Model constants
tau = 1
d = int(tau / dt)
sig = 0.1 

# Synaptic weights
wee, wei, wie, wii = 20, 21, 16, 6

# Input currents
ie, ii = 1.5, -0.5

# Initial conditions
E0 = 0 
I0 = 0 

ZE1 = -5
ZI1 = 1

# Coupling constant
C = 0.01

# Perturbation by direct method
impulse_stepsize = 0.07
impulse_power = 0.07
impulse_width = 1
