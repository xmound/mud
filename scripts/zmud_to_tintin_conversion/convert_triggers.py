import sys
import os
import re
from collections import defaultdict

input_file   = sys.argv[1]
output_file  = sys.argv[2]

def process_file(input_file):
	trigger_classes = defaultdict(list)
	with open(input_file) as f:
		for lines in f:
			line = lines.strip().split(" ")
			#line = unicode(line, "utf-8")
			if line[0] == "#TRIGGER":
				trigger_class = line[-2]
				trigger = " ".join(line[1:-2])
				trigger_classes[trigger_class].append(trigger)
	return trigger_classes
				
	
def write_results(trigger_list, output_file):
	with open(output_file, "w") as f:
		for classes, triggers in trigger_list.iteritems():
			text_to_write = """%s\n""" % (classes)
			f.write(text_to_write)
			for trigger in sorted(triggers):
				text_to_write = """#action\t%s\n""" % (trigger)
				f.write(text_to_write)
			text_to_write = """\n\n"""
			f.write(text_to_write)

def main():
    results = process_file(input_file)
    write_results(results, output_file)
    
if __name__=='__main__':
    main()
					
					
				




