## =============================================================================
## MTA0034 - Biotecnologia Computacional | Aula B - Oncologia de Precisao (14/09)
## Script de acompanhamento em R - hands-on ao vivo
##
## NENHUMA etapa aqui depende de download durante a aula.
## Os dados vem EMBUTIDOS no pacote maftools (~600 KB) ou de um MAF sintetico local
## (poucos KB) que acompanha este script. O unico requisito e ter os pacotes
## instalados ANTES da aula (Fase 0 do seu roteiro).
## =============================================================================


## -----------------------------------------------------------------------
## 0. PACOTES
## -----------------------------------------------------------------------
## maftools: le, resume e visualiza arquivos MAF (Mutation Annotation Format
##   - o formato padrao para variantes somaticas, usado por GDC/TCGA, ICGC,
##   cBioPortal etc). E o pacote de referencia da area (Mayakonda et al.,
##   Genome Research 2018) e o que sustenta praticamente toda a Aula B.
install.packages("BiocManager")
BiocManager::install("maftools") 
install.packages("R.utils")

library(maftools)


## -----------------------------------------------------------------------
## PARTE 1 - PANORAMA DO CANCER
## -----------------------------------------------------------------------
## Por que usar o dataset "laml" embutido em vez de baixar um MAF do GDC
## ao vivo (via TCGAbiolinks)?
##   1) Tamanho: o MAF embutido tem ~200 amostras de LAML (leucemia mieloide
##      aguda, TCGA) e roda em qualquer notebook (e levinho).
##   3) O dataset LAML e o mesmo usado no tutorial oficial
##      do maftools - farta documentacao caso algum aluno queira se
##      aprofundar sozinho depois.
## Vamos usar o dataset LAML e leucemia para ensinar a MECANICA da analise
## oncoplot, TMB, co-ocorrencia, hotspots..
## que e transferivel para qualquer tipo tumoral.

## 1.1 Localizar os arquivos de exemplo dentro do pacote instalado
maf_file <- system.file("extdata","tcga_laml.maf.gz", package = "maftools")
clinic_file <- system.file("extdata","tcga_laml_annot.tsv", package = "maftools")

## 1.2 Ler o MAF
## a funcao read.maf() faz tres coisas ao mesmo tempo: 
##(a) parseia o arquivo texto
## (b) valida as colunas obrigatorias (Hugo_Symbol, Chromosome,
## Variant_Classification, Tumor_Sample_Barcode...), e
## (c) computa resumos por amostra e por gene que os proximos comandos vao reaproveitar.
## os argumentos dentro da funcao, como clinicalData, e opcional, 
## mas permite depois estratificar graficos por
## variavel clinica disponivel nos dados (ex.: subtipo FAB da leucemia).

laml <- read.maf(maf = maf_file, clinicalData = clinic_file) #salvando o maf no objeto "laml"
# No seu console, ira aparecer esse output(resultado):
# -Reading
# -Validating
# -Silent variants: 475 
# -Summarizing
# -Processing clinical data
# -Finished in 0.117s elapsed (0.106s cpu) 


## 1.3 Primeira leitura de "saude" dos dados - SEMPRE faca isso antes de
## qualquer grafico. E o equivalente de "olhar a tabela" antes de "olhar a figura",
## evita interpretar um artefato como biologia.
laml # imprime um resumo: n amostras, n genes, tipos de variante
# O output esperado no console sera esse abaixo:
# An object of class  MAF 
#                   ID          summary  Mean Median
#                <char>           <char> <num>  <num>
# 1:        NCBI_Build               37    NA     NA
# 2:            Center genome.wustl.edu    NA     NA
# 3:           Samples              193    NA     NA
# 4:            nGenes             1241    NA     NA
# 5:   Frame_Shift_Del               52 0.269      0
# 6:   Frame_Shift_Ins               91 0.472      0
# 7:      In_Frame_Del               10 0.052      0
# 8:      In_Frame_Ins               42 0.218      0
# 9: Missense_Mutation             1342 6.953      7
# 10: Nonsense_Mutation              103 0.534      0
# 11:       Splice_Site               92 0.477      0
# 12:             total             1732 8.974      9



laml@variant.classification.summary # contagem de cada classe de variante por amostra
#Nao vou colar o output todo aqui pq que vai ser maior, mas é pra começar assim:
#          Tumor_Sample_Barcode Frame_Shift_Del Frame_Shift_Ins In_Frame_Del In_Frame_Ins Missense_Mutation
#                    <fctr>           <int>           <int>        <int>        <int>             <int>
# 1:         TCGA-AB-3009               0               5            0            1                25
# 2:         TCGA-AB-2807               1               0            1            0                16




## -----------------------------------------------------------------------
## 1.4 Oncoplot - "genes x amostras num relance"
## -----------------------------------------------------------------------
## O oncoplot (tambem chamado de OncoPrint) e a visualizacao central da
## oncologia de precisao computacional. Cada COLUNA e uma amostra, cada
## LINHA e um gene (ordenado por frequencia de mutacao), e a cor indica o
## tipo de alteracao. E a mesma logica visual que voces vao ver no
## cBioPortal - so que aqui voces controlam os dados e o codigo por tras.
oncoplot(maf = laml, top = 15) #funcao para gerar o oncoplot, simples ne?
#Vai gerar um plot na lateral, observem com calma as informacoes!


## -----------------------------------------------------------------------
## 1.5 Co-ocorrencia x exclusividade mutua - de onde vem o "padrao" do
## oncoplot
## -----------------------------------------------------------------------
## somaticInteractions() testa, para cada par de genes, se as mutacoes
## tendem a aparecer JUNTAS (co-ocorrencia - sugere cooperacao oncogenica)
## ou se sao MUTUAMENTE EXCLUSIVAS (sugere redundancia funcional: mutar os
## dois nao traz vantagem seletiva extra, entao raramente coexistem).
## Estatisticamente e um teste exato de Fisher pareado, com correcao para
## multiplas comparacoes.
somaticInteractions(maf = laml, top = 15, pvalue = c(0.05, 0.1))
# nessa funcao, tanto sai um output no console (com os numeros), 
# quanto um plot na lateral. Vejam com calma oq foi gerado. 

## Isso e o racional biologico por tras de pq
## bancos como CIViC/OncoKB as vezes recomendam olhar PAINEIS de genes, e
## nao um gene isolado - a acionabilidade de uma via pode depender do que
## mais esta (ou nao esta) mutado.

## -----------------------------------------------------------------------
## 1.6 TMB (tumor mutational burden) em contexto pan-cancer
## -----------------------------------------------------------------------
## TMB = numero de mutacoes somaticas / Mb de genoma coberto. E um dos
## "biomarcadores compostos" q vamos falar no Bloco 1 da aula (junto com MSI e HRD)
## E usado, por exemplo, para indicar imunoterapia em tumores TMB-high.
## tcgaCompare() plota o TMB da SUA coorte ao lado de ~30 coortes do TCGA
## Esse dado ja esta PRE-CALCULADO e embutido no pacote.
## Mas com essa funcao, se tivessemos um arquivo maf nosso (derivado dos nossos dados)
## poderiamos estar comparando com os demais tumores depositados no tcga. 
laml_tmb <- tcgaCompare(maf = laml, cohortName = "Exemplo (LAML)", logscale = TRUE)

## Como vcs podem ver, LAML costuma ter TMB BAIXO comparado a outros tumores
## solidos como melanoma ou pulmao (LUSC, SKCM),
## isso e visivel no grafico e reforca a ideia de 
## "assinaturas mutacionais" que vamos falar no Bloco 4.


## -----------------------------------------------------------------------
## PARTE 2 - HOTSPOT EM DETALHE: LOLLIPOP PLOT (opcional, se sobrar tempo)
## -----------------------------------------------------------------------
## lollipopPlot mapeia cada mutacao na posicao do AMINOACIDO dentro da
## proteina (nao do genoma) e sobrepoe os DOMINIOS proteicos (Pfam). Isso
## e o que da suporte visual ao conceito de "hotspot" que voces vao usar
## no Bloco 3 para julgar oncogenicidade (ClinGen/CGC/VICC: mutacoes que
## se acumulam no mesmo residuo/dominio, em varias amostras/estudos,
## pesam a favor de "oncogenica").
lollipopPlot(
  maf = laml,
  gene = "DNMT3A", #metiltransferase de novo
  showMutationRate = TRUE,
  labelPos = 882 #hotspot classico do gene
)
##Percebam qeue aqui tbm temos um output no console. Olhem a informacao gerada
#Lembrem do que foi discutido nas aulas anteriores.
# Esse grafico gerado e bastante comum. Se ele ficou meio "compactado"
# Deem zoom ou aumentem a janela de plots para ficar melhor distribuida a fig.

## -----------------------------------------------------------------------
## PARTE 3 - MINI TUMOR BOARD 
## -----------------------------------------------------------------------
## Agora trocamos de dataset: "tumor_board_case.maf" e um MAF SINTETICO
## (nao veio de paciente real) com 5 amostras ilustrando os casos do seu
## guia do facilitador (TB-MEL-01, TB-CRC-01, TB-LUAD-01, TB-CRC-02,
## TB-BRCA-01). Ele contem o par BRAF V600E melanoma x
## colorretal que e o ancoradouro conceitual da aula toda.
##
## IMPORTANTE:
## as coordenadas de BRAF, TP53, EGFR e KRAS sao valores GRCh38 realistas
## e amplamente citados na literatura; as demais (marcadas "ilustrativa"
## no arquivo) sao aproximadas, apenas para fins de exercicio 
##
## Ajustem o caminho abaixo para onde voces salvaram o arquivo que eu enviei
## boas praticas: deixem-o na mesma pasta que vcs salvaram esse script
## e que deve ser o diretorio de trabalho de voces.
tb <- read.maf(maf = "tumor_board_case.maf")
#Output no console:
# -Reading
# -Validating
# -Summarizing
# -Processing clinical data
# --Missing clinical data
# -Finished in 0.031s elapsed (0.025s cpu) 


## 3.1 Oncoplot do caso fake
oncoplot(maf = tb, top = 12)

## 3.2 VAF (variant allele frequency) por amostra
## VAF = fracao de reads que suportam o alelo mutado. Eh o dado quantitativo
## por tras da pergunta "isso eh somatico de baixa fracao de celulas
## tumorais (subclone), um artefato tecnico, ou sera que eh germinativo?"
## Caso BRCA2 (~50% VAF) e TTN (~1,5% VAF)
plotVaf(maf = tb, vafCol = NULL)
# Argumento vafCol como NULL => calcula a partir de t_ref_count/t_alt_count
# Olhem com calma esse grafico e as proporcoes.
#Se o grafico ficar achatado, excluam ele e rodem de novo a funcao plotVaf.




##  1. Cada grupo classifica oncogenicidade + acionabilidade da sua amostra.
##  2. Confronte TB-MEL-01 x TB-CRC-01 lado a lado: mesma variante BRAF
##     V600E, oncogenicidade identica, CONDUTA diferente -> acionabilidade
##     e um match(variante, droga, contexto tumoral), nao propriedade da
##     variante isolada.
##  3. TP53 (oncogenica, nao diretamente acionavel) e NOTCH1 (VUS) reforcam
##     que oncogenicidade != acionabilidade.
##  4. BRCA2 com VAF ~50% -> suspeita de origem GERMINATIVA

