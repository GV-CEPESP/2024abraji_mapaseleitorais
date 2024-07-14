# Codificação: Banco em ASCII e Script em UTF-8
# Descrição do Script: Script de visualização dos Mapas

# Pacotes -=====================================================================

library(dplyr) # Gramatica de manipulacao de dados
library(sf) # Gramatica de manipulacao de dados espaciais
library(geobr) # Obtencao de mapas brasileiros
library(ggplot2) # Gramatica para a producao de graficos
library(classInt) # Calculo de diferentes quebras de dados
library(cartography) # Producao de mapas tematicos
library(ggspatial) # Elementos espaciais do ggplot2

# ==============================================================================

# IMPORTACAO DE BASES ==========================================================

# Todos os objetos foram salvos no formato .rds para maior compressao e 
# minimizar erros de importacao. Elas sao importadas com a funcao readRDS().

## Resultados eleitorais

# Importa a base de votos por secao eleitoral do candidato a prefeito 
# Guilherme Boulos (PSOL), e dos candidatos a vereador Milton Leite (DEM), 
# Fernando Holiday (PATRIOTA) e Eduardo Suplicy (PT)
candsp2020 <- readRDS("base/base2020_sp.rds") |> 
  mutate(nm_votavel = case_when(
    nm_votavel == "MILTON LEITE DA SILVA" ~ "Milton Leite",
    nm_votavel == "GUILHERME CASTRO BOULOS" ~ "Boulos",
    nm_votavel == "EDUARDO MATARAZZO SUPLICY" ~ "Suplicy",
    nm_votavel == "FERNANDO HOLIDAY SILVA BISPO" ~ "Holiday"))

## Locais de votacao

# Importa a base de locais de votação geolocalizados
lvsp2020 <- readRDS("base/lvsp2020.rds")

# Transforma essa base num objeto espacial
lvsp2020 <- lvsp2020 |> 
  st_as_sf(
    coords = c("long", "lat"), # Define as colunas long e lat como coordenadas
    crs = 4674) # Define o sistema de referência de coordenadas (CRS) como 4674 - SIRGAS 2000

## Distritos de SP

# Lê o mapa com os 96 distritos da cidade de São Paulo
mapa <- readRDS("base/mapa_distritos_sp.rds")

## Pre-visualização do mapa dos distritos da cidade de Sao Paulo usando ggplot2

ggplot(mapa) +
  # Adicionando camadas de features espaciais ao gráfico
  geom_sf()

## Pre-visualizacao: locais de votação no mapa da cidade de SP

ggplot(mapa) + 
  geom_sf() + 
  geom_sf(data = lvsp2020) + # Adiciona camada com pontos dos locais de votação
  theme_void() # Ajusta o layout do gráfico deixando a tela de fundo em branco

########## EXERCICIO 2 =========================================================

# Preparacao do banco de dados =================================================

# Calcula votos por local de votacao
candsp2020_porlv <- candsp2020 |>
  # Filtra somente pelo Boulos
  filter(nm_votavel == "Boulos") |> 
  # Soma os votos do candidato e total da urna por local de votacao
  group_by(nr_zona, nr_local_votacao, nm_votavel) |>
  summarise(votos_cand = sum(qt_votos),
            votos_validos = sum(votos_validos_secao)) |>
  ungroup() |> 
  # Calcula o percencual de votos por local
  mutate(votos_cand_porc = round(votos_cand/votos_validos*100,1)) 

# Une com a base de LV geolocalizado 
candsp2020_porlv <- candsp2020_porlv |>   
  # Renomeia a variavel nr_local_votacao para facilitar o join
  rename(nr_locvot = nr_local_votacao) |>
  # Traz a informacao da base de LV geolocalizado
  left_join(lvsp2020, by = c("nr_zona", "nr_locvot")) |>
  # Transforma em objeto espacial
  st_as_sf(sf_column_name = "geometry")

# Pré-visualização dos votos dos candidatos por local de votação
candsp2020_porlv |> 
  filter(nm_votavel == "Boulos") |> 
  ggplot() +
  geom_sf(data=mapa)+
  geom_sf(aes(size=votos_cand_porc, color=votos_cand_porc))+
  theme_void()

### Obter o bairro do local de votacao

# Faz o spatial join
lvsp2020_distrito <- st_join(lvsp2020, mapa)

## Problemas acontecem!

nrow(lvsp2020)
nrow(lvsp2020_distrito) # Ele tem uma linha a mais

# Isso ocorreu porque um LV está bem na divisa entre dois distritos
ggplot() +
  geom_sf(data=mapa %>% filter(name_district %in% c("Vila Mariana", "Bela Vista")))+
  geom_sf(data = lvsp2020 |> slice(269), size=2)+
  theme_void()

# Possivel solução: selecionar aleatoriamente o bairro ao qual ele esta atribuido
lvsp2020_distrito <- lvsp2020_distrito |> 
  group_by(nr_locvot, nr_zona) |> 
  slice_sample(n = 1) |> 
  ungroup() |> 
  # Seleciona so as variaveis que vamos usar para o mapa
  select(nr_zona, nr_locvot, name_district) |> 
  # Retira a geometria, para ela ser tratada como uma tabela
  st_drop_geometry()
nrow(lvsp2020_distrito) # 2.063 linhas, pronto!

# agregação dos votos nos locais de votação por distrito
# mensuração dos votos percentuais por local de votação

candsp2020_pordist <- candsp2020_porlv |>
  # Retira a informacao da geometria do ponto
  st_drop_geometry() |>
  # Traz a informacao do distrito referente ao ponto, que obtivemos acima
  left_join(lvsp2020_distrito, by = c("nr_zona", "nr_locvot"))

# Soma os votos do candidato por distrito e calcula o %
candsp2020_pordist <- candsp2020_pordist |> 
  group_by(name_district, nm_votavel) |>
  summarise(votos_cand = sum(votos_cand),
            votos_validos = sum(votos_validos)) |> 
  ungroup() |> 
  mutate(votos_cand_porc = round(votos_cand/votos_validos*100,1)) 
  
# Cria um objeto espacial em que passamos para o mapa a votacao
# de Boulos em cada um dos distritos de SP
boulos_final <- left_join(mapa, candsp2020_pordist, by = c("name_district"))

# pré-visualização dos votos dos candidatos por distrito
boulos_final |> 
  ggplot() +
  geom_sf(aes(fill=votos_cand_porc))+
  theme_void()

########## EXERCICIO 3 =========================================================

# Producao do mapa coropletico =================================================

# Existem diversas escalas para definir os cortes de uma variavel, que vao 
# informar como colorir areas de um mapa. Para mais informacoes, vejam:
# para mais informações: https://www.youtube.com/watch?v=0ebL8OvG8Jc

# Vejam como ao escolher duas delas, produzimos dois mapas que sugerem
# informacoes diferentes fundamentados na mesma base de dados

## Cortes de Jenks

# Criamos os cortes e os guardamos num objeto
cortes <- classIntervals(boulos_final$votos_cand_porc, 4, "jenks")

# Cria uma variavel com os cortes
boulos_final$cortes_jenks <- cut(boulos_final$votos_cand_porc, cortes$brks, 
                                 include.lowest = T)

## Intervalos geometricos

# Criamos os cortes e os guardamos num objeto
cortes <- getBreaks(boulos_final$votos_cand_porc, 4, "geom")

# inserindo os cortes na base de dados usando a função cut
boulos_final$int_geom <- cut(boulos_final$votos_cand_porc, cortes, 
                             include.lowest = T)

# Visualizacao dos dois cortes
ggplot() +
  geom_sf(data=boulos_final, aes(fill=cortes_jenks))+
  scale_fill_brewer(palette = "RdBu", name="Votação (%)")+
  theme_void()

ggplot() +
  geom_sf(data=boulos_final, aes(fill=int_geom))+
  scale_fill_brewer(palette = "RdBu", name="Votação (%)")+
  theme_void()

# Em boa parte dos casos, porem, voce vai querer criar uma escala, a partir
# dos resultados observados. No codigo abaixo, criamos uma escala manualmente
# com intervalos de 5 p.p. em 5 p.p., inciando em 10.
# Alem disso, incluimos diversos elementos, como titulo, legenda, escala,
# e rosa dos ventos

# A partir do objeto espacial
boulos_final  |> 
  # Cria uma variavel categoria e preenche os niveis, que serao a legenda
  mutate(
    categoria = case_when(
      is.na(votos_cand_porc) ~ "Sem LV",
      votos_cand_porc > 10 & votos_cand_porc <= 15 ~ "10-15%",
      votos_cand_porc > 15 & votos_cand_porc <= 20 ~ "15-20%",
      votos_cand_porc > 20 & votos_cand_porc <= 25 ~ "20-25%",
      votos_cand_porc > 25 & votos_cand_porc <= 30 ~ "25-30%",
      votos_cand_porc > 30 ~ ">30%"),
    categoria = factor(
      categoria,
      levels = c("Sem LV", "10-15%", "15-20%", "20-25%", "25-30%", ">30%"))) |> 
  # Inicia o ggplot
  ggplot() + 
  # Usa uma camada de sf
  geom_sf(aes(fill = categoria), color = "black", size = 0.1) +
  # Retira o datum
  coord_sf(datum = NA) +
  # Coloca o fill na paleta de verdes
  scale_fill_brewer(palette = "YlOrBr") +
  # Adicionar titulo, subtitulo e legenda
  labs(
    title = "Votação de Guilherme Boulos (2020, 1º turno)",
    subtitle = "Distritos do município do SP",
    caption = "Fonte: Elaborado por Gelape, Guedes e Faganello (2023), a partir de\ndados de Daniel Hidalgo, TSE, IBGE.") +
  # Adiciona escala
  ggspatial::annotation_scale(
    location = "br", width_hint = 0.4, line_width = 0.5, 
    height = unit(0.1,"cm")) +
  # Coloca titulo na legenda
  guides(fill = guide_legend(title = "Votos válidos (%)")) +
  # Ajusta elementos do tema do ggplot
  theme(
    # Posicao e direcao da legenda
    legend.position = "bottom",
    legend.direction = "horizontal",
    # Centralizacao de alguns elementos textuais
    plot.title = element_text(hjust = 0.5),
    plot.subtitle = element_text(hjust = 0.5),
    plot.caption = element_text(hjust = 0.5)) +
  # Adiciona rosa-dos-ventos
  ggspatial::annotation_north_arrow(
    location = "br", which_north = "true",
    style = north_arrow_fancy_orienteering(),
    # Ajusta a altura da rosa-dos-ventos (pode exigir tentativa e erro)
    pad_x = unit(0.5, "cm"), pad_y = unit(1, "cm")) 


