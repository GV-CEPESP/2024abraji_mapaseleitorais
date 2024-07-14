# Codificação: Banco em ASCII e Script em UTF-8
# Descrição do Script: Atividade Mapa Eleitoral da candidata Marta Suplicy em 2000

# Pacotes ====================================================================== 
library(dplyr)
library(tidyr)
library(sf)
library(ggplot2)
library(ggspatial)
library(RColorBrewer)

# Importação de dados ==========================================================

# Importa os dados de resultado por local de votação em SP
lv2000 <- readRDS("base/base2000_sp.rds")

# Importa o mapa de distritos de São Paulo
mapa <- readRDS("base/mapa_distritos_sp.rds")

# Identificar o total de votos por LV ==========================================

# A base lv2000 do CEM já contém os dados de votação dos candidatos a prefeito.

# As colunas com os dados de votação seguem o seguinte padrão:
# PF00_111 - PF indica votação para prefeito, 
# o primeiro dígito depois de _ indica o turno,
# e os dois números seguintes indicam o número do prefeito.
# A coluna com a votação da Marta Suplicy no primeiro turno portanto é PF00_113 
# Mais informações consulte a documentação em PDF no arquivo disponivel em:
# https://centrodametropole.fflch.usp.br/pt-br/file/18772/download?token=t4vNFXTg

# Obtencao do total de votos validos para prefeito por LV
votos_pref <- lv2000 |>
  # Remove as colunas de geometria espacial
  st_drop_geometry() |>  
  # Seleciona as colunas 'ID' e um intervalo de colunas de 'PF00_111' a 'PF00_156'
  select(ID, PF00_111:PF00_156) |>  
  # Transforma as colunas de votos em linhas
  pivot_longer(cols = c(PF00_111:PF00_156),
               names_to = "coluna",
               values_to = "voto") |>  
  # Substitui valores NA em 'voto' por 0
  mutate(voto = replace_na(voto, 0)) |>  
  # Cria uma nova coluna 'voto_total' que é a soma dos votos por 'ID'
  group_by(ID) |>  
  summarise(voto_total = sum(voto)) |> 
  ungroup()

# Cria um novo tibble 'lv2000_2' a partir do 'lv2000'
lv2000_2 <- lv2000 |> 
  # Combina 'lv2000' com 'votos_pref' usando um leftjoin pelo 'ID'
  left_join(votos_pref, by = "ID") |>  
  # Seleciona as colunas 'ID', 'PF00_113' e 'voto_total'
  select(ID, PF00_113, voto_total)  

# Unir a base de LV (ponto) com seus respecitvos distritos (poligonos) =========

# Unifica as bases com st_join. 
# Isso garante que os pontos sejam associados espacialmente com os poligonos
mapa_unificado <- st_join(mapa, lv2000_2) 

# Por que mapa_unificado agora tem 1135 linhas e não 1134? 
# Dica: investigue o distrito (em mapa) de Marsilac no extremo sul da cidade.

# Agrupar as votações da candidata por distrito ================================

# Usa o tibble 'mapa_unificado'
mapa_final <- mapa_unificado |>  
  # Calcula a soma total dos votos para 'Marta' e no total em cada distrito
  group_by(name_district) |>  
  summarise(marta = sum(PF00_113),  
            voto_total = sum(voto_total)) |>  
  ungroup() |> 
  # Calcula a porcentagem de votos para 'Marta' e arredonda para 1 casa decimal
  mutate(porc = round(marta/voto_total*100, 1))  

# Cria uma variavel categorica para melhorar a visualizacao
mapa_final <- mutate(
  mapa_final,
  voto_cat = case_when(
    is.na(porc) ~ "Sem LV",
    TRUE ~ cut(porc,
               seq(25, 49, 6),
               labels = c("25-31%", "31-37%",
                          "37-43%","43-49%"))))

# Produz a visualizacao de mapa com ggplot =====================================

# Monta uma string de cores.
cores <- brewer.pal(4, "OrRd")
cores <- c(cores, "#999999")

# Inicia o ggplot
mapa_final |>
  ggplot() + 
  # Usa uma camada de sf
  geom_sf(aes_string(fill = "voto_cat"), color = "black", size = 0.1) +
  # Retira o datum
  theme_void() +
  # Coloca o fill na paleta de verdes
  scale_fill_manual(values = cores) +
  # Adicionar titulo, subtitulo e legenda
  labs(
    title = "Votação de Marta Suplicy (2000, 1º turno)",
    subtitle = "Distritos do município de São Paulo",
    caption = "Fonte: Elaborado a partir de\ndados do CEM e IBGE.") +
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

