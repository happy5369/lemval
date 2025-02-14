#!/usr/bin/python3

import sys
import subprocess
import ast

# setdefault(key, 0) returns the value of the key if it exists, or sets it to 0 and returns 0 if it doesn't exist.
def update_dictionary(my_dict, key):
    my_dict[key] = my_dict.setdefault(key, 0) + 1
    return my_dict
    
    
    
if len(sys.argv) == 1:
    print("Need args! How many epochs?")
    sys.exit()

epochs=sys.argv[1]

# Run the shell script and capture the output
result = subprocess.run(['./val_participation_check.sh', epochs], capture_output=True, text=True)
#print(result)

output = result.stdout.strip()
lines = output.splitlines()
my_dict = {}
for line in lines:
    # Split the string into the key and the list content
    epoch, val_list = line.split(']', 1)[0].split('[')

    # Clean up the key and list content
    epoch = epoch.strip('| ')
    val_list = val_list.strip()
    values = val_list.split(", ")

    for value in values:
        my_dict = update_dictionary(my_dict, int(value))  

print(f"The last {epochs} epochs - {len(my_dict)} vals")
for key, value in dict(sorted(my_dict.items())).items():
    print(f"{key:3}: {value:{len(epochs)}} ({(value/int(epochs)):.2%})")
    
