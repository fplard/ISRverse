
#Growth Functions


# Von Bertalanffy growth function:
vbGrowth <- function(gamma = 0.5 , zinf = 0, z0 = 0, LL = F, logx, logz = 0) {
  zEst <-z0 + zinf * (1 - exp(- gamma * logx))
  if(LL){
    return(sum((logz - zEst)^2))
  }else{return(zEst)}
}
# Logistic growth function:
logisGrowth <- function( zinf = 0, gamma= 0.5, xInfl = 0, LL = F, logx, logz = 0) {
  zEst <-  zinf / (1 + exp(- gamma * (logx - xInfl)))
  if(LL){
    return(sum((logz - zEst)^2))
  }else{return(zEst)}
}
# Polynomial of degree 4:
polyGrowth <- function( gam0 = 0, gam1 = 0, gam2 = 0, gam3 = 0, gam4 = 0, LL = F, logx, logz = 0) {
  zEst <-  gam0 + gam1 * logx + gam2 * logx^2 + gam3 * logx^3 + gam4 * logx^4
  if(LL){
    return(sum((logz - zEst)^2))
  }else{return(zEst)}
}
# Gompertz growth function:
gompertzGrowth <- function( zinf = 0, beta = 0, gamma= 0.5, LL = F, logx, logz = 0) {
  zEst <-  zinf * exp(-beta * exp(-gamma* logx));
  if(LL){
    return(sum((logz - zEst)^2))
  }else{return(zEst)}
}
# Chapman-Richards:
chapmanRichards <- function( zinf = 0, beta = 0, gamma= 0.5, m = 0, LL = F, logx, logz = 0) {
  zEst <- zinf * (1 - beta * exp(-gamma * logx))^(1 / (1 - m))
  if(LL){
    return(sum((logz - zEst)^2))
  }else{return(zEst)}
}
# #Monomolecular
# monomolecular <- function(x, zinf, beta, gamma) {
#   result <- zinf * (1 - beta * exp(-gamma * x))
#   return(result)
# }
