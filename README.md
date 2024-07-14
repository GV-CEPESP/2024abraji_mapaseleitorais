# Mapas Eleitorais com R

Este repositório apresenta os materiais da oficina "Mapas Eleitorais com R", realizada no dia 14 de julho de 2024, como parte da programação do [19 Congresso Internacional de Jornalismo Investigativo](https://congresso.abraji.org.br/), da ABRAJI.

Os tutoriais de referência para esta oficina estão disponíveis [neste link](https://gv-cepesp.github.io/mapaseleitorais2023/) e as bases de dados necessárias para as atividades estão [neste link](https://github.com/GV-CEPESP/2024abraji_mapaseleitorais/tree/main/base). Para facilitar, você pode fazer o [download deste repositório completo](https://github.com/GV-CEPESP/2024abraji_mapaseleitorais/archive/refs/heads/main.zip).

### Sobre o Workshop

Em 2018, PT e PSL protagonizaram a disputa pela presidência. Como mostrou uma [reportagem do site Pindograma](https://pindograma.com.br/2020/09/18/polarizacoes.html), no Capão Redondo, a disputa para deputado reproduziu essa tendência. Porém, em Pinheiros, os mais votados saíram desse padrão: foram PSOL e Novo. Mapas eleitorais permitem investigar esse fenômeno.

O objetivo desse workshop é ensinar os participantes a trabalhar com dados espaciais no R a partir de informações eleitorais. Nele, vamos apresentar algumas características e cuidados especiais com esse tipo de dados, como associar os resultados eleitorais ao espaço (inclusive intramunicipais), e a produzir mapas.

### Pré-Requisitos

R, RStudio, pacotes (`tidyverse` e `sf`).

## Roteiro

Esta oficina é composta por duas partes, descritas abaixo:

### Parte 1

-   *"Por que eu estou aqui?"*: a utilidade de se trabalhar com dados espaciais no jornalismo de dados.
-   [Meu primeiro mapa](https://gv-cepesp.github.io/mapaseleitorais2023/meu-primeiro-mapa.html): não é tão difícil assim!
-   Mapas focados em eleições municipais:
    -   A organização territorial das eleições brasileiras
    -   [Importação](https://gv-cepesp.github.io/mapaseleitorais2023/mapas-municipais.html#importa%C3%A7%C3%A3o-das-bases) e [preparação](https://gv-cepesp.github.io/mapaseleitorais2023/mapas-municipais.html#prepara%C3%A7%C3%A3o-do-banco-de-dados) dos dados
    -   [Produção de mapas](https://gv-cepesp.github.io/mapaseleitorais2023/mapas-municipais.html#visualiza%C3%A7%C3%A3o-do-mapa)

### Parte 2

-   *"E agora?"*: algumas ideias de pautas.
-   Mãos à obra!:
    -   [Marta Suplicy em 2000](https://gv-cepesp.github.io/mapaseleitorais2023/atividades-extras.html#marta-suplicy-em-2000) e/ou
    -   [Eduardo Paes em 2020](https://gv-cepesp.github.io/mapaseleitorais2023/atividades-extras.html#eduardo-paes-em-2020) e/ou
    -   explorar algumas ideias de pauta.

## Ministrantes

[Lucas Gelape](https://lgelape.github.io/) é pesquisador de pós-doutorado no CEPESP FGV, doutor em Ciência Política pela Universidade de São Paulo. Atualmente, pesquisa temas relacionados a política local e geografia eleitoral. No jornalismo, trabalhou no G1 e no Volt Data Lab/Núcleo.

[Marco Antonio Faganello](https://github.com/marcofaga) é pesquisador, cientista de dados e pós-doutorando no CEPESP FGV, doutor em Ciência Política pela Universidade Estadual de Campinas (UNICAMP). Atualmente, pesquisa temas relacionados à eleições, partidos, direita e geografia eleitoral.

[Cedric Antunes](https://github.com/CedricAntunes) é bacharel em Relações Internacionais (cum laude) pela Fundação Getúlio Vargas (FGV-SP). É membro do Centro de Política e Economia do Setor Público (FGV-CEPESP) e assistente de pesquisa do CEPESP DATA. Sua pequisa foca em estratégias partidárias e sistemas eleitorais comparados, ancorados em teoria formal e métodos quantitativos.

[Cecilia do Lago](https://linktr.ee/ceciliadolago) é jornalista de dados na TV Globo. Antes cobriu meio ambiente e clima para o Washington Post; e política, desinformação e eleições para o Estadão. Utiliza R para apurações em bases de dados públicas. Prêmio Nina Mason Pulliam por Melhor Reportagem Ambiental de 2023 da SEJ (Sociedade de jornalistas de meio ambiente dos Estados Unidos) e finalista do Pulitzer na categoria Jornalismo Explicativo.
