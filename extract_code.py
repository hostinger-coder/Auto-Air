import os

# --- Configuration ---
# The directory to extract files from. For Flutter, this is 'lib'.
SRC_DIR = 'lib'
# The name of the file where all the code will be saved.
OUTPUT_FILE = 'extracted_flutter_code.txt'
# Extensions of files to include.
ALLOWED_EXTENSIONS = ['.dart']
# Directories to ignore. Using a set for faster lookups.
IGNORED_DIRS = {'.dart_tool', 'build', '.idea', 'generated', 'test'}

def walk_and_extract(dir, file_contents_array):
    """
    Recursively walks a directory and collects the content of allowed files.
    """
    # os.walk is a generator that yields the root, dirs, and files for each directory
    for root, dirs, files in os.walk(dir, topdown=True):
        # This is an efficient way to prevent os.walk from recursing into ignored directories
        dirs[:] = [d for d in dirs if d not in IGNORED_DIRS]

        for file in files:
            # Check if the file has an allowed extension
            if any(file.endswith(ext) for ext in ALLOWED_EXTENSIONS):
                full_path = os.path.join(root, file)

                try:
                    # 1. Get the relative path to use in the header comment.
                    # We use '.' to make it relative to the script's execution directory.
                    relative_path = os.path.relpath(full_path, start='.')
                    # Normalize path separators for consistency (use '/' like in the node example)
                    relative_path = relative_path.replace(os.sep, '/')

                    # 2. Read the file content. 'utf-8' is crucial.
                    with open(full_path, 'r', encoding='utf-8') as f:
                        content = f.read()

                    # 3. Format the output block.
                    output_block = f"// ===== {relative_path} =====\n\n{content}\n"

                    # 4. Add the block to our array.
                    file_contents_array.append(output_block)

                    print(f"✅ Extracted: {relative_path}")

                except Exception as e:
                    print(f"❌ Error reading file {full_path}: {e}")


def main():
    """
    Main function to run the script.
    """
    print(f"Starting extraction from directory: \"{SRC_DIR}\"...")

    try:
        all_contents = []
        walk_and_extract(SRC_DIR, all_contents)

        # Join all the collected blocks with a couple of newlines for separation.
        final_output = "\n".join(all_contents)

        # Write the combined content to the output file.
        with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
            f.write(final_output)

        print(f"\n🎉 Success! All code has been extracted to \"{OUTPUT_FILE}\".")

    except FileNotFoundError:
        print(f"❌ Error: The source directory \"{SRC_DIR}\" was not found.")
        print("Please make sure you are running this script from your project's root directory.")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")

# This ensures the main function is called only when the script is executed directly
if __name__ == "__main__":
    main()