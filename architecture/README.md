# Architecture du projet LAB-TOMCAT

## 1. Vue générale

Le projet LAB-TOMCAT permet d'automatiser l'installation, la configuration et le déploiement d'une application Web sur Apache Tomcat sous CentOS 7.

L'architecture repose sur plusieurs composants :

```text
                         ┌──────────────────────┐
                         │      CentOS 7        │
                         │                      │
                         │     OpenJDK 8         │
                         └──────────┬───────────┘
                                    │
                                    ▼
                         ┌──────────────────────┐
                         │    Apache Tomcat     │
                         │      9.0.120          │
                         │                      │
                         │      Port 8080        │
                         └──────────┬───────────┘
                                    │
                       ┌────────────┴────────────┐
                       │                         │
                       ▼                         ▼
              ┌─────────────────┐      ┌─────────────────┐
              │     systemd      │      │     webapps     │
              │ tomcat.service   │      │                 │
              └─────────────────┘      │      demo       │
                                       │                 │
                                       │   index.html    │
                                       └─────────────────┘
```

---

## 2. Organisation du projet

Le dépôt GitHub est organisé comme suit :

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

---

## 3. Rôle des composants

### README.md

Le fichier `README.md` constitue la page principale du dépôt GitHub.

Il présente :

* le projet ;
* les objectifs ;
* l'environnement technique ;
* la structure du dépôt ;
* les principales commandes ;
* les résultats attendus.

### architecture/

Ce répertoire contient la description de l'architecture technique du laboratoire.

### config/

Le fichier `tomcat.conf` contient les paramètres utilisés par le script d'installation :

```bash
TOMCAT_VERSION="9.0.120"
TOMCAT_USER="tomcat"
TOMCAT_GROUP="tomcat"
TOMCAT_DIR="/opt/tomcat"
TOMCAT_PORT="8080"
APP_NAME="demo"
```

Cette séparation permet de modifier les paramètres sans modifier directement le script.

### scripts/

Le répertoire contient le script d'automatisation :

```text
scripts/install-tomcat.sh
```

Le script réalise notamment :

1. la vérification des privilèges ;
2. la vérification et l'installation de Java ;
3. la détermination de `JAVA_HOME` ;
4. la création de l'utilisateur `tomcat` ;
5. l'installation d'Apache Tomcat ;
6. la configuration des permissions ;
7. la création du service `systemd` ;
8. l'activation et le démarrage de Tomcat ;
9. la création de l'application `demo` ;
10. les tests de fonctionnement.

### docs/

Ce répertoire contient la documentation technique détaillée du laboratoire.

---

## 4. Architecture du serveur

Les principaux éléments installés sur le serveur sont :

| Élément     | Valeur                |
| ----------- | --------------------- |
| Système     | CentOS 7              |
| Java        | OpenJDK 1.8.0_412     |
| Serveur     | Apache Tomcat 9.0.120 |
| Utilisateur | `tomcat`              |
| Répertoire  | `/opt/tomcat`         |
| Port HTTP   | `8080`                |
| Application | `demo`                |

---

## 5. Flux d'installation

Le fonctionnement général du projet est :

```text
tomcat.conf
     │
     ▼
install-tomcat.sh
     │
     ├── Vérification Java
     │
     ├── Création utilisateur tomcat
     │
     ├── Installation Tomcat
     │
     ├── Configuration JAVA_HOME
     │
     ├── Configuration systemd
     │
     ├── Déploiement application demo
     │
     └── Tests HTTP
              │
              ▼
       http://localhost:8080/demo/
```

---

## 6. Séparation configuration / automatisation

Le projet sépare les paramètres de configuration du code d'automatisation.

Le fichier :

```text
config/tomcat.conf
```

contient les variables de configuration.

Le fichier :

```text
scripts/install-tomcat.sh
```

utilise ces variables pour réaliser l'installation.

Cette organisation améliore la lisibilité, la maintenance et la réutilisation du projet.

---

## 7. Résultat attendu

À la fin de l'installation :

```text
Apache Tomcat 9.0.120
        │
        ├── Port : 8080
        │
        ├── Service : tomcat.service
        │
        └── Application : demo
                         │
                         └── index.html
```

L'application doit être accessible avec :

```text
http://localhost:8080/demo/
```

et retourner le message :

```text
Bienvenue dans LAB-TOMCAT
```

---

## 8. Validation

La validation du laboratoire consiste notamment à vérifier :

```bash
systemctl status tomcat
```

```bash
ss -lnt | grep 8080
```

```bash
curl http://localhost:8080/
```

```bash
curl http://localhost:8080/demo/
```

Le projet est considéré comme fonctionnel lorsque le service Tomcat est actif et que l'application `demo` répond correctement aux requêtes HTTP.
