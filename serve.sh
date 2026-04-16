#!/usr/bin/env bash

# Run the python server
python -mhttp.server -d public 1234 &
# Rebuild public folder when content dir changes.
find content | entr make
