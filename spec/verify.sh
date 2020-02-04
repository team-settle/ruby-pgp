#!/bin/bash

BASE_DIR='.'

echo 'Current gpg home dir'
gpg --version

echo 'Cleanup existing keys'
rspec ${BASE_DIR}/spec/lib/pgp/gpg/runner_integration_spec.rb

echo 'List existing public keys'
gpg --quiet --batch --list-keys --fingerprint

echo 'List existing private keys'
gpg --quiet --batch --list-secret-keys --fingerprint


