clear

# If you cannot understand this, read Bash_Shell_Scripting#if_statements again.
if (whiptail --title "PlexGuide Installer/Upgrader" --yesno "Do You Agree to Install / Upgrade PlexGuide?" 8 45) then

###################### Install Depdency Programs ###############

    clear
    echo "PlexGuide Pre-Installer"
    echo ""
    echo "1. Conducting a System Update (Please Wait)"
    yes | apt-get update 1>/dev/null 2>&1
    echo "2. Installing Software Properties Common (Please Wait)"
    yes | apt-get install software-properties-common 1>/dev/null 2>&1
    echo "3. Pre-Install for Ansible Playbook (Please Wait)"
    yes | apt-add-repository ppa:ansible/ansible 1>/dev/null 2>&1
    apt-get update -y 1>/dev/null 2>&1
    apt-get install ansible -y 1>/dev/null 2>&1
    apt install python-pip -y 1>/dev/null 2>&1
    pip install docker 1>/dev/null 2>&1
    echo "4. Installing Ansible Playbook & Supporting Components (Please Wait)"
    yes | apt-get update 1>/dev/null 2>&1
    echo "5. Installing Dependicies - Please Wait"
    echo
    ansible-playbook /opt/plexguide/ansible/plexguide.yml --tags preinstall
    echo ""
    echo "6. Installing Supporting Programs - Directories & Permissions (Please Wait)"

   ansible-playbook /opt/plexguide/ansible/plexguide.yml --tags folders
   ansible-playbook /opt/plexguide/ansible/plexguide.yml --tags label
######################################################### For RCLONE

echo "7. Pre-Installing RClone & Services (Please Wait)"

#Installing RClone and Service
  bash /opt/plexguide/scripts/startup/rclone-preinstall.sh 1>/dev/null 2>&1

#Lets the System Know that Script Ran Once
  touch /var/plexguide/basics.yes 1>/dev/null 2>&1
  touch /var/plexguide/version.5 1>/dev/null 2>&1

echo "8. Pre-Installing PlexDrive & Services (Please Wait)"

#Installing MongoDB for PlexDrive
  bash /opt/plexguide/scripts/startup/plexdrive-preinstall.sh 1>/dev/null 2>&1

  echo "9. Installing Docker & Docker Compose (Please Standby)"

# Install Docker and Docker Composer / Checks to see if is installed also

  #curl -sSL https://get.docker.com | sh 1>/dev/null 2>&1
  #curl -L https://github.com/docker/compose/releases/download/1.18.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose 1>/dev/null 2>&1
  #chmod +x /usr/local/bin/docker-compose 1>/dev/null 2>&1
  ansible-playbook /opt/plexguide/ansible/plexguide.yml --tags docker
  #pip install docker 1>/dev/null 2>&1

  echo "10. Installing Portainer & Reverse Proxy (Please Wait)"

# Installs Portainer
  ansible-playbook /opt/plexguide/ansible/plexguide.yml --tags portainer
# Instlls Reverse Prox
  ansible-playbook /opt/plexguide/ansible/test.yml --tags nginx
# Remove NGINX if it exists

############################################# Install a Post-Docker Fix ###################### START

  echo "11. Installing DockerFix & Service Activation"

  ansible-playbook /opt/plexguide/ansible/plexguide.yml --tags dockerfix

  echo "12. Installing Watcher"

  ansible-playbook /opt/plexguide/ansible/plexguide.yml --tags watchtower

  file="/var/plexguide/donation.yes"
  if [ -e "$file" ]
    then
        echo "" 1>/dev/null 2>&1
    else
        echo "13. Donation Information - Coming Up"
        echo ""
        read -n 1 -s -r -p "Press any key to continue "
        bash /opt/plexguide/scripts/menus/donate-menu.sh
    fi

   rm -r /var/plexguide/dep* 1>/dev/null 2>&1
   touch /var/plexguide/dep30.yes

############################################# Install a Post-Docker Fix ###################### END

else
    echo "Install Aborted - You Failed to Agree to Install the Program!"
    echo
    echo "You will be able to browse the programs but doing anything will cause"
    echo "problems! Good Luck!"
    echo
    read -n 1 -s -r -p "Press any key to continue "
fi

clear