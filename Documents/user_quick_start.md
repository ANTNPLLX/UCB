# Guide de Démarrage Rapide - Boîtier Nettoyage USB

## Démarrage du Boîtier

1. **Brancher l'alimentation** - Connectez le câble d'alimentation au boîtier
2. **Attendre l'initialisation** - Patienter environ 20 secondes
   - L'écran LCD s'allume
   - Animation des LEDs (serpent)
   - Son de démarrage (jingle)
3. **Message prêt** - L'écran affiche : "Inserer une / clé USB..."

---

## Utilisation

### Étape 1 : Insérer la Clé USB
- Insérer la clé USB dans le port USB du boîtier
- Le boîtier détecte automatiquement la clé
- Un bip sonore confirme la détection
- L'écran affiche la taille de la clé

### Étape 2 : Choisir les Traitements
Pour chaque traitement disponible, l'écran affiche une question :
- **Bouton GAUCHE (NON)** - Passer au traitement suivant
- **Bouton DROIT (OUI)** - Lancer le traitement

### Étape 3 : Patienter
- Le boîtier exécute les traitements sélectionnés
- L'écran affiche la progression
- Les LEDs indiquent l'état :
  - 🟢 **VERT** = Succès, aucun problème
  - 🟠 **ORANGE** = Avertissement, vérifier les résultats
  - 🔴 **ROUGE** = Menace détectée ou erreur

### Étape 4 : Retirer la Clé
- Lorsque l'écran affiche "Au revoir / Retirer cle USB"
- Retirer la clé USB du boîtier
- Le boîtier est prêt pour une nouvelle clé

---

## Traitements Disponibles

### 1. Analyse Complète ? (Antivirus ClamAV)
**Question affichée :** "Analyse complete?"

**Description :** Analyse antivirus complète de tous les fichiers de la clé USB avec mise à jour automatique des signatures virales.

**Durée :** Variable selon le nombre de fichiers (2-10 minutes)

**Résultats possibles :**
- ✅ "Analyse OK / Propre!" - Aucun virus détecté
- ⚠️ "ALERTE! / X menaces" - Virus ou malware détecté
- ❌ "NE PAS UTIL. / USB infecte!" - Clé infectée, ne pas utiliser

---

### 2. Recherche Fichier Exécutable ?
**Question affichée :** "Executable chk?"

**Description :** Détecte les fichiers potentiellement dangereux (programmes Windows .exe, scripts, binaires Linux).

**Durée :** Rapide (30 secondes à 2 minutes)

**Résultats possibles :**
- ✅ "Pas de fichier / executable" - Aucun exécutable trouvé
- ⚠️ "SUSPECT! / X exec." - Fichiers suspects détectés
- 📋 Liste des fichiers suspects affichée à l'écran

---

### 3. Vitrification ?
**Question affichée :** "Vitrification?"

**Description :** Convertit les documents Office et PDF en fichiers PDF nettoyés (supprime macros, JavaScript, objets malveillants). Les fichiers originaux sont déplacés dans le dossier "FICHIERS_POTENTIELLEMENT_DANGEREUX".

**Durée :** Variable selon le nombre de documents (2-15 minutes)

**Formats traités :**
- PDF (nettoyage)
- Documents Office (.doc, .docx, .xls, .xlsx, .ppt, .pptx)
- OpenOffice (.odt, .ods, .odp)
- RTF

**Résultats :**
- Fichiers nettoyés : `nom_fichier.ext_vitrified_.pdf`
- Fichiers originaux : `FICHIERS_POTENTIELLEMENT_DANGEREUX/`
- Autres fichiers suspects : renommés avec extension `.hold`

---

### 4. Formatage USB ?
**Question affichée :** "Formatage USB?"

**Description :** Efface TOUTES les données et formate la clé USB en FAT32 (nom "CLEAN_USB").

**Durée :** 30 secondes à 2 minutes

**⚠️ ATTENTION : Cette opération EFFACE DÉFINITIVEMENT toutes les données !**

**Résultats possibles :**
- ✅ "Formatage OK! / CLEAN_USB" - Formatage réussi
- ❌ "ERREUR! / Disque systeme" - Protection activée (disque système)

---

### 5. Copie Rapport ?
**Question affichée :** "Copie rapport?"

**Description :** Crée un fichier rapport sur la clé USB avec tous les logs de la session en cours (analyses, détections, traitements).

**Durée :** Très rapide (5-10 secondes)

**Fichier créé :** `YYYY-MM-DD_HH-MM_rapport_UCB.txt`

**Contenu du rapport :**
- Informations détaillées sur la clé USB
- Tous les traitements effectués
- Résultats des analyses
- Fichiers détectés ou traités

---

## Recommencer un Traitement

Après tous les traitements, le boîtier demande :

**"Recommencer?"**
- **OUI** - Relance les questions pour la même clé USB
- **NON** - Passe au message de fin

**Cas d'usage :** Utile si vous voulez effectuer un formatage après vitrification, ou créer un rapport après analyse.

---

## Codes Couleur des LEDs

| LED | Signification |
|-----|---------------|
| 🟢 **VERT** | Opération réussie, aucun problème détecté |
| 🟠 **ORANGE** | Avertissement, fichiers suspects trouvés |
| 🔴 **ROUGE** | Menace détectée ou erreur critique |
| 🔵 **Animation** | Traitement en cours, patientez... |

---

## Sons du Boîtier

| Son | Signification |
|-----|---------------|
| 🎵 Jingle (démarrage) | Le boîtier est prêt |
| 🔊 Bip simple | Clé USB détectée |
| ✅ Mélodie ascendante | Opération réussie |
| ❌ Mélodie descendante | Erreur ou menace détectée |
| ⚠️ 4 bips courts | Avertissement |

---

## Dépannage Rapide

### L'écran ne s'allume pas
- Vérifier l'alimentation électrique
- Attendre 30 secondes (initialisation)

### La clé USB n'est pas détectée
- Retirer et réinsérer la clé
- Vérifier que la clé n'est pas défectueuse
- Essayer un autre port USB (si disponible)

### Le boîtier est bloqué
- Débrancher l'alimentation
- Attendre 10 secondes
- Rebrancher et attendre l'initialisation

### Message "Echec montage"
- La clé USB est peut-être défectueuse
- Essayer de formater la clé sur un ordinateur
- Vérifier le système de fichiers (FAT32, NTFS, exFAT supportés)

---

## Conseils d'Utilisation

### ✅ Bonnes Pratiques

1. **Analyse systématique** - Toujours effectuer l'analyse antivirus complète en premier
2. **Vitrification recommandée** - Pour les clés contenant des documents Office ou PDF
3. **Rapport de session** - Créer un rapport pour garder une trace des traitements
4. **Formatage en dernier** - Le formatage efface tout, à faire uniquement si nécessaire

### ⚠️ À Éviter

1. **Ne pas débrancher pendant un traitement** - Risque de corruption de données
2. **Ne pas formater sans sauvegarde** - Le formatage est IRRÉVERSIBLE
3. **Ne pas ignorer les alertes rouges** - Une clé infectée doit être traitée

---

## Ordre Recommandé des Traitements

Pour une désinfection complète d'une clé USB suspecte :

1. **✅ Analyse complète** → Détecter les menaces
2. **✅ Recherche exécutable** → Identifier les fichiers suspects
3. **✅ Vitrification** → Nettoyer les documents
4. **✅ Copie rapport** → Sauvegarder les logs
5. **⚠️ Formatage** (optionnel) → Si la clé est très infectée

---

## Support et Documentation

**Documentation complète :** Voir le dossier `Documents/` du boîtier

**Fichiers de logs :** Consultables dans le rapport généré ou dans `/var/log/usb_malware_scan.log`

**Version du logiciel :** Affiché au démarrage sur l'écran LCD

---

## Caractéristiques Techniques

**Système d'exploitation :** Raspberry Pi OS (Linux)
**Antivirus :** ClamAV avec mise à jour automatique
**Formats supportés :** FAT32, NTFS, exFAT
**Taille max clé USB :** Jusqu'à 2 To
**Écran :** LCD 16x2 caractères
**Alimentation :** 5V USB-C ou 9V batterie

---

**🛡️ Boîtier Nettoyage USB - Protégez vos données**

*Guide de démarrage rapide - Version 1.0 - 2025*
