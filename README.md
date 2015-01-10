# DrugBank-Gene-Nexus

Search gene-drug interactions found in DrugBank with Shiny.

## What is DrugBank?

As per the [Drugbank](http://www.drugbank.ca/) website: The DrugBank database is a unique bioinformatics and cheminformatics resource that combines detailed drug (i.e. chemical, pharmacological and pharmaceutical) data with comprehensive drug target (i.e. sequence, structure, and pathway) information. The database contains 7737 drug entries including 1585 FDA-approved small molecule drugs, 158 FDA-approved biotech (protein/peptide) drugs, 89 nutraceuticals and over 6000 experimental drugs. Additionally, 4281 non-redundant protein (i.e. drug target/enzyme/transporter/carrier) sequences are linked to these drug entries. Each DrugCard entry contains more than 200 data fields with half of the information being devoted to drug/chemical data and the other half devoted to drug target or protein data.

References can be found in the acknowledgement section. I encourage anyone not familiar with DrugBank to visit the site. Here I've tried to consolidate the fields pertaining to gene-drug interaction. Some of the search fields are available at drugbank and are virutally identical. Some on the other hand are unique, allowing one to search for gene famlies (all CYP genes) with *Fuzzy* search and a drug action filter to locate all inhibitors of CYP2D6. 

## Gene-drug nexus

### Overview 
This is the main search tool for gene-drug interactions. The tab contains two elements: a search filter where search fields can be manipulated depending upon the users interest and a results section where the results for the search are delivered in a table.

### Search Filter

  **Gene Category** - This allows the user to select which dataset to use while searching for a gene or drug. *Enzymes* are genes involved in metabolism; most of which belong to the Cytochrome P450 (CYP) class. *Targets* are genes that drugs ultimately interact with to deliver their pharmacologic effect or adverse reaction; this is the largest dataset by far. *Transporters* are genes that encode proteins whose primary role is the transportation of drugs and ions accross the plasma membrane; this dataset is rich in the solute carrier family (SLC) of genes. *Carriers* are genes that encode proteins which help in drug distribution; the archetypal example is serum albumin (ALB).
    
  **Search Type** - Choose the search type conducted by *Gene-Drug Search*. A *Fuzzy* search returns all genes which contain the input text. For instance, if a user types in 'CYP2C' the whole family of genes are returned: CYP2C18, CYP2C19, etc. Similarly the entire CYP class can be returned by typing in 'CYP'. A *Discrete* search will return exactly what has been entered into *Gene-Drug Search*. In this case if 'CYP' is entered nothing will be returned because there is no gene named CYP. This search is mainly used to eliminate unwanted genes that share common elements. For instance, if you type in CYP3A4 as a fuzzy search you will get both CYP3A4 and CYP3A43; with the discrete search only CYP3A4 will be returned. Searching for drugs is ONLY done as a discrete search regardless of the search type selected. It is also spelling sensitive, but not case sensitive, and will not return drugs which are spelled incorrectly. In the future I plan to have it give suggestions, but for now spell your drugs correctly.
    
  **Gene-Drug Search** - Type in any drug or gene of interest and see what's returned. Be sure to spell all drugs correctly as they will not be returned otherwise.
    
  **Drug Action** - A pull down menu that allows you to filter the search based on the kind of interaction between drug and gene. Some drug actions include: inducers, inhibitors and activators(enzyme) or agonists, antagonists and antibodies(targets). 
    
  **Drug Class** - Filter the search based on drug class. The list is massive and is categorized based on MeSH nomenclature. For example one can search for every drug labeled an anesthetic. Almost every drug is tagged with multiple classificatons; for instance acetaminophen is labled under Analgesics, Non-Narcotic/Antipyretics. Searching for either classification wll return acetaminophen and every gene associated with it.
    
  **Drug Group** - Filter the search based on group which are basically approval statuses. In the case of acetaminophen it is grouped as 'approved'. Other groups include: experimental, investigational and withdrawn. Like drug class, drugs can belong to more than one group. Drugs classed as vitamins or supplements may even have three or four groups like L-glutamine grouped as approved/investigational/nutraceutical. Approved drugs are approved in at least one country; withdrawn are drugs that have been withdrawn from at least one country. For further information read the [DrugBank Documentation](http://www.drugbank.ca/documentation). 

###Table and Search Results

   **Search Results** - A read out containing the number of entries, drugs and genes retreived from a search field. In an example, a search for genes that metabolize acetaminophen by selecting the *Gene Category* 'Enzyme' and typing the drug name will result in 18 entries 1 drug and 16 genes. All 18 entries are acetaminophen representing 15 proteins with accepted gene names and 3 proteins with no gene name. This brings up a very important point: all proteins(targets, enzymes, etc.) that have no associated gene name and are therefore blank under the gene column are categorized as their own gene, the 'null gene'. These proteins cannot be searched individually but must be accessed either by searching for the 'null gene' or indirectly from other searches.  To see the 'null gene' for a given *Gene Category* simply clear the *Gene-Drug Search* field and use a discrete *Search Type*.

  **Table** - The table contains all the information from the search fields. The variables included are the drug name, drug class, drug group, gene name, protein name, drug action and a link to the drug page at DrugBank. In addition all columns of the table can be sorted alpha-numerically by clicking the column name. This is particularly useful if the search has returned a large amount of data. For instance, looking for drugs that act as agonists on their *Targets* is a pretty general search which will return over 800 entries with 404 distinct drugs and almost 200 genes. In order to make sense of a table this size sorting is necessary. Even searching for approved drugs that act as substrates for CYP2D6 return nearly 200 drugs. In this case too, making the list alphabetical by drug is very useful and may help to narrow your search further.

##Drug Class Graphics Tool

##Acknowledgements 

All data here has been gathered from [DrugBank](http://www.drugbank.ca/). They have done an excellent job gathering data from an array of sources and I encourage anyone with further interest to visit their site. I am not afilliated with Drugbank, but I appreciate their generous distribution and the wonderful information contained in their database.

Here I have attempted to bring together as much as possible all information regarding gene-drug interaction under the various classification schemes offered by DrugBank. This includes an enzyme section that allows one to search by gene, drug, drug class, group or action. Similar tables were put together for drug targets, transporters and carriers. In no way is this a complete list nor does it offer the number of fields available at Drugbank, however it does offer quick access to all gene-drug relationships such that with only three clicks of the mouse one can find all information related to acetaminophen; from the genes involved in its metabolism to its protein targets, carriers or cellular transporters. I've done my best to eliminate the extraneous information and to offer filters to adjust to user interest. This is no doubt a work in progress with my hope of including many more graphical aids and perhaps anatomical or cellular distributions.

Thank you!

- **References**
  1. DrugBank 4.0: shedding new light on drug metabolism. Law V, Knox C, Djoumbou Y, Jewison T, Guo AC, Liu Y, Maciejewski A, Arndt D, Wilson M, Neveu V, Tang A, Gabriel G, Ly C, Adamjee S, Dame ZT, Han B, Zhou Y, Wishart DS.Nucleic Acids Res. 2014 Jan 1;42(1):D1091-7.PubMed ID: [24203711](http://www.ncbi.nlm.nih.gov/pubmed/24203711)

 
