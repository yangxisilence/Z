clear
cd"C:\Users\qss\Desktop\2023"
use firm+控制变量.dta,replace
global cv3 ln_gdp Fin Hum Urb Int

*基准
reghdfe Entrep DID ,vce(robust)
est sto m1
estadd local city "No"
estadd local year "No"
reghdfe Entrep DID , ab(city year) vce(robust)
est sto m2
estadd local city "Yes"
estadd local year "Yes"
reghdfe Entrep DID $cv3
est sto m3
estadd local city "No"
estadd local year "No"
reghdfe Entrep DID $cv3, ab(city year) vce(robust)
est sto m4
estadd local city "Yes"
estadd local year "Yes"
reghdfe Entrep DID $cv3, ab(city year) vce(cluster city) 
esttab m1 m2 m3 m4 using 基准回归.rtf, b(%12.4f) t(%12.2f) r2 scalars(city year N) star(* 0.1 ** 0.05 *** 0.01) nogap compress replace


***平行趋势检验
xtset city_code year
gen distance = year - 2018
tab distance

*归并时期数，由于过远的时期样本量较少，故将事前样本归并至5期，事后样本归并至4期
replace distance = -5 if distance < -5 
replace distance = 4 if distance > 4

forvalues i = 5(-1)1{
	gen pre_`i' = (distance == -`i')
}

forvalues i = 0(1)4{
	gen post_`i' = (distance == `i')
}


reghdfe Entrep pre_* post_* ln_gdp Fin Hum Urb Int, ab(city) vce(cluster city)

**去均值
forvalues j =5(-1)1{
gen b_`j'=_b[pre_`j']
}
gen ave_cofe=(b_1+b_2+b_3+b_4+b_5)/5 //去除事前均值
**coefplot命令画图，注意要一起运行
su ave_cofe
return list
coefplot, baselevels ///
keep(pre_* post_*) ///
vertical ///转置图形
yline(0,lcolor(edkblue*0.8)) ///加入y=0这条虚线
xline(10, lwidth(vthin) lpattern(dash) lcolor(teal)) ///x虚线
ylabel(,labsize(*0.75)) xlabel(,labsize(*0.75)) ///刻度标签
ytitle("政策动态效应", size(small)) ///加入Y轴标题,大小small
xtitle("政策时点", size(small) margin(t+2)) ///加入X轴标题，大小small
transform(*=@-r(mean)) /// ！！！！！！！！！！！！！！重点
addplot(line @b @at) ///增加点之间的连线
ciopts(lpattern(dash) recast(rcap) msize(medium)) ///CI为虚线上下封口
msymbol(circle_hollow) ///点为空心格式
scheme(s1mono) ///
legend(order(1 "95%置信区间" 2 "经济效应的估计值")) //
graph export "平行趋势置信区间图2.png",replace


***安慰剂检验-didplacebo代码，生成伪个体伪时间，重复500次。详情看陈强老师最新论文
reghdfe Entrep DID ln_gdp Fin Hum Urb Int,absorb(city year) vce(robust)
est sto reg
didplacebo reg, treatvar(DID) pbotime(1(1)5) pbounit pbomix(1 2 3) repeat(500)
