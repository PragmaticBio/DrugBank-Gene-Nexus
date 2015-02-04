#################################################################################################

                          # GLOBAL.R for DRUGBANK GENE NEXUS APP #

#################################################################################################

#Requried Packages
library(shiny)
library(plyr)
library(RCurl)

################################# DATASETS ########################################################

#drug_url<-getURL('https://raw.githubusercontent.com/PragmaticBio/DrugBank-Gene-Nexus/master/all_drugs.csv')
#master_drugs<-read.csv(text = drug_url)
master_drugs<-read.csv('C:/Users/Ryan/Dropbox/Bioconductor/Shiny Apps/all_drugs.csv')
master_target<- subset(master_drugs, Gene.Type == 'target')
master_enzyme<- subset(master_drugs, Gene.Type == 'enzyme')
master_transporter<- subset(master_drugs, Gene.Type == 'transporter')
master_carrier<- subset(master_drugs, Gene.Type == 'carrier')

################################ DRUG INDICATION DATA #############################################

#indication_url<-getURL('https://raw.githubusercontent.com/PragmaticBio/DrugBank-Gene-Nexus/master/drug_indications.csv')
#drug_indication<- read.csv(text = indication_url)
drug_indication<- read.csv('C:/Users/Ryan/Dropbox/Bioconductor/Shiny Apps/drug_indications.csv')

#Function to modify drug name to include link to drugbank
indicationLinks<- function(dataframe){
  if(!is.null(dataframe$Drug)){
    urls=c()
    for (i in 1:nrow(dataframe)){
      drug_name<-dataframe$Drug[i]
      drug_id<- master_drugs$'DrugBank.ID'[which(master_drugs$Drug %in% drug_name)][1]
      urls[i]<-paste0('http://www.drugbank.ca/drugs/', drug_id)
    }
    
    #ammend data frame to include links to drubank under the drug name
    titles = dataframe$Drug
    new_dataframe<-
      transform(dataframe, 
                Drug = paste('<a href = ', shQuote(urls), '>', titles, '</a>'))
    
    return(new_dataframe)
  }
}

#add links to the drug names and get rid of newlines and backslashes from indication column
drug_indication_links<- indicationLinks(drug_indication)
drug_indication_links$Indication<- gsub("[\r\n]|[\\]", "", drug_indication_links$Indication)

############################### DRUGBANK LINKS FUNCTION  ####################################

nexusLinks<- function(dataframe){
  
  #add links to drugbank ids
  urls=c()
  for (i in 1:nrow(dataframe)){
    urls[i]<-paste0('http://www.drugbank.ca/drugs/', dataframe$'DrugBank.ID'[i])
  }
  
  titles = dataframe$Drug
  new_dataframe<-
    transform(dataframe, 
              Drug = paste('<a href = ', shQuote(urls), '>', titles, '</a>'))
  
  return(new_dataframe)
}

############################### TARGET DATA MODIFICATION ##########################################

#designate target data in new variable
target<- master_target
rownames(target)<- 1:nrow(target)

#Replace the combined drug actions and groups with seperated values.
target$'Drug.Action'<-revalue(target$'Drug.Action',
                              c("agonistpartial agonist" ="agonist/partial agonist",
                                "antagonistagonist"= "antagonist/agonist",
                                "antagonistpartial agonist" = "antagonist/partial agonist",
                                "antagonistother/unknown"= "antagonist/other/unknown", 
                                "antagonistbinder"= "antagonist/binder",
                                "antagonistinhibitory allosteric modulator"= "antagonist/inhibitory allosteric modulator",
                                "agonistmodulator"= "agonist/modulator",
                                "antagonistmultitarget"= "antagonist/multitarget",
                                "antagonistinhibitor"= "antagonist/inhibitor",
                                "agonistinhibitor"= "agonist/inhibitor",
                                "antagonistinhibitor, competitive"= "antagonist/inhibitor, competitive",
                                "Inhibitor" = "inhibitor"))

target$Groups<-revalue(target$Groups, c("approvedinvestigational"= "approved/investigational", 
                                        "approvednutraceutical"= "approved/nutraceutical", 
                                        "approvedinvestigationalnutraceutical"= "approved/investigational/nutraceutical", 
                                        "approvedillicit"= "approved/illicit", 
                                        "approvedwithdrawn"= "approved/withdrawn", 
                                        "approvednutraceuticalwithdrawn"= "approved/nutraceutical/withdrawn", 
                                        "approvedillicitinvestigational"= "approved/illicit/investigational", 
                                        "investigationalwithdrawn"= "investigational/withdrawn", 
                                        "approvedinvestigationalwithdrawn"= "approved/investigational/withdrawn", 
                                        "approvedillicitwithdrawn"= "approved/illicit/withdrawn", 
                                        "experimentalillicit"= "experimental/illicit", 
                                        "approvedexperimental"= "approved/experimental", 
                                        "experimentalinvestigational"= "experimental/investigational", 
                                        "experimentalwithdrawn"= "experimental/withdrawn",   
                                        "approvedexperimentalinvestigational"= "approved/experimental/investigational", 
                                        "illicitwithdrawn"= "illicit/withdrawn", 
                                        "illicitinvestigational"= "illicit/investigational", 
                                        "approvedillicitinvestigationalwithdrawn"= "approved/illicit/investigational/withdrawn"))

#split concatenated strings into their proper drug classes
split_class_target<-strsplit(as.character(target$Classes),
                             '(?<=[A-Z])(?=[A-Z][a-z])|(?<=[a-z])(?=[0-9])|(?<=[^A-Z][a-z])(?=[A-Z])'
                             , perl=T)

#split target actions/groups
split_action_target<-strsplit(as.character(target$'Drug.Action'), '/')
split_group_target<-strsplit(as.character(target$Groups), '/')

#recombine with '/' as delimiters
classes_target<-unlist(sapply(split_class_target, function(x) paste(x, collapse= '/')))
target$Classes<-classes_target

#add links to drugbank ids
target<-nexusLinks(target)

#################################### ENZYME DATA MODIFICATION ######################################

#designate enzyme data in new variable
enzyme<- master_enzyme
rownames(enzyme)<- 1:nrow(enzyme)

#split concatenated strings into their proper drug classes
split_class_enzyme<-strsplit(as.character(enzyme$Classes),
                             '(?<=[A-Z])(?=[A-Z][a-z])|(?<=[a-z])(?=[0-9])|(?<=[^A-Z][a-z])(?=[A-Z])', perl=T)


#recombine with '/' as delimiters
classes_enzyme<-unlist(sapply(split_class_enzyme, function(x) paste(x, collapse= '/')))
enzyme$Classes<-classes_enzyme

#Alter factor levels of drug action by adding '/' delimiter
enzyme$'Drug.Action'<-revalue(enzyme$'Drug.Action', c("inhibitorinducer"= "inhibitor/inducer", 
                                                      "substrateinducer"= "substrate/inducer",
                                                      "substrateinhibitor"= "substrate/inhibitor",
                                                      "substrateinhibitorinducer"= "substrate/inhibitor/inducer",
                                                      "substrateactivator" = "substrate/activator"))

enzyme$Groups<-revalue(enzyme$Groups, c("approvedinvestigational"= "approved/investigational",
                                        "approvednutraceutical"= "approved/nutraceutical",
                                        "approvedinvestigationalnutraceutical"= "approved/investigational/nutraceutical",
                                        "approvedillicit"= "approved/illicit",
                                        "approvedwithdrawn"= "approved/withdrawn",
                                        "approvedillicitinvestigational"= "approved/illicit/investigational",
                                        "investigationalwithdrawn"= "investigational/withdrawn",
                                        "approvedinvestigationalwithdrawn"= "approved/investigational/withdrawn",
                                        "approvedillicitwithdrawn"= "approved/illicit/withdrawn",
                                        "experimentalillicit"= "experimental/illicit",
                                        "approvedexperimentalillicit"= "approved/experimental/illicit",
                                        "experimentalinvestigational"= "experimental/investigational",
                                        "approvedexperimentalinvestigational"= "approved/experimental/investigational",
                                        "illicitwithdrawn"= "illicit/withdrawn",
                                        "approvedillicitinvestigationalwithdrawn"= "approved/illicit/investigational/withdrawn"))

split_action_enzyme<-strsplit(as.character(enzyme$'Drug.Action'), '/')
split_group_enzyme<-strsplit(as.character(enzyme$Groups), '/')

#add links to drugbank ids
enzyme<- nexusLinks(enzyme)

############################# TRANSPORTER DATA MODIFICATION ##############################

#designate enzyme data in new variable
transporter<- master_transporter
rownames(transporter)<- 1:nrow(transporter)

#split concatenated strings into their proper drug classes
split_class_transporter<-strsplit(as.character(transporter$Classes),
                                  '(?<=[A-Z])(?=[A-Z][a-z])|(?<=[a-z])(?=[0-9])|(?<=[^A-Z][a-z])(?=[A-Z])', perl=T)


#recombine with '/' as delimiters
classes_transporter<-unlist(sapply(split_class_transporter, function(x) paste(x, collapse= '/')))
transporter$Classes<-classes_transporter

#Alter factor levels of drug action by adding '/' delimiter
transporter$'Drug.Action'<-revalue(transporter$'Drug.Action', c("inhibitorinducer"= "inhibitor/inducer", 
                                                                "substrateinducer"= "substrate/inducer",
                                                                "substrateinhibitor"= "substrate/inhibitor",
                                                                "substrateinhibitorinducer"= "substrate/inhibitor/inducer",
                                                                "substrateOther" = "substrate/Other"))

transporter$Groups<-revalue(transporter$Groups, c("approvedinvestigational"= "approved/investigational",
                                                  "approvednutraceutical"= "approved/nutraceutical",
                                                  "approvedinvestigationalnutraceutical"= "approved/investigational/nutraceutical",
                                                  "approvedillicit"= "approved/illicit",
                                                  "approvedwithdrawn"= "approved/withdrawn",
                                                  "approvedillicitinvestigational"= "approved/illicit/investigational",
                                                  "experimentalillicit"= "experimental/illicit",
                                                  "experimentalinvestigational"= "experimental/investigational",
                                                  "experimentalwithdrawn" = "experimental/withdrawn",
                                                  "investigationalwithdrawn" = "investigational/withdrawn",
                                                  "approvedexperimental"= "approved/experimental"))

split_action_transporter<-strsplit(as.character(transporter$'Drug.Action'), '/')
split_group_transporter<-strsplit(as.character(transporter$Groups), '/')

#add links to drugbank ids
transporter<- nexusLinks(transporter)

############################# CARRIER DATA MODIFICATION #################################

#designate enzyme data in new variable
carrier<- master_carrier
rownames(carrier)<- 1:nrow(carrier)

#split concatenated strings into their proper drug classes
split_class_carrier<-strsplit(as.character(carrier$Classes),
                              '(?<=[A-Z])(?=[A-Z][a-z])|(?<=[a-z])(?=[0-9])|(?<=[^A-Z][a-z])(?=[A-Z])', perl=T)


#recombine with '/' as delimiters
classes_carrier<-unlist(sapply(split_class_carrier, function(x) paste(x, collapse= '/')))
carrier$Classes<-classes_carrier

#Drug action needs no modification
carrier$Groups<-revalue(carrier$Groups, c("approvedinvestigational"= "approved/investigational",
                                          "approvednutraceutical"= "approved/nutraceutical",
                                          "approvedillicit"= "approved/illicit",
                                          "experimentalillicit"= "experimental/illicit",
                                          "approvedexperimental"= "approved/experimental",
                                          "experimentalinvestigational"= "experimental/investigational",
                                          "experimentalwithdrawn" = "experimental/withdrawn"))

split_action_carrier<-strsplit(as.character(carrier$'Drug.Action'), '/')
split_group_carrier<-strsplit(as.character(carrier$Groups), '/')

#add links to drugbank ids
carrier<- nexusLinks(carrier)

############################# ALL DRUG DATA MODIFICATION #################################

all_drugs<- rbind(enzyme, target, transporter, carrier)

#split classes, actions and groups for all data
split_class_all<-strsplit(as.character(all_drugs$Classes), '/')
split_action_all<-strsplit(as.character(all_drugs$'Drug.Action'), '/')
split_group_all<-strsplit(as.character(all_drugs$Groups), '/')

########## DRUG CLASS, GROUP AND ACTION VALUES USED FOR DROPDOWN FILTERS ON UI.R ##############

#drop down values for drug classes
class_all<- sort(unique(unlist(split_class_all)))
class_enzyme<-sort(unique(unlist(split_class_enzyme)))
class_target<-sort(unique(unlist(split_class_target)))
class_transporter<-sort(unique(unlist(split_class_transporter)))
class_carrier<-sort(unique(unlist(split_class_carrier)))

#drop down values for drug actions
action_all<- sort(unique(unlist(split_action_all)))
action_enzyme<- sort(unique(unlist(split_action_enzyme)))
action_target<- sort(unique(unlist(split_action_target)))
action_transporter<- sort(unique(unlist(split_action_transporter)))
action_carrier<- sort(unique(unlist(split_action_carrier)))

#drop down values for drug groups
group_all<- sort(unique(unlist(split_group_all)))
group_enzyme<-sort(unique(unlist(split_group_enzyme)))
group_target<-sort(unique(unlist(split_group_target)))
group_transporter<-sort(unique(unlist(split_group_transporter)))
group_carrier<-sort(unique(unlist(split_group_carrier)))

