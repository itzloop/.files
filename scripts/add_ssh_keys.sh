#!/usr/bin/env bash

set -e

# TODO check if ~/.vault/.ssh is empty otherwise cancel operation
# TODO rewrite this in an ansible-playbook
VAULT="$HOME/.vault"
SSH="$HOME/.ssh"
SSH_ARVHIVE="$VAULT/ssh.tar.gz"

# expand aliases so 'config' would be recognized
shopt -s expand_aliases
source ~/Dotfiles/.zsh_aliases # TODO move config alias somewhere else

echo "archiving $SSH => $SSH_ARVHIVE"
tar czf $SSH_ARVHIVE $SSH

echo "encrypting ~/.vault/ssh"
ansible-vault encrypt $SSH_ARVHIVE

echo "config add $SSH_ARVHIVE"
config add $SSH_ARVHIVE

echo "run 'config status' and 'config commit' to continue"
