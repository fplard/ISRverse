% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/weights.R
\docType{data}
\name{weights}
\alias{weights}
\title{Weights data}
\format{
A data.frame object with 2273 rows and 14 variables:
\describe{
\item{AnimalAnonID}{Anonimized ID of the Animal}
\item{RecordingInstitution}{Anonimized ID of recording institution}
\item{MeasurementType}{Name of the measurement made}
\item{RecordType}{Type of record}
\item{MeasurementValue}{Estimated value of the measure}
\item{EstimatedMeasurement}{1 = The measurment was not measured but estimated/guessed}
\item{ExcludedFromNorms}{}
\item{MeasurementDate}{Estimate date of measurement}
\item{MeasurementDateEstimateType}{If measurement date is not known with certainty, it can be estimated using: "Undetermined" = Unkwnown / "Range" = any date between min and max measurement date / "ApproxAfter" = Birth date is later than the min measurement date / "AproxBefore" = Birth date is ealier than the max measurement date / "Approxvariance" = measurement date estimated at mean with an error of some days around the estimated date}
\item{MeasurementDateEstimateStart}{Measurement estimated birth date}
\item{MeasurementDateEstimateEnd}{Measurement estimated birth date}
\item{CollectionScopeType}{"Local" = Only private use or "Global" = Zims user use}
\item{Age}{Animal age in years at measurement date}
\item{UnitOfMeasure}{Unit of Measure = kilogram}
#' }
}
\source{
Subset of a toy database created by the Species360 Development team in 08-2024
}
\usage{
data(weights)
}
\description{
A simulated dataset including information about individual weights.
}
\keyword{datasets}
