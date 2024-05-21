#!/bin/bash

# --------------------------------------------------------------------------------
# Auteur : HAMEL Vincent
#
# Description :
# Script de mise à jour automatique du Poller Centreon vers la version souhaitée.
#
# --------------------------------------------------------------------------------

# Récuperation du chemin ou est executer le script
chemin=$(pwd);

# Récupération de la version PHP utilisée
version_php=$(php -r 'echo phpversion();' | cut -d '.' -f 1,2)

# Choix de la version souhaité
echo -n "Veuillez entrer le numero de version Centreon souhaité dans le format suivant X.X"
echo
read version
echo "Voulez-vous vraiment passer à la version ${version} de Centreon ? (o/n)"
read reponse
if [ "$reponse" = "o" ]; then
  echo "Mise à jour vers la version ${version}..."

  # Mise à jour de Centreon
  echo "deb https://packages.centreon.com/apt-standard-${version}-stable/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/centreon.list && echo "Ajout du dépot Centreon reussi !" || { echo -e "\E[31mErreur : échec ajout dépot Centreon.\E[0m"; exit 1; }
  echo "deb https://packages.centreon.com/apt-plugins-stable/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/centreon-plugins.list
  wget -O- https://apt-key.centreon.com | gpg --dearmor | tee /etc/apt/trusted.gpg.d/centreon.gpg > /dev/null 2>&1
  apt update

  # Arrêt du processus Centreon Broker
  systemctl stop cbd

  # Suppression des fichiers de rétention présents
  rm /var/lib/centreon-broker/* -f

  # Videz le cache
  apt clean all
  apt update

  # Mise à jour de l'ensemble des composants
  apt full-upgrade centreon -y

  # Finalisation de la mise à jour
  apt autoremove -y

  # Redémarrer le serveur Apache & Centreon pour appliquer les changements
  echo "Redémarrage de Centreon..."
  systemctl daemon-reload 
  systemctl restart php$version_php-fpm
  systemctl restart centreon cbd centengine gorgoned && echo "Centreon est maintenant à jour et en ligne !" || { echo -e "\E[31mErreur : échec du redémarrage de Centreon.\E[0m"; exit 1; }

  # Sécurité Suppression du script upgrade
  rm $chemin/script_upgrade_poller.bash && echo "Suppression du script upgrade !" || { echo -e "\E[31mErreur : échec suppression du script upgrade.\E[0m"; exit 1; }

else
  echo "Mise à jour annulée."
  exit 1  # Quitte le script si l'utilisateur répond "non"
fi
