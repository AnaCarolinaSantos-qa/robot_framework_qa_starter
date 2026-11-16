"""Generate a Robot Framework Dashboard from output.xml files."""

from __future__ import annotations

import argparse
import shutil
import subprocess
import sys
from pathlib import Path


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", type=Path, default=Path("results"), help="Folder to scan recursively for output XML files")
    parser.add_argument("--database", type=Path, default=Path("results/dashboard/robot_results.db"))
    parser.add_argument("--output", type=Path, default=Path("results/dashboard/robot_dashboard.html"))
    args = parser.parse_args()

    if shutil.which("robotdashboard") is None:
        parser.error("robotdashboard não encontrado; instale com: python -m pip install -r requirements-dashboard.txt")

    output_files = sorted(args.input.rglob("output.xml"))
    if not output_files:
        parser.error(f"Nenhum output.xml encontrado em {args.input}")

    args.database.parent.mkdir(parents=True, exist_ok=True)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    command = ["robotdashboard"]
    for output_file in output_files:
        command.extend(["-o", str(output_file)])
    command.extend(
        ["-d", str(args.database), "-n", str(args.output), "--offlinedependencies", "-u", "true"]
    )
    return subprocess.run(command, check=False).returncode


if __name__ == "__main__":
    sys.exit(main())
