#####################################################################
# Rheadspace_table.R
#
# R function to calculate pCO2 in water samples (ppmv) using a complete headspace method accounting for the 
# carbonate ewuilibrium in the equilibration vessel. This version uses a table to feed the input data for
# an unlimited number of samples.
#
# Authors: Rafael Marcé (Catalan Institute for Water Research - ICRA)
#          Jihyeon Kim (Université du Québec à Montréal - UQAM) 
#          Yves T. Prairie (Université du Québec à Montréal - UQAM)
#
# Date: July 2020
#
# Copyright statement: This code is shared under GNU GENERAL PUBLIC LICENSE Version 3. 
# Refer to the LICENSE file in the Github repository for details.
# Please, when using this software for scientific purposes, cite this work as a source:
#
#   Koschorreck, M., Y.T. Prairie, J. Kim, and R. Marcé. 2020. Technical note: CO2 is not like CH4 – limits of the headspace method to analyse pCO2 in water. Biogeosciences, in revision
#
#Contact information: Rafael Marcé (rmarce@icra.cat)
#
#INPUT: 
#       Data frame built from the import of a csv file
#       Example: dataset <- read.csv("R_test_data.csv")
#       The first row of this file must contain column names, then one row for each sample to be solved.
#       The columns names must be:
# 
#         1. Sample.ID 
#         2. HS.pCO2.before
#         3. HS.pCO2.after
#         4. Temp.insitu
#         5. Temp.equil
#         6. Alkalinity.measured
#         7. Volume.gas
#         8. Volume.water
#
#       For the different samples, values must be as follows:
#
#         Sample.ID # User defined
#         HS.pCO2.before #the pCO2 (ppmv) of the headspace "before" equilibration (e.g. zero for nitrogen)
#         HS.pCO2.after #the measured pCO2 (ppmv) of the headspace "after" equilibration
#         Temp.insitu #in situ (field) water temperature in degrees celsius
#         Temp.equil #the water temperature after equilibration in degree celsius
#         Alkalinity.measured #Total alkalinity (micro eq/L) of the water sample
#         Volume.gas #Volume of gas in the headspace vessel (mL)
#         Volume.water #Volume of water in the headspace vessel (mL)
#
#EXAMPLE OF USE:
# source("Rheadspace_table.R")
# dataset <- read.csv("R_test_data.csv")
# pCO2 <- Rheadspace_table(dataset)
#
#OUTPUT: a data frame containing:
#      1. Sample IDs
#      2. pCO2 complete headspace (ppmv) # pCO2 calculated using the complete headspace method accounting for the carbonate equilibrium
#      3. pH  # pH calculated for the sanple at in situ field conditions (using the complete headspace method)
#      4. pCO2 simple headspace (ppmv)  # pCO2 calculated using the simple headspace method NOT accounting for the carbonate equilibrium
#      5. % error # error associated with using the simple headspace calculation
#
#####################################################################
#  NOTE ON BAROMETRIC PRESSURE: this script calculates the fractional abundance of CO2 in a gas phase in
#                               equilibrium with a water sample expressed as ppmv. To express this in terms 
#                               of a true partial pressure (e.g., atmospheres) or concentration (e.g., mol CO2/L)
#                               you need to account for barometric pressure at field conditions. This script does
#                               not solve this step. Although we use the customary acronym "pCO2" when expressing 
#                               CO2 as ppmv, note that this is equivalent to a partial pressure (e.g., micro-atmospheres)
#                               ONLY in case of barometric pressure = 1 atm.        
#
#  NOTE ON SALINITY: because our choice for the values of the constants of the carbonate equilinrium,
#                    this script shoul be used ONLY for freshwater samples.
#####################################################################

Rheadspace_table <-  function(input.table) {
  
  # INPUT DATA
  # Caution for the table of input parameters
  # 1) make sure all column names match the ones below
  # 2) Double check the right units of all input variables
  
  Sample.ID = as.character(input.table$Sample.ID)
  pCO2_headspace = input.table$HS.pCO2.before #the pCO2 (ppmv) of the headspace "before" equilibration
  pCO2_eq = input.table$HS.pCO2.after #the measured pCO2 (ppmv) of the headspace "after" equilibration
  temp_insitu = input.table$Temp.insitu #in situ water temperature in degrees celsius
  temp_eq = input.table$Temp.equil #the water temperature after equilibration in degree celsius
  alk = input.table$Alkalinity.measured #Total alkalinity (micro eq/L) of the water sample
  vol_gas = input.table$Volume.gas #Volume of gas in the headspace vessel (mL)
  vol_water = input.table$Volume.water #Volume of water in the headspace vessel (mL)
 
  #initialization of variables
  pCO2_orig <- data.frame(matrix(NA,length(pCO2_headspace),5))
  names(pCO2_orig) <- c("Sample.ID","pCO2 complete headspace (ppmv)","pH", "pCO2 simple headspace (ppmv)", "% error")
  
  
  R <- 0.082057338 #L atm K-1 mol-1
  
  #the function uniroot cannot handle vectors, so we need a loop
  for (i in 1:length(pCO2_headspace)){ 
  
  # Kw = the dissociation constant of H2O into H+ and OH-
  # K1 = the equilibrium constant between CO2 and HCO3-
  # K2 = the equilibrium constant between HCO3- and CO3 2-
  # Kh = the solubility of CO2 in water - equilibration conditions
  # Kh2 = the solubility of CO2 in water - in situ field conditions
    
  #Constants of the carbonate ewuilibrium
  AT = alk[i]*(1e-6) #conversion to mol/L
  Kw = 10^(-(0.0002*((temp_eq[i])^2)-0.0444*temp_eq[i]+14.953))
  K1 = 10^(((-(3404.71/(temp_eq[i]+273.15)))+14.8435)-0.032786*(temp_eq[i]+273.15))
  K2 = 10^(((-(2902.39/(temp_eq[i]+273.15)))+6.498)-0.02379*(temp_eq[i]+273.15))
  Kh = 10^((-60.2409+93.4517*(100/(273.15+temp_eq[i]))+23.3585*log((273.15+temp_eq[i])/100))/log(10)) # mol/L/atm equilibration conditions
  Kh2 = 10^((-60.2409+93.4517*(100/(273.15+temp_insitu[i]))+23.3585*log((273.15+temp_insitu[i])/100))/log(10)) # mol/L/atm original conditions
  
  HS.ratio <- vol_gas[i]/vol_water[i] #Headspace ratio (=vol of gas/vol of water)
  
  #DIC at equilibrium
  co2 <- Kh * pCO2_eq[i]/1000000
  h_all <- polyroot(c(-(2*K1*K2*co2),-(co2*K1+Kw),AT,1))
  real<-Re(h_all)
  h <-real[which(real>0)]
  DIC_eq <- co2 * (1 + K1/h + K1 * K2/(h * h))
  
  #DIC in the original sample
  DIC_ori <- DIC_eq + (pCO2_eq[i] - pCO2_headspace[i])/1000000/(R*(temp_eq[i]+273.15))*HS.ratio
  
  #pCO2 in the original sample
  h_all <- polyroot(c(-(K1*K2*Kw),K1*K2*AT-K1*Kw-2*DIC_ori*K1*K2,AT*K1-Kw+K1*K2-DIC_ori*K1,AT+K1,1))
  real<-Re(h_all)
  h <-real[which(real>0)]
  
  co2 <- h* (DIC_ori * h * K1/(h * h + K1 * h + K1 * K2)) / K1
 
  pCO2_orig[i,1] <- as.character(Sample.ID[i])
  pCO2_orig[i,2] <- co2/Kh2*1000000
  pCO2_orig[i,3] <- -log10( h )
  
  
  
  #Calculation not accounting for alkalinity effects and associated error
  
  #concentration and total mass in the water sample assuming ideal gas from the pCO2 measured at the headspace
  CO2_solution <- pCO2_eq[i]/1000000*Kh #mol/L
  CO2_solution_mass <- CO2_solution * vol_water[i]/1000 #mol
  
  #mass of CO2 in the measured headspace
  final_C_headspace_mass <- pCO2_eq[i]/1000000*(vol_gas[i]/1000) / (R * (temp_eq[i]+273.15)) #mol
  
  mols_headspace <- pCO2_headspace[i]/1000000*(vol_gas[i]/1000)/(R * (temp_eq[i]+273.15)) #mol PV / RT = n
  
  #implication: mass, concentration, and partial pressure of CO2 in the original sample (aount in sample and headspace after equilibration minus original mass in the headspace)
  Sample_CO2_mass <- CO2_solution_mass + final_C_headspace_mass - mols_headspace #mol
  Sample_CO2_conc <- Sample_CO2_mass/(vol_water[i]/1000) #mol/L
  pCO2_orig[i,4] <- Sample_CO2_conc/Kh2*1000000 #ppmv
  
  #calculation of the error
  pCO2_orig[i,5] <- (pCO2_orig[i,4]-pCO2_orig[i,2])/pCO2_orig[i,2] *100  #%
  }
   
  return(pCO2_orig) #Output data frame
  
}
