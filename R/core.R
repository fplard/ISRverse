#' Animal data
#'
#' A simulated dataset including information about individual animals.
#'
#' @format A data.frame object with 1000 rows and 10 variables:
#' \describe{
#' \item{AnimalAnonID}{Anonimized ID of the Animal}
#' \item{Class}{Taxonomy: Class}
#' \item{Order}{Taxonomy: Order}
#' \item{Family}{Taxonomy: Family}
#' \item{SpeciesName}{Taxonomy: SpeciesName}
#' \item{CommonName}{Point where observation conditions have been monitored}
#' \item{FirstHoldingInstitution}{Anonimized ID of the first institution holding the animal}
#' \item{FirstCollectionScopeType}{First collection can be "Local" = Only private use or "Global" = Zims user use}
#' \item{LastHoldingInstitution}{Anonimized ID of the last institution holding the animal}
#' \item{LastCollectionScopeType}{Last collection can be "Local" = Only private use or "Global" = Zims user use}
#' \item{AnyLocalCollectionFlag}{Whether the individual has ever been in a "local" (= Private use) collection in his life}
#' \item{LatitudeZone}{}
#' \item{BirthDate}{Estimated birth date}
#' \item{BirthDateEstimateType}{If birth date is not known with certainty, it can be estimated using: "Undetermined" = Unkwnown / "Range" = any date between min and max birth date / "ApproxAfter" = Birth date is later than the min birth date / "AproxBefore" = Birth date is ealier than the max birth date / "Approxvariance" = birth date estimated at mean with an error of some days around the estimated date}
#' \item{BirthObserved}{Whether the birth was observed}
#' \item{FirstAcquisitionDate}{Date of first acquisition of the animal}
#' \item{SexType}{Sex}
#' \item{DeathDate}{Estimated death date}
#' \item{DeathDateEstimateType}{If death date is not known with certainty, it can be estimated, see BirthDateEstimateType}
#' \item{GlobalStatus}{Current status of the animal}
#' \item{LastCommentEntryDate}{Last date a measure/observation/action included in ZIMS was made for a given animal}
#' \item{LastTXDate}{Last transaction date}
#' \item{RelevantDeathInformationType}{Information about cause of death}
#' \item{MinBirthDate}{Minimum estimated birth date}
#' \item{MaxBirthDate}{Maximum estimated birth date}
#' \item{MinDeathDate}{Minimum estimated death date}
#' \item{MaxDeathDate}{Maximum estimated death date}
#' \item{EntryDate}{Entry date in Zims}
#' \item{EntryType}{Whether the indivual entered in Zims at birth "b" or later "T"}
#' \item{DepartDate}{Depart Date from Zims}
#' \item{DepartType}{Whether the indivual exit Zims at death "D" or was censored/lost to follow up "C"}
#' \item{above95}{1 = the individual is within the oldest 5% of the distribution of individual lifespans}
#' \item{above99}{1 = the individual is within the oldest 1% of the distribution of individual lifespans}
#' \item{above99.9}{1 = the individual is within the oldest 0.1% of the distribution of individual lifespans}
#' #' }
#'
#' @usage data(core)
#'
#' @source Subset of a toy database created by the Species360 Development team in 08-2024
"core"
