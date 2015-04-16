import sys
import os
import re
from collections import defaultdict

input_file   = sys.argv[1]
output_file  = sys.argv[2]

def convert_alias(input_file):
	aliases = []
	with open(input_file) as f:
		for line in f:
			m = re.match(r"#ALIAS (zao.*) ({.*?})", line)
			if m:
				alias = m.group(0)
				alias = alias.replace("@","$").replace("(","{").replace(")","}")
				aliases.append(alias)
	aliases = sorted(aliases)
	return aliases

def write_results(aliases, output_file):
	with open(output_file, "w") as f:
		for alias in aliases:
			text_to_write = alias + "\n"
			f.write(text_to_write)

def main():
	aliases = convert_alias(input_file)
	write_results(aliases, output_file)
    
if __name__=='__main__':
    main()
					
					
				




