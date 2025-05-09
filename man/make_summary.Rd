% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/make_summary.R
\name{make_summary}
\alias{make_summary}
\title{Summarize taxon profiles analyses}
\usage{
make_summary(
  AnalysisDir,
  SaveDir,
  namefile = "",
  TaxaList = "Mammalia",
  BySex = list(Mammalia = c("Male", "Female")),
  Sections = c("sur", "rep", "gro"),
  MinAge = 0
)
}
\arguments{
\item{AnalysisDir}{\code{character} Directory where to find the .Rdata files: Results of the analyses}

\item{SaveDir}{\code{character} Directory where to save summary plots and tables}

\item{namefile}{\code{character} Suffix to add to the name of files produced if needed.}

\item{TaxaList}{\code{vector of character} names of the taxa studied.}

\item{BySex}{\code{list} of the taxa names indicating the sexes analyzed.}

\item{Sections}{\code{vector of character} names of the sections: "sur", "rep" and/or "gro".}

\item{MinAge}{\code{numeric} Ages at which the survival analyses started.}
}
\value{
It saves summary tables and plots for each Sections and a general summary table. It returns the main summary table
}
\description{
Produce summary tables and plots of the demographic analyses made for all species
}
\examples{
# file = system.file("sci_Animal.csv", package = 'ISRverse')
# AnalysisDir  = paste0(dirname(file),'/Rdata')
# SaveDir = paste0(tempdir(check = TRUE),'/temp')
# dir.create(SaveDir)
# 
# SummTab <- make_summary(AnalysisDir, SaveDir,
#                         TaxaList = "Reptilia",
#                         BySex = list(Reptilia = c("Male", "Female")) ,
#                         Sections = c("sur", 'gro')
# )
# list.files(SaveDir)
# 
# unlink(SaveDir, recursive = TRUE)
}
