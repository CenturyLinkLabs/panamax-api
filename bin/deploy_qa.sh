#!/bin/bash

ssh root@8.22.8.121 "cd panamax-vagrant; git pull; ./setup.sh -op=reinstall; cd ~; ./commit.sh; ./runscope.sh"
