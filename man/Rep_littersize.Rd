% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rep_littersize.R
\name{Rep_littersize}
\alias{Rep_littersize}
\title{Litter Size}
\usage{
Rep_littersize(
  ReproData,
  NDay = 7,
  ParentPercDam = 80,
  ParentPercSire = 80,
  MinNLitter = 30
)
}
\arguments{
\item{ReproData}{\code{data frame} including at least the columns \emph{AnimalAnonID}, \emph{ParentAnonID}, \emph{ParentType}, \emph{Probability}, \emph{Offspring_BirthDate}, \emph{Offspring_Inst} and \emph{Parent_Age}.}

\item{NDay}{\code{numeric} Number of consecutive days over which the birth dates of a litter/clutch can be spread.}

\item{ParentPercDam}{\code{numeric} Minimum percentage of parentage probability to include for Dam.}

\item{ParentPercSire}{\code{numeric} Minimum percentage of parentage probability to include for Sire.}

\item{MinNLitter}{\code{numeric} Minimum number of litters to run the analysis. The data frame for litter size will be produced in all cases.}
}
\value{
A list including:
\itemize{
\item A data frame with the litter size per mother and birth date
\item A table including the number and proportion of each size of litter
\item Summary statistics including:
}
\itemize{
\item NOffsp_prob: Number of offspring
\item NParent_prob: Number of parents
\item NReprEvent: Number of litters
\item MeanLittSize: Mean litter size
\item MedLittSize: Median litter size
\item SdLittSize: Standard deviation of litter size
\item analyzed = FALSE,
\item error: if the litter size where not analysze, the associated error is printed here. It can be :"No births with parentage probability higher than {parentProb} or  N litter < {MinNLitter}
\item Nerr: The number id of the error
}
\itemize{
\item a table including the mean and standard deviation of litter size per maternal age
}
}
\description{
Make a data frame of litter size per parent and birth date and produce summary tables of litter size. it selects only offspring/mother couples
}
\examples{
data(core)
data(collection)
data(parent)
data(moves)
#prepare Data
Data <- Rep_prepdata (coresubset = core, collection, parent, moves, MinNRepro = 1, MinNPaRepro = 1,
                      BirthType_parent = "All", BirthType_offspring = "All" )

#Estimate litter size
out <- Rep_littersize(Data$ReproData, 
                      NDay = 7)

out
}
