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

# Choix de la version souhaité
echo -n "Veuillez entrer le numero de version Centreon souhaité dans le format suivant X.X"
read version
echo
echo "Voulez-vous vraiment passer à la version ${version} de Centreon ? (o/n)"
read reponse
if [ "$reponse" = "o" ]; then
    echo "Mise à jour vers la version ${version}..."

    # Sauvegarde de la base de données
    echo "Sauvegarde de la base de données ..."
    echo -n "Entrez le nom de la base de données à sauvegarder: "
    echo
    read database_name
    echo -n "Entrez le mot de passe MySQL pour l'utilisateur 'root': "
    echo
    read -s password
    # Dump mysql dans /tmp
    mysqldump -u root -p$password --databases "$database_name" > "/tmp/backup_${database_name}.sql" && echo "La sauvegarde de la base de données '$database_name' a été créée avec succès dans /tmp." || { echo -e "\E[31mErreur : échec de la sauvegarde de la base de données.\E[0m"; exit 1; }

    
    # Mise à jour de Centreon


    # Redémarrer le serveur Apache & Centreon pour appliquer les changements
    echo "Redémarrage de Centreon..."
    systemctl restart apache2 && echo "Centreon est maintenant à jour et en ligne !" || { echo -e "\E[31mErreur : échec du redémarrage de Centreon.\E[0m"; exit 1; }

    # Sécurité Suppression du script upgrade
    rm $chemin/script_upgrade_centreon.bash && echo "Suppression du script upgrade !" || { echo -e "\E[31mErreur : échec suppression du script upgrade.\E[0m"; exit 1; }

else
    echo "Mise à jour annulée."
    exit 1  # Quitte le script si l'utilisateur répond "non"
fi
