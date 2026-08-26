#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/../config/tomcat.conf"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Erreur : fichier de configuration introuvable : $CONFIG_FILE"
    exit 1
fi

source "$CONFIG_FILE"

echo "======================================"
echo "      Installation de Apache Tomcat"
echo "======================================"

echo "Version Tomcat : $TOMCAT_VERSION"
echo "Utilisateur    : $TOMCAT_USER"
echo "Répertoire     : $TOMCAT_DIR"
echo "Port HTTP      : $TOMCAT_PORT"
echo "Application     : $APP_NAME"
echo ""
echo "Vérification de Java..."

if ! command -v java >/dev/null 2>&1; then
    echo "Java n'est pas installé."
    echo "Installation de OpenJDK 8..."

    yum install -y java-1.8.0-openjdk-devel
else
    echo "Java est déjà installé."
fi

echo "Version Java détectée :"
java -version

echo ""
echo "Vérification de l'utilisateur Tomcat..."

if id "$TOMCAT_USER" >/dev/null 2>&1; then
    echo "L'utilisateur $TOMCAT_USER existe déjà."
else
    echo "Création de l'utilisateur $TOMCAT_USER..."

    useradd --system --home-dir "$TOMCAT_DIR" \
        --shell /sbin/nologin "$TOMCAT_USER"

    echo "Utilisateur $TOMCAT_USER créé."
fi

echo ""
echo "Préparation du répertoire Tomcat..."

mkdir -p "$TOMCAT_DIR"

echo "Répertoire créé : $TOMCAT_DIR"
