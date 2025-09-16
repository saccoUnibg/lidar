import os
import subprocess
import argparse

def run_demo_on_folder(input_path):

    print(input_path)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Batch runner per pcd_demo.py")
    parser.add_argument("--input", required=True, help="Cartella con i file .bin di input")

    args = parser.parse_args()

    run_demo_on_folder(
        input_path=args.input
    )