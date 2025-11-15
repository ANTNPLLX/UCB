# Guide de Démarrage Rapide - Boîtier Nettoyage USB

## Étape 1 : Démarrage du boîtier
1. **Brancher l'alimentation** - Connectez le câble d'alimentation au boîtier
2. **Attendre l'initialisation** - Patienter environ 20 secondes
3. **Boitier prêt** - L'écran affiche : "Inserer une / clé USB..."

## Étape 2 : Insérer la Clé USB
- Insérer la clé USB dans le port USB du boîtier

## Étape 3 : Choisir les Traitements
Pour chaque traitement disponible, l'écran affiche une question
- **Bouton GAUCHE (NON)** - Passer au traitement suivant
- **Bouton DROIT (OUI)** - Lancer le traitement

---

### Explications des traitements
##"Executable chk?"
Détecte les fichiers potentiellement dangereux (programmes Windows .exe, scripts, binaires Linux).
  - 🟢 **VERT** = "Pas de fichier / executable" - Aucun exécutable trouvé
  - 🟠 **ORANGE** = "SUSPECT! / X exec." - Fichiers executables détectés
  - 🔴 **ROUGE** = "Erreur" - le traitement ne s'est pas passé comme prévu

##"Vitrification?"
Convertit les documents Office et PDF en fichiers PDF nettoyés (supprime macros, JavaScript, objets malveillants). Les fichiers originaux sont déplacés dans le dossier "FICHIERS_POTENTIELLEMENT_DANGEREUX".
**Formats traités :**
- PDF (nettoyage)
- Documents Office (.doc, .docx, .xls, .xlsx, .ppt, .pptx)
- OpenOffice (.odt, .ods, .odp)
- RTF
**Résultats :**
- Fichiers nettoyés : renommés en `nom_fichier.ext_vitrified_.pdf`
- Fichiers originaux : déplacés dans `FICHIERS_POTENTIELLEMENT_DANGEREUX/`
- Autres fichiers : renommés avec extension `.hold`

##"Formatage USB?"
Efface TOUTES les données et formate la clé USB en FAT32 (nom "CLEAN_USB").
**⚠️ ATTENTION : Cette opération EFFACE DÉFINITIVEMENT toutes les données !**
**Résultats possibles :**
- 🟢 **VERT** = "Formatage OK! / CLEAN_USB" - Formatage réussi
- 🔴 **ROUGE** = "ERREUR! / Disque systeme" - Protection activée (disque système)

##"Copie rapport?"
Crée un fichier rapport sur la clé USB avec tous les logs de la session en cours (analyses, détections, traitements).
**Fichier créé :** `YYYY-MM-DD_HH-MM_rapport_UCB.txt`
**Contenu du rapport :**
- Informations détaillées sur la clé USB
- Tous les traitements effectués
- Résultats des analyses
- Fichiers détectés ou traités

##"Recommencer?"
Après tous les traitements, le boîtier demande :
- **OUI** - Relance les questions pour la même clé USB
- **NON** - Passe au message de fin

---


###Étape 4 : Retirer la Clé
- Lorsque l'écran affiche "Au revoir / Retirer cle USB"
- Retirer la clé USB du boîtier
- Le boîtier est prêt pour une nouvelle clé


