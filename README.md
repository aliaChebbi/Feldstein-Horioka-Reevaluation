# 📈 Réévaluation du puzzle de Feldstein-Horioka (2000-2024)

Ce dépôt contient les travaux réalisés pour le projet d'économétrie appliquée du **Master 1 MBFA** (Monnaie, Banque, Finance, Assurances), parcours SIEF, à la **Faculté d'Économie de l'Université de Montpellier**.

## 📝 Présentation du projet
L'étude propose une réévaluation empirique du célèbre "puzzle" de Feldstein et Horioka (1980) au sein de **30 pays de l'OCDE** sur la période 2000-2024. L'objectif est de mesurer le degré d'intégration financière internationale en analysant la corrélation entre l'épargne nationale et l'investissement domestique.

### Principaux résultats
* **Mobilité élevée du capital** : L'estimation globale par MCO révèle un coefficient de rétention de l'épargne ($\beta$) de **0,35**, signalant une intégration bien plus forte que dans les années 1970 (où il avoisinait 0,90).
* **Rupture structurelle post-2008** : Le **test de Chow** confirme une rupture significative après la crise financière : la corrélation, quasi nulle dans les années 2000 (0,14), s'est renforcée durant la décennie suivante (0,48), traduisant une re-fragmentation partielle des marchés.
* **Effet Zone Euro** : Les tests d'interaction indiquent que l'appartenance à l'union monétaire n'a pas engendré de surplus d'intégration significatif par rapport au reste de l'OCDE sur cette période.

## 🛠 Méthodologie et Outils
* **Données** : World Development Indicators (WDI) - Banque Mondiale.
* **Analyses statistiques** : Moindres Carrés Ordinaires (MCO), tests d'hétéroscédasticité (Breusch-Pagan, White), test de normalité (Shapiro-Wilk) et détection des points influents (Distance de Cook).
* **Logiciel** : Stata.

## 📁 Contenu du dépôt
* `Code_Stata.do` : Script Stata complet pour le nettoyage des données et les estimations.
* `Log_Complet.smcl` : Journal brut des résultats et diagnostics économétriques.
* `Rapport_Final.pdf` : Analyse détaillée, interprétations économiques et graphiques de synthèse.
* `Sujet.docx` : Descriptif des objectifs et consignes du projet.

## 👥 Équipe
* **Alia Chebbi** 
* **Rajaa Yamoul** 
* Sous la direction du **Dr.Benoit Mulkay**.
