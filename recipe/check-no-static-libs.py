import json
import os
import sys
from pathlib import Path


package = sys.argv[1]
record = next(
    (Path(os.environ["PREFIX"]) / "conda-meta").glob(f"{package}-*.json"), None
)
if record is None:
    raise SystemExit(f"Could not find {package} package record")

bad = []
for path in json.loads(record.read_text()).get("files", []):
    lower = path.lower()
    if lower.endswith(".a") or (
        lower.endswith(".lib") and not lower.endswith(".dll.lib")
    ):
        bad.append(path)

if bad:
    raise SystemExit(
        f"Unexpected static libraries found in {package} package:\n  "
        + "\n  ".join(bad)
    )
