from pathlib import Path
import yaml

ROOT = Path(__file__).resolve().parents[2]


def load_performance_config():
    """Load the main performance configuration YAML file."""
    config_path = ROOT / "config" / "config.yaml"
    with open(config_path, "r", encoding="utf-8") as fh:
        return yaml.safe_load(fh)


def get_performance_scenario(name):
    """Return configuration for a given scenario name.

    If the scenario does not exist, an empty dict is returned.
    """
    data = load_performance_config() or {}
    scenarios = data.get("test_scenarios", {})
    return scenarios.get(name, {})


if __name__ == "__main__":
    import pprint
    pprint.pprint(load_performance_config())
