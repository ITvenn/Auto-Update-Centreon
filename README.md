
---

# Mise à jour automatique de Centreon

## Description
Ce script Bash permet de mettre à jour automatiquement Centreon vers une version souhaitée. Il offre également une option pour sauvegarder la base de données avant la mise à jour.
Script testé sur une montée en version de centreon de la version 23.10 vers 24.04.

## Auteur
Vincent HAMEL

## Prérequis
- Système d'exploitation basé sur Debian (comme Ubuntu)
- Accès root ou sudo
- Centreon déjà installé
- Connexion internet pour accéder aux dépôts Centreon

## Utilisation
1. Clonez le dépôt GitHub contenant ce script :
    ```sh
    git clone <URL_DU_DEPOT_GITHUB>
    cd <REPERTOIRE_DU_DEPOT>
    ```

2. Donnez les permissions d'exécution au script :
- Version Central
    ```sh
    chmod +x script_upgrade_centreon.bash
    ```
- Version Poller
    ```sh
    chmod +x script_upgrade_poller.bash
    ```

3. Exécutez le script :
- Version Central
    ```sh
    ./script_upgrade_centreon.bash
    ```
- Version Poller
    ```sh
    ./script_upgrade_poller.bash
    ```
## Fonctionnalités
- **Demande de la version de Centreon souhaitée** : Le script vous invite à entrer la version souhaitée de Centreon.
- **Confirmation de la mise à jour** : Vous devez confirmer la mise à jour avant qu'elle ne commence.
- **Option de sauvegarde de la base de données** : Avant la mise à jour, le script propose de sauvegarder la base de données.
- **Ajout des dépôts Centreon** : Les dépôts pour la version spécifiée de Centreon sont ajoutés à la liste des sources APT.
- **Mise à jour des paquets** : Le script met à jour Centreon et ses composants.
- **Redémarrage des services** : Les services liés à Centreon sont redémarrés pour appliquer les changements.
- **Suppression du script** : Par mesure de sécurité, le script se supprime après exécution.

## Avertissements
- Assurez-vous d'avoir une sauvegarde récente de vos données avant d'exécuter ce script.
- Testez ce script dans un environnement de test avant de l'exécuter en production.

