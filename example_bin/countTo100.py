#!/usr/bin/env python3

import cumulus
import time

paused = False

def pause_handler(*args):
    global paused
    paused = True

cumulus.parse_args("Count to 100")
cumulus.setPauseHandler(pause_handler)

cumulus.log("Input Directory: ", cumulus.input_dir)
cumulus.log("Output Directory: ", cumulus.output_dir)
cumulus.log("State File: ", cumulus.state_file)
cumulus.log("Resume: ", cumulus.resume)
cumulus.log("InputFiles: ", cumulus.input_files)

my_number = 1
while (my_number <= 100 and paused == False):
    print (my_number, " ", paused)
    time.sleep(1)
    my_number = my_number + 1
