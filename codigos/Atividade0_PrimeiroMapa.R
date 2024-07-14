# Codificação: Banco em ASCII e Script em UTF-8
# Descrição do Script: Atividade mapas eleitorais das eleições presidenciais de 2014 e 2022

# Pacotes ====================================================================== 

library(dplyr) ## Gramática para manipulação de dados
library(sf) ## Gramática para dados espaciais
library(ggplot2) ## Elaboração de gráficos
library(geobr) ## Mapas brasileiros

# Eleições de 2014 =============================================================

# Cria uma tabela com os estados e seus respectivos vencedores
ganhadores_2014 <- tibble(abbrev_state = 
                            c("RS", "SC", "PR",
                              "SP", "MG", "RJ", "ES",
                              "MS", "MT", "GO", "DF", "TO",
                              "RO", "AC", "AM", "PA", "AP", "RR",
                              "MA", "PI", "CE", "RN", "PB", 
                              "PE", "AL", "SE", "BA"),
                          ganhador =
                            c("Aécio", "Aécio", "Aécio",
                              "Aécio", "Dilma", "Dilma", "Aécio",
                              "Aécio", "Aécio", "Aécio","Aécio", "Dilma",
                              "Aécio", "Aécio", "Dilma", "Dilma", "Dilma", "Aécio",
                              "Dilma", "Dilma", "Dilma", "Dilma", "Dilma", 
                              "Dilma", "Dilma", "Dilma", "Dilma"))

# Visualiza a tabela
data.frame(ganhadores_2014)

# Puxa um mapa de estados brasileiros
mapa_brasil <- read_state(code_state="all",
                          year=2018,
                          showProgress = FALSE)

# Passa a informacao dos resultados ao mapa
ganhadores_2014 <- left_join(mapa_brasil, ganhadores_2014, by = "abbrev_state")

ganhadores_2014  %>%
  # Inicia o ggplot
  ggplot() + 
  ## Identifica a coluna "ganhador" como fonte para colorir os estados
  geom_sf(aes(fill = ganhador)) 

# Eleições de 2022 =============================================================

# Cria uma tabela com os estados e seus respectivos vencedores
ganhadores_2022 <- tibble(abbrev_state = 
                            c("RS", "SC", "PR",
                              "SP", "MG", "RJ", "ES",
                              "MS", "MT", "GO", "DF", "TO",
                              "RO", "AC", "AM", "PA", "AP", "RR",
                              "MA", "PI", "CE", "RN", "PB", "PE", "AL", "SE", "BA"),
                          ganhador =
                            c("Bolsonaro", "Bolsonaro", "Bolsonaro",
                              "Bolsonaro", "Lula", "Bolsonaro", "Bolsonaro",
                              "Bolsonaro", "Bolsonaro", "Bolsonaro","Bolsonaro", "Lula",
                              "Bolsonaro", "Bolsonaro", "Lula", "Lula", "Bolsonaro", "Bolsonaro",
                              "Lula", "Lula", "Lula", "Lula", "Lula", "Lula", "Lula", "Lula", "Lula"))

# Passa a informacao dos resultados ao mapa
ganhadores_2022 <- left_join(mapa_brasil, ganhadores_2022, by = "abbrev_state")

ganhadores_2022  %>%
  # Inicia o ggplot
  ggplot() + 
  ## Identifica a coluna "ganhador" como fonte para colorir os estados
  geom_sf(aes(fill = ganhador)) 

