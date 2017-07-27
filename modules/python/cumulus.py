import signal
import sys
import os
import argparse

input_dir = None
input_files = []
output_dir = None
state_file = None
resume = False

def setPauseHandler(pause_handler):
    signal.signal(signal.SIGUSR1, pause_handler)

def log(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

def parse_args(program_description):
    global input_dir
    global input_files
    global output_dir
    global state_file
    global resume

    parser = argparse.ArgumentParser(program_description)
    parser.add_argument('-i', '--input-dir', dest='input_dir', help='Directory containing input files')
    parser.add_argument('-o', '--output-dir', dest='output_dir', help='Directory for storing output files, if any')
    parser.add_argument('-s', '--state-file', dest='state_file', help='Path to file containing state, if resuming, or to write state to in case of a pause')
    parser.add_argument('-r', '--resume', action='store_true', default=False, help='Whether to resume from a previously paused state')

    args = parser.parse_args()

    input_dir = args.input_dir
    output_dir = args.output_dir
    state_file = args.state_file
    resume = args.resume

    if (os.path.exists(input_dir)):
        input_files = [f for f in os.listdir(input_dir) if os.path.isfile(os.path.join(input_dir, f))]
