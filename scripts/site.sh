#!/usr/bin/env bash

# Just run the playbook, defaults to included sample inventory.
# Pass in any regular ansible-playbook commands.
#
# For example, us another inventory, limit hosts and set extra args:
# ./run.sh --inventory ~/my_inventory --limit kvmhost,guests -e virt_infra_state=undefined

DIR="$(dirname "$(readlink -f "${0}")")"
source /etc/os-release

ANSIBLE_GALAXY=ansible-galaxy
ANSIBLE_PLAYBOOK=ansible-playbook

if [[ "${ID,,}" == "centos" && "${VERSION_ID}" -eq "7" ]] ; then
	ANSIBLE_GALAXY=ansible-galaxy-3
	ANSIBLE_PLAYBOOK=ansible-playbook-3
fi

# Check for dependencies
if ! type ${ANSIBLE_PLAYBOOK} &>/dev/null ; then
	read -r -p "Ansible missing, install it? [y/N]: " answer
	if [[ "${answer,,}" != "y" && "${answer,,}" != "yes" ]] ; then
		echo "OK, please install it and retry."
		exit 1
	fi
	case "${ID,,}" in
		centos)
			if [[ "${VERSION_ID}" -eq "7" ]] ; then
				echo sudo yum -y install epel-release centos-release-ansible-29
				sudo yum -y install epel-release centos-release-ansible-29
				echo sudo yum -y install ansible-python3 python36-netaddr
				sudo yum -y install ansible-python3 python36-netaddr
			else
				echo sudo dnf -y install epel-release
				sudo dnf -y install epel-release
				echo sudo dnf -y install ansible python3-netaddr
				sudo dnf -y install ansible python3-netaddr
			fi
			;;
		fedora)
			echo sudo dnf -y install ansible
			sudo dnf -y install ansible python3-netaddr
			;;
		debian)
			echo "Installing Ansible from Ubuntu PPA..."
			echo sudo apt install -y gnupg2
			sudo apt install -y gnupg2
			echo "echo 'deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main' | sudo tee -a /etc/apt/sources.list"
			grep -q ansible /etc/apt/sources.list || echo 'deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main' | sudo tee -a /etc/apt/sources.list
			echo sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
			sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
			echo sudo apt update
			sudo apt update
			echo sudo apt install -y ansible python3-netaddr
			sudo apt install -y ansible python3-netaddr
			;;
		ubuntu)
			echo "Installing Ansible from PPA..."
			echo sudo apt install -y software-properties-common
			sudo apt install -y software-properties-common
			echo sudo apt-add-repository --yes --update ppa:ansible/ansible
			sudo apt-add-repository --yes --update ppa:ansible/ansible
			echo sudo apt install -y ansible python3-netaddr
			sudo apt install -y ansible python3-netaddr
			;;
		opensuse|opensuse-leap)
			echo sudo zypper install -y ansible python3-netaddr
			sudo zypper install -y ansible python3-netaddr
			;;
		*)
			echo "${ID} not supported, please install manually"
			exit 1
			;;
	esac
	if [[ "$?" -ne 0 ]]; then
		echo "Something went wrong, sorry."
		exit 1
	fi
	echo "Continuing with Ansible playbook!"
fi

${ANSIBLE_GALAXY} install --force -r "${DIR}/../ansible/requirements.yml"

exec ${ANSIBLE_PLAYBOOK} -i "${DIR}/../inventory" "${DIR}/../ansible/site.yml" -l swift "${@}"
