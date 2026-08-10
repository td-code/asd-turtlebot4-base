#!/bin/bash

# Copyright (c) 2025, Thao Dang, University of Applied Sciences Esslingen, Germany
# SPDX-License-Identifier: BSD-3-Clause

# move to doc directory
cd ../doc

DIR=".mkdocs_venv"
if [ -d "$DIR" ]; then
    echo "venv for mkdocs exists. Activating."
    source $DIR/bin/activate
else
    echo "mkdocs_venv does not exist. Creating venv."
    # create venv
    python3 -m venv .mkdocs_venv
    source $DIR/bin/activate
    # install pip
    python -m ensurepip --default-pip
    pip install --upgrade pip
    # install mkdocs
    pip install mkdocs mkdocs-material mkdocs-jupyter
fi

echo "Publishing documentation"
mkdocs serve