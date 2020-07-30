# headspace
Scripts to calculate pCO2 in freshwater samples using a complete headspace method accounting for the carbonate equilibrium

# Authors
Rafael Marcé (Catalan Institute for Water Research - ICRA) - rmarce@icra.cat

Jihyeon Kim (Université du Québec à Montréal - UQAM) 

Yves T. Prairie (Université du Québec à Montréal - UQAM)

# License
This code is shared under GNU GENERAL PUBLIC LICENSE Version 3. 
Refer to the LICENSE file in the Github repository for details.

Please, when using this software for scientific purposes, cite this work as a source:

Koschorreck, M., Y.T. Prairie, J. Kim, and R. Marcé. 2020. Technical note: CO2 is not like CH4 – limits of the headspace method to analyse pCO2 in water. Biogeosciences, in revision

# Getting Started

"headspace" is a collection of R and JSL (JMP SAS) scripts to calculate pCO2 in freshwater samples using data from headspace analysis. "headspace" scripts account for the carbonate equilibrium in the equilibration vessel, a frequently disregarded issue when applying the headspace method in freshwater research. We offer a collection of tools to calculate pCO2 accounting for carbonate equilibria, and also to calculate the error associated with the commonly used headspace analysis that does not account for the carbonate equilibria. 

"headspace" comes as an R script (Rheadspace.R) and a JSL script for JMP (aslo in the format of a JMP add-in for user convenience). The R script is function for command line use or scripting, while the JSL script runs within JMP as a user-friendly graphical user interface. 

The distribution also includes a test dataset for R (R_test_data.csv and R_test_data_with_results.csv), as well as an additional file corresponding to the data shown in Figure 4 of the paper mentioned in the section # License  

# Prerequisites

The R script has been tested in R version 3.6.3. No additional libraries beyond those included in customary R installations are required.

The JSL script requires JMP version 14 or higher (not tested on earlier versions).

# R script

Rheadspace.R is a function to calculate pCO2 of a water sample using the complete headspace calculation, and the error associated with using headpsace disregarding the carbonate equilibrium. You can solve either a single water sample providing an input vector or anumber of samples providing a data frame, to facilitate the batch processing of large collection of samples.

####################################################################
####################################################################

Rheadspace.R

INPUT:
      You can either input a vector of 9 values for solving a single sample or a data frame of 9
      columns and an arbitrary number of rows for batch processing of several samples.

 If supplying a vector for one sample, the vector should contain (in this order):

        1. The ID of the sample (arbitrary test, e.g."Sample_1")
        2. pCO2 (ppmv) of the headspace "before" equilibration (e.g., zero for nitrogen)
        3. pCO2 (ppmv) of the headspace "after" equilibration (e.g., as measured by a GC)
        4. In situ (field) water temperature in degrees celsius
        5. Water temperature after equilibration in degree celsius
        6. Alkalinity (micro eq/L) of the water sample
        7. Volume of gas in the headspace vessel (mL)
        8. Volume of water in the headspace vessel (mL)
        9. Barometric pressure at field conditions in kPa. 101.325 kPa = 1 atm

   If supplying a data frame, you can build it importing of a csv file
   
      Example: dataset <- read.csv("R_test_data.csv")
   
   The first row of this file must contain column names, then one row for each sample to be solved.
   
   The columns names must be:

        1. Sample.ID
        2. HS.pCO2.before
        3. HS.pCO2.after
        4. Temp.insitu
        5. Temp.equil
        6. Alkalinity.measured
        7. Volume.gas
        8. Volume.water
        9. Bar.pressure

   For the different samples, values must be as follows:

        Sample.ID # User defined text
        HS.pCO2.before #the pCO2 (ppmv) of the headspace "before" equilibration (e.g. zero for nitrogen)
        HS.pCO2.after #the measured pCO2 (ppmv) of the headspace "after" equilibration
        Temp.insitu #in situ (field) water temperature in degrees celsius
        Temp.equil #the water temperature after equilibration in degree celsius
        Alkalinity.measured #Total alkalinity (micro eq/L) of the water sample
        Volume.gas #Volume of gas in the headspace vessel (mL)
        Volume.water #Volume of water in the headspace vessel (mL)
        Bar.pressure #Barometric pressure at field conditions in kPa. 101.325 kPa = 1 atm

EXAMPLE OF USE:

 source("Rheadspace.R")

 pCO2 <- Rheadspace("Sample_1",0,80,20,25,1050,30,30,101.325)

 dataset <- read.csv("R_test_data.csv")
 
 pCO2 <- Rheadspace_table(dataset)

OUTPUT:

a data frame containing:

     1. Sample IDs
     2. pCO2 complete headspace (ppmv) # pCO2 calculated using the complete headspace method accounting for the carbonate equilibrium
     3. pCO2 complete headspace (micro-atm) # pCO2 calculated using the complete headspace method accounting for the carbonate equilibrium
     4. pH  # pH calculated for the sanple at in situ field conditions (using the complete headspace method)
     5. pCO2 simple headspace (ppmv)  # pCO2 calculated using the simple headspace method NOT accounting for the carbonate equilibrium
     6. pCO2 simple headspace (micro-atm)  # pCO2 calculated using the simple headspace method NOT accounting for the carbonate equilibrium
     7. % error # error associated with using the simple headspace calculation

####################################################################
####################################################################


####################################################################

 NOTE ON SALINITY: because our choice for the values of the constants of the carbonate equilibrium,
                   this script should be used ONLY for freshwater samples.
                   
####################################################################


# JMP script and JMP add-in

PLEASE, SEE THE PDF FILE IN THE REPOSITORY FOR FURTHER DETAILS

The input data can be an Excel, .CSV or JMP data file containing the following input variables:

    1) pCO2 of headspace before equilibration (ppmv). This value is 0 when N2 or CO2-free gas is used as headspace. If ambient air is used, its pCO2 should be measured or assumed to be close to atmospheric average (currently about 402 ppmv).
    2) pCO2 of headspace after equilibration(ppmv).
    3) Temperature of water during sampling (ºC).
    4) Temperature of vessel during equilibration process (ºC).
    5) Alkalinity (µequiv/L).
    6) Headspace ratio (Vol(gas):Vol(water)).
    7) Barometric pressure (kPa)

Values for variables 1, 6, 7 and 8 are not required in the data file if they are constant.

Load or import the input data file in JMP. Load and launch the script file. A dialog box will appear.

Select or drag the data columns into the appropriate variable selection box. A choice a carbonate equilibrium equation set is given corresponding to various field sample types (freshwater, estuarine or marine, see references below). A choice of numerical solution methods is also given. The “Analytical solutions” is nearly instantaneous but can suffer minor imprecisions in extreme situations (Alk> 4000 (µequiv/L and pCO2(after equil.)<100 ppmv) inherent to double precision calculations. The “iterative solutions” is much slower but more stable in such situations. In all cases, results are added as three new columns to the data table (uncorrected pCO2, corrected pCO2, corrected [CO2]) Partial pressures are in µatm and concentrations in µmole/L. The code is available as a JSL script and as a JMP add-in. 

References:

Dickson, A. G., Sabine, C. L., and Christian, J. R. ( 2007): Guide to best practices for ocean CO2 measurements, PICES Special Publication 3, 191 pp.

Millero, F. (1979). The thermodynamics of the carbonate system in seawater Geochimica et Cosmochimica Acta 43(10), 1651 1661. https://dx.doi.org/10.1016/0016-7037(79)90184-4.

Millero, F. (2010). Carbonate constants for estuarine waters Marine and Freshwater Research 61(2), 139. https://dx.doi.org/10.1071/mf09254
