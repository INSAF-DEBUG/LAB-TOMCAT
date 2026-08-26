# LAB-TOMCAT

## Installation, configuration et déploiement d'une application Web avec Apache Tomcat

**Réalisé par : Insaf NEMRI**
**Année : 2026**
**Company : @linqiny**

---

## Présentation

**LAB-TOMCAT** est un projet d'automatisation permettant d'installer, configurer et déployer **Apache Tomcat 9.0.120** sur **CentOS 7** avec **OpenJDK 8**.

Le projet utilise un script Shell pour automatiser les principales étapes de l'installation :

* installation et vérification de Java ;
* création de l'utilisateur `tomcat` ;
* installation d'Apache Tomcat ;
* configuration des permissions ;
* configuration du service `systemd` ;
* déploiement d'une application Web ;
* vérification du serveur ;
* tests HTTP.

---

## Environnement technique

| Élément                | Valeur                |
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

## Architecture du projet

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

### Description

| Répertoire / fichier | Description                            |
| -------------------- | -------------------------------------- |
| `README.md`          | Présentation du projet et guide rapide |
| `architecture/`      | Architecture technique du laboratoire  |
| `config/`            | Paramètres de configuration            |
| `docs/`              | Documentation technique détaillée      |
| `scripts/`           | Scripts d'automatisation               |

---

## Configuration

Les paramètres principaux sont définis dans :

```text
config/tomcat.conf
```

Contenu :

```bash
TOMCAT_VERSION="9.0.120"
TOMCAT_USER="tomcat"
TOMCAT_GROUP="tomcat"
TOMCAT_DIR="/opt/tomcat"
TOMCAT_PORT="8080"
APP_NAME="demo"
```

Le script d'installation charge automatiquement ce fichier.

---

## Installation

### Prérequis

La machine doit disposer de :

* CentOS 7 ;
* accès Internet ;
* privilèges administrateur (`root` ou `sudo`).

### Rendre le script exécutable

```bash
chmod +x scripts/install-tomcat.sh
```

### Lancer l'installation

```bash
sudo bash scripts/install-tomcat.sh
```

Le script effectue automatiquement l'installation et la configuration de Tomcat.

---

## Ce que réalise le script

Le script `scripts/install-tomcat.sh` réalise les opérations suivantes :

```text
Vérification des privilèges
          │
          ▼
Vérification / installation de Java
          │
          ▼
Détermination de JAVA_HOME
          │
          ▼
Création de l'utilisateur tomcat
          │
          ▼
Téléchargement de Tomcat 9.0.120
          │
          ▼
Installation dans /opt/tomcat
          │
          ▼
Configuration des permissions
          │
          ▼
Création du service systemd
          │
          ▼
Activation et démarrage de Tomcat
          │
          ▼
Déploiement de l'application demo
          │
          ▼
Tests HTTP
```

---

## Service Tomcat

Le service est géré avec `systemd`.

### Démarrer

```bash
sudo systemctl start tomcat
```

### Arrêter

```bash
sudo systemctl stop tomcat
```

### Redémarrer

```bash
sudo systemctl restart tomcat
```

### Vérifier le statut

```bash
sudo systemctl status tomcat
```

Le résultat attendu est :

```text
Active: active (running)
```

### Activer au démarrage

```bash
sudo systemctl enable tomcat
```

---

## Vérification du port

Tomcat utilise le port HTTP `8080`.

```bash
sudo ss -lnt | grep 8080
```

---

## Application Web

L'application de démonstration est nommée :

```text
demo
```

Elle est déployée dans :

```text
/opt/tomcat/webapps/demo
```

Le fichier principal est :

```text
/opt/tomcat/webapps/demo/index.html
```

---

## Tests

### Tester Tomcat

```bash
curl http://localhost:8080/
```

### Tester l'application

```bash
curl http://localhost:8080/demo/
```

Le résultat attendu contient :

```text
Bienvenue dans LAB-TOMCAT
Application de démonstration déployée sur Apache Tomcat.
Serveur : CentOS 7
```

L'application est accessible à :

```text
http://localhost:8080/demo/
```

---

## Logs

Les logs du service peuvent être consultés avec :

```bash
sudo journalctl -u tomcat -n 50
```

Les logs Tomcat sont disponibles dans :

```text
/opt/tomcat/logs/
```

---

## Documentation complète

La documentation technique détaillée est disponible dans :

```text
docs/documentation.md
```

L'architecture technique est décrite dans :

```text
architecture/architecture.md
```

---

## Validation finale

Pour considérer l'installation comme réussie, les éléments suivants doivent être vérifiés :

* [x] Java installé et fonctionnel
* [x] OpenJDK 8 disponible
* [x] Utilisateur `tomcat` créé
* [x] Tomcat 9.0.120 installé
* [x] Tomcat installé dans `/opt/tomcat`
* [x] Permissions configurées
* [x] Service `tomcat.service` créé
* [x] Service Tomcat activé
* [x] Service Tomcat actif
* [x] Port `8080` en écoute
* [x] Application `demo` déployée
* [x] Test HTTP réussi

Test final :

```bash
curl http://localhost:8080/demo/
```

---

## Dépannage rapide

### Tomcat n'est pas actif

```bash
sudo systemctl status tomcat
```

Puis consulter les logs :

```bash
sudo journalctl -u tomcat -n 50
```

### Le port 8080 n'est pas disponible

```bash
sudo ss -lnt | grep 8080
```

### L'application retourne une erreur 404

Vérifier :

```bash
sudo ls -la /opt/tomcat/webapps/demo/
```

Le fichier `index.html` doit être présent.

---

## Auteur

**Insaf NEMRI**

**LAB-TOMCAT — 2026**
