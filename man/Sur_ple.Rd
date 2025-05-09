% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sur_ple.R
\name{Sur_ple}
\alias{Sur_ple}
\title{Kaplan-Meier table}
\usage{
Sur_ple(Data)
}
\arguments{
\item{Data}{\code{data.frame} including at least the following columns \emph{deparAge}, \emph{entryAge} (\code{date}), and \emph{DepartType}}
}
\value{
A data frame including 3 colummns:
\itemize{
\item Ages: the different ages
\item Surv: survivorship
\item event = 1 if the individual was dead at this age
vs. 0 is the individual was left-censored at this age
}
}
\description{
This function estimated the Kaplan-Meier estimator from the raw data.
}
\examples{

entryAge = sample(c(1:10), 200, replace = TRUE)
data <- data.frame(
  entryAge = entryAge,
  deparAge =  entryAge + sample(c(0:10), 200, replace = TRUE),
  DepartType = sample(c('C', 'D'), 200, replace = TRUE))


out<-Sur_ple(data)
}
