import os
import subprocess
import argparse

def run_demo_on_folder(input_path, output_path):
    
    print ('--- Run Batch.py ---')

    root_path = '/home/cal/Documents/Cristian_S/mmdetection3d'
    input_path = os.path.join(root_path,input_path);

    # Itero su tutti i file nella cartella di input
    for filename in os.listdir(input_path):
        file_path = os.path.join(input_path, filename)

        # Salto se non è un file o se non è .bin
        if not os.path.isfile(file_path) or not filename.endswith(".bin"):
            continue

        print(f"Eseguo su: {file_path}")

        config_file = "configs/second/second_hv_secfpn_8xb6-amp-80e_kitti-3d-3class.py"
        #config_file = "configs/centerpoint/centerpoint_voxel0075_second_secfpn_8xb4-cyclic-20e_nus-3d.py"
        #config_file = "configs/pointpillars/pointpillars_hv_secfpn_8xb6-160e_kitti-3d-3class.py"
        #config_file = "configs/parta2/parta2_hv_secfpn_8xb2-cyclic-80e_kitti-3d-3class.py"
        
        checkpoint_file = "checkpoints/hv_second_secfpn_fp16_6x8_80e_kitti-3d-3class_20200925_110059-05f67bdf.pth"
        #checkpoint_file = "checkpoints/centerpoint_0075voxel_second_secfpn_dcn_circlenms_4x8_cyclic_20e_nus_20220810_025930-657f67e0.pth"
        #checkpoint_file = "checkpoints/hv_pointpillars_secfpn_6x8_160e_kitti-3d-3class_20220301_150306-37dc2420.pth"
        #checkpoint_file = "checkpoints/hv_PartA2_secfpn_2x8_cyclic_80e_kitti-3d-3class_20210831_022017-454a5344.pth"
        
        
        # Costruisco il comando
        cmd = [
            "/home/cal/miniconda3/envs/mmdet3d/bin/python",
            "demo/pcd_demo.py",
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