#!/bin/bash

# Fast fail the script on failures.
set -e

if ! [[ -z "${TRAVIS_TAG}" ]]; then
    echo "No TRAVIS_TAG found: $TRAVIS_TAG"
    exit 0
fi

pub global activate dart_coveralls

dart_coveralls report --debug -C -E -T --retry=1 --token=$coverallsToken ./test/activatory_test.dart
