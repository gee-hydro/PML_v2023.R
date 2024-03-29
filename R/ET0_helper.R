#' ET helper
#' @name ET_helper
#'
#' @description
#' - `get_lambda`: latent heat of vaporization (~2500 J g-1)
#' - `get_Rn`: net solar radiation (W m-2)
#' - `get_VPD`: vapor pressure deficit (kPa)
NULL

#' @param Tavg daily mean temperature, deg
#'
#' @export
#' @rdname ET_helper
get_lambda <- function(Tavg) {
  # latent heat of vaporization, 2500 [J g-1]  at 25 0C
  Cp <- 4.2 * 0.242 # specific heat at constant pressure, 1.013 [kJ kg-1 0C-1]
  lambda <- 2500 - 2.2 * Tavg # J g-1
  lambda
}

#' @param Rs shortwave inward solar radiation, W m-2
#' @param Rln longwave inward solar radiation, W m-2
#' @param albedo shortwave albedo, -
#' @param emiss longwave emissivity, -
#'
#' @rdname ET_helper
#' @export
get_Rn <- function(Rs, Rln, Tavg, albedo, emiss) {
  Stefan <- 4.903e-9 # Stefan-Boltzmann constant [MJ K-4 m-2 day-1],

  Rns <- (1 - albedo) * Rs
  RLout <- Stefan * (Tavg + 273.15)^4 / 0.0864 # convert from MJ m-2 d-1 to W/m2

  ## fix bug at emiss*Rln, 20230922
  Rnl <- emiss*(Rln - RLout)
  Rn <- pmax(Rns + Rnl, 0) # Rns+Rnl, includenan
  Rn
}

#' @param Pa air pressure, kPa
#' @param q specific humidity, kg kg-1
#' @param Tmax,Tmin maximum and minimum temperature, deg C
#'
#' @rdname ET_helper
#' @export
get_VPD <- function(Pa, q, Tmax, Tmin) {
  # function INPUTS = add_VPD(INPUTS)
  # # anonymous function of vapor pressure
  # # add VPD variable
  # # calculate VPD
  # p = INPUTS.Pa;
  # q = INPUTS.q;
  ea <- q * Pa / (0.622 + 0.378 * q) # specific humanity

  es_tmax <- cal_es(Tmax)
  es_tmin <- cal_es(Tmin)
  # # es_tavg = vapor_pressure(dt_gee.Tavg);
  es <- (es_tmax + es_tmin) / 2
  VPD <- pmax(es - ea, 0.001) # kpa
  VPD
}
