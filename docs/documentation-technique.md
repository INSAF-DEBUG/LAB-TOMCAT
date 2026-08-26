# LAB-TOMCAT

## Documentation technique

### Installation, configuration et déploiement d'une application Web avec Apache Tomcat sur CentOS 7

**Réalisé par :** Insaf NEMRI
**Année :** 2026

---

# 1. Introduction

Le projet **LAB-TOMCAT** a pour objectif d'automatiser l'installation, la configuration et le déploiement d'un serveur Apache Tomcat sur une machine **CentOS 7**.

L'environnement utilisé est basé sur :

* CentOS 7 ;
* OpenJDK 8 ;
* Apache Tomcat 9.0.120 ;
* un utilisateur système dédié `tomcat` ;
* le service `systemd` ;
* une application Web de démonstration nommée `demo`.

L'installation est automatisée à l'aide du script :

```text
scripts/install-tomcat.sh
```

Les paramètres de l'installation sont centralisés dans :

```text
config/tomcat.conf
```

Cette organisation permet de séparer la configuration de la logique d'installation.

---

# 2. Objectifs du laboratoire

Les objectifs sont les suivants :

* installer Java OpenJDK 8 ;
* vérifier l'environnement Java ;
* créer un utilisateur dédié pour Tomcat ;
* installer Apache Tomcat 9.0.120 ;
* configurer les permissions ;
* déterminer automatiquement `JAVA_HOME` ;
* créer et configurer un service `systemd` ;
* activer et démarrer Tomcat ;
* déployer une application Web `demo` ;
* vérifier le port HTTP 8080 ;
* effectuer des tests HTTP ;
* automatiser les différentes étapes avec un script Shell.

---

# 3. Environnement technique

| Élément                | Version / valeur      |
| ---------------------- | --------------------- |
| Système d'exploitation | CentOS 7              |
| Java                   | OpenJDK 1.8.0_412     |
| Serveur Web            | Apache Tomcat 9.0.120 |
| Utilisateur            | `tomcat`              |
| Groupe                 | `tomcat`              |
| Répertoire             | `/opt/tomcat`         |
| Port HTTP              | `8080`                |
| Application            | `demo`                |

---

# 4. Structure du projet

Le projet GitHub est organisé de la manière suivante :

```text
LAB-TOMCAT/
│
├── README.md
│
├── architecture/
│   └── architecture.md
│
├── config/
│   └── tomcat.conf
│
├── docs/
│   └── documentation.md
│
└── scripts/
    └── install-tomcat.sh
```

### Rôle des répertoires

**`architecture/`**

Contient la description de l'architecture technique du laboratoire.

**`config/`**

Contient les paramètres utilisés par le script d'installation.

**`docs/`**

Contient la documentation technique détaillée.

**`scripts/`**

Contient les scripts Shell permettant d'automatiser l'installation.

---

# 5. Fichier de configuration

Le fichier :

```text
config/tomcat.conf
```

contient les paramètres principaux :

```bash
TOMCAT_VERSION="9.0.120"
TOMCAT_USER="tomcat"
TOMCAT_GROUP="tomcat"
TOMCAT_DIR="/opt/tomcat"
TOMCAT_PORT="8080"
APP_NAME="demo"
```

Le script charge automatiquement ce fichier avant de commencer l'installation.

Cette séparation permet de modifier les paramètres du laboratoire sans modifier directement le script.

---

# 6. Script d'installation

Le script principal est :

```text
scripts/install-tomcat.sh
```

Il doit être exécuté avec les privilèges administrateur.

Avant l'exécution, les droits peuvent être vérifiés avec :

```bash
chmod +x scripts/install-tomcat.sh
```

Puis le script est exécuté avec :

```bash
sudo bash scripts/install-tomcat.sh
```

---

# 7. Vérification des privilèges

Le script vérifie que l'installation est exécutée avec les privilèges `root`.

Si le script n'est pas exécuté avec les privilèges nécessaires, l'installation est interrompue.

Cette vérification permet d'éviter les erreurs lors de la création des utilisateurs, de l'installation des paquets et de la configuration de `systemd`.

---

# 8. Installation et vérification de Java

Tomcat nécessite Java pour fonctionner.

Le script vérifie la présence de la commande :

```bash
java
```

Si Java n'est pas installé, OpenJDK 8 est installé avec :

```bash
yum install -y java-1.8.0-openjdk-devel
```

La version installée est ensuite vérifiée :

```bash
java -version
```

La version utilisée dans le laboratoire est :

```text
OpenJDK 1.8.0_412
```

---

# 9. Détermination de JAVA_HOME

Le script détermine automatiquement le chemin du programme Java :

```bash
JAVA_BIN="$(readlink -f "$(command -v java)")"
```

Puis il détermine automatiquement la variable :

```bash
JAVA_HOME
```

Cette variable est utilisée dans la configuration du service `systemd`.

Cela évite de dépendre d'un chemin Java écrit manuellement dans le script.

---

# 10. Création de l'utilisateur Tomcat

Pour des raisons de sécurité, Tomcat ne doit pas fonctionner avec `root`.

Le script vérifie si l'utilisateur :

```text
tomcat
```

existe.

S'il n'existe pas, il est créé comme utilisateur système :

```bash
useradd --system \
    --home-dir /opt/tomcat \
    --shell /sbin/nologin \
    tomcat
```

L'utilisation d'un compte dédié limite les privilèges du serveur Tomcat.

---

# 11. Installation d'Apache Tomcat

La version utilisée est :

```text
Apache Tomcat 9.0.120
```

L'archive est téléchargée depuis l'archive officielle Apache :

```text
https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.120/bin/apache-tomcat-9.0.120.tar.gz
```

Le fichier est temporairement stocké dans :

```text
/tmp/apache-tomcat-9.0.120.tar.gz
```

Tomcat est ensuite installé dans :

```text
/opt/tomcat
```

---

# 12. Configuration des permissions

Après l'installation, les fichiers Tomcat appartiennent à l'utilisateur et au groupe :

```text
tomcat:tomcat
```

Les permissions sont configurées avec :

```bash
chown -R tomcat:tomcat /opt/tomcat
```

Les scripts Tomcat sont rendus exécutables :

```bash
chmod +x /opt/tomcat/bin/*.sh
```

---

# 13. Configuration du service systemd

Le script crée automatiquement :

```text
/etc/systemd/system/tomcat.service
```

Le service utilise :

```text
User=tomcat
Group=tomcat
```

Les variables principales sont :

```text
JAVA_HOME
CATALINA_HOME=/opt/tomcat
CATALINA_BASE=/opt/tomcat
```

Le démarrage et l'arrêt sont assurés par :

```text
/opt/tomcat/bin/startup.sh
/opt/tomcat/bin/shutdown.sh
```

Après création du service, `systemd` est rechargé :

```bash
systemctl daemon-reload
```

Le service est ensuite activé :

```bash
systemctl enable tomcat
```

---

# 14. Démarrage de Tomcat

Le script démarre le service avec :

```bash
systemctl restart tomcat
```

Le statut peut être vérifié avec :

```bash
systemctl status tomcat
```

Le résultat attendu est :

```text
Active: active (running)
```

---

# 15. Vérification du port HTTP

Apache Tomcat utilise le port :

```text
8080
```

La vérification peut être effectuée avec :

```bash
ss -lnt | grep 8080
```

Le port doit apparaître comme étant en écoute.

---

# 16. Déploiement de l'application demo

L'application de démonstration est nommée :

```text
demo
```

Elle est créée automatiquement dans :

```text
/opt/tomcat/webapps/demo
```

Le fichier principal est :

```text
/opt/tomcat/webapps/demo/index.html
```

Le contenu de la page est :

```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>LAB-TOMCAT</title>
</head>
<body>
    <h1>Bienvenue dans LAB-TOMCAT</h1>
    <p>Application de démonstration déployée sur Apache Tomcat.</p>
    <p>Serveur : CentOS 7</p>
</body>
</html>
```

Les permissions sont ensuite attribuées à :

```text
tomcat:tomcat
```

---

# 17. Test du serveur Tomcat

Le serveur est testé avec :

```bash
curl http://localhost:8080/
```

Une réponse HTTP doit être retournée par Tomcat.

---

# 18. Test de l'application

L'application est testée avec :

```bash
curl http://localhost:8080/demo/
```

Le résultat attendu contient notamment :

```text
Bienvenue dans LAB-TOMCAT
```

L'application est accessible localement à :

```text
http://localhost:8080/demo/
```

Si le serveur est accessible depuis une autre machine :

```text
http://ADRESSE_IP_DU_SERVEUR:8080/demo/
```

---

# 19. Validation automatique

Le script réalise également des tests de validation.

Il vérifie notamment :

* que le service Tomcat est actif ;
* que le port 8080 est accessible ;
* que Tomcat répond aux requêtes HTTP ;
* que l'application `demo` est accessible.

Si l'un des tests critiques échoue, le script signale une erreur.

---

# 20. Dépannage

## 20.1 Vérification du service

```bash
systemctl status tomcat
```

## 20.2 Vérification du port

```bash
ss -lnt | grep 8080
```

## 20.3 Vérification des fichiers Tomcat

```bash
ls -la /opt/tomcat
```

## 20.4 Vérification de l'application

```bash
ls -la /opt/tomcat/webapps/demo
```

## 20.5 Consultation des logs

```bash
journalctl -u tomcat -n 50
```

Les logs Tomcat peuvent également être consultés avec :

```bash
ls -la /opt/tomcat/logs/
```

---

# 21. Erreur HTTP 404

Si l'application retourne une erreur :

```text
HTTP Status 404 - Not Found
```

il faut vérifier l'existence du répertoire :

```bash
ls -la /opt/tomcat/webapps/demo
```

Le fichier suivant doit être présent :

```text
index.html
```

Les permissions peuvent être corrigées avec :

```bash
chown -R tomcat:tomcat /opt/tomcat/webapps/demo
```

Puis Tomcat peut être redémarré :

```bash
systemctl restart tomcat
```

---

# 22. Commandes principales

## Installation

```bash
chmod +x scripts/install-tomcat.sh
sudo bash scripts/install-tomcat.sh
```

## Gestion du service

```bash
sudo systemctl start tomcat
sudo systemctl stop tomcat
sudo systemctl restart tomcat
sudo systemctl status tomcat
sudo systemctl enable tomcat
```

## Port HTTP

```bash
sudo ss -lnt | grep 8080
```

## Tests HTTP

```bash
curl http://localhost:8080/
curl http://localhost:8080/demo/
```

## Logs

```bash
sudo journalctl -u tomcat -n 50
sudo ls -la /opt/tomcat/logs/
```

---

# 23. Validation finale

Le laboratoire est considéré comme validé lorsque les éléments suivants sont vérifiés :

1. Java est installé et fonctionnel.
2. OpenJDK 8 est disponible.
3. `JAVA_HOME` est correctement déterminé.
4. L'utilisateur `tomcat` existe.
5. Tomcat 9.0.120 est installé dans `/opt/tomcat`.
6. Les permissions sont correctement configurées.
7. Le service `tomcat.service` existe.
8. Le service Tomcat est activé.
9. Tomcat est à l'état `active (running)`.
10. Le port 8080 est en écoute.
11. Tomcat répond aux requêtes HTTP.
12. L'application `demo` existe.
13. Le fichier `index.html` existe.
14. L'application répond correctement.

Le test final est :

```bash
curl http://localhost:8080/demo/
```

Le résultat attendu contient :

```text
Bienvenue dans LAB-TOMCAT
Application de démonstration déployée sur Apache Tomcat.
Serveur : CentOS 7
```

---

# 24. Conclusion

Le projet **LAB-TOMCAT** permet d'automatiser l'installation et la configuration d'Apache Tomcat 9.0.120 sur CentOS 7.

L'utilisation d'un fichier de configuration séparé et d'un script Shell permet de rendre l'installation plus structurée, reproductible et maintenable.

Le serveur Tomcat utilise OpenJDK 8 et fonctionne avec l'utilisateur système dédié `tomcat`.

Le service est géré par `systemd` et l'application Web `demo` est automatiquement déployée dans :

```text
/opt/tomcat/webapps/demo
```

La validation finale est effectuée à l'aide de tests du service, du port HTTP et de l'application Web.

---

## Auteur

**Insaf NEMRI**

**LAB-TOMCAT — 2026**
