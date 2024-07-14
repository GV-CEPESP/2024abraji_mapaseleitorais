# Codificação: Banco em ASCII e Script em UTF-8
# Descrição do Script: Atividade Mapa Eleitoral da candidata Marta Suplicy em 2000

# Pacotes
library(dplyr)
#library(stringr)
library(sf)
library(geobr)
library(ggplot2)
library(ggspatial)

# Script =======================================================================

# Leitura da base dos locais de votação no Rio em 2020
lvrj <- readRDS("base/lvrj2020.rds")

# Leitura da base com dados eleitorais de Eduardo Paes
paes2020 <- readRDS("base/base2020_rj.rds")

# Lendo o mapa de setores censitários do Rio de Janeiro
rj_sc <- readRDS("base/mapa_setores_rj.rds")

################################################################################

##### Unir as informacoes de bairro "corretas" ao banco de LVs

# Transforma lvrj em um objeto espacial
lvrj_espacial <- lvrj |> 
  # Remove os NA, se houver (importante checar quantos NA, se for o caso)
  filter(!is.na(long)) |> 
  # Objeto com crs = 4326 (WGS84)
  st_as_sf(coords = c("long", "lat"), crs = 4674)

# Faz o spatial join
lvrj_espacial <- st_join(lvrj_espacial, rj_sc)

# Checa n. de NAs (0 de 1.422)
table(is.na(lvrj_espacial$NM_MUNICIP))

################################################################################

##### Agregar os votos por bairro do RJ

# Remove atributos espaciais do banco de LVs
lvrj <- st_drop_geometry(lvrj_espacial) 

# Unir os bancos de voto-secao com os de LVs atualizados
paes2020_lv <- paes2020 |> 
  # Agrupa os votos do Paes por LV
  group_by(dt_geracao, ano_eleicao, nr_turno, sg_uf, 
           nm_municipio, cd_municipio, nr_zona, nr_local_votacao, 
           ds_cargo, nm_votavel) |> 
  summarise(qt_votos = sum(qt_votos),
            votos_validos_lv = sum(votos_validos_secao)) |> 
  ungroup() |> 
  # Junta com o banco de LV
  left_join(lvrj, 
            by = c("cd_municipio" = "cd_localidade_tse", 
                   "nr_zona", 
                   "nr_local_votacao" = "nr_locvot", 
                   "ano_eleicao" = "ano")) 

# Agrupa os votos do Paes por bairro
paes2020_bairro <- paes2020_lv |> 
  group_by(NM_BAIRRO, CD_GEOCODB) |> 
  summarise(qt_votos = sum(qt_votos),
            votos_validos_bairro = sum(votos_validos_lv)) |> 
  ungroup()
  
################################################################################

##### Produzir visualizacao

# Preparar o banco de dados
paes2020_bairro <- paes2020_bairro |> 
  mutate(percentual = (qt_votos/votos_validos_bairro)*100)

# Algumas estatisticas descritivas do percentual
summary(paes2020_bairro$percentual)

# Abre um shp de bairros mais "limpo"
rj_bairros <- read_neighborhood() |> 
  filter(name_muni == "Rio De Janeiro")

# Passa a info de votos pro shp
rj_bairros_paes <- rj_bairros |> 
  left_join(paes2020_bairro, 
            by = c("name_neighborhood" = "NM_BAIRRO",
                   "code_neighborhood" = "CD_GEOCODB"))

# A partir do objeto espacial
rj_bairros_paes  |> 
  # Cria uma variavel categoria e preenche os niveis, que serao a legenda
  mutate(
    categoria = case_when(
      is.na(percentual) ~ "Sem LV",
      percentual > 20 & percentual <= 30 ~ "20-30%",
      percentual > 30 & percentual <= 40 ~ "30-40%",
      percentual > 40 & percentual <= 50 ~ "40-50%",
      percentual > 50 ~ ">50%"),
    categoria = factor(
      categoria,
      levels = c("Sem LV", "20-30%", "30-40%", "40-50%", ">50%"))) |> 
  # Inicia o ggplot
  ggplot() + 
  # Usa uma camada de sf
  geom_sf(aes_string(fill = "categoria"), color = "black", size = 0.1) +
  # Retira o datum
  coord_sf(datum = NA) +
  # Coloca o fill na paleta de verdes
  scale_fill_brewer(palette = "Greens") +
  # Adicionar titulo, subtitulo e legenda
  labs(
    title = "Votação de Eduardo Paes (2020, 1º turno)",
    subtitle = "Bairros do município do RJ",
    caption = "Fonte: Elaborado por Gelape (2023), a partir de\ndados de Daniel Hidalgo, TSE, IBGE.") +
  # Adiciona escala
  ggspatial::annotation_scale(
    location = "br", width_hint = 0.4, line_width = 0.5, 
    height = unit(0.1,"cm")) +
  # Coloca titulo na legenda
  guides(fill = guide_legend(title = "Votos válidos")) +
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
    pad_x = unit(17.5, "cm"), pad_y = unit(8.5, "cm")) 

