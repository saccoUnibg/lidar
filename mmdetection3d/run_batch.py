import os
import subprocess
import argparse

def run_demo_on_folder(input_path, output_path):

    # Itero su tutti i file nella cartella di input
    for filename in os.listdir(input_path):
        file_path = os.path.join(input_path, filename)

        # Salto se non è un file o se non è .bin
        if not os.path.isfile(file_path) or not filename.endswith(".bin"):
            continue

        print(f"Eseguo su: {file_path}")

        config_file = "configs/pointpillars/pointpillars_hv_secfpn_8xb6-160e_kitti-3d-3class.py"
        
        checkpoint_file = "checkpoints/hv_pointpillars_secfpn_6x8_160e_kitti-3d-3class_20220301_150306-37dc2420.pth"
        
        
        # Costruisco il comando
        cmd = [
            "python", "demo/pcd_demo.py",
            file_path,
            config_file,
            checkpoint_file,
            "--out-dir", output_path
        ]

        # Eseguo il comando
        subprocess.run(cmd)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Batch runner per pcd_demo.py")
    parser.add_argument("--input", required=True, help="Cartella con i file .bin di input")
    parser.add_argument("--output", required=True, help="Cartella di output")

    args = parser.parse_args()

    run_demo_on_folder(
        input_path=args.input,
        output_path=args.output
    )