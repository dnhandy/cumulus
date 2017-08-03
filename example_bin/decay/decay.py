#!/usr/bin/env python3

import cumulus
import time
import json
import os

paused = False
config = None

def pause_handler(*args):
    global paused
    paused = True
    cumulus.log("Received PAUSE command. Pausing...")

def concave_lambda(epoch):
    lambda_conf = config['lambda']
    l_min = lambda_conf['min']
    l_max = lambda_conf['max']
    max_epochs = config['epochs']

    # The decay rate is the (E-1) root of min/max
    decay_rate = (l_min / l_max) ** (1 / (max_epochs - 1))

    return l_max * decay_rate ** (epoch - 1)

def convex_lambda(epoch):
    lambda_conf = config['lambda']
    l_min = lambda_conf['min']
    l_max = lambda_conf['max']
    max_epochs = config['epochs']

    # The decay rate is the (E-1) root of (1 + max - min)
    decay_rate = (1 + l_max - l_min) ** (1 / (max_epochs - 1))

    return 1 + l_max - decay_rate ** (epoch - 1)

def sigmoid_lambda(epoch):
    lambda_conf = config['lambda']
    return (
        lambda_conf['min'] + (lambda_conf['max'] - lambda_conf['min']) /
        (1 + lambda_conf['rate'] ** (epoch - lambda_conf['inflection_point']))
    )

def linear_lambda(epoch):
    lambda_conf = config['lambda']
    # This function represents a line going through (1, MAX) and (MAX_EPOCHS, MIN)
    # let's build this in "y = mx + b" notation, where y is the resulting lambda
    # value, x is the epoch number, m is the slope, and b is the y-intercept
    m = (lambda_conf['min'] - lambda_conf['max']) / (config['epochs'] - 1)
    b = lambda_conf['max'] - m

    return m * epoch + b

def constant_lambda(epoch):
    return config['lambda']['max']

lambda_profiles = {
    "concave" : concave_lambda,
    "constant" : constant_lambda,
    "convex" : convex_lambda,
    "linear" : linear_lambda,
    "sigmoid" : sigmoid_lambda
}

cumulus.parse_args("Test decay function")
cumulus.setPauseHandler(pause_handler)

cumulus.log('Beginning work')

if ('config.json' in cumulus.input_files):
    with open(os.path.join(cumulus.input_dir, "config.json")) as json_config:
        config = json.load(json_config)

    start_epoch = 1
    max_epochs = config['epochs']

    if (cumulus.resume):
        with open(cumulus.state_file, 'r') as state_file:
            start_epoch = int(state_file.readline())

    if (config['lambda']['profile'] in lambda_profiles):
        for epoch in range(start_epoch, max_epochs + 1):
            if (paused):
                with open(cumulus.state_file, 'w') as state_file:
                    state_file.write(str(epoch))
                break;

            if (epoch % 20 == 0):
                cumulus.log('Heartbeat: ', epoch)
            lambda_val = lambda_profiles[config['lambda']['profile']](epoch)
            if ('reflected' in config['lambda'] and config['lambda']['reflected']):
                lambda_val = config['lambda']['max'] + config['lambda']['min'] - lambda_val

            #print (epoch, ", ", lambda_val)
            print (epoch, ',', concave_lambda(epoch), ',', convex_lambda(epoch), ',', sigmoid_lambda(epoch))

            time.sleep(0.5)

            #TODO: Run the network with this lambda
        with open(os.path.join(cumulus.output_dir, 'test1.txt'), 'w') as file1:
            file1.write("This was a test")
        with open(os.path.join(cumulus.output_dir, 'test2.txt'), 'w') as file2:
            file2.write("This was another test")
    else:
        cumulus.log("unknown profile: ", config['lambda']['profile'])
        exit(2)

else:
    cumulus.log("Config file not found: config.json")
    exit(1)
