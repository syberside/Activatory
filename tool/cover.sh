#!/bin/bash

# Fast fail the script on failures.
set -e

pub global activate dart_coveralls

ls

dart_coveralls report -C -E -T --retry=1 --token=$coverallsToken