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

"headspace" is a collection of R and JMP scripts to calculate pCO2 in freshwater samples using data from headspace analysis. "headspace" scripts account for the carbonate equilibrium in the equilibration vessel, a frequently disregarded issue when applying the headspace method in freshwater research. We offer a collection of tools to calculate pCO2 accounting for carbonate equilibria, and also to calculate the error associated with the use of a headspace analysis that does not account for the carbonate equilibria.

"headspace" comes as a collection of R scripts (Rheadspace.R and Rheadspace_table.R) and a JMP SAS script. R scripts are command line tools, while the JMP SAS script runs within JMP as a user-friendly GUI. 

# Prerequisites

R scripts have been tested in R version 3.6.3. No additional libraries beyond those included in customary R installations are required.

The JMP script requires XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
INSTALLING INSTRUCTIONS FOR JMP????

# R scripts

Rheadspace.R is a function to calculate pCO2 of a water sample using the complete headspace calculation, and the error associated with using headpsace disregarding the carbonate equilibrium.

Rheadspace_table.R is the same function prepared to be used with a data.frame as an input, to facilitate the batch processing of large collection of samples.


####################################################################
####################################################################
Rheadspace.R

R function to calculate pCO2 in a water sample (ppmv) using a complete headspace method accounting for the
carbonate ewuilibrium in the equilibration vessel.

INPUT:
      Vector contaning (in this order):

        1. pCO2 (ppmv) of the headspace "before" equilibration (e.g., zero for nitrogen)
        2. pCO2 (ppmv) of the headspace "after" equilibration (e.g., as measured by a GC)
        3. In situ (field) water temperature in degrees celsius
        4. Water temperature after equilibration in degree celsius
        5. Alkalinity (micro eq/L) of the water sample
        6. Volume of gas in the headspace vessel (mL)
        7. Volume of water in the headspace vessel (mL)

EXAMPLE OF USE:

source("Rheadspace.R")

pCO2 <- Rheadspace(0,80,20,25,1050,30,30)

OUTPUT: a data frame containing:

     1. pCO2 complete headspace (ppmv) # pCO2 calculated using the complete headspace method accounting for the carbonate equilibrium
     2. pH  # pH calculated for the sanple at in situ field conditions (using the complete headspace method)
     3. pCO2 simple headspace (ppmv)  # pCO2 calculated using the simple headspace method NOT accounting for the carbonate equilibrium
     4. % error # error associated with using the simple headspace calculation



####################################################################
####################################################################

Rheadspace_table.R

R function to calculate pCO2 in water samples (ppmv) using a complete headspace method accounting for the
carbonate ewuilibrium in the equilibration vessel. This version uses a table to feed the input data for
an unlimited number of samples.

INPUT:
      Data frame built from the import of a csv file
      
      Example: dataset <- read.csv("data.csv")
      
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

      For the different samples, values must be as follows:

        Sample.ID # User defined
        HS.pCO2.before #the pCO2 (ppmv) of the headspace "before" equilibration (e.g. zero for nitrogen)
        HS.pCO2.after #the measured pCO2 (ppmv) of the headspace "after" equilibration
        Temp.insitu #in situ (field) water temperature in degrees celsius
        Temp.equil #the water temperature after equilibration in degree celsius
        Alkalinity.measured #Total alkalinity (micro eq/L) of the water sample
        Volume.gas #Volume of gas in the headspace vessel (mL)
        Volume.water #Volume of water in the headspace vessel (mL)

EXAMPLE OF USE:

source("Rheadspace_table.R")

dataset <- read.csv("R_test_data.csv")

pCO2 <- Rheadspace_table(dataset)

OUTPUT: a data frame containing:

     1. Sample IDs
     2. pCO2 complete headspace (ppmv) # pCO2 calculated using the complete headspace method accounting for the carbonate equilibrium
     3. pH  # pH calculated for the sanple at in situ field conditions (using the complete headspace method)
     4. pCO2 simple headspace (ppmv)  # pCO2 calculated using the simple headspace method NOT accounting for the carbonate equilibrium
     5. % error # error associated with using the simple headspace calculation

####################################################################
####################################################################


####################################################################

 NOTE ON BAROMETRIC PRESSURE: this script calculates the fractional abundance of CO2 in a gas phase in
                              equilibrium with a water sample expressed as ppmv. To express this in terms
                              of a true partial pressure (e.g., atmospheres) or concentration (e.g., mol CO2/L)
                              you need to account for barometric pressure at field conditions. This script does
                              not solve this step. Although we use the customary acronym "pCO2" when expressing
                              CO2 as ppmv, note that this is equivalent to a partial pressure (e.g., micro-atmospheres)
                              ONLY in case of barometric pressure = 1 atm.

 NOTE ON SALINITY: because our choice for the values of the constants of the carbonate equilinrium,
                   this script shoul be used ONLY for freshwater samples.
                   
####################################################################


# JMP script

