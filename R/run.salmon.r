#' @title Run Salmon
#' @description This function helps the user to run the Salmon program. The user must assign the location of the program, an output directory, the transcriptome, the location of the libraries, the kmer size, the processing threads, and a label for the index.
#' @param output_dir output salmon directory
#' @param index paterrn of output salmon directory. This tag will be used to create the index and a folder containing the counts for each library
#' @param salmon_path A path indicating the location of the program
#' @param kmer The kmer size used during Salmon indexing
#' @param lib_dir A path indicating the location of libraries. Libraries should be tagged with ".fastq.gz" (single-end) or "_R#.fastq.gz" (paired-end) at the end, for example: anyName.fastq.gz (single-end) or anyName_R1.fastq.gz and anyName_R2.fastq.gz (paired-end)
#' @param threads number of threads to be used
#' @param trme A path indicating the location of transcriptome
#' @param decoys The location path of the \code{decoy.txt} file generated by the \code{mk.reference} function
#' @param pe_se Indicate if you using paired-end (\code{"pe"}) or single-end (\code{"se"}) libraries
#' @export
run.salmon <- function(index, decoys, salmon_path="salmon", kmer, lib_dir,pe_se=c("pe","se"), threads, trme){
  pwd <- getwd()
  if(dir.exists(paste0(pwd,"/salmon_out"))==F){
      dir.create(paste0(pwd,"/salmon_out"))
    }
dir.create(paste0(pwd,"/",index))
  if(pe_se=="pe"){
  system(
    paste(paste0("INDEX_PATH=",paste0(pwd,"/",index),";"),
          paste0("DECOYS_PATH=",normalizePath(decoys),";"),
          paste0("READS_PATH=",normalizePath(lib_dir),";"),
          paste0("TRME_PATH=",normalizePath(trme),";"),
          "cd", paste0(pwd,"/salmon_out;"),
          salmon_path, "index -t", "$TRME_PATH",
          "-k", kmer,
          "-i", "$INDEX_PATH",
          "--decoys", "$DECOYS_PATH", "|| exit 1 &&",

          "lista=`ls $READS_PATH/*R1.fastq.gz | sed s/_R1.fastq.gz//g`;",
          "cd", paste0(pwd,"/salmon_out;"),
          "for fn in ${lista}; do",salmon_path, "quant -i", "$INDEX_PATH",
          "-l A --gcBias",
          "--useVBOpt",
          "-1", "${fn}_R1.fastq.gz",
          "-2", "${fn}_R2.fastq.gz",
          "-p", threads, "--validateMappings",
          "-o", paste0("temp/",index,"/${fn}_q;"),"done","|| exit 1 &&",
          "mv",paste0("temp/",index,"$READS_PATH/*"),paste0(pwd,"/salmon_out/"),"|| exit 1 &&",
          "rm -r temp/"
    )
  )
  }else{
    system(
    paste(paste0("INDEX_PATH=",paste0(pwd,"/",index),";"),
          paste0("DECOYS_PATH=",normalizePath(decoys),";"),
          paste0("READS_PATH=",normalizePath(lib_dir),";"),
          paste0("TRME_PATH=",normalizePath(trme),";"),
          "cd", paste0(pwd,"/salmon_out;"),
          salmon_path, "index -t", "$TRME_PATH",
          "-k", kmer,
          "-i", "$INDEX_PATH",
          "--decoys", "$DECOYS_PATH", "|| exit 1 &&",

          "lista=`ls $READS_PATH/*.fastq.gz | sed s/.fastq.gz//g`;",
          "cd", paste0(pwd,"/salmon_out;"),
          "for fn in ${lista}; do",salmon_path, "quant -i", "$INDEX_PATH",
          "-l A --gcBias",
          "--useVBOpt",
          "-r", "${fn}.fastq.gz",
          "-p", threads, "--validateMappings",
          "-o", paste0("temp/",index,"/${fn}_q;"),"done","|| exit 1 &&",
          "mv",paste0("temp/",index,"$READS_PATH/*"),paste0(pwd,"/salmon_out/"),"|| exit 1 &&",
          "rm -r temp/"
      )
    )
  }
}
