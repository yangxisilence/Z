*替换被解释变量
cd"C:\Users\qss\Desktop\2023"
use firm+控制变量.dta,replace
global cv3 ln_gdp Fin Hum Urb Int
*未标准化企业数
reghdfe new_firms DID $cv3, ab(city year) vce(robust)
est sto m1
estadd local city "Yes"
estadd local year "Yes"
esttab m1 using 替换被解释变量.rtf, b(%12.4f) t(%12.2f) r2 scalars(city year N) star(* 0.1 ** 0.05 *** 0.01) nogap compress replace
