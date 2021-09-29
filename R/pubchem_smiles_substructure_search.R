
#library(httr2)

#smiles <- c('C1CCC1CC(CN(C)(C))CC(=O)CC')

#pubchem_smiles_substructure_search(smiles,threshold = 9)


pubchem_smiles_substructure_search <- function(smiles,MatchIsotopes=F,MatchCharges=F,MatchTautomers=F,RingsNotEmbedded=F,
                                               SingleDoubleBondsMatch=T,ChainsMatchRings=T,StripHydrogen=F,Stereo = "ignore",
                                               maxRecords=20,debug=F){


  if(debug) {print("running query")
    print(paste(smiles,threshold,maxRecords))
    }

  url <- paste0("https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/substructure/smiles/",
                smiles,
                "/JSON",
                "?MatchIsotopes=",MatchIsotopes,
                "&MatchCharges=",MatchCharges,
                "&MatchTautomers=",MatchTautomers,
                "&RingsNotEmbedded=",RingsNotEmbedded,
                "&SingleDoubleBondsMatch=",SingleDoubleBondsMatch,
                "&ChainsMatchRings=",ChainsMatchRings,
                "&StripHydrogen=",StripHydrogen,
                "&Stereo=",Stereo,
                "&MaxRecords=",maxRecords)

  r1 <-httr2::req_perform(httr2::request(url) %>% httr2::req_method("POST"))

  listkey <-  httr2::resp_body_json(r1)$Waiting$ListKey


  result_url <- paste0("https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/listkey/",
                       listkey,"/cids/JSON")
  r2 <-req_perform(httr2::request(result_url) %>% httr2::req_method("POST"))


   while(!is.null(httr2::resp_body_json(r2)$Waiting$Message )){


            r2 <-httr2::req_perform(httr2::request(result_url) %>% httr2::req_method("POST"))
          Sys.sleep(2)
   }

cid_list <- unlist(resp_body_json(r2)$IdentifierList$CID)


compound_url <- paste0("https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/",
                       paste0(cid_list,collapse=","),
                       "/property/MolecularFormula,MolecularWeight,CanonicalSMILES/CSV"
                       )

table<- read.csv(compound_url)

table$`Compound Page` <- paste0("https://pubchem.ncbi.nlm.nih.gov/#query=",table$CID)



  DT::datatable(data = table)
 }

