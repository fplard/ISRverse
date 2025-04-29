#' Parent data
#'
#' A simulated dataset including information about individual parents.
#'
#' @format A data.frame object with 1503 rows and 7 variables:
#' \describe{
#' \item{AnimalAnonID}{Anonimized ID of the Animal}
#' \item{ParentOriginType}{"ZIMS" or "Non-Zims"}
#' \item{ParentType}{"Dam" or "Sire"}
#' \item{ParentAnonID}{Anonimized ID of the parent}
#' \item{Probability}{Percentage of parentage certainty}
#' \item{OffspringCollectionScopeType}{Offspring collection at birth "Local" = Only private use or "Global" = Zims user use}
#' \item{ParentCollectionScopeType}{Parent collection at offspring birth "Local" = Only private use or "Global" = Zims user use}
#' }
#'
#' @usage data(parent)
#'
#' @source Subset of a toy database created by the Species360 Development team in 08-2024
"parent"
