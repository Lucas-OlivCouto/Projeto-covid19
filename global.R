#use to be call global.
   
# ---- Loading libraries ----
library("shiny")
library("shinydashboard")
library("tidyverse")
library("leaflet")
library("plotly")
library("DT")
library("fs")
library("wbstats")
library("readr")
library("readxl")

source("utils.R", local = T)

#download/ update data functions#

getdata_brasil <- function() {
  download.file(
    url      = "https://github.com/wcota/covid19br/archive/master.zip",
    destfile = "dados/covid19_data_wcota.zip"
  )
  data_path <- "covid19br-master/cases-brazil"
  unzip(
    zipfile   = "dados/covid19_data_wcota.zip",  
    files     = paste0(data_path, c("-states.csv","-cities-time_changesOnly.csv")),
    exdir     = "dados",
    junkpaths = T
  )
}

updatedata_brasil <- function() {
  if (!dir_exists("dados")) {
    dir.create('dados')
    getdata_brasil()
  } else if ((!file.exists("dados/covid19_data_wcota.zip")) || (as.double(Sys.time() - file_info("dados/covid19_data_wcota.zip")$change_time, units = "hours") > 0.5)) {
    getdata_brasil()
  }
}

updatedata_brasil()

###################

getdata_global <- function() {
  download.file(
    url      = "https://github.com/CSSEGISandData/COVID-19/archive/master.zip",
    destfile = "dados/covid19_data.zip"
  )
  
  data_path <- "COVID-19-master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_"
  unzip(
    zipfile   = "dados/covid19_data.zip",
    files     = paste0(data_path, c("confirmed_global.csv", "deaths_global.csv", "recovered_global.csv", "confirmed_US.csv", "deaths_US.csv")),
    exdir     = "dados",
    junkpaths = T
  )
}

updatedata_global <- function() {
  if (!dir_exists("dados")) {
    dir.create('dados')
    getdata_global()
  } else if ((!file.exists("dados/covid19_data.zip")) || (as.double(Sys.time() - file_info("dados/covid19_data.zip")$change_time, units = "hours") > 0.5)) {
    getdata_global()
  }
}

updatedata_global()

###################

#criating dataset#

# import data pop e demograf

casos_munic <- read_csv("dados/cases-brazil-cities-time_changesOnly.csv", 
                        col_types = cols(`_source` = col_skip(), 
                                         country = col_skip()), locale = locale("pt"))%>%
  separate(city, c("cidade", "uf"), sep = "/")

#import dados demograficos

demograf_municipios <- read_csv("dados/demografico_municip.csv", locale = locale("pt"))

demograf_estados <- read_csv("dados/demografico_estados.csv", locale = locale("pt"))

#import dados de população

pop_municip <- read_excel("dados/pop_IBGE_municip_2019.xls", 
                          col_types = c("text", "numeric", "numeric", 
                                        "text", "numeric"))

pop_estados <- read_excel("dados/pop_IBGE_estado_2019.xlsx", 
                          col_types = c("text", "numeric"))

################################################################

#criando banco de dados por estado

data_evolution_estados <- read_csv("dados/cases-brazil-states.csv", 
                                   col_types = cols(city = col_skip(), deathsMS = col_skip(), 
                                                    deaths_by_totalCases = col_skip(), 
                                                    deaths_per_100k_inhabitants = col_number(), 
                                                    recovered = col_number(), suspects = col_skip(), 
                                                    tests = col_skip(), tests_per_100k_inhabitants = col_skip(), 
                                                    totalCasesMS = col_skip(), totalCases_per_100k_inhabitants = col_number()))%>%
  full_join(demograf_estados, by= c("state"= "uf")) %>%
  mutate(date = as.Date(date))%>%
  select(-codigo_uf)%>%
  rename(
    lat         = latitude,
    long = longitude, confirmed = totalCases, deceased = deaths )%>%
  mutate(date = as.Date(date, "%m/%d/%y")) %>%
  arrange(date) %>%
  group_by(date) %>%
  replace_na(list(deaths = 0, confirmed = 0))%>%
  mutate(
    recovered = lag(confirmed, 14, default = 0) - deceased,
    recovered = ifelse(recovered > 0, recovered, 0),
    active = confirmed - recovered - deceased
  ) %>%
  pivot_longer(names_to = "var", cols = c(confirmed, recovered, deceased, active)) %>%
  ungroup() %>%
  mutate(estados = nome)

#

data_evolution_estados <- data_evolution_estados %>%
  group_by(`state`) %>%
  mutate(value_new = value - lag(value, 4, default = 0)) %>%
  ungroup()


data_evolution_estados <- data_evolution_estados %>%
  left_join(pop_estados, by = c("state" = "state"))

#drop NA (OK)

data_evolution_estados <- data_evolution_estados %>%
  drop_na(population)



# Get latest data (OK)

data_atdate_estados <- function(inputDate) {
  data_evolution_estados[which(data_evolution_estados$date == inputDate),] %>%
    distinct() %>%
    pivot_wider(id_cols = c("state", "date", "lat", "long", "population", "nome"), names_from = var, values_from = value) %>%
    filter(confirmed > 0 |
             recovered > 0 |
             deceased > 0 |
             active > 0)
}

data_latest_estados <- data_atdate_estados(max(data_evolution_estados$date))
#

rm(demograf_estados, pop_estados)
#

current_date_estados <- max(data_evolution_estados$date, na.rm = T)
changed_date_estados <- file_info("dados/COVID19_data_wcota.zip")$change_time
#

top5_estados <- data_latest_estados %>%
  filter(date == current_date_estados) %>%
  select(state, confirmed) %>%
  arrange(desc(confirmed)) %>%
  top_n(5) %>%
  select(state) %>%
  pull()

#####################################

#criando banco de dados por município

data_evolution_municip <- casos_munic %>%
  full_join(demograf_municipios, by= c("cidade"= "nome"))%>%
  mutate(date = as.Date(date))%>%
  select(-uf, -codigo_ibge, -ibgeID, -codigo_uf, -deaths_by_totalCases, -deaths_per_100k_inhabitants, -totalCases_per_100k_inhabitants )%>%
  mutate(date = as.Date(date, "%m/%d/%y")) %>%
  arrange(date) %>%
  group_by(date) %>%
  replace_na(list(deaths = 0, confirmed = 0))%>%
  rename(
    lat         = latitude,
    long = longitude, confirmed = totalCases, deceased = deaths )

#junta com dados populacionais 2019

data_evolution_municip <- data_evolution_municip %>%
  left_join(pop_municip, by = c("cidade" = "Nome_municip"))

#drop NA (OK) - IMPORTANTE
#esse drop NA tira tb as variaveis com dados sem localiza??o especifica pq a? n?o tem n? de pop

data_evolution_municip <- data_evolution_municip%>%
  drop_na("pop_estimada")

# Get latest data ((OK))

data_atdate_municip <- function(inputDate) {
  data_evolution_municip[which(data_evolution_municip$date == inputDate-1),] %>%
    filter(confirmed > 0 |
             deceased > 0 )
}

data_latest_municip <- data_atdate_municip(max(data_evolution_municip$date, na.rm = T))

# remover banco extra

rm(demograf_municipios, pop_municip, casos_munic)
#

current_date_municip <- max (data_evolution_municip$date, na.rm = T)
changed_date_municip <- file_info("dados/COVID19_data_wcota.zip")$change_time

top5_municipios <- data_latest_municip %>%
  filter(date == date) %>% #coloquei -1 para ser os top 5 do dia anterior
  select(cidade, confirmed) %>%
  arrange(desc(confirmed)) %>%
  top_n(5) %>%
  select(cidade) %>%
  pull()

##############################################################################

#criando banco de dados por países

data_confirmed    <- read_csv("dados/time_series_covid19_confirmed_global.csv")
data_deceased     <- read_csv("dados/time_series_covid19_deaths_global.csv")
data_recovered    <- read_csv("dados/time_series_covid19_recovered_global.csv")
data_confirmed_us <- read_csv("dados/time_series_covid19_confirmed_US.csv")
data_deceased_us  <- read_csv("dados/time_series_covid19_deaths_US.csv")



# Get latest data
current_date <- as.Date(names(data_confirmed)[ncol(data_confirmed)], format = "%m/%d/%y")
changed_date <- file_info("dados/covid19_data.zip")$change_time

# Get evolution data by country
data_confirmed_sub <- data_confirmed %>%
  pivot_longer(names_to = "date", cols = 5:ncol(data_confirmed)) %>%
  group_by(`Province/State`, `Country/Region`, date, Lat, Long) %>%
  summarise("confirmed" = sum(value, na.rm = T))

data_recovered_sub <- data_recovered %>%
  pivot_longer(names_to = "date", cols = 5:ncol(data_recovered)) %>%
  group_by(`Province/State`, `Country/Region`, date, Lat, Long) %>%
  summarise("recovered" = sum(value, na.rm = T))

data_deceased_sub <- data_deceased %>%
  pivot_longer(names_to = "date", cols = 5:ncol(data_deceased)) %>%
  group_by(`Province/State`, `Country/Region`, date, Lat, Long) %>%
  summarise("deceased" = sum(value, na.rm = T))

# US States
data_confirmed_sub_us <- data_confirmed_us %>%
  select(Province_State, Country_Region, Lat, Long_, 12:ncol(data_confirmed_us)) %>%
  rename(`Province/State` = Province_State, `Country/Region` = Country_Region, Long = Long_) %>%
  pivot_longer(names_to = "date", cols = 5:(ncol(data_confirmed_us) - 7)) %>%
  group_by(`Province/State`, `Country/Region`, date) %>%
  mutate(
    Lat  = na_if(Lat, 0),
    Long = na_if(Long, 0)
  ) %>%
  summarise(
    "Lat"       = mean(Lat, na.rm = T),
    "Long"      = mean(Long, na.rm = T),
    "confirmed" = sum(value, na.rm = T)
  )

data_deceased_sub_us <- data_deceased_us %>%
  select(Province_State, Country_Region, 13:(ncol(data_confirmed_us))) %>%
  rename(`Province/State` = Province_State, `Country/Region` = Country_Region) %>%
  pivot_longer(names_to = "date", cols = 5:(ncol(data_deceased_us) - 11)) %>%
  group_by(`Province/State`, `Country/Region`, date) %>%
  summarise("deceased" = sum(value, na.rm = T))

data_us <- data_confirmed_sub_us %>%
  full_join(data_deceased_sub_us) %>%
  add_column(recovered = NA) %>%
  select(`Province/State`, `Country/Region`, date, Lat, Long, confirmed, recovered, deceased)

data_evolution <- data_confirmed_sub %>%
  full_join(data_recovered_sub) %>%
  full_join(data_deceased_sub) %>%
  rbind(data_us) %>%
  ungroup() %>%
  mutate(date = as.Date(date, "%m/%d/%y")) %>%
  arrange(date) %>%
  group_by(`Province/State`, `Country/Region`, Lat, Long) %>%
  fill(confirmed, recovered, deceased) %>%
  replace_na(list(deceased = 0, confirmed = 0)) %>%
  mutate(
    recovered_est = lag(confirmed, 14, default = 0) - deceased,
    recovered_est = ifelse(recovered_est > 0, recovered_est, 0),
    recovered     = coalesce(recovered, recovered_est),
    active        = confirmed - recovered - deceased
  ) %>%
  select(-recovered_est) %>%
  pivot_longer(names_to = "var", cols = c(confirmed, recovered, deceased, active)) %>%
  filter(!(is.na(`Province/State`) && `Country/Region` == "US")) %>%
  filter(!(Lat == 0 & Long == 0)) %>%
  ungroup()%>%
  mutate(paises = `Country/Region`)
  

# Calculating new cases
data_evolution <- data_evolution %>%
  group_by(`Province/State`, `Country/Region`) %>%
  mutate(value_new = value - lag(value, 4, default = 0)) %>%
  ungroup()

rm(data_confirmed, data_confirmed_sub, data_recovered, data_recovered_sub, data_deceased, data_deceased_sub,
   data_confirmed_sub_us, data_deceased_sub_us)

# ---- Download population data ----
population                                                            <- wb(country = "countries_only", indicator = "SP.POP.TOTL", startdate = 2018, enddate = 2020) %>%
  select(country, value) %>%
  rename(population = value)
countryNamesPop                                                       <- c("Brunei Darussalam", "Congo, Dem. Rep.", "Congo, Rep.", "Czech Republic",
                                                                           "Egypt, Arab Rep.", "Iran, Islamic Rep.", "Korea, Rep.", "St. Lucia", "West Bank and Gaza", "Russian Federation",
                                                                           "Slovak Republic", "United States", "St. Vincent and the Grenadines", "Venezuela, RB")
countryNamesDat                                                       <- c("Brunei", "Congo (Kinshasa)", "Congo (Brazzaville)", "Czechia", "Egypt", "Iran", "Korea, South",
                                                                           "Saint Lucia", "occupied Palestinian territory", "Russia", "Slovakia", "US", "Saint Vincent and the Grenadines", "Venezuela")
population[which(population$country %in% countryNamesPop), "country"] <- countryNamesDat


# Data from wikipedia
noDataCountries <- data.frame(
  country    = c("Cruise Ship", "Guadeloupe", "Guernsey", "Holy See", "Jersey", "Martinique", "Reunion", "Taiwan*"),
  population = c(3700, 395700, 63026, 800, 106800, 376480, 859959, 23780452)
)
population      <- bind_rows(population, noDataCountries)

# data_evolution <- data_evolution %>%
#   left_join(population, by = c("Country/Region" = "country"))

population <- read_excel("dados/pop_global.xlsx")

data_evolution <- data_evolution %>%
  left_join(population, by = c("Country/Region" = "country"))


rm(population, countryNamesPop, countryNamesDat, noDataCountries)


data_atDate <- function(inputDate) {
  data_evolution[which(data_evolution$date == inputDate),] %>%
    distinct() %>%
    pivot_wider(id_cols = c("Province/State", "Country/Region", "date", "Lat", "Long", "population"), names_from = var, values_from = value) %>%
    filter(confirmed > 0 |
             recovered > 0 |
             deceased > 0 |
             active > 0)
}

data_latest <- data_atDate(max(data_evolution$date))

top5_paises <- data_evolution %>%
  filter(var == "active", date == current_date) %>%
  group_by(`Country/Region`) %>%
  summarise(value = sum(value, na.rm = T)) %>%
  arrange(desc(value)) %>%
  top_n(5) %>%
  select(`Country/Region`) %>%
  pull()




#get data
getdata_raw <- function() {
  download.file(
    url      = "https://www.gstatic.com/covid19/mobility/Global_Mobility_Report.csv?cachebust=722f3143b586a83f",
    destfile = "data/df_new_raw.csv"
  )
 
}

updategetdata_raw <- function() {
  if (!dir_exists("data")) {
    dir.create('data')
    getdata_rawl()
  } else if ((!file.exists("data/df_new_raw.csv")) || (as.double(Sys.time() - file_info("data/df_new_raw.csv")$change_time, units = "hours") > 0.5)) {
    getdata_raw()
  }
}

updategetdata_raw()


# read data
df_may <- read_csv("data/google_mobility_report_2020-07-25.csv")
df_new_raw <- read_csv("data/df_new_raw.csv")


# filter data to update
df_may <- df_may %>% filter(country_region_code == 'BR')%>%
  arrange(sub_region_1, date)

df_new <- df_new_raw %>%
  filter(country_region_code == 'BR' & date > '2020-07-21' ) %>%
  arrange(sub_region_1, date)

# group by and aggregate df_new_raw to create df_new
df_new <- df_new %>%
  group_by(country_region_code, country_region, sub_region_1, date) %>%
  summarise(across(ends_with("baseline"), ~median(.x, na.rm = TRUE)))

# row bind data sets
df_updated <- bind_rows(df_may, df_new, .id = 'id')

# transform to tidy data
df <- df_updated %>% 
  select(country_region, 
         sub_region_1, 
         date, 
         retail_and_recreation_percent_change_from_baseline, 
         grocery_and_pharmacy_percent_change_from_baseline,
         parks_percent_change_from_baseline, 
         transit_stations_percent_change_from_baseline, 
         workplaces_percent_change_from_baseline, 
         residential_percent_change_from_baseline) %>% 
  pivot_longer(-c(country_region, sub_region_1, date), names_to = "type", values_to = "values") %>% 
  mutate(type = sub("_percent_change_from_baseline$", "", type))

# write data
# write_csv(df_new_raw, path = paste0("data/google_mobility_report_", Sys.Date(), ".csv"))
# write_csv(df, path = "data/google_mobility_report.csv")



# read processed data -----------------------------------------------------
#df <- read_csv("data/google_mobility_report.csv")
# set system locale to spanish in order to show days ----------------------
# Sys.getlocale("LC_TIME")
Sys.setlocale("LC_TIME", "pt_BR.UTF-8")

# shiny app ---------------------------------------------------------------
# create vector of choices for provinces
province_choices <- c(
  sort(unique(df$sub_region_1)))[-25]


rm(df_may,df_new, df_new_raw,df_updated)






