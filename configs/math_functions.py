import numpy as np

def F(s):
    """Sigmoid activation function (Wilson-Cowan model)."""
    return 1 / (1 + np.exp(-s))

def lognormal(x, mu, sig): 
    """Lognormal distribution function."""
    return np.exp(-(((np.log(x) - mu) ** 2) / (2 * sig ** 2))) / (np.sqrt(2 * np.pi) * sig * x)

def gaussian(x, mu, sig):
    """Gaussian function."""
    return np.exp(-((x - mu) ** 2) / (2 * sig ** 2)) / (np.sqrt(2 * np.pi) * sig)
