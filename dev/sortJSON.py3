#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# vim:fenc=utf-8
#
# Filename: sortJSON.py3
# Author:   KuoE0 <kuoe0.tw@gmail.com>
#
# Copyright (C) 2017
#
# Distributed under terms of the MIT license.

"""

"""

import json
import sys
from collections import OrderedDict

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: sortJSON.py3 [package file]")
        exit(1)

    filename = sys.argv[1]
    sorted_data = None

    with open(filename) as f:
        data = json.load(f, object_pairs_hook=OrderedDict)
        sorted_data = sorted(data, key=lambda k: k['name'].casefold())
        sorted_data = json.dumps(sorted_data, indent=2)
    # clear file content
    open(filename, 'w').close()

    with open(filename, 'w') as f:
        f.write(sorted_data)
        f.write('\n')
