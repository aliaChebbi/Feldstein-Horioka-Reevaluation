/* ==========================================================================
   PROJET ECONOMETRIE : REEVALUATION DU PUZZLE FELDSTEIN-HORIOKA
   Binôme : Alia Chebbi et Rajaa Yamoul
   Période : 2000-2024
   ========================================================================== */

// --- Début du Journal (Log) ---
log using "CHEBBI_YAMOUL_Log_Complet.smcl", replace text


clear all
set more off
set graphics on 
set scheme s1color 

// >>> A MODIFIER : CHEMIN D'ACCES <<<
cd "/Users/aliachebbi/Desktop/M1/S7/Econometrie_theorique/Projet" 

/* ==========================================================================
   ETAPE 1 : PREPARATION DE LA BASE DE DONNEES
   ========================================================================== */
import excel "BDD.xlsx", sheet("Data") firstrow clear

rename SeriesCode code
rename CountryName pays
rename CountryCode id_pays 
drop SeriesName


keep if inlist(code, "NE.GDI.TOTL.ZS", "NY.GNS.ICTR.ZS", "NY.GDP.MKTP.KD.ZG", "NE.TRD.GNFS.ZS")

drop if missing(pays)
duplicates drop pays code, force

// Reshape Long (Années)
reshape long YR, i(pays id_pays code) j(annee)
replace YR = "" if YR == ".."
destring YR, replace force
rename YR valeur

// Reshape Wide (Variables)
replace code = "Investissement" if code == "NE.GDI.TOTL.ZS"
replace code = "Epargne" if code == "NY.GNS.ICTR.ZS"
replace code = "Croissance" if code == "NY.GDP.MKTP.KD.ZG"
replace code = "Ouverture" if code == "NE.TRD.GNFS.ZS"

reshape wide valeur, i(pays id_pays annee) j(code) string
rename valeur* *

// Labeling
label var Investissement "Taux d'investissement (% du PIB)"
label var Epargne "Taux d'épargne (% du PIB)"
label var Croissance "Croissance du PIB (%)"
label var Ouverture "Ouverture commerciale (% du PIB)"

save "master_data_projet.dta", replace
di ">>> BASE PRETE <<<"

/* ==========================================================================
   ETAPE 2 : ANALYSE PRINCIPALE (Modèle de Base)
   ========================================================================== */

/* --- 1. Statistiques Descriptives --- */
use "master_data_projet.dta", clear
keep if annee >= 2000 & annee <= 2024
collapse (mean) Investissement Epargne Croissance Ouverture, by(pays id_pays)
summarize

/* --- 2. Estimation Globale (2000-2024) & Graphique --- */
di _n ">>> REGRESSION MCO GLOBALE (2000-2024) <<<"
reg Investissement Epargne

// Graphique Esthétique
twoway (scatter Investissement Epargne, mlabel(id_pays) mlabsize(tiny) mlabcolor(black) mlabpos(12) msymbol(circle_hollow) mcolor(navy)) ///
       (lfit Investissement Epargne, lcolor(maroon) lwidth(medthick)), ///
       title("Relation Épargne-Investissement (2000-2024)") ///
       subtitle("Moyennes de long terme (30 pays OCDE)") ///
       ytitle("Taux d'Investissement (% PIB)") xtitle("Taux d'Épargne (% PIB)") ///
       legend(order(1 "Pays" 2 "Droite de régression") position(6)) ///
       graphregion(color(white)) name(Graph_Q1_Clean, replace)
graph export "Graph_Q1_Clean.png", replace

/* ==========================================================================
   ETAPE 3 : DIAGNOSTICS ECONOMETRIQUES
   ========================================================================== */

/* --- 1. Hétéroscédasticité --- */
di _n ">>> TEST DE BREUSCH-PAGAN <<<"
hettest

di _n ">>> TEST DE WHITE <<<"
estat imtest, white

// Correction Robuste (si nécessaire)
di _n ">>> REGRESSION ROBUSTE (VCE ROBUST) <<<"
reg Investissement Epargne, vce(robust)

/* --- 2. Normalité des Résidus --- */
predict e_resid, residuals
di _n ">>> TEST DE SHAPIRO-WILK (Normalité) <<<"
swilk e_resid

// Graphique Normalité
histogram e_resid, kdensity normal ///
          title("Distribution des Résidus") ///
          note("Test de la normalité des erreurs") ///
          graphregion(color(white)) name(Graph_Normalite, replace)
graph export "Graph_Normalite.png", replace

/* --- 3. Multicolinéarité (Modèle Augmenté) --- */
di _n ">>> DIAGNOSTIC MULTICOLINEARITE (VIF) <<<"
quietly reg Investissement Epargne Croissance Ouverture
vif

/* ==========================================================================
   ETAPE 4 : ROBUSTESSE ET DYNAMIQUE
   ========================================================================== */

/* --- 1. Sensibilité à la taille de l'échantillon (15 pays) --- */
use "master_data_projet.dta", clear
keep if annee >= 2000 & annee <= 2024
collapse (mean) Investissement Epargne, by(pays id_pays)
sort pays
gen echantillon_15 = (_n <= 15)

di _n ">>> REGRESSION ECHANTILLON REDUIT (15 PAYS) <<<"
reg Investissement Epargne if echantillon_15 == 1
test Epargne = 1

// Graphique Robustesse
twoway (lfit Investissement Epargne, lcolor(red) lwidth(thick)) ///
       (lfit Investissement Epargne if echantillon_15 == 1, lcolor(forest_green) lpattern(dash) lwidth(thick)), ///
       title("Sensibilité à la taille de l'échantillon") ///
       subtitle("Comparaison des droites de régression") ///
       ytitle("Taux d'Investissement (% PIB)") xtitle("Taux d'Épargne (% PIB)") ///
       legend(order(1 "Complet (30 pays)" 2 "Réduit (15 pays)") position(6)) ///
       graphregion(color(white)) name(Graph_Robustesse_Lignes, replace)
graph export "Graph_Robustesse_Lignes.png", replace

/* --- 2. Dynamique par Sous-Périodes --- */
di _n ">>> COMPARAISON SOUS-PERIODES <<<"

// 2000-2009
use "master_data_projet.dta", clear
keep if annee >= 2000 & annee <= 2009
collapse (mean) Investissement Epargne, by(pays)
di _n "--- 2000-2009 ---"
reg Investissement Epargne

// 2010-2019
use "master_data_projet.dta", clear
keep if annee >= 2010 & annee <= 2019
collapse (mean) Investissement Epargne, by(pays)
di _n "--- 2010-2019 ---"
reg Investissement Epargne

// 2020-2024
use "master_data_projet.dta", clear
keep if annee >= 2020 & annee <= 2024
collapse (mean) Investissement Epargne, by(pays)
di _n "--- 2020-2024 ---"
reg Investissement Epargne

/* ==========================================================================
   ETAPE 5 : EXTENSIONS
   ========================================================================== */

/* --- 1. Outliers (Distance de Cook) --- */
use "master_data_projet.dta", clear
keep if annee >= 2000 & annee <= 2024
collapse (mean) Investissement Epargne, by(pays id_pays)

quietly reg Investissement Epargne
predict cook, cooksd

di _n ">>> PAYS OUTLIERS (Cook > 0.133) <<<"
list pays cook if cook > 0.133

di _n ">>> REGRESSION SANS OUTLIERS <<<"
reg Investissement Epargne if cook <= 0.133

// Graphique Outliers
graph hbar cook, bar(1, color(maroon)) yline(0.133) ///
      over(id_pays, sort(cook) descending label(labsize(vsmall))) ///
      title("Distance de Cook (Points Influents)") name(Graph_Outliers, replace)
graph export "Graph_Outliers.png", replace

/* --- 2. Test de Rupture Structurelle (Chow) --- */
use "master_data_projet.dta", clear
keep if annee >= 2000 & annee <= 2024
gen Period_Post2010 = (annee >= 2010)
collapse (mean) Investissement Epargne, by(pays Period_Post2010)

di _n ">>> TEST DE CHOW (Rupture 2010) <<<"
reg Investissement c.Epargne##i.Period_Post2010

/* --- 3. Effet Zone Euro --- */
use "master_data_projet.dta", clear
keep if annee >= 2000 & annee <= 2024

gen ZoneEuro = 0
// Liste coupée en deux pour éviter l'erreur r(130)
replace ZoneEuro = 1 if inlist(pays, "Austria", "Belgium", "Finland", "France", "Germany", "Greece")
replace ZoneEuro = 1 if inlist(pays, "Ireland", "Italy", "Luxembourg", "Netherlands", "Portugal", "Spain")

collapse (mean) Investissement Epargne, by(pays ZoneEuro)

di _n ">>> TEST ZONE EURO <<<"
reg Investissement c.Epargne##i.ZoneEuro

/* --- 4. Modèle Augmenté --- */
use "master_data_projet.dta", clear
keep if annee >= 2000 & annee <= 2024
collapse (mean) Investissement Epargne Croissance Ouverture, by(pays)

di _n ">>> MODELE AUGMENTE <<<"
reg Investissement Epargne Croissance Ouverture

/* --- 5. Graphiques Annexes Manquants --- */
// Recréation des variables nécessaires
use "master_data_projet.dta", clear
keep if annee >= 2000 & annee <= 2024
collapse (mean) Investissement Epargne, by(pays id_pays)
quietly reg Investissement Epargne
predict e_final, residuals
predict y_hat_final, xb

// Graphique Homoscédasticité
rvfplot, yline(0, lcolor(red)) mlabel(id_pays) mlabsize(tiny) ///
         title("Graphique des Résidus") subtitle("Test visuel d'homoscédasticité") ///
         ytitle("Résidus") xtitle("Valeurs Prédites (Investissement)") ///
         graphregion(color(white)) name(Graph_Homoscedasticite, replace)
graph export "Graph_Homoscedasticite.png", replace

// Graphique Zone Euro (récupération dummy rapide)
use "master_data_projet.dta", clear
keep if annee >= 2000 & annee <= 2024
gen ZoneEuro = 0
replace ZoneEuro = 1 if inlist(pays, "Austria", "Belgium", "Finland", "France", "Germany", "Greece")
replace ZoneEuro = 1 if inlist(pays, "Ireland", "Italy", "Luxembourg", "Netherlands", "Portugal", "Spain")
collapse (mean) Investissement Epargne, by(pays id_pays ZoneEuro)

twoway (scatter Investissement Epargne if ZoneEuro==0, mcolor(gs10) msymbol(circle)) ///
       (scatter Investissement Epargne if ZoneEuro==1, mcolor(blue) msymbol(diamond) mlabel(id_pays) mlabsize(tiny) mlabcolor(blue) mlabpos(12)) ///
       (lfit Investissement Epargne if ZoneEuro==0, lcolor(gs10)) ///
       (lfit Investissement Epargne if ZoneEuro==1, lcolor(blue)), ///
       title("Zone Euro vs Reste de l'OCDE") ///
       legend(order(1 "Reste OCDE" 2 "Zone Euro" 3 "Fit Reste" 4 "Fit Euro")) ///
       graphregion(color(white)) name(Graph_ZoneEuro, replace)
graph export "Graph_ZoneEuro.png", replace

/* ==========================================================================
   ETAPE 6 : GRAPHIQUE SYNTHESE AUTOMATISÉ (BONUS 20/20)
   ========================================================================== */

// 1. Préparation du fichier de stockage des résultats
capture postclose memhold
tempname memhold
postfile `memhold' id str20 periode beta lower upper using "graph_data.dta", replace

// --- PERIODE 1 : 2000-2009 ---
use "master_data_projet.dta", clear
keep if annee >= 2000 & annee <= 2009
collapse (mean) Investissement Epargne, by(pays)
quietly reg Investissement Epargne
post `memhold' (1) ("2000-2009") (_b[Epargne]) (_b[Epargne] - 1.96*_se[Epargne]) (_b[Epargne] + 1.96*_se[Epargne])

// --- PERIODE 2 : 2010-2019 ---
use "master_data_projet.dta", clear
keep if annee >= 2010 & annee <= 2019
collapse (mean) Investissement Epargne, by(pays)
quietly reg Investissement Epargne
post `memhold' (2) ("2010-2019") (_b[Epargne]) (_b[Epargne] - 1.96*_se[Epargne]) (_b[Epargne] + 1.96*_se[Epargne])

// --- PERIODE 3 : 2020-2024 ---
use "master_data_projet.dta", clear
keep if annee >= 2020 & annee <= 2024
collapse (mean) Investissement Epargne, by(pays)
quietly reg Investissement Epargne
post `memhold' (3) ("2020-2024") (_b[Epargne]) (_b[Epargne] - 1.96*_se[Epargne]) (_b[Epargne] + 1.96*_se[Epargne])

postclose `memhold'

// 2. Chargement des résultats
use "graph_data.dta", clear
label define period_lbl 1 "2000-2009" 2 "2010-2019" 3 "2020-2024"
label values id period_lbl

// 3. Création du Graphique (Correction xlim -> xscale)
set scheme s1color
set graphics on

twoway (rcap lower upper id, lcolor(gs10) lwidth(medium)) ///
       (scatter beta id, mcolor(navy) msymbol(square) msize(medium) mlabel(beta) mlabpos(9) mlabsize(small)), ///
       yline(0, lcolor(red) lpattern(dash)) ///
       yline(1, lcolor(black) lwidth(thin)) ///
       xlabel(1 2 3, valuelabel noticks) ///
       xscale(range(0.5 3.5)) ///  <-- CORRECTION ICI
       xtitle("") ytitle("Coefficient Beta Estimé") ///
       title("Dynamique de l'intégration financière (OCDE)") ///
       subtitle("Évolution du coefficient Beta et intervalles de confiance (95%)") ///
       legend(order(2 "Estimation Beta" 1 "Intervalle de Confiance 95%") position(6) rows(1)) ///
       text(0.05 3.3 "Mobilité Parfaite", size(vsmall) color(red)) ///
       graphregion(color(white)) name(Graph_Synthese_Auto, replace)

graph export "Graph_Synthese_Beta.png", replace

di _n ">>> GRAPHIQUE SYNTHESE AUTOMATISÉ GÉNÉRÉ AVEC SUCCÈS <<<"
log close

di ">>> FIN DU PROGRAMME - LOG SAUVEGARDE <<<"
