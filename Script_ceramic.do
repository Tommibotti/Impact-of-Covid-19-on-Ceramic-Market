* clear the memory
clear all
* import the excel file
import excel "C:\Users\TOMMASO\Desktop\Ceramic_Italy_Revenue.xlsx", sheet("Sheet1") firstrow

******************************************************************************************************
* DATA CLEANING
******************************************************************************************************

* rename variables
rename A id
rename Companynam~t Company_Name
rename Operatingr~h revenue2019
rename D revenue2020
rename E revenue2021

* check for n.a.
* 2019
replace revenue2019 = "." if ( revenue2019 == "n.a." )
* 2020
replace revenue2020 = "." if ( revenue2020 == "n.a." )
* 2021
replace revenue2021 = "." if ( revenue2021 == "n.a." )

* destring numeric type variables
destring revenue*, replace
destring id, replace

*Remove negative and zero values of turnover by setting them equal to missing (".")
replace revenue2019 = . if(revenue2019 <= 0) 
replace revenue2020 = . if(revenue2020 <= 0) 
replace revenue2021 = . if(revenue2021 <= 0)

* reduce the number of decimal
format revenue* %12.2f




******************************************************************************************************
* Descriptive Analysis
******************************************************************************************************

summ revenue*
describe

******************************************************************************************************
* Churn Rate for 2020
******************************************************************************************************

* Creation of the counter variables
gen entry_company = 0
gen exit_company = 0
gen company = 0

* Count the firms entering the market in 2020
replace entry_company = 1 if missing(revenue2019) & !missing(revenue2020)

* Count the firm exiting the market 
replace exit_company = 1 if !missing(revenue2020) & missing(revenue2021)

* Conta il numero totale di aziende presenti nel 2020
replace company = 1 if !missing(revenue2020)

* Ottieni il numero totale di aziende entranti e uscenti
egen total_entry = total(entry_company)
egen total_exit = total(exit_company)
egen total_company = total(company)

* Calcola il churn rate
gen churn_rate_2020 = (total_entry + total_exit) / total_company

* Stampa i risultati
display "Total number of firms entering the market: " total_entry
display "Total number of firms exiting the market: " total_exit
display "Total number of firms in 2020: " total_company
display "Churn Rate: " churn_rate_2020

******************************************************************************************************
* ANALYSIS FOR 2019,2020,2021 using LOOP
******************************************************************************************************

forvalues i = 2019(1)2021 {
	
	* box plot
	*graph box revenue`i' , ytitle("Turnover `i'") name(boxMktSize`i')
	* sort revenue descending order
    gsort -revenue`i'
	* cumulative revenue
    gen cumRevenue`i' = sum(revenue`i')
	* total revenue
    egen totalRevenue`i' = max(cumRevenue`i')
	* share of each firm
    gen share`i' = (revenue`i' / totalRevenue`i') * 100
	* Square of the share 
	gen quadraticShare`i' = (share`i')^2
	* cumulative share
    gen cumShare`i' = sum(share`i')
	* cumulative quadratic share
	gen cumQuadraticShare`i' = sum(quadraticShare`i')
    * list of the first 4 firm's share
	list Company_Name share`i' in 1/4
	* descriptive statistics
    summ cumShare`i'
    * rank market share
    egen rank`i' = group(cumShare`i')
	
	* Compute CR4
	gen CR4in`i' = cumShare`i' if(rank`i'==4)
    egen CR4`i' = max(CR4in`i')
	drop CR4in`i'
	
		* Compute CR10
	gen CR10in`i' = cumShare`i' if(rank`i'==10)
    egen CR10`i' = max(CR10in`i')
	drop CR10in`i'
	
	* Compute HHI
	egen HHI`i' = max(cumQuadraticShare`i')
	summ HHI`i'
	

}


******************************************************************************************************
* DATA VISUALIZATION (PLOT)
******************************************************************************************************

*** Box Plot ***
*graph box revenue2019 , title("Revenue 2019") ytitle("Revenue (thousands)") name(boxMktSize2019) ylabel(0(2000)12000) 
*graph box revenue2020 , title("Revenue 2020") ytitle("Revenue (thousands)") name(boxMktSize2020) ylabel(0(2000)12000)
*graph box revenue2021 , title("Revenue 2021") ytitle("Revenue (thousands)") name(boxMktSize2021) ylabel(0(2000)12000)

graph box revenue*, title("Box Plot Revenues") ytitle("Revenues (thousands)") legend(label(1 "2019") label(2 "2020") label(3 "2021")) name(FirmsRevenue) box(1, color(bluishgray)) box(2, color(ltblue)) box(3, color(navy)) ylabel(0(2000)12000)


*** Bar charts for total market share ***

*Name the variables for the three years that we'd like to plot in the bar chart
label variable totalRevenue2019 "2019"
label variable totalRevenue2020 "2020"
label variable totalRevenue2021 "2021"
graph bar (mean) totalRevenue*, title("Total market size") ytitle("Market size (thousands)") legend(label(1 "2019") label(2 "2020") label(3 "2021")) name(Total_Market_Share) bar(1, color(bluishgray)) bar(2, color(ltblue)) bar(3, color(navy)) ylabel(0(10000)60000) barlabel(bar, format(%9.2f))


*** Bar charts CR4s from 2019-2021 ***

* Name the CR4s for the three years that we'd like to plot in the bar chart
label variable CR42019 "2019"
label variable CR42020 "2020"
label variable CR42021 "2021"
graph bar CR4*, title("Top 4 Concentration Ratio") ytitle("CR4 (%)") legend(label(1 "2019") label(2 "2020") label(3 "2021"))name(CR4s) bar(1, color(bluishgray)) bar(2, color(ltblue)) bar(3, color(navy)) ylabel(0 "0%" 20 "20%" 40 "40%" 60 "60%" 80 "80%" 100 "100%")


*** Bar charts CR10s from 2019-2021 ***

* Name the CR4s for the three years that we'd like to plot in the bar chart
label variable CR102019 "2019"
label variable CR102020 "2020"
label variable CR102021 "2021"
graph bar CR10*, title("Top 10 Concentration Ratio") ytitle("CR10 (%)") legend(label(1 "2019") label(2 "2020") label(3 "2021"))name(CR10s) bar(1, color(bluishgray)) bar(2, color(ltblue)) bar(3, color(navy)) ylabel(0 "0%" 20 "20%" 40 "40%" 60 "60%" 80 "80%" 100 "100%")


*** Bar charts HHI from 2019-2021 ***
* Name the CR4s for the three years that we'd like to plot in the bar chart
label variable HHI2019 "2019"
label variable HHI2020 "2020"
label variable HHI2021 "2021"
graph bar HHI*, title("Herfindahl-Hirschman Index") ytitle("HHI") legend(label(1 "2019") label(2 "2020") label(3 "2021"))name(HHI) bar(1, color(bluishgray)) bar(2, color(ltblue)) bar(3, color(navy)) ylabel(0(500)2500)


*** Bar charts Revenue 2019-2021 ***
preserve
keep if revenue2019 > 2000 & revenue2019 != .
graph bar (sum) revenue2019, over(Company_Name, sort(1) descending label(angle(10) labsize(vsmall))) ///
    ytitle("Revenue (thousands)") title("Top 5 Firms 2019") bar(1, color(bluishgray)) ///
    name(revenue2019) ylabel(0(2000)12000)
restore

preserve
keep if revenue2020 > 2000 & revenue2020 != .
graph bar (sum) revenue2020, over(Company_Name, sort(1) descending label(angle(10) labsize(vsmall))) ///
    ytitle("Revenue (thousands)") title("Top 5 Firms 2020") bar(1, color(ltblue)) ///
    name(revenue2020) ylabel(0(2000)12000)
restore

preserve
keep if revenue2021 > 3000 & revenue2021 != .
graph bar (sum) revenue2021, over(Company_Name, sort(1) descending label(angle(10) labsize(vsmall))) ///
    ytitle("Revenue (thousands)") title("Top 5 Firms 2021") bar(1, color(navy)) ///
    name(revenue2021) ylabel(0(2000)12000)
restore


save ceramic.dta, replace

