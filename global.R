##-- Pacotes ----
#devtools::install_github("Cepesp-Fgv/cepesp-r")
library(cepespR)
library(dplyr)
library(dbplyr)
library(data.table)
library(reshape2)
library(tidyr)
library(lubridate)
library(shiny)
library(shinydashboard)
library(shinyWidgets)
#devtools::install_github('andrewsali/shinycssloaders')
library(shinycssloaders)
library(ggthemes)
library(RColorBrewer)
library(sf)
library(sp)
library(scales)
library(leaflet)
library(plotly)
#devtools::install_github("jbkunst/highcharter")
library(highcharter)
library(DT)
library(mapview)
#devtools::install_github("lgsilvaesilva/mapsBR")
library(mapsBR)
library(RMySQL)
library(yaml)
library(foreach)
library(parallel)
library(doMC)

##-- Chamando as funções criadas ----
source("functions/utils.R")
source("functions/plot_functions.R")
cores <- c("#098ebb", "#fdc23a", "#e96449", "#818286")

##-- Dados do banco ----
config <- read_yaml(file = "config.yml")

conexao <- dbConnect(drv = MySQL(), 
                     host = config$mysql$host, port = config$mysql$port, 
                     user = config$mysql$user, password = config$mysql$password, 
                     dbname = config$mysql$databaseName)
  
dados_receitas <- tbl(conexao, "receitas_partidos")
dados_despesas <- tbl(conexao, "despesas_partidos")
dados_gerais <- tbl(conexao, "resultados_gerais")
chaves <- dbReadTable(conn = conexao, name = "chaves") 

anos <- chaves %>% distinct(ANO_ELEICAO) %>% .$ANO_ELEICAO %>% as.numeric() %>% sort
cargos <- chaves %>% mutate(DESCRICAO_CARGO = toupper(DESCRICAO_CARGO)) %>%distinct(CODIGO_CARGO, DESCRICAO_CARGO)
cargos <- setNames(as.list(cargos$CODIGO_CARGO), cargos$DESCRICAO_CARGO)
partidos <- chaves %>% distinct(SIGLA_PARTIDO) %>% .$SIGLA_PARTIDO %>% sort
partidos_2014 <- dados_despesas %>% distinct(SIGLA_PARTIDO) %>% collect() %>% .$SIGLA_PARTIDO
estados <- chaves %>% distinct(UF) %>% .$UF
estados <- estados[!is.na(estados)]
municipios_df <- chaves %>% filter(UF == "SP") %>% distinct(COD_MUN_IBGE, NOME_MUNICIPIO) %>% group_by(COD_MUN_IBGE) %>% summarise(NOME_MUNICIPIO = last(NOME_MUNICIPIO))
municipios <- as.list(c(municipios_df$COD_MUN_IBGE, "TODOS MUNICIPIOS"))
names(municipios) <- c(municipios_df$NOME_MUNICIPIO, "Todos os municípios")

partidos_cores <- readRDS(file = "dados/data/cores_partidos.RDS")

# votos <- readRDS("dados/data/voronoy/votos_gordoy.rds")
# enderecos <- readRDS("dados/data/voronoy/secoes_sp_endereco.rds")
# lat_long <- readRDS("dados/data/voronoy/secoes_sf.RDS")

load("dados/data/voronoy/voronoi_est_sp.RData")

##-- Chamando os componentes do header shiny ----
tab_files <- list.files(path = "tabs", full.names = T, recursive = T)
tab_files <- tab_files[-grep(x = tab_files, pattern = "server")]

suppressMessages(lapply(tab_files, source))

##-- Chamando os shapes do mapsBR ----
data("regMun")
data("regUF")