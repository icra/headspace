#####################################################################
# Rheadspace.R
#
# R function to calculate pCO2 in a water sample (ppmv) using a complete headspace method accounting for the 
# carbonate ewuilibrium in the equilibration vessel. 
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
# Contact information: Rafael Marcé (rmarce@icra.cat)
#
# INPUT: 
#       You can either input a vector of 11 values for solving a single sample or a data frame of 11
#       columns and an arbitrary number of rows for batch processing of several samples.
#       
#       If supplying a vector for one sample, the vector should contain (in this order):
# 
#         1. The ID of the sample (arbitrary test, e.g."Sample_1")
#         2. pCO2 (ppmv) of the headspace "before" equilibration (e.g., zero for nitrogen)
#         3. pCO2 (ppmv) of the headspace "after" equilibration (e.g., as measured by a GC)
#         4. In situ (field) water temperature in degrees celsius
#         5. Water temperature after equilibration in degree celsius
#         6. Alkalinity (micro eq/L) of the water sample
#         7. Volume of gas in the headspace vessel (mL)
#         8. Volume of water in the headspace vessel (mL)
#         9. Barometric pressure at field conditions in kPa. 101.325 kPa = 1 atm 
#        10. Set of constants for carbonate equilibrium calculations (1=Freshwater, Millero 1979; 2=Estuarine, Millero 2010; 3=Marine, Dickson et al 2007) 
#        11. Salinity (PSU) # Set to zero if option in 10 is set to 1.
#
#       If supplying a data frame, you can build it importing of a csv file
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
#         9. Bar.pressure
#        10. Constants
#        11. Salinity
#
#       For the different samples, values must be as follows:
#
#         Sample.ID #User defined text
#         HS.pCO2.before #the pCO2 (ppmv) of the headspace "before" equilibration (e.g. zero for nitrogen)
#         HS.pCO2.after #the measured pCO2 (ppmv) of the headspace "after" equilibration
#         Temp.insitu #in situ (field) water temperature in degrees celsius
#         Temp.equil #the water temperature after equilibration in degree celsius
#         Alkalinity.measured #Total alkalinity (micro eq/L) of the water sample
#         Volume.gas #Volume of gas in the headspace vessel (mL)
#         Volume.water #Volume of water in the headspace vessel (mL)
#         Bar.pressure #Barometric pressure at field conditions in kPa. 101.325 kPa = 1 atm   
#         Constants #Set of constants for carbonate equilibrium calculations (1=Freshwater; 2=Estuarine; 3=Marine) 
#         Salinity # Salinity in PSU, set to zero if option in 10 is set to 1.
#
#
# EXAMPLE OF USE:
#  source("Rheadspace.R")
# 
#  pCO2 <- Rheadspace("Sample_1",0,80,20,25,1050,30,30,101.325,1,0)
# 
#  dataset <- read.csv("R_test_data.csv")
#  pCO2 <- Rheadspace(dataset)
#
# OUTPUT: a data frame containing:
#      1. Sample IDs
#      2. pCO2 complete headspace (ppmv) # pCO2 calculated using the complete headspace method accounting for the carbonate equilibrium
#      3. pCO2 complete headspace (micro-atm) # pCO2 calculated using the complete headspace method accounting for the carbonate equilibrium
#      4. pH  # pH calculated for the sanple at in situ field conditions (using the complete headspace method)
#      5. pCO2 simple headspace (ppmv)  # pCO2 calculated using the simple headspace method NOT accounting for the carbonate equilibrium
#      6. pCO2 simple headspace (micro-atm)  # pCO2 calculated using the simple headspace method NOT accounting for the carbonate equilibrium
#      7. % error # error associated with using the simple headspace calculation
#
#
# REFERENCES
#
#  Millero, F. (1979). The thermodynamics of the carbonate system in seawater
#  Geochimica et Cosmochimica Acta 43(10), 1651 1661.  
#
#  Millero, F. (2010). Carbonate constants for estuarine waters Marine and Freshwater
#  Research 61(2), 139.
#
#  Dickson, A. G., Sabine, C. L., and Christian, J. R. (2007): Guide to best practices for
#  ocean CO2 measurements, PICES Special Publication 3, 191 pp.
#####################################################################

Rheadspace <-  function(...){
  arguments <- list(...)
  
  # test arguments and initialize variables
  if (is.data.frame(arguments[[1]])) {
    input.table=arguments[[1]]
    if (dim(input.table)[2]!=11){
      stop("You should input a data frame with 11 columns. See the readme file or comments in the function", call.=FALSE)
    }else{
      Sample.ID = as.character(input.table$Sample.ID)
      pCO2_headspace = input.table$HS.pCO2.before #the pCO2 (ppmv) of the headspace "before" equilibration
      pCO2_eq = input.table$HS.pCO2.after #the measured pCO2 (ppmv) of the headspace "after" equilibration
      temp_insitu = input.table$Temp.insitu #in situ water temperature in degrees celsius
      temp_eq = input.table$Temp.equil #the water temperature after equilibration in degree celsius
      alk = input.table$Alkalinity.measured #Total alkalinity (micro eq/L) of the water sample
      vol_gas = input.table$Volume.gas #Volume of gas in the headspace vessel (mL)
      vol_water = input.table$Volume.water #Volume of water in the headspace vessel (mL)   
      Bar.pressure = input.table$Bar.pressure #Barometric pressure at field conditions in kPa. 101.325 kPa = 1 atm   
      c_constants = input.table$Constants #Constants for carbonate equilibrium (1=Freshwater; 2=Estuarine; 3=Marine) 
      Salinity = input.table$Salinity #Salinity in PSU. Set to zero if Constants = 1
      } 
  } else if (length(arguments)==11) {
    Sample.ID = as.character(arguments[[1]])
    pCO2_headspace = arguments[[2]] #the pCO2 (ppmv) of the headspace "before" equilibration
    pCO2_eq = arguments[[3]] #the measured pCO2 (ppmv) of the headspace "after" equilibration
    temp_insitu = arguments[[4]] #in situ water temperature in degrees celsius
    temp_eq = arguments[[5]] #the water temperature after equilibration in degree celsius
    alk = arguments[[6]] #Total alkalinity (micro eq/L) of the water sample
    vol_gas = arguments[[7]] #Volume of gas in the headspace vessel (mL)
    vol_water = arguments[[8]] #Volume of water in the headspace vessel (mL)   
    Bar.pressure = arguments[[9]] #Barometric pressure at field conditions in kPa. 101.325 kPa = 1 atm   
    c_constants = arguments[[10]] #Constants for carbonate equilibrium (1=Freshwater; 2=Estuarine; 3=Marine) 
    Salinity = arguments[[11]] #Salinity in PSU. Set to zero if Constants = 1
  } else {
    stop("You should input either a data frame or a vector of 11 values. See the readme file or comments in the function", call.=FALSE)
  }
  
  #initialization of variables
  pCO2_orig <- data.frame(matrix(NA,length(pCO2_headspace),7))
  names(pCO2_orig) <- c("Sample.ID","pCO2 complete headspace (ppmv)","pCO2 complete headspace (micro-atm)", "pH", "pCO2 simple headspace (ppmv)", "pCO2 simple headspace (micro-atm)","% error")
  
  
  R <- 0.082057338 #L atm K-1 mol-1
  
  #the function uniroot cannot handle vectors, so we need a loop
  for (i in 1:length(pCO2_headspace)){ 
    
    AT = alk[i]*(1e-6) #conversion to mol/L
    
    #Constants of the carbonate ewuilibrium
    # Kw = the dissociation constant of H2O into H+ and OH-
    # Kh = the solubility of CO2 in water - equilibration conditions
    # Kh2 = the solubility of CO2 in water - in situ field conditions
    # K1 = the equilibrium constant between CO2 and HCO3-
    # K2 = the equilibrium constant between HCO3- and CO3 2-
    
    Kw = 10^(-(0.0002*((temp_eq[i])^2)-0.0444*temp_eq[i]+14.953))
    Kh = 10^((-60.2409+93.4517*(100/(273.15+temp_eq[i]))+23.3585*log((273.15+temp_eq[i])/100))/log(10)) # mol/L/atm equilibration conditions
    Kh2 = 10^((-60.2409+93.4517*(100/(273.15+temp_insitu[i]))+23.3585*log((273.15+temp_insitu[i])/100))/log(10)) # mol/L/atm original conditions
    
    if (c_constants == 1) {
    
      #Millero, F. (1979). The thermodynamics of the carbonate system in seawater
      #Geochimica et Cosmochimica Acta 43(10), 1651 1661.  
      K1=10^-(-126.34048+6320.813/(temp_eq[i]+273.15)+19.568224*log(temp_eq[i]+273.15))
      K2=10^-(-90.18333+5143.692/(temp_eq[i]+273.15)+14.613358*log(temp_eq[i]+273.15))
      
    } else if (c_constants == 2) {
      
      #Millero, F. (2010). Carbonate constants for estuarine waters Marine and Freshwater
      #Research 61(2), 139.
      pK10=(-126.34048+6320.813/(temp_eq[i]+273.15)+19.568224*log(temp_eq[i]+273.15))
      A1 = 13.4038*Salinity[i]^0.5 + 0.03206*Salinity[i] - 5.242e-5*Salinity[i]^2
      B1 = -530.659*Salinity[i]^0.5 - 5.8210*Salinity[i]
      C1 = -2.0664*Salinity[i]^0.5
      pK1 = pK10 + A1 + B1/(temp_eq[i]+273.15) + C1*log(temp_eq[i]+273.15)
      K1 = 10^-pK1;
      pK20=(-90.18333+5143.692/(temp_eq[i]+273.15)+14.613358*log(temp_eq[i]+273.15))
      A2 = 21.3728*Salinity[i]^0.5 + 0.1218*Salinity[i] - 3.688e-4*Salinity[i]^2
      B2 = -788.289*Salinity[i]^0.5 - 19.189*Salinity[i]
      C2 = -3.374*Salinity[i]^0.5
      pK2 = pK20 + A2 + B2/(temp_eq[i]+273.15) + C2*log(temp_eq[i]+273.15)
      K2 = 10^-pK2;
      
    } else if (c_constants == 3) {
      
      #Dickson, A. G., Sabine, C. L., and Christian, J. R. ( 2007): Guide to best practices for
      #ocean CO2 measurements, PICES Special Publication 3, 191 pp.
      K1=10^(-3633.86/ (temp_eq[i] + 273.15)+61.2172-9.67770*log(temp_eq[i]+273.15)+0.011555*Salinity[i]-0.0001152*Salinity[i]^2)
      K2 = 10^(-417.78/ (temp_eq[i] + 273.15) - 25.9290 + 3.16967*log(temp_eq[i]+273.15)+0.01781*Salinity[i]-0.0001112*Salinity[i]^2)
      
    } else {
      print(i)
      stop("Option for carbonate equilibrium constants should be a number between 1 and 3", call.=FALSE)
      
    }
      
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
    pCO2_orig[i,3] <- pCO2_orig[i,2]*Bar.pressure[i]/101.325
    pCO2_orig[i,4] <- -log10( h )
    
    
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
    pCO2_orig[i,5] <- Sample_CO2_conc/Kh2*1000000 #ppmv
    pCO2_orig[i,6] <- pCO2_orig[i,5]*Bar.pressure[i]/101.325 # micro-atm
    
    #calculation of the error
    pCO2_orig[i,7] <- (pCO2_orig[i,5]-pCO2_orig[i,2])/pCO2_orig[i,2] *100  #%
  }
  
  
  return(pCO2_orig) #Output data frame
  
}