# LAB-TOMCAT

## Documentation technique

Installation, configuration et déploiement d'une application Web avec Apache Tomcat sur CentOS 7.

**Réalisé par :** Insaf NEMRI

**Année :** 2026

---

## Environnement technique

| Élément | Version / valeur |
|---|---|
| Système d'exploitation | CentOS 7 |
| Java | OpenJDK 1.8.0_412 |
| Serveur Web | Apache Tomcat 9.0.120 |
| Utilisateur applicatif | `tomcat` |
| Répertoire d'installation | `/opt/tomcat` |
| Port HTTP | `8080` |
| Application | `demo` |

---

## 1. Introduction

Cette documentation présente les différentes étapes réalisées dans le cadre du laboratoire **LAB-TOMCAT**.

L'objectif principal est d'installer et de configurer **Apache Tomcat 9.0.120** sur un serveur **CentOS 7** avec **OpenJDK 8**.

Une application Web de démonstration appelée `demo` est ensuite créée et déployée dans Tomcat.

La documentation décrit également la configuration du service `systemd` permettant de gérer le serveur Tomcat.

Les captures d'écran réalisées pendant le laboratoire seront intégrées afin de présenter les différentes étapes de manière visuelle.

---

## Objectifs du laboratoire

Les objectifs du laboratoire sont les suivants :

- Installer Apache Tomcat sur une machine CentOS 7.
- Utiliser un compte applicatif dédié nommé `tomcat`.
- Configurer l'environnement Java nécessaire à Tomcat.
- Configurer le service Tomcat avec `systemd`.
- Déployer une application Web de démonstration.
- Vérifier le fonctionnement du serveur et de l'application.
- Documenter les différentes étapes de réalisation.
- Automatiser les actions d'installation et de configuration avec un script Shell et un fichier de configuration.

---

## Structure générale du laboratoire

Le laboratoire est organisé autour des composants suivants :

```text
CentOS 7
   |
   +-- OpenJDK 8
   |
   +-- Utilisateur applicatif : tomcat
   |
   +-- Apache Tomcat 9.0.120
   |      |
   |      +-- Port HTTP : 8080
   |      |
   |      +-- webapps/
   |             |
   |             +-- demo/
   |                    |
   |                    +-- index.html
   |
   +-- systemd
          |
          +-- tomcat.service
