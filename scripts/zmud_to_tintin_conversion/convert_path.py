import sys
import os
import re
from collections import defaultdict

input_file   = sys.argv[1]
output_file  = sys.argv[2]

def load_directions(input_file):
	path_dirs = {}
	i = 0
	j = 0
	with open(input_file) as f:
		for line in f:
			m = re.match(r"#DIR (.{1,2})", line)
			if m:
				i = i + 1
				direction = m.group(1)[0]
				m2 = re.search(r"(\{.*?\})", line)
				if m2:
					j = j + 1
					direction_command = m2.group(0).replace("{", "").replace("}", "").split("|")[0]
					#print j, direction, direction_command
					path_dirs[direction] = direction_command
					print j, direction, path_dirs[direction]
	#print i
	#print j
	#print len(path_dirs)
	return path_dirs
				
def translate_path(path_dirs, input_file):
	pathes = {}
	temp_count = ""
	with open(input_file) as f:
		for line in f:
			m = re.match(r"#PATH (my_.*?) ", line)
			if m:
				path_name = m.group(1)
				m2 = re.search(r"(\{.*?\})", line)
				if m2:
					path_string = m2.group(0).replace("{", "").replace("}", "")
					new_path_string = ""
					for s in path_string:
						if s.isdigit():
							temp_count = temp_count + s
							continue
						else:
							if temp_count != "": #if previous one is a number
								for i in range(0, int(temp_count)):
									new_path_string = new_path_string + str(path_dirs[s]) + ";"
								temp_count = ""
							else:
								new_path_string = new_path_string + str(path_dirs[s]) + ";"
								
							"""new_path_string = new_path_string + "#%d " % (int(s))
						else:
							if s in path_dirs:
								new_path_string = new_path_string + str(path_dirs[s]) + ";"
							else:
								print path_name
								print "ERROR:" + s"""
				pathes[path_name] = new_path_string				
	return pathes
				
	
def write_results(pathes, output_file):
	with open(output_file, "w") as f:
		for key, value in sorted(pathes.items()):
			text_to_write = "#VARIABLE\t" + key + "\t{" + value + "}\n"
			f.write(text_to_write)

def main():
	#results = process_file(input_file)
	#write_results(results, output_file)
	path_dirs = load_directions(input_file)
	k = 0
	#for key, value in path_dirs.items():
		#print k, key, ":", value
		#k = k + 1
	print len(path_dirs)

	pathes = translate_path(path_dirs, input_file)
	#for key, value in pathes:
	#print k, key, ":", value
	
	write_results(pathes, output_file)
    
if __name__=='__main__':
    main()
					
					
				




