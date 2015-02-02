library(shiny)
library(plyr)

#create checkbox input based on type of gene choosen (drug indication ui)
actionInput<- function(genetype){
  
  if(genetype == 'All'){
    HTML("")
  }else{
    action_choice<- switch(genetype,
                           'Enzyme' = action_enzyme,
                           'Target' = action_target,
                           'Transporter' = action_transporter,
                           'Carrier' = action_carrier)
    
    if(genetype == 'Enzyme'){
      checkboxGroupInput('actionChoice1', 'Drug Actions to include: ',
                         action_choice)
      
    }else if(genetype == 'Target'){
      checkboxGroupInput('actionChoice2', 'Drug Actions to include: ',
                         action_choice)
      
    }else if(genetype == 'Transporter'){
      checkboxGroupInput('actionChoice3', 'Drug Actions to include: ',
                         action_choice)
      
    }else if(genetype == 'Carrier'){
      checkboxGroupInput('actionChoice4', 'Drug Actions to include: ',
                         action_choice)
      
    }      
  }
}

########################################## UI.R ###########################################

shinyUI(pageWithSidebar(
  headerPanel("DrugBank Gene Nexus"),
  
  sidebarPanel(
    
######################################### DRUG INDICATION UI #################################

    conditionalPanel(
      'input.dataset === "Drug Indication"',
      h4("Drug Indication Search"),
      radioButtons('indication_drug', 'Choose a search type',
                   choices = c('Drug Query', 'Indication')),
      br(),
      
      textInput('indicationSearch', "Type in drug name (Drug Query) or indication (Indication)"),
      br(),
      
      
      conditionalPanel(
        'input.indication_drug === "Drug Query"',
        selectInput('drugClassSelect', "Select a drug class",
                    choices = c('All', class_all)),
        br()
      ),
      
      conditionalPanel(
        'input.indication_drug === "Indication"',
        
        textInput('geneLocator', "Type in gene name or leave blank to search for all drugs with indication"),
        br(),
        
        checkboxGroupInput('groupChoice', 'Drug groups to include',
                           group_all),
        br(),
        
        selectInput('geneType', 'Choose gene type for drug action search',
                    choices = c('All', 'Enzyme', 'Target', 'Transporter', 'Carrier')),
        br(),
        
        conditionalPanel(
          'input.geneType === "All"',
          actionInput('All'),
          br()
        ),  
        conditionalPanel(
          'input.geneType === "Enzyme"',
          actionInput('Enzyme'),
          br()
        ),  
        conditionalPanel(
          'input.geneType === "Target"',
          actionInput('Target'),
          br()
        ), 
        conditionalPanel(
          'input.geneType === "Transporter"',
          actionInput('Transporter'),
          br()
        ),  
        conditionalPanel(
          'input.geneType === "Carrier"',
          actionInput('Carrier'),
          br()
        )
      )    
    ),

########################################### GENE-DRUG NEXUS ###################################

conditionalPanel(
  'input.dataset === "Gene-Drug Nexus"',
  h4("Gene-Drug Nexus"),
  radioButtons('geneCategory', label= "Please choose gene category", 
               choices= c('All', 'Enzyme', 'Target',
                          'Transporter', 'Carrier')),
  br(),
  radioButtons('searchLabel', label = "Type of Search",
               choices = c('Fuzzy', 'Discrete')),
  br(),
  textInput("geneSearch", 
            label= "Search gene name or drug (ie. CYP2D6, Acetaminophen)"),
  br(),    
  conditionalPanel(
    'input.geneCategory === "Enzyme"',
    selectInput("drugAction1", label="Select a drug action",
                as.list(c("All", action_enzyme))       
    ),
    br(),      
    selectInput("drugClass1", label="Select a drug class",
                as.list(c("All", class_enzyme))
    ),
    br(),   
    selectInput("drugGroup1", label= "Select a drug group",
                as.list(c("All", group_enzyme))
    )
  ),
  conditionalPanel(
    'input.geneCategory === "Target"',
    selectInput("drugAction2", label="Select a drug action",
                as.list(c("All", action_target))
    ),
    br(),    
    selectInput("drugClass2", label= "Select a drug class",
                as.list(c("All", class_target))
    ),
    br(), 
    selectInput("drugGroup2", label= "Select a drug group",
                as.list(c("All", group_target))
    )            
  ),
  conditionalPanel(
    'input.geneCategory === "Transporter"',
    selectInput("drugAction3", label="Select a drug action",
                as.list(c("All", action_transporter))
    ),
    br(),    
    selectInput("drugClass3", label= "Select a drug class",
                as.list(c("All", class_transporter))
    ),
    br(), 
    selectInput("drugGroup3", label= "Select a drug group",
                as.list(c("All", group_transporter))
    )            
  ),
  conditionalPanel(
    'input.geneCategory === "Carrier"',
    selectInput("drugAction4", label="Select a drug action",
                as.list(c("All", action_carrier))
    ),
    br(),    
    selectInput("drugClass4", label= "Select a drug class",
                as.list(c("All", class_carrier))
    ),
    br(), 
    selectInput("drugGroup4", label= "Select a drug group",
                as.list(c("All", group_carrier))
    )            
  ),
  conditionalPanel(
    'input.geneCategory === "All"',
    selectInput("drugAction5", label="Select a drug action",
                as.list(c("All", action_all))       
    ),
    br(),      
    selectInput("drugClass5", label="Select a drug class",
                as.list(c("All", class_all))
    ),
    br(),   
    selectInput("drugGroup5", label= "Select a drug group",
                as.list(c("All", group_all))
    )
  )
),

########################################### CLASS BROWSE UI ###################################

    conditionalPanel(
      'input.dataset === "Class Browse"',
      h4("Drug Class Browse"),
      radioButtons("geneClass", "Choose Gene Category", 
                   choices = list('Enzyme','Target',
                                  'Transporter', 'Carrier')),
      br(),
    
      radioButtons("searchType", "Search Type", 
                  choices = list('Discrete',
                                  'Fuzzy')),
      br(),
    
      textInput("plotSearch", "Use 'All' for all genes or type gene name (CYP2D6)", 
                value= "All"), 
      br(),
    
      radioButtons("numClasses", "Number of drug classes per page", 
                   choices = list('10', '20', '50', 'All')),
      br(),
      conditionalPanel(
        'input.plotSearch === "All"',
        sliderInput('rangeSlider1', 'Choose range of the number of drugs',
                    min = 0, max = 756,
                    value= c(0, 756))
      ),
      conditionalPanel(
        'input.plotSearch !== "All"',
        sliderInput('rangeSlider2', 'Choose range of the number of drugs',
                    min = 0, max = 200,
                    value= c(0, 200))
      )
    ),

######################################### AKNOWLEDGEMENT UI ##################################

    conditionalPanel(
     'input.dataset === "Acknowledgements"',
     h4("References"),
     p("1. DrugBank 4.0: shedding new light on drug metabolism. Law V, Knox C, 
       Djoumbou Y, Jewison T, Guo AC, Liu Y, Maciejewski A, Arndt D, Wilson M, Neveu V, 
       Tang A, Gabriel G, Ly C, Adamjee S, Dame ZT, Han B, Zhou Y, 
       Wishart DS.Nucleic Acids Res. 2014 Jan 1;42(1):D1091-7.PubMed ID:",
       a(href= "http://www.ncbi.nlm.nih.gov/pubmed/24203711", "24203711"))
    )
  ),
  
#################### MAINPANEL OUTPUT ########################################

  mainPanel(
    tabsetPanel(
      id= 'dataset',
      
      #tab for drug indication
      tabPanel("Drug Indication", 
               htmlOutput('entryText'),
               htmlOutput('indication_table'),
               htmlOutput('geneText')),
      
      #tab for gene-drug nexus
      tabPanel("Gene-Drug Nexus", 
               strong(htmlOutput("text")), 
               htmlOutput("table")),
      
      #tab for class browse
      tabPanel("Class Browse", 
               strong(htmlOutput("geneName"), style= 'color:green'), 
               strong(htmlOutput("drugNumber")), 
               htmlOutput("plot")),
      
      #aknowledgement tab
      tabPanel("Acknowledgements", p("All data here has been gathered from", 
                                     a(href= "http://www.drugbank.ca", 'DrugBank.'),
                                     "They have done an excellent job gathering data from an
                                     array of sources and I encourage anyone with further interest
                                     to visit their site. I am not afilliated with Drugbank, but I appreciate
                                     their generous distribution and the wonderful information contained in
                                     their database."),
               p("Here I have attempted to bring together as much as possible all information regarding
                 gene-drug interaction under the various classification schemes offered by DrugBank.
                 This includes an enzyme section that allows one to search by gene, drug,
                 drug class, group or action. Similar tables were put together for drug targets, transporters and carriers.
                 In no way is this a complete list nor does it offer the number of fields available at Drugbank, 
                 however it does offer quick access to all gene-drug relationships such that with only three clicks of the mouse one can find all information related to Acetaminophen; 
                 from genes involved in its metabolism to its protein targets, carriers or cellular transporters.
                 All of this information can be found on DrugBank but usually involves sifting through numerous pages of information.
                 I've done my best to eliminate the extraneous information and to offer filters to adjust the important.
                 This is no doubt a work in progress with my hope of including many more graphical aids to help visualize interactions and perhaps anatomical or cellular distributions.
                 Please send questions or comments to my email at", a(href= 'mailto:garrisrg@gmail.com', 'garrisrg@gmail.com'), "."),
               p("Thank you!")
      )
      
    )
  )
))  
