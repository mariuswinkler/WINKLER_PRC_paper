def _format_filename(template, **kwargs):
    return template.format(**kwargs)
    
def get_params_for_filename(keys, namespace=None):
    if namespace is None:
        namespace = globals()
    return {k: namespace[k] for k in keys}

def get_filename(distribution: str, kind: str, **params):
    try:
        template = WCM_TEMPLATES[distribution][kind]
    except KeyError as e:
        raise ValueError(f"Unknown distribution or kind: {e}")
    return _format_filename(template, **params)

param_keys = [
    "itr", "dt", "tau", "sig", "wee", "wei", "wie", "wii",
    "ie", "ii", "E0", "I0", "ZE1", "ZI1", "C",
    "impulse_stepsize", "impulse_power", "impulse_width"
]

gaussian_lognormal_base_info = (
    "itr={itr}_dt={dt}_tau={tau}_sig={sig}_wee={wee}_wei={wei}_wie={wie}_wii={wii}_ie={ie}_ii={ii}"
)

discrete_base_info = (
    "itr={itr}_dt={dt}_tau={tau}_wee={wee}_wei={wei}_wie={wie}_wii={wii}_ie={ie}_ii={ii}"
)

direct_PRC_base_info = (
    "stepsize={impulse_stepsize}_impulse_power={impulse_power}_impulse_width={impulse_width}"
)

WCM_TEMPLATES = {
    "discrete": {
        "WCM":            f"WCM_DISCRETE_delay_{discrete_base_info}_E0={{E0}}_I0={{I0}}.npy",
        "PRC":            f"PRC_WCM_DISCRETE_delay_{discrete_base_info}_ZE1={{ZE1}}_ZI1={{ZI1}}.npy",
        "Normalized_PRC": f"Normalized_PRC_DISCRETE_delay_{discrete_base_info}_ZE1={{ZE1}}_ZI1={{ZI1}}.npy",
        "Direct_PRC":     f"Direct_PRC_WCM_DISCRETE_delay_{discrete_base_info}_{direct_PRC_base_info}.npy",
        "Coupled":        f"Coupled_WCM_DISCRETE_delay_{discrete_base_info}_C={{C}}.npy",
        "Interaction":    f"Interaction_Function_DISCRETE_delay_{discrete_base_info}_C={{C}}.npz"
    },
    "gaussian": {
        "WCM":            f"WCM_GAUSSIAN_delay_{gaussian_lognormal_base_info}_E0={{E0}}_I0={{I0}}.npy",
        "PRC":            f"PRC_WCM_GAUSSIAN_delay_{gaussian_lognormal_base_info}_ZE1={{ZE1}}_ZI1={{ZI1}}.npy",
        "Normalized_PRC": f"Normalized_PRC_GAUSSIAN_delay_{gaussian_lognormal_base_info}_ZE1={{ZE1}}_ZI1={{ZI1}}.npy",
        "Direct_PRC":     f"Direct_PRC_WCM_GAUSSIAN_delay_{gaussian_lognormal_base_info}_{direct_PRC_base_info}.npy",
        "Coupled":        f"Coupled_WCM_GAUSSIAN_delay_{gaussian_lognormal_base_info}_C={{C}}.npy",
        "Interaction":    f"Interaction_Function_GAUSSIAN_delay_{gaussian_lognormal_base_info}_C={{C}}.npz",
        "Bifurcation":    f"Bifurcation_data_{gaussian_lognormal_base_info}_ZE1={{ZE1}}_ZI1={{ZI1}}_C={{C}}.npy"
    },
    "lognormal": {
        "WCM":            f"WCM_LOGNORMAL_delay_{gaussian_lognormal_base_info}_E0={{E0}}_I0={{I0}}.npy",
        "PRC":            f"PRC_WCM_LOGNORMAL_delay_{gaussian_lognormal_base_info}_ZE1={{ZE1}}_ZI1={{ZI1}}.npy",
        "Normalized_PRC": f"Normalized_PRC_LOGNORMAL_delay_{gaussian_lognormal_base_info}_ZE1={{ZE1}}_ZI1={{ZI1}}.npy",
        "Direct_PRC":     f"Direct_PRC_WCM_LOGNORMAL_delay_{gaussian_lognormal_base_info}_{direct_PRC_base_info}.npy",
        "Coupled":        f"Coupled_WCM_LOGNORMAL_delay_{gaussian_lognormal_base_info}_C={{C}}.npy",
        "Interaction":    f"Interaction_Function_LOGNORMAL_delay_{gaussian_lognormal_base_info}_C={{C}}.npz",
        "Bifurcation":    f"Bifurcation_data_{gaussian_lognormal_base_info}_ZE1={{ZE1}}_ZI1={{ZI1}}_C={{C}}.npy"
    }
}





