#!/bin/bash

BASE_DIR='.'

function cleanup() {
  echo 'Cleanup existing keys'
  rspec ${BASE_DIR}/spec/lib/pgp/gpg/runner_integration_spec.rb

  listKeys
}

function listKeys() {
  echo 'List existing public keys'
  gpg --quiet --batch --list-keys --fingerprint

  echo 'List existing private keys'
  gpg --quiet --batch --list-secret-keys --fingerprint
}

function sectionStart() {
    echo ''
    echo $1
    echo '================================================'
}

function sectionEnd() {
    echo '================================================'
    echo ''
}

sectionStart "Setup"
gpg --version
cleanup
sectionEnd


sectionStart 'Decrypt key without passphrase'
gpg --quiet --batch --import ${BASE_DIR}/spec/support/fixtures/private_key.asc
listKeys
cleanup
sectionEnd