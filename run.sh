#!/bin/sh

vagrant up
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook playbook.yml -i .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory
