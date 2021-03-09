Rheadspace.R

R fun ction to calculate pCO2 in a water sample (micro-atm) using a complete headspace method accounting for the
carbonate ewuilibrium in the equilibration vessel.

Authors: Rafael Marcé (Catalan Institute for Water Research - ICRA)
         Jihyeon Kim (Université du Québec à Montréal - UQAM)
         Yves T. Prairie (Université du Québec à Montréal - UQAM)

Date: March 2021

Copyright statement: This code is shared under GNU GENERAL PUBLIC LICENSE Version 3.
Refer to the LICENSE file in the Github repository for details.
Please, when using this software for scientific purposes, cite this work as a source:

  Koschorreck, M., Y.T. Prairie, J. Kim, and R. Marcé. 2021. Technical note: CO2 is not like CH4 – limits and corrections to the headspace method to analyse pCO2 in fresh  water. Biogeosciences, 18, 1619–1627, 2021, https://doi.org/10.5194/bg-18-1619-2021

Contact information: Rafael Marcé (rmarce@icra.cat)

INPUT:
      You can either input a vector of 11 values for solving a single sample or a data frame of 11
      columns and an arbitrary number of rows for batch processing of several samples.

If supplying a vector for one sample, the vector should contain (in this order):

        1. The ID of the sample (arbitrary test, e.g."Sample_1")
        2. mCO2 (ppmv) of the headspace "before" equilibration (e.g., zero for nitrogen)
        3. mCO2 (ppmv) of the headspace "after" equilibration (e.g., as measured by a GC)
        4. In situ (field) water temperature in degrees celsius
        5. Water temperature after equilibration in degree celsius
        6. Alkalinity (micro eq/L) of the water sample
        7. Volume of gas in the headspace vessel (mL)
        8. Volume of water in the headspace vessel (mL)
        9. Barometric pressure at field conditions in kPa. 101.325 kPa = 1 atm
       10. Set of constants for carbonate equilibrium calculations (1=Freshwater, Millero 1979; 2=Estuarine, Millero 2010; 3=Marine, Dickson et al 2007)
       11. Salinity (PSU) # Set to zero if option in 10 is set to 1.

If supplying a data frame, you can build it importing of a csv file
Example: dataset <- read.csv("R_test_data.csv")
The first row of this file must contain column names, then one row for each sample to be solved.
The columns names must be:

        1. Sample.ID
        2. HS.mCO2.before
        3. HS.mCO2.after
        4. Temp.insitu
        5. Temp.equil
        6. Alkalinity.measured
        7. Volume.gas
        8. Volume.water
        9. Bar.pressure
       10. Constants
       11. Salinity

For the different samples, values must be as follows:

        Sample.ID #User defined text
        HS.mCO2.before #the pCO2 (ppmv) of the headspace "before" equilibration (e.g. zero for nitrogen)
        HS.mCO2.after #the measured pCO2 (ppmv) of the headspace "after" equilibration
        Temp.insitu #in situ (field) water temperature in degrees celsius
        Temp.equil #the water temperature after equilibration in degree celsius
        Alkalinity.measured #Total alkalinity (micro eq/L) of the water sample
        Volume.gas #Volume of gas in the headspace vessel (mL)
        Volume.water #Volume of water in the headspace vessel (mL)
        Bar.pressure #Barometric pressure at field conditions in kPa. 101.325 kPa = 1 atm
        Constants #Set of constants for carbonate equilibrium calculations (1=Freshwater; 2=Estuarine; 3=Marine)
        Salinity # Salinity in PSU, set to zero if option in 10 is set to 1.


EXAMPLE OF USE:
 source("Rheadspace.R")

 pCO2 <- Rheadspace("Sample_1",0,80,20,25,1050,30,30,101.325,1,0)

 dataset <- read.csv("R_test_data.csv")
 pCO2 <- Rheadspace(dataset)

OUTPUT: a data frame containing:

     1. Sample IDs
     2. mCO2 complete headspace (ppmv) # mCO2 calculated using the complete headspace method accounting for the carbonate equilibrium
     3. pCO2 complete headspace (micro-atm) # pCO2 calculated using the complete headspace method accounting for the carbonate equilibrium
     4. CO2 concentration complete headspace (micro-mol/L) # CO2 concentration calculated using the complete headspace method accounting for the carbonate equilibrium
     5. pH  # pH calculated for the sanple at in situ field conditions (using the complete headspace method)
     6. mCO2 simple headspace (ppmv)  # mCO2 calculated using the simple headspace method NOT accounting for the carbonate equilibrium
     7. pCO2 simple headspace (micro-atm)  # pCO2 calculated using the simple headspace method NOT accounting for the carbonate equilibrium
     8. CO2 concentration simole headspace (micro-mol/L) # CO2 concentration calculated using the simple headspace method NOT accounting for the carbonate equilibrium
     9. % error # error associated with using the simple headspace calculation


REFERENCES

 Dickson, A.G & J.P Riley (1979). The estimation of acid dissociation constants in sea-water media
 from potentiometric titrations with strong base. II. The dissociation of phosphoric acid,
 Marine Chemistry, 7(2), 101-109.

 Dickson, A. G., Sabine, C. L., and Christian, J. R. (2007). Guide to best practices for
 ocean CO2 measurements, PICES Special Publication 3, 191 pp.

 Millero, F. (1979). The thermodynamics of the carbonate system in seawater,
 Geochimica et Cosmochimica Acta, 43(10), 1651-1661.

 Millero, F. (2010). Carbonate constants for estuarine waters,
 Marine and Freshwater Research, 61(2), 139.

 Orr, J. C., Epitalon, J.-M., and Gattuso, J.-P. (2015). Comparison of ten packages that compute
 ocean carbonate chemistry, Biogeosciences, 12, 1483–1510.

 Weiss, R.F. (1974). Carbon dioxide in water and seawater: the solubility of a non-ideal gas,
 Marine Chemistry, 2, 203-215.

