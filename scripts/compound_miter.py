"""Compound miter angle calculator for an N-sided tilted box.

Conventions (per https://jansson.us/jcompound.html):
  N = number of sides
  T = side tilt from vertical, in degrees
      T = 0  -> sides straight up
      T > 0  -> box splays outward (top wider than bottom)
      T < 0  -> walls slope inward (top narrower than bottom)
"""

import argparse
import json
import math


def compound_miter(n: int, tilt_deg: float) -> dict:
    if n < 3:
        raise ValueError("N must be at least 3")

    half_seg_deg = 180.0 / n
    half_seg = math.radians(half_seg_deg)
    t = math.radians(tilt_deg)

    cos_dihedral = 2.0 * math.cos(t) ** 2 * math.sin(half_seg) ** 2 - 1.0
    cos_dihedral = max(-1.0, min(1.0, cos_dihedral))
    dihedral_angle = math.degrees(math.acos(cos_dihedral))

    blade_tilt_miter = 90.0 - dihedral_angle / 2.0
    miter_angle = math.degrees(math.atan(math.sin(t) * math.tan(half_seg)))
    miter_complement = 90.0 - miter_angle

    if tilt_deg > 0:
        lean = "outward"
    elif tilt_deg < 0:
        lean = "inward"
    else:
        lean = "vertical"

    return {
        "inputs": {"N": n, "tilt_from_vertical_deg": tilt_deg},
        "lean_direction": lean,
        "blade_tilt_miter_deg": round(blade_tilt_miter, 4),
        "miter_angle_deg": round(miter_angle, 4),
        "miter_complement_deg": round(miter_complement, 4),
        "dihedral_angle_deg": round(dihedral_angle, 4),
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--n", type=int, default=4, help="number of sides (default: 4)")
    parser.add_argument(
        "--tilt",
        type=float,
        default=0.0,
        help="side tilt from vertical in degrees (default: 0 = vertical sides)",
    )
    args = parser.parse_args()

    print(json.dumps(compound_miter(args.n, args.tilt), indent=2))


if __name__ == "__main__":
    main()
