#Read the First Additional Metadata. sample_metadata
sample_md <- read.csv() |>
  clean_names()
colnames(sample_md)  
nrow(sample_md)  
sum(ms_obj_sample %in% sample_md$donor) 
sum(ms_obj_sample %in% sample_md$sample)  #Appropriate Cols for metadata merging 
sum(ms_obj_sample %in% sample_md$sample_10x)  
sum(ms_obj_sample %in% sample_md$hash)  
setdiff(ms_obj_sample , unique(sample_md$sample)) #Identify the Non_matched samples
#The per_sample metadata include 204 rows, It should be evaluate, don't delete blindly. 
length(unique(sample_md$sample)) #The unique sample count in the both are equal. 
sample_md |> 
  dplyr::count(sample, sort = TRUE)
#Identifying the Duplicated rows in metadata
sample_md_unique <- sample_md |>
  distinct(sample, .keep_all = TRUE)
nrow(sample_md_unique)  
length(unique(sample_md_unique$sample))  
dplyr::setdiff(meta$orig.ident, sample_md_unique$sample)
dplyr::setdiff(sample_md_unique$sample, meta$orig.ident) 
# So, per_sample metadata doesn't include additional sample and the controversy in numbers regarding to technical duplication. 
#Now Choose the appropriate cols in metadata. 
colnames(sample_md_unique)
sample_md_selected <- sample_md_unique |>
  dplyr::select(
    dplyr::any_of(c( "donor", 
                     "sample",
                     "match",
                     "batch_pair",
                     "group",
                     "cohort",
                     "age_sampling",
                     "sex",
                     "edss",
                     "disease_onset",
                     "prev_treatment",
                     "natalizumab_treatment")
    )
  )
meta <- meta |> tibble::rownames_to_column("Barcode")
#Add the selected columns of additional metadata and Creat a DataFrame
merged_meta <- meta |>
  dplyr::left_join(
    sample_md_selected,
    by = c("orig.ident" = "sample"),
    relationship = "many-to-one"
  )

#Add metadata dataframe to Seurat Object 
cols_to_add <- setdiff(colnames(sample_md_selected), "sample")
metadata_to_add <- merged_meta |>
  dplyr::select(Barcode, dplyr::all_of(cols_to_add))|>
  tibble::column_to_rownames("Barcode")
identical(rownames(metadata_to_add), colnames(ms_obj))
ms_obj <- Seurat::AddMetaData(
  object= ms_obj,
  metadata = metadata_to_add
)
head(ms_obj[[]][, cols_to_add, drop = FALSE])
merged_md <- ms_obj@meta.data

#Adding the second Metadata. per_cell 
md_pc <- read.csv() |>
  clean_names()
nrow(md_pc)  #497705
colnames(md_pc)
md_pc <- md_pc|>
  dplyr::select(
    dplyr::any_of(
      c("cell_names", #This column in per cell metadata is the key to merging. 
        "percent_mito",
        "basictype",
        "cluster_names")
    )
  )
merged_md <- merged_md |> tibble::rownames_to_column("barcode")
merge_meta_pc <- merged_md |>
  dplyr::left_join(
    md_pc,
    by = c("barcode" = "cell_names"),
    relationship = "one-to-one"
  )
cols_to_add2 <- setdiff(colnames(merge_meta_pc), "cell_names")
meta_to_add2 <- merge_meta_pc |>
  dplyr::select(barcode, all_of(cols_to_add2)) |>
  tibble::column_to_rownames("barcode")
ms_obj <- Seurat::AddMetaData(
  object = ms_obj,
  metadata = meta_to_add2
)
head(ms_obj@meta.data)