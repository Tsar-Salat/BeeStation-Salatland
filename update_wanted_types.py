import re
import os

# Directory containing the files
directory_path = r"c:\Users\Boneyards\Documents\Cloned Repos\BeeStation-Salatland\code\modules\cargo\bounties"

# Regex pattern to match wanted_types lists
pattern = r"wanted_types = list\(([^)]+)\)"
replacement = r"wanted_types = list(\1 = TRUE)"

# Iterate through all files in the directory
for root, _, files in os.walk(directory_path):
    for file_name in files:
        if file_name.endswith(".dm"):  # Only process .dm files
            file_path = os.path.join(root, file_name)

            # Read the file
            with open(file_path, "r", encoding="utf-8") as file:
                content = file.read()

            # Perform the replacement
            updated_content = re.sub(pattern, replacement, content)

            # Write the updated content back to the file
            with open(file_path, "w", encoding="utf-8") as file:
                file.write(updated_content)

            print(f"Processed: {file_path}")

print("Replacement complete!")
