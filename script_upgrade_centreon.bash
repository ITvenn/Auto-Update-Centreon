#!/bin/bash

# --------------------------------------------------------------------------------
# Auteur : HAMEL Vincent
#
# Description :
# Script de mise à jour automatique de Centreon vers la version souhaitée.
#
# --------------------------------------------------------------------------------

# Récuperation du chemin ou est executer le script
chemin=$(pwd);

# Récupération de la version PHP utilisée
version_php=$(php -r 'echo phpversion();' | cut -d '.' -f 1,2)

# Récupération de la version web serveur utilisée
# Vérifier si Apache2 est en cours d'exécution
if pgrep apache2 > /dev/null; then
  webserver="apache2"
# Vérifier si Nginx est en cours d'exécution
elif pgrep nginx > /dev/null; then
  webserver="nginx"
# Si aucun des deux n'est trouvé
else
  echo "aucun serveur web n'a été trouvé"
fi

# Choix de la version souhaité
echo -n "Veuillez entrer le numero de version Centreon souhaitée dans le format suivant X.X"
echo
read version
echo "Voulez-vous vraiment passer à la version ${version} de Centreon ? (o/n)"
read reponse
if [ "$reponse" = "o" ]; then
  echo "Mise à jour vers la version ${version}..."
  echo "Voulez-vous sauveguarder la base de données de Centreon ? (o/n)"
  read reponsebd1
  # Sauvegarde de la base de données
  if [ "$reponsebd1" = "o" ]; then
    echo "Sauvegarde de la base de données ..."
    echo -n "Entrez le nom de la base de données à sauvegarder: "
    echo
    read database_name
    echo -n "Entrez le mot de passe MySQL pour l'utilisateur 'root': "
    echo
    read -s password
    # Dump mysql dans /tmp
    mysqldump -u root -p$password --databases "$database_name" > "/tmp/backup_${database_name}.sql" && echo "La sauvegarde de la base de données '$database_name' a été créée avec succès dans /tmp." || { echo -e "\E[31mErreur : échec de la sauvegarde de la base de données.\E[0m"; exit 1; }
  else
    echo "la base de données Centreon ne sera pas sauvegardé"
    echo "Voulez-vous continuer ? (o/n)"
    read reponsebd2
    if [ "$reponsebd2" = "o" ]; then
      echo "Bypass de la sauvegarde de la base de données"
    else
      echo "Mise à jour annulée."
      exit 1  # Quitte le script si l'utilisateur répond "non"
    fi
  fi
    
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
  systemctl restart $webserver 
  systemctl restart centreon cbd centengine gorgoned && echo "Centreon est maintenant à jour et en ligne !" || { echo -e "\E[31mErreur : échec du redémarrage de Centreon.\E[0m"; exit 1; }

  # Sécurité Suppression du script upgrade
  rm $chemin/script_upgrade_centreon.bash && echo "Suppression du script upgrade !" || { echo -e "\E[31mErreur : échec suppression du script upgrade.\E[0m"; exit 1; }

else
  echo "Mise à jour annulée."
  exit 1  # Quitte le script si l'utilisateur répond "non"
fi
