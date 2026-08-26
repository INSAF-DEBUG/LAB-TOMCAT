#!/bin/bash

set -e

# ======================================
# Détermination des chemins
# ======================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/../config/tomcat.conf"

# ======================================
# Vérification du fichier de configuration
# ======================================

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Erreur : fichier de configuration introuvable : $CONFIG_FILE"
    exit 1
fi

source "$CONFIG_FILE"

# ======================================
# Vérification des privilèges
# ======================================

if [ "$EUID" -ne 0 ]; then
    echo "Erreur : ce script doit être exécuté en root."
    echo "Utilisez : sudo $0"
    exit 1
fi

# ======================================
# Informations
# ======================================

echo "======================================"
echo "      Installation de Apache Tomcat"
echo "======================================"
echo "Version Tomcat : $TOMCAT_VERSION"
echo "Utilisateur    : $TOMCAT_USER"
echo "Groupe         : $TOMCAT_GROUP"
echo "Répertoire     : $TOMCAT_DIR"
echo "Port HTTP      : $TOMCAT_PORT"
echo "Application    : $APP_NAME"
echo ""

# ======================================
# Vérification des commandes nécessaires
# ======================================

echo "Vérification des commandes nécessaires..."

for command in curl tar systemctl; do
    if ! command -v "$command" >/dev/null 2>&1; then
        echo "Erreur : commande '$command' introuvable."
        exit 1
    fi
done

echo "Commandes nécessaires disponibles."
echo ""

# ======================================
# Vérification / installation de Java
# ======================================

echo "Vérification de Java..."

if ! command -v java >/dev/null 2>&1; then
    echo "Java n'est pas installé."
    echo "Installation de OpenJDK 8..."

    yum install -y java-1.8.0-openjdk-devel
else
    echo "Java est déjà installé."
fi

echo ""
echo "Version Java détectée :"
java -version

# ======================================
# Détermination de JAVA_HOME
# ======================================

echo ""
echo "Détermination de JAVA_HOME..."

JAVA_BIN="$(readlink -f "$(command -v java)")"
JAVA_HOME="$(dirname "$(dirname "$JAVA_BIN")")"

if [ ! -d "$JAVA_HOME" ]; then
    echo "Erreur : JAVA_HOME introuvable."
    exit 1
fi

echo "JAVA_HOME : $JAVA_HOME"

# ======================================
# Création de l'utilisateur Tomcat
# ======================================

echo ""
echo "Vérification de l'utilisateur Tomcat..."

if id "$TOMCAT_USER" >/dev/null 2>&1; then
    echo "L'utilisateur $TOMCAT_USER existe déjà."
else
    echo "Création de l'utilisateur $TOMCAT_USER..."

    useradd --system \
        --home-dir "$TOMCAT_DIR" \
        --shell /sbin/nologin \
        "$TOMCAT_USER"

    echo "Utilisateur $TOMCAT_USER créé."
fi

# ======================================
# Préparation du répertoire Tomcat
# ======================================

echo ""
echo "Préparation du répertoire Tomcat..."

mkdir -p "$TOMCAT_DIR"

# ======================================
# Téléchargement de Tomcat
# ======================================

TOMCAT_ARCHIVE="/tmp/apache-tomcat-${TOMCAT_VERSION}.tar.gz"
TOMCAT_URL="https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz"

echo ""
echo "Téléchargement de Tomcat $TOMCAT_VERSION..."

if [ ! -f "$TOMCAT_ARCHIVE" ]; then
    curl -fL "$TOMCAT_URL" -o "$TOMCAT_ARCHIVE"
else
    echo "Archive déjà présente : $TOMCAT_ARCHIVE"
fi

echo "Archive disponible."

# ======================================
# Installation de Tomcat
# ======================================

echo ""
echo "Installation de Tomcat..."

if [ -f "$TOMCAT_DIR/bin/catalina.sh" ]; then
    echo "Tomcat semble déjà installé dans $TOMCAT_DIR."
else
    TEMP_DIR="/tmp/tomcat-install-${TOMCAT_VERSION}"

    rm -rf "$TEMP_DIR"
    mkdir -p "$TEMP_DIR"

    tar -xzf "$TOMCAT_ARCHIVE" -C "$TEMP_DIR"

    EXTRACTED_DIR="$TEMP_DIR/apache-tomcat-${TOMCAT_VERSION}"

    if [ ! -d "$EXTRACTED_DIR" ]; then
        echo "Erreur : répertoire Tomcat extrait introuvable."
        exit 1
    fi

    cp -a "$EXTRACTED_DIR/." "$TOMCAT_DIR/"

    rm -rf "$TEMP_DIR"

    echo "Tomcat installé dans : $TOMCAT_DIR"
fi

# ======================================
# Configuration des permissions
# ======================================

echo ""
echo "Configuration des permissions..."

chown -R "$TOMCAT_USER:$TOMCAT_GROUP" "$TOMCAT_DIR"
chmod +x "$TOMCAT_DIR"/bin/*.sh

echo "Permissions configurées."

# ======================================
# Création du service systemd
# ======================================

echo ""
echo "Configuration du service systemd..."

cat > /etc/systemd/system/tomcat.service <<EOF
[Unit]
Description=Apache Tomcat 9 Web Application Container
After=network.target

[Service]
Type=forking

User=$TOMCAT_USER
Group=$TOMCAT_GROUP

Environment="JAVA_HOME=$JAVA_HOME"
Environment="CATALINA_HOME=$TOMCAT_DIR"
Environment="CATALINA_BASE=$TOMCAT_DIR"

ExecStart=$TOMCAT_DIR/bin/startup.sh
ExecStop=$TOMCAT_DIR/bin/shutdown.sh

Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

echo "Service systemd créé : /etc/systemd/system/tomcat.service"

# ======================================
# Rechargement de systemd
# ======================================

echo ""
echo "Rechargement de systemd..."

systemctl daemon-reload

# ======================================
# Activation du service
# ======================================

echo ""
echo "Activation du service Tomcat..."

systemctl enable tomcat

# ======================================
# Création de l'application demo
# ======================================

APP_DIR="$TOMCAT_DIR/webapps/$APP_NAME"

echo ""
echo "Préparation de l'application $APP_NAME..."

mkdir -p "$APP_DIR"

cat > "$APP_DIR/index.html" <<EOF
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
EOF

chown -R "$TOMCAT_USER:$TOMCAT_GROUP" "$APP_DIR"

echo "Application créée : $APP_DIR"

# ======================================
# Démarrage de Tomcat
# ======================================

echo ""
echo "Démarrage de Tomcat..."

systemctl restart tomcat

# ======================================
# Vérification du service
# ======================================

echo ""
echo "Vérification du service..."

sleep 3

if systemctl is-active --quiet tomcat; then
    echo "Tomcat est actif."
else
    echo "Erreur : Tomcat n'est pas actif."
    systemctl status tomcat --no-pager
    exit 1
fi

# ======================================
# Vérification du port
# ======================================

echo ""
echo "Vérification du port $TOMCAT_PORT..."

if ss -lnt | grep -q ":$TOMCAT_PORT "; then
    echo "Le port $TOMCAT_PORT est ouvert."
else
    echo "Attention : le port $TOMCAT_PORT n'est pas détecté."
fi

# ======================================
# Test HTTP Tomcat
# ======================================

echo ""
echo "Test HTTP de Tomcat..."

if curl -fsS "http://localhost:$TOMCAT_PORT/" >/dev/null; then
    echo "Tomcat répond correctement sur le port $TOMCAT_PORT."
else
    echo "Erreur : Tomcat ne répond pas."
    exit 1
fi

# ======================================
# Test HTTP application demo
# ======================================

echo ""
echo "Test HTTP de l'application $APP_NAME..."

if curl -fsS "http://localhost:$TOMCAT_PORT/$APP_NAME/" >/dev/null; then
    echo "Application $APP_NAME accessible."
else
    echo "Erreur : application $APP_NAME inaccessible."
    exit 1
fi

# ======================================
# Résumé final
# ======================================

echo ""
echo "======================================"
echo "       INSTALLATION TERMINEE"
echo "======================================"
echo ""
echo "Tomcat       : $TOMCAT_VERSION"
echo "Utilisateur  : $TOMCAT_USER"
echo "Répertoire   : $TOMCAT_DIR"
echo "Port HTTP    : $TOMCAT_PORT"
echo "Application  : $APP_NAME"
echo ""
echo "URL Tomcat   : http://localhost:$TOMCAT_PORT/"
echo "URL App       : http://localhost:$TOMCAT_PORT/$APP_NAME/"
echo ""
echo "Service      : active"
echo "======================================"
