import os

def dump_dir_structure(source_dir, output_file):
    with open(output_file, 'w') as outfile:
        for root, dirs, files in os.walk(source_dir):
            # Skip certain directories if needed
            if "venv" in dirs:
                dirs.remove("venv")
            # Write the directory path
            outfile.write(f"Directory: {root}\n")
            # Write the files in the current directory
            for file in files:
                outfile.write(f"\t{file}\n")
            outfile.write("\n")

# Set the directory where you want to dump the structure
source_directory = '../'
# Set the path for the output file
output_file_path = 'directory_structure.txt'

dump_dir_structure(source_directory, output_file_path)
