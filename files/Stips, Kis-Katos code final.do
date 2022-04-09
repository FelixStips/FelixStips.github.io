********************************************************************************

*** Title: The impact of co-national networks on asylum seekers’ employment: Quasi-
*** experimental evidence from Germany
*** Data source: Asylbewerberleistungsempfängerstatistik und Zensus2011
***					https://www.forschungsdatenzentrum.de/de/sonstige-sozialstatistiken/asyl
***					https://www.forschungsdatenzentrum.de/de/haushalte/zensus-2011
*** Date: 24.05.2018
***
***
***
*** Variables:	
***
*** Original variable: 			(note: only Asylleistungsempfängerstatistik)
***
*** Kreis: regional county id
*** Jahr: year
*** bl: federal state
*** EF5: type of carrier 
*** EF7: household position
*** EF8: gender
*** EF10: nationality
*** EF11: residence status
*** EF12: type of accomodation
*** EF13: employment status
*** EF34: type of income
*** EF35: income
*** EF38: benefit duration
*** EF39: age at time of reporting
*** EF40: household type
*** EF44: age
*** EF46: gender
*** EF49: Familienstand
*** EF310: Höchster allgemeiner Schulabschluss
*** EF952: Standardhochrechnungsfaktor Jahr (Basis: Zensus 2011)>
***
***
***
***
*** New variables:
***
*** age: =EF39
*** duration: =EF38
*** status: =EF11
*** origin: =EF10
*** female: dichotomous variable with female yes/no
*** träger: dichotomous variable with supralocal carrier yes/no
*** duration_j: benefit duration in years
*** age_cat: age in 5-year categories 
*** employment: dichotomous variables employed yes/no 
*** fullempl: dichotomous variable employed full-time yes/no 
*** partempl: dichotomous variable employed part-time yes/no 
*** hhhead: dichotomous variable household head yes/no 
*** hhsize: number of household members
*** wage: Income from employment in Euros 
*** wage_asinh: inverse hyperbolic sine of wage income
*** income_asinh: inverse hyperbolic sine of EF35
*** Anzahl_kreis: number of asylum seekers at in county  
*** network1_kreis: number of asylum seekers from same nationality in county 
*** network3_kreis: numer of asylum seekers from same nationality arrived in same year in county 
*** network1_kreis_asinh: inverse hyperbolic sine of network1_kreis 
*** network3_kreis_asinh: inverse hyperbolic sine of network3_kreis
*** network40_kreis: number of asylum seekers from same nationality aged below 18 in county
*** network41_kreis: number of asylum seekers from same nationality aged 18 - 25 in county 
*** network42_kreis: number of asylum seekers from same nationality aged 26 - 35 in county
*** network43_kreis: number of asylum seekers from same nationality aged 36 - 65 in county 
*** network44_kreis: number of asylum seekers from same nationality aged above 65 in county 
*** network40_kreis_asinh: inverse hyperbolic sine of network40_kreis
*** network41_kreis_asinh: inverse hyperbolic sine of network41_kreis
*** network42_kreis_asinh: inverse hyperbolic sine of network42_kreis
*** network43_kreis_asinh: inverse hyperbolic sine of network43_kreis
*** network44_kreis_asinh: inverse hyperbolic sine of network44_kreis
*** network50_kreis: number of non-employed asylum seekers from same nationality in county 
*** network51_kreis: number of employed asylum seekers from same nationality in county 
*** network50_kreis_asinh: inverse hyperbolic sine of network50_kreis
*** network51_kreis_asinh: inverse hyperbolic sine of network51_kreis
*** networkMigr_kreis: number of persons with migratory background from same nationality in county (2011 based on Census) 
*** networkMigr_kreis_asinh: inverse hyperbolic sine of networkMigr_kreis
***	parent: dichotomous variables if person has children yes/no
*** duration_jg: benefit duration truncated at 10 years 
*** dur_i: Umkodierung von duration_j in
*** age_cat2: Umkodierung von EF39
*** employment2: employment variable based on condition wage income > 0 
*** employment3 = employment2 * 100
*** aufentbefugnis: dichotomous variable = 1 if status == 1
*** aufentgestattung: dichotomous variable = 1 if status == 0
*** ausreiseverpfl: dichotomous variable = 1 if status == 2
*** familienang: dichotomous variable = 1 if status == 3
*** gedultet: dichotomous variable = 1 if status == 4 
*** flughafenein: dichotomous variable = 1 if status == 5
*** zweitantrag: dichotomous variable = 1 if  status == 6
***
*** Weighting variables: none
***
********************************************************************************
********************************************************************************

adopath + "Q:\Afs\55_FDZ\Tools\STATA\fdzado"

*******************Programm start*******************

cap clear matrix
cap log close
clear all
version 14 
set more off, permanently
set mem 1000m
set matsize 11000
set maxvar 20000
set seed 7
set logtype text
set linesize 255
set dp comma, permanently
set scrollbufsize 2000000

*** packages
ssc install avar
ssc install reghdfe
ssc install estout //FDZ-Kommentar: bereits installiert
ssc install egenmore //FDZ-Kommentar: bereits installiert
ssc install erepost
ssc install bigtab
ssc install tabout
ssc install tuples
ssc install mdesc
ssc install spmap		// package for heatmaps
ssc install shp2dta		// package for heatmaps
ssc install mif2dta		// package for heatmaps
ssc install mergepoly		// collapse states in shapefile

*** Ado-path
*sysdir set PERSONAL "<Pfad wird im Forschungsdatenzentrum ergänzt>"
*adopath + "Q:\AfS\55_FDZ\Tools\STATA\ado" 
mata mata mlib index

*** Paths 
global DATADIR "Q:\AfS\55_FDZ\Forschungsprojekte\2017-3344 Uni Göttingen - Kis-Katos"
global LOGDIR "Q:\AfS\55_FDZ\Forschungsprojekte\2017-3344 Uni Göttingen - Kis-Katos\KDFV\2018_05_25" //FDZ-Kommentar: Bitte stets das Datum anpassen (Eingang Auftrags-E-Mail)
global arbeitsdat "Q:\AfS\55_FDZ\Forschungsprojekte\2017-3344 Uni Göttingen - Kis-Katos\Daten\Arbeitsdateien"
global outputpfad "Q:\AfS\55_FDZ\Forschungsprojekte\2017-3344 Uni Göttingen - Kis-Katos\KDFV\2018_05_25" //FDZ-Kommentar: Bitte stets das Datum anpassen (Eingang Auftrags-E-Mail)
global datenpfad "$DATADIR\Daten\"

*** Makros für Datei- und Outputnamen
global dateiname "3344_KDFV_Zensus_Asyl_2010-2016.dta"							// ändern
global dateiname2 "Manipulated_dataset.dta"
local date = c(current_date)
global outputname "analysis`date'"

********************************************************************************************************************
*** Aufzeichung in Protokoll starten.
capture log close
log using "$LOGDIR/$outputname.log", replace
********************************************************************************************************************
********************************************************************************************************************
********************************************************************************************************************






********************************************************************************************************************
*** I. Data preparation
********************************************************************************************************************

*** a. read data
use "$datenpfad\$dateiname", replace


*** drop superfluous counties
drop if merge1 == 1


*** b. clean and rename variable
numlabel, add
	
** change coding from census
ds, has(type string)															
foreach z of varlist `r(varlist)' {												
	disp "`z'"
	count if `z' == "/"
	count if `z' == "-"											
		cap replace `z' = subinstr(`z',"/",.,.)										
		cap replace `z' = subinstr(`z',"-",0,.)
}

** destring
destring Kreis, replace
rename Gemeinde Gemeinde_zen
egen gem = sieve(EF6), keep(numeric)										
destring gem, replace
rename gem Gemeinde
compare Gemeinde Gemeinde_zen

** rename
* census variables
foreach name in bild1_anteil_ bild2_anteil_ bild3_anteil_ erwerb_anteil_ erwerb1_anteil_ erwerb2_anteil_ erwerb3_anteil_ erwerb_migr_anteil_ erwerb1_migr_anteil_ erwerb2_migr_anteil_ erwerb3_migr_anteil_ wz1_anteil_ wz2_anteil_ wz3_anteil_ auspendler_anteil_ einpendler_anteil_ {
	rename `name'gg `name'gem
}

* Gender 
rename EF8 female
recode female (1=0) (2=1) (.=.)
label def female 0 "male" 1 "female"
label values female female

* Carrier
rename EF5 träger
recode träger (2 = 1) (1 = 0)
label def träger 0 "örtlich" 1 "überörtlich"
label values träger träger

* Residence
rename EF12 wohn
recode wohn (1=2) (2=0) (3=1)
label def wohn 0 "Gemeinschaftsunterkunft" 1 "Dezentrale Unterbringung" 2 "Aufnahmeeinrichtung" 
label values wohn wohn

* Age
rename EF39 age 

* benefit duration
rename EF38 duration

* income
gen income = EF35
recode income (. = 0) 	 														// Wenn kein Einkommen angegeben wurde ist auch keins da.
replace income = 0 if EF34 == 6 | EF34 == 1 
label var income "Höhe des eingesetzten Einkommens und Vermögens, ausgenommen Erwerbstätigkeit"

* residency status
rename EF11 status	
recode status (1 = 0) (6 = 1)  (7 = 6)
replace status = . if status == 8						
label def status 0 "Aufenthaltsgestattung" 1 "Aufenthaltsbefugnis"  2 "Ausreiseverpflichtung" ///
				 3 "Familienangehöriger" 4 "Gedultete(r)" 5 "Einreise über Flughagen" 6 "Folge- oder Zweitantrag", replace
label values status status

* create dummy variables
gen aufentbefugnis = (status == 1)
gen aufentgestattung = (status == 0)
gen ausreiseverpfl = (status == 2)
gen familienang = (status == 3)
gen gedultet = (status == 4)
gen flughafenein = (status == 5)
gen zweitantrag = (status == 6)


* Adjust country names
rename EF10 origin
recode origin (999 = .) (998 = .) (533 = .) 									// "ungeklärt", "ohne Angabe" und "533" als missing, "staatenlos" als eigene Kategorie gelassen.
recode origin (120 = .) (132 = .) (133 = .) (138 = .) (159 = .)					// "Serbien, einschließlich ist Kosovo", "Serbien und Montenegro", "Jugoslawien" und "Sowjetunion" als missing
replace origin = 277 if origin == 276 											// "Sudan, einschließlich Südsudan" ist "Sudan" 
					
label var origin "Staatsangehörigkeit"

********************************************************************************************************************

*** c. Create variables

tempvar one
gen `one' = 1

* benefit duration
qui su duration, meanonly
local end = `r(max)' + 1
egen duration_j = cut(duration), at(0(12)`end')
replace duration_j = duration_j / 12
label var duration_j "Leistungsgewährung in ganzen Jahren"

* truncated benefit duration
gen duration_jg = duration_j
replace duration_jg = 10 if duration_jg > 10 & duration_jg != .
label var duration_jg "Aufenthaltsdauer in Jahren, clustered ab 10 Jahren"

* age categories
qui su age, meanonly
local end = r(max) + 1
egen age_cat = cut(age), at(0,15(5)65,`end')									// Die Werte hier sind jetzt nicht brauchbar aber egal weil wir eh Dummies nehmen
label var age_cat "Alter in 5er-Jahresschritten"

* employment 
gen employment = EF13
recode employment (2 = 1) (3 = 0) (. = 0)
label var employment "1 wenn erwerbstätig zum Erhebungszeitpunkt"

* monthly wage income
gen wage = .
replace wage = EF35 if EF34 == 1
label var wage "Monthly wage income in €"
replace wage = . if wage == 0

* transformed wage income
gen wage_asinh = asinh(wage)
label var wage_asinh "Transformiertes Monatliches Einkommen aus Erwerbstätigkeit"

* full-time employment
gen fullempl = (EF13 == 1)
label var fullempl "1 wenn Vollzeitertwerb zum Erhebungszeitpunkt"

* part-time employment
gen partempl = (EF13 == 2)
label var partempl "1 wenn Teilzeiterwerb zum Erhebungszeitpunkt"
 
* any employment
gen employment2 = employment
replace employment2 = 1 if employment == 0 & wage > 0 & wage < .

* household head
gen hhhead = (EF7 == 1)
label var hhhead "1 wenn Person Haushaltsvorstand ist" 

* household size
bysort Jahr EF4: egen hhsize = total(`one')
label var hhsize "Anzahl der Personen im Haushalt"

* children
gen parent = (EF40 == 2 | EF40 == 5 | EF40 == 6)
label var parent "Eltern; Kodierung nach EF 40" 

* tranformed income
gen income_asinh = asinh(income)
label var income_asinh "Transformiertes Monatliches Einkommen oder Vermögen"

* nationality times county identifier.
cap egen group = group(Kreis origin)


********************************************************************************************************************************************

* number of asylum seekers in county
bysort Jahr Kreis: gen Anzahl_kreis = _N
replace Anzahl_kreis = . if Kreis == . | Jahr == . | origin == .
label var Anzahl_kreis "Anzahl der Asylbewerber*innen je Kreis"

* transformed number of asylum seekers in country
gen Anzahl_kreis_asinh = asinh(Anzahl_kreis)
label var Anzahl_kreis_asinh "Transformierte Anzahl der Asylbewerber*innen je Kreis"


**********************************************************************************************************************

* asylum network 1
bysort Jahr Kreis origin: gen network1_kreis = _N - 1
replace network1_kreis = . if Kreis == . | origin == . | Jahr == .
label var network1_kreis "Anzahl der Asylbewerber*innen aus dem gleichen Herkunftsland auf Kreisebene"

* transformed asylum network 1
gen network1_kreis_asinh = asinh(network1_kreis)
label var network1_kreis_asinh "Transformierte Anzahl der Asylbewerber*innen aus dem gleichen Herkunftsland auf Kreisebene"


****************************************************************************************************************************

* asylum network 3 (cohorts)
bysort Jahr Kreis origin duration_jg: gen network3_kreis = _N - 1
replace network3_kreis = . if duration_jg == . | Kreis == . | origin == . | Jahr == .
label var network3_kreis "Anzahl der Asylbewerber*innen aus dem gleichen Herkunftsland in der gleichen Kohorte auf Kreisebene"

* transformed asylum network 3
gen network3_kreis_asinh = asinh(network3_kreis)
label var network3_kreis_asinh "Transformierte Anzahl der Asylbewerber*innen aus dem gleichen Herkunftsland in der gleichen Kohorte auf Kreisebene"



***********************************************************************************************************************************************

* Migrant network variable
gen networkMigr_kreis = 0
replace networkMigr_kreis = migr_land1_anteil_kreis * ew_amt_kreis if origin == 121		// Albanien
replace networkMigr_kreis = migr_land2_anteil_kreis * ew_amt_kreis if origin == 122		// Bosnien und Herzegowina
replace networkMigr_kreis = migr_land3_anteil_kreis * ew_amt_kreis if origin == 140		// Montenegro
replace networkMigr_kreis = migr_land4_anteil_kreis * ew_amt_kreis if origin == 144		// Mazedonien
replace networkMigr_kreis = migr_land5_anteil_kreis * ew_amt_kreis if origin == 150		// Kosovo
replace networkMigr_kreis = migr_land6_anteil_kreis * ew_amt_kreis if origin == 166		// Ukraine
replace networkMigr_kreis = migr_land7_anteil_kreis * ew_amt_kreis if origin == 170		// Serbien
replace networkMigr_kreis = migr_land8_anteil_kreis * ew_amt_kreis if origin == 221		// Algerien
replace networkMigr_kreis = migr_land9_anteil_kreis * ew_amt_kreis if origin == 224		// Eritrea
replace networkMigr_kreis = migr_land10_anteil_kreis * ew_amt_kreis if origin == 225		// Äthiopien
replace networkMigr_kreis = migr_land11_anteil_kreis * ew_amt_kreis if origin == 238		// Ghana
replace networkMigr_kreis = migr_land12_anteil_kreis * ew_amt_kreis if origin == 246		// Kongo, Demokratische Republik
replace networkMigr_kreis = migr_land13_anteil_kreis * ew_amt_kreis if origin == 252		// Marokko
replace networkMigr_kreis = migr_land14_anteil_kreis * ew_amt_kreis if origin == 261		// Guinea
replace networkMigr_kreis = migr_land15_anteil_kreis * ew_amt_kreis if origin == 277		// Sudan
replace networkMigr_kreis = migr_land16_anteil_kreis * ew_amt_kreis if origin == 287		// Ägypten
replace networkMigr_kreis = migr_land17_anteil_kreis * ew_amt_kreis if origin == 422		// Armenien
replace networkMigr_kreis = migr_land18_anteil_kreis * ew_amt_kreis if origin == 423		// Afghanistan
replace networkMigr_kreis = migr_land19_anteil_kreis * ew_amt_kreis if origin == 430		// Georgien
replace networkMigr_kreis = migr_land20_anteil_kreis * ew_amt_kreis if origin == 431		// Sri Lanka
replace networkMigr_kreis = migr_land21_anteil_kreis * ew_amt_kreis if origin == 436		// Indien
replace networkMigr_kreis = migr_land22_anteil_kreis * ew_amt_kreis if origin == 438		// Irak
replace networkMigr_kreis = migr_land23_anteil_kreis * ew_amt_kreis if origin == 439		// Iran
replace networkMigr_kreis = migr_land24_anteil_kreis * ew_amt_kreis if origin == 451		// Libanon
replace networkMigr_kreis = migr_land25_anteil_kreis * ew_amt_kreis if origin == 461		// Pakistan
replace networkMigr_kreis = migr_land26_anteil_kreis * ew_amt_kreis if origin == 475		// Syrien
replace networkMigr_kreis = migr_land27_anteil_kreis * ew_amt_kreis if origin == 273		// Somalia
replace networkMigr_kreis = migr_land28_anteil_kreis * ew_amt_kreis if origin == 425		// Aserbaidschan
replace networkMigr_kreis = migr_land29_anteil_kreis * ew_amt_kreis if origin == 163		// Türkei
replace networkMigr_kreis = migr_land30_anteil_kreis * ew_amt_kreis if origin == 160		// Russische Föderation
replace networkMigr_kreis = migr_land31_anteil_kreis * ew_amt_kreis if origin == 232		// Nigeria

replace networkMigr_kreis = . if Kreis == . | origin == . | Jahr == .
label var networkMigr_kreis "Anzahl der Personen mit Migrationshintergrund vom gleichen Herkunftsland je Kreis"

* transformed migrants network
gen networkMigr_kreis_asinh = asinh(networkMigr_kreis)
label var networkMigr_kreis_asinh "Transformierte Anzahl der Personen mit Migrationshintergrund vom gleichen Herkunftsland je Kreis"


************************************************************************************************************************************

**************************************************
*** Calculate cohort sizes ***
**************************************************

foreach n in 1 2 3 4  {
	preserve
	keep duration_jg Jahr Kreis origin network3_kreis 
	replace duration_jg = duration_jg - `n'
	rename network3_kreis L`n'network3_kreis
	replace L`n'network3_kreis = L`n'network3_kreis + 1							// no need to substract the person itself
	duplicates drop
	save "$arbeitsdat\temp`n'.dta", replace
	restore
}


foreach n in 1 2 3 4 {
	merge m:1 Jahr Kreis origin duration_jg using "$arbeitsdat\temp`n'.dta"
	drop if _merge == 2
	replace L`n'network3_kreis = 0 if L`n'network3_kreis == . & _merge == 1							// Set zero where no observation for merging
	replace L`n'network3_kreis = . if duration_jg == . | Kreis == . | origin == . | Jahr == .
	drop _merge
	erase "$arbeitsdat\temp`n'.dta"
}



* Set missing for those who cannot have a lag													
	su duration_jg, meanonly
	replace L1network3_kreis = . if duration_jg == `r(max)'
	replace L2network3_kreis = . if duration_jg == `r(max)' | duration_jg == `r(max)' - 1
	replace L3network3_kreis = . if duration_jg == `r(max)' | duration_jg == `r(max)' - 1 | duration_jg == `r(max)' - 2
	replace L4network3_kreis = . if duration_jg == `r(max)' | duration_jg == `r(max)' - 1 | duration_jg == `r(max)' - 2 | duration_jg == `r(max)' - 3
	
label var L1network3_kreis "Anzahl der Asylbewerber*innen aus dem gleichen Herkunftsland in der vorherigen Kohorte auf Kreisebene"
label var L2network3_kreis "Anzahl der Asylbewerber*innen aus dem gleichen Herkunftsland in der Kohorte vor zwei Jahren auf Kreisebene"
label var L3network3_kreis "Anzahl der Asylbewerber*innen aus dem gleichen Herkunftsland in der Kohorte vor drei Jahren auf Kreisebene"
label var L4network3_kreis "Anzahl der Asylbewerber*innen aus dem gleichen Herkunftsland in der Kohorte vor vier Jahren auf Kreisebene"


* transformed cohort
foreach n in 1 2 3 4 {
	gen L`n'network3_kreis_asinh = asinh(L`n'network3_kreis)
	label var L`n'network3_kreis_asinh "Transformierte Anzahl der Asylbewerber*innen aus dem gleichen Herkunftsland in der Kohorte vor `n' Jahren auf Kreisebene"
}


******************************************************************************************************************************************************

************************************************
*** network by age ***
************************************************

gen age_cat2 = . 
replace age_cat2 = 0 if age < 18
replace age_cat2 = 1 if age >= 18 & age <= 25
replace age_cat2 = 2 if age > 25 & age <= 35
replace age_cat2 = 3 if age > 35 & age <= 65
replace age_cat2 = 4 if age > 65 & age < .


* Asylnetzwerkvariable 4 als Anzahl auf Kreisebene

cap egen group = group(Kreis Jahr origin)

forval i = 0(1)4 {
	bysort Jahr Kreis origin age_cat2: gen temp = _N
	replace temp = 0 if age_cat2 != `i'
	replace temp = 0 if age_cat2 == .
	egen temp2 = max(temp), by(group)
	gen network4`i'_kreis = . 
	replace network4`i'_kreis = temp2 - 1 if age_cat2 == `i'
	replace network4`i'_kreis = temp2 if age_cat2 != `i'
	replace network4`i'_kreis = . if age_cat2 == . | Kreis == . | origin == . | Jahr == .
	drop temp temp2
}


label var network40_kreis "Anzahl der Asylbewerber*innen aus dem gleichen Herkunftsland im Alter unter 15 auf Kreisebene"
label var network41_kreis "Anzahl der Asylbewerber*innen aus dem gleichen Herkunftsland im Alter 18 - 25 auf Kreisebene"
label var network42_kreis "Anzahl der Asylbewerber*innen aus dem gleichen Herkunftsland im Alter 26 - 35 auf Kreisebene"
label var network43_kreis "Anzahl der Asylbewerber*innen aus dem gleichen Herkunftsland im Alter 36 - 65 auf Kreisebene"
label var network44_kreis "Anzahl der Asylbewerber*innen aus dem gleichen Herkunftsland im Alter über 65 auf Kreisebene"


* tranformed network 4
gen network40_kreis_asinh = asinh(network40_kreis)
label var network40_kreis_asinh "Anzahl der Asylbewerber*innen aus dem gleichen Herkunftsland im Alter bis 15 Jahre auf Kreisebene transformiert"
 
gen network41_kreis_asinh = asinh(network41_kreis)
label var network41_kreis_asinh "Transformierte Anzahl der Asylbewerber*innen aus dem gleichen Herkunftsland im Alter 15 - 25 auf Kreisebene"

gen network42_kreis_asinh = asinh(network42_kreis)
label var network42_kreis_asinh "Transformierte Anzahl der Asylbewerber*innen aus dem gleichen Herkunftsland im Alter 26 - 35 auf Kreisebene"

gen network43_kreis_asinh = asinh(network43_kreis)
label var network43_kreis_asinh "Transformierte Anzahl der Asylbewerber*innen aus dem gleichen Herkunftsland im Alter 36 - 65 auf Kreisebene"

gen network44_kreis_asinh = asinh(network44_kreis)
label var network44_kreis_asinh "Transformierte Anzahl der Asylbewerber*innen aus dem gleichen Herkunftsland im Alter über 65 auf Kreisebene"


gen check1 = network40_kreis + network41_kreis + network42_kreis + network43_kreis + network44_kreis
assert check1 == network1_kreis
drop check1

***********************************************************************************************************************************************

********************************************
*** Network by employment ***
********************************************

*** Number unemployed

bysort Kreis Jahr origin employment2: gen temp = _N
replace temp = 0 if employment2 != 0
egen temp2 = max(temp), by(group)
gen network50_kreis = .
replace network50_kreis = temp2 - 1 if employment2 == 0
replace network50_kreis = temp2 if employment2 == 1
replace network50_kreis = . if employment2 == . | Kreis == . | origin == . | Jahr == .
drop temp temp2

*** Number employed

bysort Kreis Jahr origin employment2: gen temp = _N
replace temp = 0 if employment2 != 1
egen temp2 = max(temp), by(group)
gen network51_kreis = .
replace network51_kreis = temp2 - 1 if employment2 == 1
replace network51_kreis = temp2 if employment2 == 0
replace network51_kreis = . if employment2 == . | Kreis == . | origin == . | Jahr == .
drop temp temp2

label var network50_kreis "Anzahl der nicht erwerbstätigen Asylbewerber*innen aus dem gleichen Herkunftsland im gleichen Kreis"
label var network51_kreis "Anzahl der erwerbstätigen Asylbewerber*innen aus dem gleichen Herkunftsland im gleichen Kreis"

gen check2 = network50_kreis + network51_kreis
assert check2 == network1_kreis
drop check2

drop group

*** transformed variables
gen network50_kreis_asinh = asinh(network50_kreis)
label var network50_kreis_asinh "Transformierte Anzahl der nicht erwerbstätigen Asylbewerber*innen aus dem gleichen Herkunftsland im gleichen Kreis"

gen network51_kreis_asinh = asinh(network51_kreis)
label var network50_kreis_asinh "Transformierte Anzahl der erwerbstätigen Asylbewerber*innen aus dem gleichen Herkunftsland im gleichen Kreis"

************************************************************************************************************************************************

**************************************************************************************************************************************************

drop age_cat2 `one' ausl_* migr_land*
numlabel, add
cap erase "$arbeitsdat\temp.dta"
save "$datenpfad\$dateiname2", replace


*****************************************************************************************************************************************

********************************************************************************************************************
*** II. Analysis 
********************************************************************************************************************

*****************************************************************************************************************************************

use "$datenpfad\$dateiname2", replace

drop merge* *_gem bev018_anteil_kreis bev1924_anteil_kreis bev2539_anteil_kreis bev4066_anteil_kreis bev6774_anteil_kreis bev75_anteil_kreis EF15 EF16 EF17 EF18 EF19 EF23 EF24 EF25 EF26 EF27 EF28 migr_reg1_anteil_kreis migr_reg2_anteil_kreis migr_reg2_anteil_kreis migr_reg3_anteil_kreis migr_reg4_anteil_kreis migr_reg5_anteil_kreis migr_reg6_anteil_kreis

cd "$outputpfad/"
cap drop __000001


*** Figure 2: Geographical Variation in Local Asylum Seeker Networks

preserve
keep share_asyl Kreis
duplicates drop
collapse (mean) share_asyl network1_kreis, by(Kreis)
export excel share_asyl network1_kreis Kreis using "data_figure_2", firstrow(varlabels) replace
restore

// for next steps use results from KDFV

/*
clear
import excel "$outputpfad/data_figure_2", sheet("Sheet1") firstrow
replace meanshare_asyl = meanshare_asyl * 100
rename meanshare_asyl share_asyl
rename REGION_KREIS Kreis
label var share_asyl "Mean share of asylum seekers relative to total population in %"
save "$outputpfad/temp.dta", replace

use "$datenpfad\$dateiname2", replace
keep Kreis NAME_KREIS
destring Kreis, replace
drop if Kreis == .
duplicates drop
merge 1:1 Kreis using "$outputpfad/temp.dta"
drop if Kreis == .
drop _merge
save "$outputpfad/Map.dta", replace
cap erase "$outputpfad/temp.dta"

/// for next steps need Germany shape files (VG250_KRS.dbf and VG250_KRS.shp) in outputfolder

clear
cd "$outputpfad/"
use "$outputpfad/Map.dta", clear
save Landkresie_kfs, replace 
shp2dta using VG250_KRS.shp, database(Deutschland) coordinates(coordinates) genid(id) replace
use Deutschland, clear 
rename RS rs
destring rs, replace
rename rs Kreis
merge m:1 Kreis using Landkresie_kfs
spmap share_asyl using coordinates, id(id) fcolor(Blues) ndfcolor(gs10) clmethod(custom) clbreaks(0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 100)
graph save "Figure_2_panel_A.png", replace

clear
cd "$outputpfad/"
use "$outputpfad/Map.dta", clear
save Landkresie_kfs, replace 
shp2dta using VG250_KRS.shp, database(Deutschland) coordinates(coordinates) genid(id) replace
use Deutschland, clear 
rename RS rs
destring rs, replace
rename rs Kreis
merge m:1 Kreis using Landkresie_kfs
spmap network1_kreis using coordinates, id(id) fcolor(Blues) ndfcolor(gs10) clmethod(custom) clbreaks(0 25 50 75 100)
graph save "Figure_2_panel_A.png", replace
*/

*** Table 12: Main countries of Origin

clear
use "$datenpfad\$dateiname2", replace
cd "$outputpfad/"	
groups origin, order(h) select(50) saving(table_12)



*****************************************************************************************************************************************

keep if Jahr != .																// Sampleeingrenzung
keep if Kreis != .
keep if age >= 18 & age <= 65													
keep if female == 0															
keep if wohn!= 2																
keep if origin == 121 | origin == 122 | origin == 140 | origin == 144 | origin == 150 | /*
	 */ origin == 166 | origin == 170 | origin == 221 | origin == 224 | origin == 225 | /*
	 */ origin == 238 | origin == 246 | origin == 252 | origin == 261 | origin == 277 | /*
	 */ origin == 287 | origin == 422 | origin == 423 | origin == 430 | origin == 431 | /*
	 */ origin == 436 | origin == 438 | origin == 439 | origin == 451 | origin == 461 | /*
	 */ origin == 475 | origin == 273 | origin == 425 | origin == 163 | origin == 160 | origin == 232 | /* 		Länder aus Verfahrensbeschreibung
	 */ origin == 237 | origin == 269 | origin == 460 | origin == 269 | origin == 285 | origin == 248 | /*		Andere häufig vorkommende Länder, die Sinn machen
	 */ origin == 251 | origin == 231 | origin == 243 | origin == 272 | origin == 283 | origin == 223 | origin == 229


*********************************************************************************************************************


*** Define Globals

global sumvars partempl fullempl lostempl employment2 wage wage_asinh age wohn duration träger hhhead hhsize parent income income_asinh aufentbefugnis aufentgestattung ausreiseverpfl familienang ///
gedultet flughafenein zweitantrag network1_kreis network1_kreis_asinh Anzahl_kreis Anzahl_kreis_asinh networkMigr_kreis networkMigr_kreis_asinh network1_kreis network1_kreis_asinh network3_kreis ///
network3_kreis_asinh L1network3_kreis L1network3_kreis_asinh L2network3_kreis L2network3_kreis_asinh L3network3_kreis L3network3_kreis_asinh L4network3_kreis L4network3_kreis_asinh network40_kreis ///
network40_kreis_asinh network41_kreis network41_kreis_asinh network42_kreis network42_kreis_asinh network43_kreis network43_kreis_asinh network44_kreis network44_kreis_asinh network50_kreis network51_kreis ///
network50_kreis_asinh network51_kreis_asinh ew_amt_kreis bild1_anteil_kreis bild2_anteil_kreis bild3_anteil_kreis wz1_anteil_kreis wz2_anteil_kreis wz3_anteil_kreis einpendler_anteil_kreis auspendler_anteil_kreis ///
bevdichte_kreis bevarb_anteil_kreis bev_mann_anteil_kreis fluktuation_kreis erwerb1_anteil_kreis erwerb1_migr_anteil_kreis fluktuation_mig_kreis migr_anteil_kreis

global indvars2 i.age_cat i.status wohn ib4.dur_i träger hhhead hhsize parent income_asinh

***********************************************************************************************************************************************

*** Figure 3: Employment Shares by Year and Benefit Duration
* Panel A: mployment Share by Benefit Duration
twoway (connected empl_share duration_jg, sort mcolor(green) lcolor(dknavy)), ylabel(, angle(horizontal) format(%9,0g)) ytitle("Employment Shares in %") xtitle("Benefit Duration in Years")
graph export "Figure_4A.png", replace

* Panel B: Employment Shares by Year
gen employment3 = employment2 * 100
graph bar (mean) employment3, over(Jahr) ytitle(Mean Employment Share) ylabel(, angle(horizontal) ticks)
graph export "Figure_4B.png", replace



*** Figure 4: Transformed and untransformed network measure
histogram network1_kreis, freq width(100) start(0) fcolor(sand) lcolor(brown) normal normopts(lcolor(cranberry)) ylabel(, angle(horizontal) ticks) xtitle("Number of asylum seekers from same country of origin")
graph export "Figure_3A.png", replace

histogram network1_kreis_asinh, freq width(1) start(0) fcolor(sand) lcolor(brown) normal normopts(lcolor(cranberry)) ylabel(, angle(horizontal) ticks) xtitle("Transformed number of asylum seekers from same country of origin")
graph export "Figure_3B.png", replace



*** Table 1: Employment Effects of Co-National Networks of Asylum Seekers
* Panel A: Composite effects
	estimates clear
	eststo: reg employment2 network1_kreis_asinh, clust(group)
	eststo: reg employment2 network1_kreis_asinh $indvars2, clust(group)
	eststo: reghdfe employment2 network1_kreis_asinh $indvars2, absorb(i.origin#i.Jahr) vce(cluster Kreis#origin) fast subopt(noconstant) 
	eststo: reghdfe employment2 network1_kreis_asinh $indvars2, absorb(i.origin#i.Jahr i.Kreis#i.Jahr) vce(cluster Kreis#origin) fast subopt(noconstant) 
	eststo: reghdfe employment2 network1_kreis_asinh $indvars2, absorb(i.origin#i.Jahr i.Kreis#i.Jahr i.origin#i.Kreis) vce(cluster Kreis#origin) fast subopt(noconstant)
	eststo: reghdfe employment2 network1_kreis_asinh networkMigr_kreis $indvars2, absorb(i.origin#i.Jahr i.Kreis#i.Jahr) vce(cluster Kreis#origin) fast subopt(noconstant) 	
	estfe . * 
	estout * using "$outputpfad\table_1A.txt", replace cells(b(star fmt(%9.3f)) se(fmt(%9.3f))) style(fixed) stats(N, fmt(3) label("N")) starlevels(* 0.1 ** 0.05 *** 0.01) legend
	estfe . *, restore	
	
* Panel B: employment status decomposition
	estimates clear
	eststo: reg employment2 network50_kreis_asinh network51_kreis_asinh, clust(group)
	eststo: reg employment2 network50_kreis_asinh network51_kreis_asinh $indvars2, clust(group)
	eststo: reghdfe employment2 network50_kreis_asinh network51_kreis_asinh $indvars2, absorb(i.origin#i.Jahr) vce(cluster Kreis#origin) fast subopt(noconstant) 
	eststo: reghdfe employment2 network50_kreis_asinh network51_kreis_asinh $indvars2, absorb(i.origin#i.Jahr i.Kreis#i.Jahr) vce(cluster Kreis#origin) fast subopt(noconstant) 
	eststo: reghdfe employment2 network50_kreis_asinh network51_kreis_asinh $indvars2, absorb(i.origin#i.Jahr i.Kreis#i.Jahr i.origin#i.Kreis) vce(cluster Kreis#origin) fast subopt(noconstant)
	estfe . * 
	estout * using "$outputpfad\table_1B.txt", replace cells(b(star fmt(%9.3f)) se(fmt(%9.3f))) style(fixed) stats(N, fmt(3) label("N")) starlevels(* 0.1 ** 0.05 *** 0.01) legend
	estfe . *, restore	
	
	

*** Table 2: Employment Effects: Heterogeneity by arrival and age cohorts
* Panel A: Cohort decomposition
	estimates clear
	eststo: reg employment2 network3_kreis_asinh L1network3_kreis_asinh L2network3_kreis_asinh L3network3_kreis_asinh L4network3_kreis_asinh, clust(group)
	eststo: reghdfe employment2 network3_kreis_asinh L1network3_kreis_asinh L2network3_kreis_asinh L3network3_kreis_asinh L4network3_kreis_asinh $indvars2, absorb(i.origin#i.Jahr) vce(cluster Kreis#origin) fast subopt(noconstant) 	
	eststo: reghdfe employment2 network3_kreis_asinh L1network3_kreis_asinh L2network3_kreis_asinh L3network3_kreis_asinh L4network3_kreis_asinh $indvars2, absorb(i.origin#i.Jahr i.Kreis#i.Jahr) vce(cluster Kreis#origin) fast subopt(noconstant) 
	eststo: reghdfe employment2 network3_kreis_asinh L1network3_kreis_asinh L2network3_kreis_asinh L3network3_kreis_asinh L4network3_kreis_asinh $indvars2, absorb(i.origin#i.Jahr i.Kreis#i.Jahr i.origin#i.Kreis) vce(cluster Kreis#origin) fast subopt(noconstant) 
	estfe . * 
	estout * using "$outputpfad\table_2A.txt", replace cells(b(star fmt(%9.3f)) se(fmt(%9.3f))) style(fixed) stats(N, fmt(3) label("N")) starlevels(* 0.1 ** 0.05 *** 0.01) legend
	estfe . *, restore

* Panel B: Age decomposition
	estimates clear
	eststo: reg employment2 network40_kreis_asinh network41_kreis_asinh network42_kreis_asinh network43_kreis_asinh network44_kreis_asinh, clust(group)
	eststo: reghdfe employment2 network40_kreis_asinh network41_kreis_asinh network42_kreis_asinh network43_kreis_asinh network44_kreis_asinh $indvars2, absorb(i.origin#i.Jahr) vce(cluster Kreis#origin) fast subopt(noconstant)
	eststo: reghdfe employment2 network40_kreis_asinh network41_kreis_asinh network42_kreis_asinh network43_kreis_asinh network44_kreis_asinh $indvars2, absorb(i.origin#i.Jahr i.Kreis#i.Jahr) vce(cluster Kreis#origin) fast subopt(noconstant) 
	eststo: reghdfe employment2 network40_kreis_asinh network41_kreis_asinh network42_kreis_asinh network43_kreis_asinh network44_kreis_asinh $indvars2, absorb(i.origin#i.Jahr i.Kreis#i.Jahr i.origin#i.Kreis) vce(cluster Kreis#origin) fast subopt(noconstant) 
	estfe . * 
	estout * using "$outputpfad\table_2B.txt", replace cells(b(star fmt(%9.3f)) se(fmt(%9.3f))) style(fixed) stats(N, fmt(3) label("N")) starlevels(* 0.1 ** 0.05 *** 0.01) legend
	estfe . *, restore
	
	
	
	
* Table 3 Part- and Full-time Employment Effects of Co-National Networks
foreach var of varlist fullempl partempl {
* Panel A: composite network measure
	eststo: reg `var' network1_kreis_asinh, clust(group)
	eststo: reghdfe `var' network1_kreis_asinh $indvars2, absorb(i.origin#i.Jahr i.Kreis#i.Jahr i.origin#i.Kreis) vce(cluster Kreis#origin) fast subopt(noconstant)
* Panel B: decomposition by employment status
	eststo: reg `var' network50_kreis_asinh network51_kreis_asinh, clust(group)
	eststo: reghdfe `var' network50_kreis_asinh network51_kreis_asinh $indvars2, absorb(i.origin#i.Jahr i.Kreis#i.Jahr i.origin#i.Kreis) vce(cluster Kreis#origin) fast subopt(noconstant)
* Panel C: cohort decomposition
	eststo: reg `var' network3_kreis_asinh L1network3_kreis_asinh L2network3_kreis_asinh L3network3_kreis_asinh L4network3_kreis_asinh, clust(group)
	eststo: reghdfe`var' network3_kreis_asinh L1network3_kreis_asinh L2network3_kreis_asinh L3network3_kreis_asinh L4network3_kreis_asinh $indvars2, absorb(i.origin#i.Jahr i.Kreis#i.Jahr i.origin#i.Kreis) vce(cluster Kreis#origin) fast subopt(noconstant) 
* Panel D: age composition
	eststo: reg `var' network40_kreis_asinh network41_kreis_asinh network42_kreis_asinh network43_kreis_asinh network44_kreis_asinh, clust(group)
	eststo: reghdfe `var' network40_kreis_asinh network41_kreis_asinh network42_kreis_asinh network43_kreis_asinh network44_kreis_asinh $indvars2, absorb(i.origin#i.Jahr i.Kreis#i.Jahr i.origin#i.Kreis) vce(cluster Kreis#origin) fast subopt(noconstant) 
}
	estfe . * 
	estout * using "$outputpfad\table_3.txt", replace cells(b(star fmt(%9.3f)) se(fmt(%9.3f))) style(fixed) stats(N, fmt(3) label("N")) starlevels(* 0.1 ** 0.05 *** 0.01) legend
	estfe . *, restore	
	
	


*** Table A1: Countries of origin
groups origin, order(h) saving(table_A1)




*** Table A2: Summary Statistics

local n = wordcount("$sumvars")
tempname A 

matrix `A' = J(`n',3,.)
matrix colnames `A' = "Obs" "Mean" "Std_Dev"
matrix rownames `A' = $sumvars

local r = 1
forvalues v = 1/`n' {
	local testvar: word `v' of $sumvars	
	qui sum `testvar'
	mat `A'[`v',1] = `r(N)'
	
if  `r(N)' == 0 {
	mat `A'[`v',2] = .
	mat `A'[`v',3] = .
	}
	
if `r(N)' > 0 {
	mat `A'[`v',2] = `r(mean)'
	mat `A'[`v',3] = `r(sd)'
	}
	
	local r = `r' + 1
}
	putexcel set "table_A2", replace
	putexcel A1 = matrix(`A'), names




	
