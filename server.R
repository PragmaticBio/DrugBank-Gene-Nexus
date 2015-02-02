#shiny server
library(shiny)
library(dplyr)
library(googleVis)

################################## CAP FUNCTION (DRUG INDICATION) ###################################################

capwords <- function(s, strict = FALSE) {
  cap <- function(s) paste(toupper(substring(s, 1, 1)),
{s <- substring(s, 2); if(strict) tolower(s) else s},
sep = "", collapse = " " )
sapply(strsplit(s, split = " "), cap, USE.NAMES = !is.null(names(s)))
}

######################################## SERVER.R ########################################################

#set up shiny interactive server
shinyServer(function(input, output) {

############################ DRUG INDICATION SERVER ###############################################

#retrieve data subset based on drug group filter (indication)
groupFilter<- reactive({
  grouplist<- strsplit(as.character(drug_indication$Groups),'/') 
  group_subset<- drug_indication[grepl(paste(input$groupChoice, collapse= '|'),
                                       grouplist), ]
  return(group_subset)
})

#class filter function for drug query- returns drug names to be matched to indication list
classFilter <- reactive({
  if(input$drugClassSelect == 'All'){
    drug_names <- unique(master_drugs$Drug)
    
  }else{
    class_subset<- master_drugs[grepl(input$drugClassSelect,
                                      split_class_all), ]
    
    drug_names<- unique(class_subset$Drug)
  }
  return(drug_names)
})

#retrieve data subset based on drug action filter (indication)
drugsFromAction<- reactive({
  
  #give all action results the same variable
  if(input$geneType == 'Enzyme'){
    action_result<- input$actionChoice1
    
  }else if(input$geneType == 'Target'){
    action_result<- input$actionChoice2
    
  }else if(input$geneType == 'Transporter'){
    action_result<- input$actionChoice3
    
  }else if(input$geneType == 'Carrier'){
    action_result<- input$actionChoice4
  }
  
  #use dataset based on gene type
  dataset<- switch(input$geneType,
                   'All' = master_drugs,
                   'Enzyme' = master_enzyme,
                   'Target' = master_target,
                   'Transporter' = master_transporter,
                   'Carrier' = master_carrier)
  
  #drug list subset based on gene input
  if(input$geneLocator != ""){
    genedrug_subset<- subset(dataset,
                             Gene == input$geneLocator)
    
  }else{
    genedrug_subset<- dataset
  }
  
  #drug list with further filtering by drug action 
  if(input$geneType == 'All'){
    drugs<- unique(genedrug_subset$Drug)
    
  }else{
    print(action_result)
    drugs<- genedrug_subset$Drug[grep(paste(action_result, collapse= '|'),
                                      genedrug_subset$'Drug.Action')]
  }
  
  return(drugs)
})

#Get information based on drug or 
indicationField<- reactive({
  
  if(input$indication_drug == 'Indication'){
    groupData<- groupFilter()[grep(paste("(?=", input$indicationSearch, ")", sep= ""), 
                                   groupFilter()$Indication, ignore.case = T, perl= T), ]
    drug_entry<- groupData[which(groupData$Drug %in% drugsFromAction()), ]
    
  }else if(input$indication_drug == 'Drug Query'){
    if(input$drugClassSelect != 'All'){
      
      drugData<- drug_indication[grep(input$indicationSearch, 
                                      drug_indication$Drug, ignore.case = T), ]
      
      drug_entry<- drugData[which(drugData$Drug %in% classFilter()), ]
      
    }else{
      drugData<- drug_indication[grep(paste0("^", input$indicationSearch), 
                                      drug_indication$Drug, ignore.case = T), ]
      drug_entry<- drugData[which(drugData$Drug %in% classFilter()), ]
    }
  }
  
  if(nrow(drug_entry) == 0){
    drug_entry<- NULL
  }
  
  return(drug_entry)
})

#Drug-gene data when a drug search is invoked
drugGeneData<- reactive({
  if(input$indication_drug == 'Drug Query'){
    
    if(input$indicationSearch == "" & input$drugClassSelect == 'All'){
      enzymes<- 'All'
      targets<- 'All'
      transporters<- 'All'
      carriers <- 'All'
      
    }else{
      
      #enzyme associations -- corrected to exclude proteins without gene names
      enzymes<- master_enzyme$Gene[which(master_enzyme$Drug %in% 
                                           capwords(as.character(indicationField()$Drug)))]
      enzyme.index<- !sapply(enzymes, function(x) any(x==""))
      enzymes<- unique(enzymes[enzyme.index])
      
      if(length(enzymes) == 0){
        enzymes <- 'None'
      }
      
      #target associations -- corrected to exclude proteins without gene names
      targets<- master_target$Gene[which(master_target$Drug %in% 
                                           capwords(as.character(indicationField()$Drug)))]
      target.index<- !sapply(targets, function(x) any(x==""))
      targets<- unique(targets[target.index])
      
      if(length(targets) == 0){
        targets <- 'None'
      }
      
      #transporter associations -- corrected to exclude proteins without gene names
      transporters<- master_transporter$Gene[which(master_transporter$Drug %in% 
                                                     capwords(as.character(indicationField()$Drug)))]
      transporter.index<- !sapply(transporters, function(x) any(x==""))
      transporters<- unique(transporters[transporter.index])
      
      if(length(transporters) == 0){
        transporters <- 'None'
      }
      
      #carrier associations -- corrected to exclude proteins without gene names
      carriers<- master_carrier$Gene[which(master_carrier$Drug %in% 
                                             capwords(as.character(indicationField()$Drug)))]
      carrier.index<- !sapply(carriers, function(x) any(x==""))
      carriers<- unique(carriers[carrier.index])
      
      if(length(carriers) == 0){
        carriers <- 'None'
      }
    }
    
    return(list(enzymes, targets, transporters, carriers))
  }
  
})

#output entry results from search
output$entryText<- renderUI({
  
  if(input$indicationSearch == "" | !is.data.frame(indicationField())){
    HTML(" ")
  }else{
    
    tableEntryNumber<- nrow(indicationField())
    HTML(paste("Number of Entries: ", tableEntryNumber, "<br/>"))
  }
  
})

#output table based on search criteria
output$indication_table <- renderGvis({
  
  #validate drug table
  validate(
    need(is.data.frame(indicationField()), 
         "No match found! Please check spelling or filters.")
  )
  
  #get table indices for selected fields
  table<- indicationField()
  table_index<- as.integer(rownames(table))
  
  #use indices above to get information from the table with links
  final_table <- drug_indication_links[table_index,]
  
  #gvis table to output
  gvisTable(final_table,
            options= list(page='enable', pageSize= 5))
  
})

#gene list for drug query
output$geneText<- renderUI({
  
  #function to create breaks in a list of enzymes, targets, etc. after 10.. 20 entries.
  breakPoint<- function(index){
    genelist<- drugGeneData()[[index]]
    if(length(genelist) <= 10 ){
      new_protein <- paste(genelist, collapse= ",&#160;")
      
    }else if(length(genelist) > 10 & length(genelist) < 20){
      new_protein <- paste(paste(genelist[1:10], collapse= ",&#160;"),
                           paste(genelist[11:length(genelist)], collapse= ",&#160;"),
                           collapse = "<br/>")
      
    }else if(length(genelist) > 20){
      new_protein <- paste(paste(genelist[1:10], collapse= ",&#160;"),
                           paste(genelist[11:20], collapse= ",&#160;"),
                           paste(genelist[21:length(genelist)], collapse= ",&#160;"),
                           collapse = "<br/>")
    }  
    return(new_protein)
  }
  
  #names of enzymes, targets, etc. associated with drug or drug class entry
  enzyme<-HTML(paste("<b>Enzymes: </b>", breakPoint(1)))
  target<-HTML(paste("<b>Targets: </b>", breakPoint(2)))
  transporter<-HTML(paste("<b>Transporters: </b>", breakPoint(3)))
  carrier<-HTML(paste("<b>Carriers: </b>", breakPoint(4)))   
  
  if(input$indication_drug == 'Drug Query'){
    genetext<- HTML(paste(paste("<b>", input$indicationSearch, "gene associations: ", "</b>",
                                "<br/>"), 
                          enzyme, target, transporter, carrier, sep= "<br/>"))
    
  }else{
    genetext<- ""
  }
  
  if(!is.data.frame(indicationField())){
    genetext<- HTML("")
    
  }  
  
  return(genetext)
})

################################# GENE-DRUG NEXUS SERVER ######################################

#Function that changes dataset based on radiobutton input
geneType<-reactive({
  switch(input$geneCategory,
         'All' = all_drugs,
         'Enzyme' = enzyme,
         'Target' = target,
         'Transporter' = transporter,
         'Carrier' = carrier)
})

#Functions used to subset table and get accurate account of fields
subsetBySearch<- function(gene_type){
  
  #input variables depending on category selection
  if(input$geneCategory == 'Enzyme'){
    input_action <- input$drugAction1
    input_class <- input$drugClass1
    input_group <- input$drugGroup1
    
  }else if(input$geneCategory == 'Target'){
    input_action <- input$drugAction2
    input_class <- input$drugClass2
    input_group <- input$drugGroup2
    
  }else if(input$geneCategory == 'Transporter'){
    input_action <- input$drugAction3
    input_class <- input$drugClass3
    input_group <- input$drugGroup3
    
  }else if(input$geneCategory == 'Carrier'){
    input_action <- input$drugAction4
    input_class <- input$drugClass4
    input_group <- input$drugGroup4
    
  }else if(input$geneCategory == 'All'){
    input_action <- input$drugAction5
    input_class <- input$drugClass5
    input_group <- input$drugGroup5
  }
  
  #get input from textInput and selectInput
  if(input$searchLabel == 'Discrete'){
    ind<-grep(paste0("^", input$geneSearch, "$"), gene_type$Gene, ignore.case=T)
  }else if(input$searchLabel == 'Fuzzy'){
    ind<-grep(input$geneSearch, gene_type$Gene, ignore.case=T)
  }
  
  action<-grep(paste0("(?<=[^a-z])", "(?=", input_action , ")|^",
                      input_action), gene_type$'Drug.Action', perl= T)
  drug<- grep(paste0("^", input$geneSearch, "$"), gene_type$Drug, ignore.case=T)
  class<-grep(input_class, gene_type$Classes)
  group<-grep(input_group, gene_type$Groups)
  
  #conditional statements to decide which subset of data to give depending on input above
  #results when the search field is not used
  if(is.null(input$geneSearch) & input_action == "All" & input_class == "All" & input_group == "All"){
    data <- gene_type
    
  } else if(is.null(input$geneSearch) & input_action != "All" & input_class == "All" & input_group == "All") {
    data <- gene_type[action, ]
    
  } else if(is.null(input$geneSearch) & input_action == "All" & input_class != "All" & input_group == "All"){
    data<- gene_type[class, ]
    
  } else if(is.null(input$geneSearch) & input_action == "All" & input_class == "All" & input_group != "All"){
    data<- gene_type[group, ]
    
  } else if(is.null(input$geneSearch) & input_action != "All" & input_class != "All" & input_group == "All"){
    data<- gene_type[intersect(action, class), ]
    
  } else if(is.null(input$geneSearch) & input_action != "All" & input_class == "All" & input_group != "All"){
    data<- gene_type[intersect(action, group), ]
    
  } else if(is.null(input$geneSearch) & input_action == "All" & input_class != "All" & input_group != "All"){
    data<- gene_type[intersect(class, group), ]   
  }
  
  #results when gene is searched 
  if(length(ind)!= 0 & length(drug)== 0 & input_action == "All" & input_class == "All" & input_group == "All"){
    data<- gene_type[ind, ]
    
  } else if(length(ind)!= 0 & length(drug)== 0 & input_action != "All" & input_class == "All" & input_group == "All"){
    data<- gene_type[intersect(ind,action), ]
    
  } else if(length(ind)!= 0 & length(drug)== 0 & input_action == "All" & input_class != "All" & input_group == "All"){
    data<- gene_type[intersect(ind, class), ]
    
  } else if(length(ind)!= 0 & length(drug)== 0 & input_action == "All" & input_class == "All" & input_group != "All"){
    data<- gene_type[intersect(ind, group), ]
    
  } else if(length(ind)!= 0 & length(drug)== 0 & input_action != "All" & input_class != "All" & input_group == "All"){
    data<- gene_type[intersect(intersect(ind, action), class), ]
    
  } else if(length(ind)!= 0 & length(drug)== 0 & input_action != "All" & input_class == "All" & input_group != "All"){
    data<- gene_type[intersect(intersect(ind, action), group), ]
    
  } else if(length(ind)!= 0 & length(drug)== 0 & input_action == "All" & input_class != "All" & input_group != "All"){
    data<- gene_type[intersect(intersect(ind, class), group), ]
    
  } else if(length(ind)!= 0 & length(drug)== 0 & input_action != "All" & input_class != "All" & input_group != "All"){
    data<- gene_type[intersect(intersect(intersect(ind, action), class), group), ]   
  }
  
  #results when drug (but not a gene) is searched
  if(length(ind)== 0 & length(drug) != 0 & input_action == "All" & input_class == "All" & input_group == "All"){
    data<- gene_type[drug, ]
    
  } else if(length(ind)== 0 & length(drug) != 0 & input_action != "All" & input_class == "All" & input_group == "All"){
    data<- gene_type[intersect(drug,action), ]
    
  } else if(length(ind)== 0 & length(drug) != 0 & input_action == "All" & input_class != "All" & input_group == "All"){
    data<- gene_type[intersect(drug, class), ]
    
  } else if(length(ind)== 0 & length(drug) != 0 & input_action == "All" & input_class == "All" & input_group != "All"){
    data<- gene_type[intersect(drug, group), ]
    
  } else if(length(ind)== 0 & length(drug) != 0 & input_action != "All" & input_class != "All" & input_group == "All"){
    data<- gene_type[intersect(intersect(drug, action), class), ]
    
  } else if(length(ind)== 0 & length(drug) != 0 & input_action != "All" & input_class == "All" & input_group != "All"){
    data<- gene_type[intersect(intersect(drug, action), group), ]
    
  } else if(length(ind)== 0 & length(drug) != 0 & input_action != "All" & input_class == "All" & input_group != "All"){
    data<- gene_type[intersect(intersect(drug, class), group), ]
    
  } else if(length(ind)== 0 & length(drug) != 0 & input_action != "All" & input_class == "All" & input_group != "All"){
    data<- gene_type[intersect(intersect(intersect(drug, action), class), group), ]
    
  } 
  return(data)
}

#Raw table
searchResults<- reactive({
  subsetBySearch(geneType())
})
#Number of entries in current table
entryNumber<- reactive({
  
  #test to see if table is produced
  validate(
    need(nrow(searchResults()) != 0, 
         "There's a problem:")
  )
  
  nrow(searchResults())
})

#Number of unique drugs in current table
drugNumber<- reactive({
  length(unique(searchResults()$Drug))
})

#Number of unique genes in current table
geneNumber<- reactive({
  length(unique(searchResults()$Gene))
})

#Output of table 
output$table<- renderGvis({
  
  #test to see if table is produced
  validate(
    need(nrow(searchResults()) != 0, 
         "No entries were returned from your search. Please try a different name or field")
  )
  
  #exclude the drugbank.id column
  nexus_table<- searchResults()[,1:7]
  
  #table output
  gvisTable(nexus_table,
            options= list(page='enable',pageSize= 10))
})

#output results of search field in html text
output$text<- renderUI({
  HTML(paste("Number of Entries: ", entryNumber(), "<br/>",
             "Number of Drugs: ", drugNumber(), "<br/>",
             "Number of Genes: ", geneNumber(), "<br/>" ))
})

########################### CLASS BROWSE SERVER ###############################################

  #Choose which dataset to parse and then apply a search by gene function.
  dataType<-reactive({
    switch(input$geneClass,
           'Enzyme' = enzyme,
           'Target' = target,
           'Transporter' = transporter,
           'Carrier' = carrier)
  })
  
  #data frame output depending on textInput 
  dataSearch<- reactive({
    
      if(input$plotSearch == ""){
        gene<- grep(paste0("^", input$plotSearch,"$"), dataType()$Gene, ignore.case= T)
        data<-dataType()[gene,]
        data$Protein<-'Null'
        
      }else if(input$plotSearch == 'All'){
        gene<-unique(dataType()$Drug)
        data<-dataType()[gene,]
        rownames(data)<- 1:nrow(data)
        data$Protein<-'All'
        
      }else{
        if(input$searchType == 'Fuzzy'){
          gene<- grep(paste0("^", input$plotSearch), dataType()$Gene, ignore.case= T)
          data<-dataType()[gene,]
        
        }else if(input$searchType == 'Discrete'){
          gene<- grep(paste0("^", input$plotSearch, "$"), dataType()$Gene, ignore.case= T)
          data<-dataType()[gene,]

        }
      }

      return(data)
    
  })
  
  #Grab split variable depending on the the gene type
  split_category<- reactive({
    
    if(input$geneClass == 'Enzyme'){
      category <- split_class_enzyme
        
    }else if(input$geneClass == 'Target'){
      category <- split_class_target
      
    }else if(input$geneClass == 'Transporter'){
      category<- split_class_transporter
      
    }else if(input$geneClass == 'Carrier'){
      category<- split_class_carrier
      
    }
      
    return(category)
  })

  #function to execute in reactive environment depending on radio button choice
  getDrugCategory<- function(split_category){

    validate(
      need(try(nrow(dataSearch())!= 0), 
           'Searching... Please check other fields, gene category or name.')
    )
    
    #Extract drug class info from data
    index <- as.numeric(rownames(dataSearch()))
    classes<- unlist(split_category[index])
      
    #validate data frame info
    validate(
       need(try(length(classes)!= 0),
            'Searching... Please check other fields, gene category or name.')
    )
    
    #only include top classes
    top_classes<-sort(table(classes), decreasing= T)
    classdf<-data.frame(Class= names(top_classes), Drugs =as.numeric(top_classes))

    return(classdf)
  }
  
  #total number of classes
  categoryNumber<-function(split_category){
    
      #Extract drug class info from data
      index <- as.numeric(rownames(dataSearch()))
      classes<- unlist(split_category[index])
      
      return(length(unique(classes)))
  }  
  
  #get drug classes of drugs for chosen gene class/gene name
  dataByCategory<- reactive({
    getDrugCategory(split_category())
  })
  

  #Total number of drugs per plot
  drug_number<- reactive({
    if(input$plotSearch== 'All'){
      drugs<-length(dataSearch()$Drug)
      
    }else{
      drugs<- length(unique(dataSearch()$Drug))
      
    }
    class<- categoryNumber(split_category())
    
    return(c(drugs, class))
    
  })
  
  adjustPlot<- reactive({
    
    #define variable for how many classes per page
    if(input$numClasses == 'All'){
      input_numClass<- length(dataByCategory()$Class)
    }else{
      input_numClass<- input$numClasses
    }
    
    #Subset based on slider input and number of classes
    if(input$plotSearch == 'All'){
      adjusted_data<-subset(dataByCategory(),
                              Drugs >= input$rangeSlider1[1] & Drugs <= input$rangeSlider1[2])[1:input_numClass,]
    
    }else if(input$plotSearch != 'All'){
      adjusted_data<-subset(dataByCategory(),
                            Drugs >= input$rangeSlider2[1] & Drugs <= input$rangeSlider2[2])[1:input_numClass,] 
    }
  })
  
  #plotting data
  drugPlot<- reactive({
    
    #weed out null dataframe due to intital value of UI
    if(!is.null(adjustPlot())){
      
      #plot size based on how many classes per page
      h.pixels<- c(400, 600, 1200, 4000)
      pxels<- if(input$numClasses== '10'){h.pixels[1]}
      else if(input$numClasses== '20'){h.pixels[2]}
      else if(input$numClasses== '50'){h.pixels[3]}
      else if(input$numClasses== 'All'){h.pixels[4]}
      
      #adjust vertical axis depending on number of classes
      if(input$numClasses== '10'){
        vertical = "{title: 'Drug Classes', titleTextStyle: {bold: true}}"
      }else if(input$numClasses== '20'){
        vertical = "{title: 'Drug Classes', titleTextStyle: {bold: true}}"
      }else if(input$numClasses== '50'){
        vertical = "{title: 'Drug Classes', titleTextStyle: {bold: true}}"
      }else if(input$numClasses== 'All'){
        vertical = "{title: 'Drug Classes', titleTextStyle: {bold: true},
                                 textPosition: 'none'}"
      }
      
      #Post different title depending on search type
      if(input$searchType == 'Discrete'){
        plot_title<- paste(dataSearch()$Protein[1],"Drug Classes")
        
      }else if(input$searchType == 'Fuzzy'){
        plot_title<- paste(input$plotSearch,"Drug Classes")
      }  
      
      
      bar_chart<- gvisBarChart(adjustPlot(),
                               options= list(
                                 title= plot_title,
                                 titleTextStyle= "{fontSize: 24}",
                                 hAxis= "{title: 'Number of Drugs',titleTextStyle: {bold: true}}",
                                 vAxis= vertical,
                                 chartArea= "{top: 75}",
                                 height= pxels))
      return(bar_chart)
    }
  })
  
  #output plot
  output$plot <- renderGvis({
    drugPlot()
  })
  
  
  #Output gene names of current search on top of main panel
  output$geneName<- renderUI({
    length<- length(unique(dataSearch()$Gene))
    if(length > 10){
      length = 10
    }else(length = length)
    
    len_list<- unique(dataSearch()$Gene)[1:length]
    gene_name<- paste(len_list, collapse = ', ')
    
    #condition to print depending on what is searched
    if(input$plotSearch == 'All'){
      gene_name<- 'All genes'
      
    }else if(input$plotSearch == ""){
      gene_name<- 'No associated genes'
    }
    HTML(paste("Genes included in search (no more than ten shown):  ", gene_name, '<br/>','<br/>'))
  })
  
  #Output text at top of mainpanel
  output$drugNumber<-renderUI({
    gene_count<- paste("Gene Total: ", length(unique(dataSearch()$Gene)))
    drug_count<- paste("Drug Total: ", drug_number()[1])
    class_count<- paste("Class Total: ", drug_number()[2])
    all_counts<- paste(gene_count, drug_count, class_count, 
                       sep = "&#160&#160&#160&#160&#160&#160&#160&#160")
    
    if(is.character(drug_number())){
      HTML("")
      
    }else{
      HTML(paste("Your search includes: ", all_counts,  sep= '<br/>'))
    }      
      
  })
  
})
