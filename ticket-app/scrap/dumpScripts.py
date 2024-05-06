import os

# Set the directory where your Python files are located
#os.chdir(os.path.dirname(__file__))
# Set the path for the output file
output_file_path = 'all_scripts_combined.txt'

def dump_py_files_to_file(source_dir, output_file):
    with open(output_file, 'w') as outfile:
        outfile.write("============== python files ==============\n")
        for root, dirs, files in os.walk(source_dir):
            # Skip "venv" directory
            if "venv" in dirs:
                dirs.remove("venv")
            for file in files:
                if file.endswith('.py') and not file=="dumpScripts.py" and not file=="__init__.py" and not file=="insert_initial_data.py":# or file.endswith(".html"):
                    file_path = os.path.join(root, file)
                    with open(file_path, 'r') as infile:
                        outfile.write(f"# {file_path}\n")
                        outfile.write(infile.read())
                        outfile.write("\n\n")
        outfile.write("============== SQL Queries ==============\n")
        for root, dirs, files in os.walk(source_dir):
            for file in files:
                if file.endswith(".sql") and not file=="queries.sql" and not file=="createMovieDB.sql" and not file=="ticketingDB.sql":
                    file_path = os.path.join(root, file)  # Corrected this line
                    with open(file_path, 'r') as infile:
                        outfile.write(f"# {file_path}\n")
                        outfile.write(infile.read())
                        outfile.write("\n\n")

dump_py_files_to_file('../', output_file_path)
