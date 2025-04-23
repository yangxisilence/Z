cd"C:\Users\qss\Desktop\2023"
*合并过程1
use firm+控制变量.dta,replace
merge 1:1 year city using 智慧城市.dta
sort city year
keep if _merge != 2
replace Smartcity=0 if missing(Smartcity)
* 1. 标记哪些城市在 2021 年 Smartcity=1
bysort city_code: egen is_smart_2021 = max(Smartcity == 1 & year == 2021)
* 2. 将 2022 和 2023 年的 Smartcity 设为 1（如果该城市 2021 年=1）
replace Smartcity = 1 if is_smart_2021 == 1 & (year == 2022 | year == 2023)
* 3. 删除临时变量
drop is_smart_2021
save data_sm.dta
*合并过程2
use data_sm.dta,replace
merge 1:1 year city using 宽带中国.dta
sort city year
keep if _merge != 2
replace Broadband=0 if missing(Broadband)&year<2010
bysort city_code: egen is_smart_2021 = max(Broadband == 1 & year == 2021)
replace Broadband = 1 if is_smart_2021 == 1 & (year == 2022 | year == 2023)
replace Broadband = 0 if is_smart_2021 == 0 & (year == 2022 | year == 2023)
drop is_smart_2021
save data_sm_br.dta
*合并过程3
use data_sm_br.dta,replace
merge 1:1 year city using 中国制造2025.dta
sort city year
keep if _merge != 2

cd"C:\Users\qss\Desktop\2023"
*宽带中国政策
use data_sm_br_ma.dta,replace
global cv3 ln_gdp Fin Hum Urb Int
reghdfe Entrep DID Broadband $cv3, ab(city_code year) vce(robust)
est sto m1
estadd local city "Yes"
estadd local year "Yes"

*中国制造2025
reghdfe Entrep DID Manufacture $cv3, ab(city_code year) vce(robust)
est sto m2
estadd local city "Yes"
estadd local year "Yes"

*智慧城市
reghdfe Entrep DID Smartcity $cv3, ab(city_code year) vce(robust)
est sto m3
estadd local city "Yes"
estadd local year "Yes"

*三个政策
//reghdfe Entrep DID Broadband Manufacture Smartcity $cv3, ab(city_code year) vce(robust)
//est sto m4
//estadd local city "Yes"
//estadd local year "Yes"

esttab m1 m2 m3 using otherpolicy.rtf, b(%12.4f) t(%12.2f) r2 scalars(city year N) star(* 0.1 ** 0.05 *** 0.01) nogap compress replace

