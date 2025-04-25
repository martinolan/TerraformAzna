# Infrastructure Azure avec Terraform

Ce projet déploie une infrastructure Azure composée d'une machine virtuelle Debian avec PostgreSQL et GeoServer.

## Architecture

- Machine virtuelle Debian 11
- PostgreSQL avec PostGIS
- GeoServer
- Réseau virtuel avec sous-réseau
- Groupe de sécurité réseau
- Adresse IP publique

## Prérequis

- [Terraform](https://www.terraform.io/downloads.html) (version 1.11.1 ou supérieure)
- Compte Azure avec les permissions nécessaires
- Clé SSH pour l'authentification => `vm.tf` > public_key = file("~/.ssh/XXX.pub")

## Configuration

Configurez les variables d'environnement Azure dans un fichier `.envrc` (prendre exemple sur `.envrc_sample`) :

```
export ARM_SUBSCRIPTION_ID="votre_subscription_id"
export ARM_CLIENT_ID="votre_client_id"
export ARM_SUB_ID="votre_sub_id"
export ARM_TENANT_ID="votre_tenant_id"
export ARM_CLIENT_SECRET="votre_client_secret"
```

Pour cela crée une Azure subscription pour permettre les requetes terraform azure.

## Déploiement

Pour Terraform :

```bash
terraform init
```

```bash
terraform apply
```

## Accès

- Adresse IP publique : disponible dans la sortie `publicID`
- Port SSH : 22
- Port GeoServer : 8080
- Identifiants PostgreSQL :
  - Utilisateur : geonature
  - Mot de passe : disponible dans la sortie `password_postgres`
- Identifiants GeoServer :
  - Utilisateur : admin
  - Mot de passe : disponible dans la sortie `password_geoserver`

## Nettoyage

Pour détruire l'infrastructure :

```bash
terraform destroy
```

## Sécurité

- L'authentification SSH est requise pour accéder à la VM
- Les ports 22 (SSH) et 8080 (GeoServer) sont ouverts
