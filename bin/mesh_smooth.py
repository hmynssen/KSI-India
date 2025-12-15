"""Mesh Smooth Utility

Applies HC Laplacian and Taubin smoothing filters to an input mesh.

Heitor Gessner,
10/12/2025
"""
import argparse
import sys
import os

import pymeshlab as ml


def simplify_mesh(input_filepath: str, output_filepath: str, max_vertices: int = 100000):
    """
    Loads a mesh, applies HC Laplacian and Taubin smoothing filters, 
    and saves the resulting mesh.

    :param input_filepath: Path to the input mesh file (e.g., in.stl).
    :param output_filepath: Path to save the output mesh file.
    """
    try:
        ms = ml.MeshSet()
        print(f"Loading mesh from: {input_filepath}")
        ms.load_new_mesh(input_filepath)
        ms.apply_filter(
            'apply_coord_hc_laplacian_smoothing',
        )
        ms.apply_filter(
            'apply_coord_taubin_smoothing',
        )
            

        print(f"Saving mesh to: {output_filepath}")
        ms.save_current_mesh(output_filepath)
        print("Done.")

    except Exception as e:
        print(f"An error occurred: {e}", file=sys.stderr)
        sys.exit(1)

def main():
    parser = argparse.ArgumentParser(
        prog='Mesh Simplification Utility',
        description=__doc__,
        formatter_class=argparse.RawTextHelpFormatter
    )
    
    parser.add_argument('-i', '--input', required=True, help='Input mesh file path (e.g., in.stl)')
    parser.add_argument('-o', '--outdir', default='./', help='Output directory path')
    parser.add_argument('-s', '--save', default='simplified_mesh.stl', help='Name of the output file (e.g., out.stl)')
    
    args = parser.parse_args()
    os.makedirs(args.outdir, exist_ok=True)
    output_path = os.path.join(args.outdir, args.save)
    simplify_mesh(args.input, output_path)

if __name__ == "__main__":
    if len(sys.argv) > 1:
        main()
    else:
        print("Error: No input arguments provided.", file=sys.stderr)
        print("Usage: python3 mesh_simplifier.py -i <input_path> -o <output_dir> -s <output_name>", file=sys.stderr)
        sys.exit(1)