#!/bin/sh
vagrant destroy -f
vagrant up
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -vv playbook.yml -i .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory
