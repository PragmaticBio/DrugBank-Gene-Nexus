# DrugBank-Gene-Nexus

Search gene-drug interactions found in DrugBank with Shiny.

## What is DrugBank?

As per the [Drugbank](http://www.drugbank.ca/) website: The DrugBank database is a unique bioinformatics and cheminformatics resource that combines detailed drug (i.e. chemical, pharmacological and pharmaceutical) data with comprehensive drug target (i.e. sequence, structure, and pathway) information. The database contains 7737 drug entries including 1585 FDA-approved small molecule drugs, 158 FDA-approved biotech (protein/peptide) drugs, 89 nutraceuticals and over 6000 experimental drugs. Additionally, 4281 non-redundant protein (i.e. drug target/enzyme/transporter/carrier) sequences are linked to these drug entries. Each DrugCard entry contains more than 200 data fields with half of the information being devoted to drug/chemical data and the other half devoted to drug target or protein data.

References can be found in the acknowledgement section. I encourage anyone not familiar with DrugBank to visit their site. Here I've tried to consolidate the fields pertaining to gene-drug interaction. Some of the search fields are available at drugbank and are virutally identical. Some on the other hand are unique, allowing one to search for gene families (all CYP genes) with *Fuzzy* search and a drug action filter to locate all inhibitors of CYP2D6. 

## Drug Indication

### Overview
The Drug Indication tab is arguably the most powerful search tool available in the drug-gene nexus. It has two search fields available: *Drug Query* and *Drug Indication*. The first allows one to search for a drug by name, which then retrieves the indication for the drug as well as genes which interact with it at various levels (ie. enzymes that metabolize it; carriers that distribute it; targets that bind or interact with it, etc.). Or if one prefers, they can search for all drugs indicated for breast cancer that are metabolized by CYP3A5 or perhaps breast cancer drugs which target the mu-opioid receptor (OPRM1). The details of the two queries and the filters available are discussed below.

### Drug Query

The *Drug Query* field allows one to search for drug-gene interactions by drug name. This will retrieve the indication for the drug as well as all known gene interactions. It is different from the *Gene-drug nexus* in that the user will get all genes associated with a particular drug or class of drugs, while the *Gene-drug nexus* is essentially the inverse: it is useful when trying to locate all drugs associated with a particular gene or gene family. It also gives drug indications which the nexus does not. The filters for *Drug Query* include:

**Drug Search** - Type in the name of your drug and see what you get. For example, when 'acetaminophen' is used, the main panel will retrieve the drug acetaminophen with an indication of 'For temporary relief of fever, minor aches, and pains' as well as the gene associations which include Enzymes: CYP1A2, CYP2D6, SULT1A1, UGT1A10.. etc; Targets: PTGS2, PTGS1; Transporters: ABCB1, SLC22A6; and Carriers: None. One can also click on the name of the drug to go directly to the DrugBank database and see all of the information available there on acetaminophen. This search is spelling sensitive and will probably return a bunch of drugs if you spell it incorrectly so be sure to spell correctly or copy and paste the drug name.

**Drug Class** - One can also search for drugs by class. This will return all drugs that have been categorized by DrugBank as 'barbiturates' or 'benzodiazepines' and return the gene associations for every drug retrieved. I've noticed some drugs like phenobarbital, which is a 'barbiturate' not retrievable under that class, but can be found under 'hypnotics and sedatives' or 'anticonvulsants'. This is due to DrugBank's classification scheme and not the program. Try not to fret if your drug isn't found under a particular class, try another.

### Drug Indication

The *Drug Indication* field allows one to search for drugs by indication and to further refine the search by filtering for drug groups, associated genes as well as their actions. For example, using *Drug Indication* you can search for all 'approved' drugs indicated for 'breast cancer' and that are 'inhibitors' of 'CYP2D6'. In this case all four filters are used to show the drugs of interest. The filters for *Drug Indication* include:

**Indication Search** - Type in an indication of interest. This can be vast and includes searches for diseases like cancer, bipolar disorder, SSC (small-cell carcinoma) or any disease sequela one can come up with. The program simply takes the expression entered and cross-references it with every drug indication in the database.

**Gene Search** - Type in a gene of interest to narrow down the search. Often the *Indication Search* will deliver a number of drugs if used alone or for research or clinical reasons it might be useful to know which drugs have some association with a gene of interest; for instance, CYP2D6. If so then this field helps to narrow down that search.

**Drug Group** - Select which drug groups you want to include in your search. These include: experimental, approved, withdrawn, illict and more. Drugs are almost always classified in more than one group so selecting 'approved' will include any drug thus classified regardless of whether it is also illict, etc.

**Gene Type and Drug Action** - The first thing shown is a drop down menu asking to filter the search by gene type. Gene types include: enzymes, targets, transporters and carriers. If no gene is put into the *Gene Search* field then all drugs with 'Enzyme' or 'Target' associations will be delivered. If a gene is put into the *Gene Search* that is not found under enzymes for instance, then a message will be given to recheck the search fields. Once a gene type is selected, check boxes will be available to choose the associated actions depending on the gene type. For instance selecting 'Enzyme' allows a search for inhibitors, substrates, activators and many more. These filters are added so that searches can be refined to only include gene-drug interactions of interest.

## Gene-drug nexus

### Overview 
This is the main search tool for gene-drug interactions. It is mainly used to find all drugs associated with a certain gene or family of genes. The tab contains two elements: a search filter where search fields can be manipulated depending upon the users interest and a main panel where the results for the search are delivered in a table.

### Search Filter

  **Gene Category** - This allows the user to select which dataset to use while searching for a gene or drug. *Enzymes* are genes involved in metabolism; most of which belong to the Cytochrome P450 (CYP) class. *Targets* are genes that drugs ultimately interact with to deliver their pharmacologic effect or adverse reaction; this is the largest dataset by far. *Transporters* are genes that encode proteins whose primary role is the transportation of drugs and ions accross the plasma membrane; this dataset is rich in the solute carrier family (SLC) of genes. *Carriers* are genes that encode proteins which help in drug distribution; the archetypal example is serum albumin (ALB).
    
  **Search Type** - Choose the type of search used by *Gene-Drug Search* covered below. A *Fuzzy* search returns all genes which contain the input text. For instance, if a user types in 'CYP2C' the whole family of genes are returned: CYP2C18, CYP2C19, etc. Similarly the entire CYP class can be returned by typing in 'CYP'. A *Discrete* search will return exactly what has been entered into *Gene-Drug Search*. In this case if 'CYP' is entered nothing will be returned because there is no gene named CYP. This search is mainly used to eliminate unwanted genes that share common elements. For instance, if you type in CYP3A4 as a fuzzy search you will get both CYP3A4 and CYP3A43; with the discrete search only CYP3A4 will be returned. Searching for drugs is ONLY done as a discrete search regardless of the search type selected. It is also sensitive to spelling, but not case sensitive, and will not return drugs which are spelled incorrectly. In the future I plan to have it give suggestions, but for now spell your drugs correctly.
    
  **Gene-Drug Search** - Type in any drug or gene of interest and see what's returned. Be sure to spell all drugs correctly as they will otherwise not be returned.
    
  **Drug Action** - A pull down menu that allows you to filter the search based on the kind of interaction between drug and gene. Some drug actions include: inducers, inhibitors and activators (enzyme) or agonists, antagonists and antibodies (targets). 
    
  **Drug Class** - Filter the search based on drug class. The list is massive and is categorized based on MeSH nomenclature. For example one can search for every drug labeled an anesthetic. Almost every drug is tagged with multiple classificatons; for instance acetaminophen is labled under 'Analgesics, Non-Narcotic' and 'Antipyretics'. Searching for either classification will return acetaminophen and every gene and drug associated with the class.
    
  **Drug Group** - Filter search based on groups, which are basically approval statuses. In the case of acetaminophen it is grouped as 'approved'. Other groups include: experimental, investigational and withdrawn. Like *Drug Class*, drugs can belong to more than one group. Drugs classed as vitamins or supplements may even have three or four groups like L-glutamine grouped as approved/investigational/nutraceutical. Approved drugs are approved in at least one country; withdrawn are drugs that have been withdrawn from at least one country. For further information read the [DrugBank Documentation](http://www.drugbank.ca/documentation). 

###Table and Search Results

   **Search Results** - A read out containing the number of entries, drugs and genes retreived from a search field. In an example, a search for genes that metabolize acetaminophen by selecting the *Gene Category* 'Enzyme' and typing the drug name will result in 18 entries 1 drug and 16 genes. All 18 entries are acetaminophen representing 15 proteins with accepted gene names and 3 proteins with no gene name. This brings up a very important point: all proteins (targets, enzymes, etc.) that have no associated gene name and are therefore blank under the gene column are categorized as their own gene, the 'null gene'. These proteins cannot be searched individually but must be accessed either by searching for the 'null gene' or indirectly from other searches.  To see the 'null gene' for a given *Gene Category* simply clear the *Gene-Drug Search* field and use a discrete *Search Type*.

  **Table** - The table contains all the information from the search fields. The columns include the drug name (where the drug names are also links to DrugBank), drug class, drug group, gene name, protein name and drug action. In addition all columns of the table can be sorted alpha-numerically by clicking the column name. This is particularly useful if the search has returned a large amount of data. For instance, looking for drugs that act as agonists on their *Targets* is a pretty general search which will return over 800 entries with 404 distinct drugs and almost 200 genes. In order to make sense of a table this size, sorting is necessary. Even searching for approved drugs that act as substrates for CYP2D6 return nearly 200 drugs. In this case too, making the list alphabetical by drug is very useful and may help to narrow your search further.

##Class Browse

### Overview
Due to the enormous amount of drug classes used by DrugBank I felt the need to add a feature that makes it easy to discover the kind of drug classes which dominate a particular gene or gene family. This is mainly to be used as a browse feature which may help to find a particular drug or gene-drug interaction when using the *Drug Indication* tab or the *Gene-drug nexus*.

##Acknowledgements 

All data here has been gathered from [DrugBank](http://www.drugbank.ca/). They have done an excellent job gathering data from an array of sources and I encourage anyone with further interest to visit their site. I am not afilliated with Drugbank, but I appreciate their generous distribution and the wonderful information contained in their database.

Here I have attempted to bring together as much as possible all information regarding gene-drug interaction under the various classification schemes offered by DrugBank. This includes an enzyme section that allows one to search by gene, drug, drug class, group or action. Similar tables were put together for drug targets, transporters and carriers. In no way is this a complete list nor does it offer the number of fields available at Drugbank, however it does offer quick access to all gene-drug relationships such that with only three clicks of the mouse one can find all information related to acetaminophen; from the genes involved in its metabolism to its protein targets, carriers or cellular transporters. I've done my best to eliminate the extraneous information and to offer filters to adjust to user interest. This is no doubt a work in progress with my hope of including many more graphical aids and perhaps anatomical or cellular distributions.

Thank you!

### References
DrugBank 4.0: shedding new light on drug metabolism. Law V, Knox C, Djoumbou Y, Jewison T, Guo AC, Liu Y, Maciejewski A, Arndt D, Wilson M, Neveu V, Tang A, Gabriel G, Ly C, Adamjee S, Dame ZT, Han B, Zhou Y, Wishart DS.Nucleic Acids Res. 2014 Jan 1;42(1):D1091-7.PubMed ID: [24203711](http://www.ncbi.nlm.nih.gov/pubmed/24203711)

 
