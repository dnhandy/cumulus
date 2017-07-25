import signal
import sys
import time

paused = 0

def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

def pause_handler(signal, frame):
    paused = 1
    eprint ("I paused!")


signal.signal(signal.SIGUSR1, pause_handler)

my_number = 1

while (my_number <= 100 and paused == 0):
    print (my_number, " ", paused)
    time.sleep(1)
    my_number = my_number + 1
