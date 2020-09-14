#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# vim:fenc=utf-8
#
# Filename: add_brew_taps.py3
# Author:   KuoE0 <kuoe0.tw@gmail.com>
#
# Copyright (C) 2018
#
# Distributed under terms of the MIT license.

"""

"""
import os


def run_system_cmd(cmd):
    print(cmd)
    os.system(cmd)


tap_list = ["homebrew/cask",
            "homebrew/cask-versions",
            "homebrew/cask-fonts",
            "railwaycat/emacsmacport"]

for tap in tap_list:
    cmd = ' '.join(['brew', 'tap', tap])
    run_system_cmd(cmd)

run_system_cmd("brew update")
