#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# vim:fenc=utf-8
#
# Filename: install.py3
# Author:   KuoE0 <kuoe0.tw@gmail.com>
#
# Copyright (C) 2018
#
# Distributed under terms of the MIT license.

"""

"""

import json
import os
import sys
import subprocess

install_cmd_collection = {
    'apt': ['sudo', 'apt', 'install', '-y'],
    'brew': ['brew', 'install'],
    'cask': ['brew', 'install'],
    'mas': ['mas', 'install'],
    'pip3': ['pip3', 'install']
}


def run_system_cmd(cmd):
    print(cmd)
    os.system(cmd)


def install(pkg_mgr, filename):
    with open(filename) as f:
        pkg_list = json.load(f)

        for pkg in pkg_list:

            if 'do_before' in pkg:
                for cmd in pkg['do_before']:
                    run_system_cmd(cmd)

            cmd = ' '.join(
                install_cmd_collection[pkg_mgr] + [pkg['id' if pkg_mgr == 'mas' else 'name']])

            # brew-specified action
            if pkg_mgr == 'brew':
                if 'args' in pkg:
                    cmd = ' '.join([cmd] + pkg['args'])
                # use `reinstall` to install with specified arguments again
                if pkg['name'] in subprocess.check_output(['brew', 'list']):
                    cmd = cmd.replace('install', 'reinstall')

            run_system_cmd(cmd)

            if 'do_after' in pkg:
                for cmd in pkg['do_after']:
                    run_system_cmd(cmd)


if __name__ == "__main__":
    if len(sys.argv) != 2:
        exit(1)
    pkg_mgr = sys.argv[1]
    install(pkg_mgr, "list-{0}.json".format(pkg_mgr))
