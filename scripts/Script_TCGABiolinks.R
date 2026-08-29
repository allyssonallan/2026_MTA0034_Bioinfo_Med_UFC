# ==============================================================================
# TCGAbiolinks: consulta e exploração de dados públicos do TCGA
# Disciplina: MTA0034 - Bioinformática aplicada à Medicina
# ==============================================================================

# OBJETIVOS DA AULA ------------------------------------------------------------
# Ao final deste roteiro, você deverá ser capaz de:
# 1. consultar dados públicos do Genomic Data Commons (GDC);
# 2. baixar dados de expressão gênica do TCGA;
# 3. reconhecer a estrutura de um objeto SummarizedExperiment;
# 4. extrair dados de expressão e metadados das amostras;
# 5. comparar visualmente a expressão de genes entre tumor e tecido normal.

# INSTALAÇÃO DOS PACOTES ----------------------------------------------------

# O TCGAbiolinks pertence ao Bioconductor, e não ao CRAN.
# Execute as linhas abaixo apenas se os pacotes ainda não estiverem instalados.

# Instalação do gerenciador de pacotes do Bioconductor (executar uma vez):
install.packages("BiocManager")

# Instalação dos pacotes utilizados no roteiro (executar uma vez):
 BiocManager::install("TCGAbiolinks")
 BiocManager::install("SummarizedExperiment")
 BiocManager::install("EDASeq")
 BiocManager::install("edgeR")

library(TCGAbiolinks)
library(SummarizedExperiment)
library(EDASeq)
library(edgeR)


# 1. PARÂMETROS DA ATIVIDADE ---------------------------------------------------

# O TCGA-CHOL estuda o colangiocarcinoma.
projeto <- "TCGA-CHOL"

# Para uma demonstração rápida, usaremos cinco arquivos de cada grupo.
n_por_grupo <- 5

# Todos os arquivos baixados e resultados produzidos ficarão nestas pastas.
# O arquivo .Rproj deve ser aberto antes da execução do script.
setwd("/Users/felipemesquita/Documents/Bioinformática UFC/")

diretorio_gdc <- file.path("dados", "TCGAbiolinks", "GDCdata")
diretorio_resultados <- file.path("resultados", "TCGAbiolinks")
dir.create(diretorio_gdc, recursive = TRUE, showWarnings = FALSE)
dir.create(diretorio_resultados, recursive = TRUE, showWarnings = FALSE)


# 2. CONSULTAR O CATÁLOGO DO GDC ----------------------------------------------

# GDCquery() consulta os arquivos de expressão gênica quantificados pelo STAR.
consulta <- GDCquery(
  project = projeto,
  data.category = "Transcriptome Profiling",
  data.type = "Gene Expression Quantification",
  workflow.type = "STAR - Counts"
)

# getResults() recupera os códigos de barras encontrados na consulta.
amostras <- getResults(consulta, cols = "cases")

# - O que representa cada linha?
# - Quantos arquivos existem em cada grupo?
# - Como o código de barras identifica o tipo de amostra?
dim(amostras)
head(amostras)


# 3. SELECIONAR UM SUBCONJUNTO PARA A AULA ------------------------------------

# TCGAquery_SampleTypes() é a função do pacote que separa os códigos de barras
# pelos códigos de tipo de amostra: TP = Primary Tumor e NT = Solid Tissue Normal.
amostras_tumor <- TCGAquery_SampleTypes(
  barcode = amostras,
  typesample = "TP"
)

amostras_normal <- TCGAquery_SampleTypes(
  barcode = amostras,
  typesample = "NT"
)

amostras_tumor <- amostras_tumor[1:n_por_grupo]
amostras_normal <- amostras_normal[1:n_por_grupo]
amostras_selecionadas <- c(amostras_tumor, amostras_normal)

amostras_selecionadas

# Agora refinamos a consulta para incluir somente as amostras escolhidas.
consulta_aula <- GDCquery(
  project = projeto,
  data.category = "Transcriptome Profiling",
  data.type = "Gene Expression Quantification",
  workflow.type = "STAR - Counts",
  barcode = amostras_selecionadas
)

# 4. BAIXAR E PREPARAR OS DADOS ------------------------------------------------

# GDCdownload() baixa os arquivos para o computador. O método "api" não exige instalar o programa gdc-client. 
# files.per.chunk limita o tamanho dos lotes.
GDCdownload(
  query = consulta_aula,
  method = "api",
  files.per.chunk = 5,
  directory = diretorio_gdc
)

# GDCprepare() reúne os arquivos e suas anotações em um SummarizedExperiment.
# Esse objeto mantém, de forma coordenada:
# - assays(): matrizes de expressão;
# - rowData(): informações dos genes;
# - colData(): informações das amostras.
se_chol <- GDCprepare(
  query = consulta_aula,
  directory = diretorio_gdc,
  summarizedExperiment = TRUE
)

# 5. CONHECER O SUMMARIZEDEXPERIMENT ------------------------------------------

se_chol
class(se_chol)
dim(se_chol)                  # genes x amostras
assayNames(se_chol)           # matrizes disponíveis

# 6. EXTRAIR EXPRESSÃO E METADADOS --------------------------------------------

# O pipeline STAR disponibiliza contagens brutas e medidas normalizadas.
# Para consultar genes e construir o heatmap, utilizaremos TPM.
expressao_tpm <- assay(se_chol, "tpm_unstrand")
rownames(expressao_tpm) <- rowData(se_chol)$gene_name

# Para expressão diferencial, utilizaremos as contagens brutas unstranded.
# Métodos baseados no edgeR devem receber contagens, e não TPM.
contagens <- assay(se_chol, "unstranded")
metadados <- as.data.frame(colData(se_chol))
genes <- as.data.frame(rowData(se_chol))

dim(expressao_tpm)
expressao_tpm[1:5, 1:5]
head(metadados)
head(genes)


# 7. CORRELAÇÃO E PRÉ-PROCESSAMENTO -------------------------------------------

# TCGAanalyze_Preprocessing() calcula a correlação entre as amostras e produz
# os gráficos AAIC e boxplot de correlação descritos na documentação do pacote.
dados_preparados <- TCGAanalyze_Preprocessing(
  object = se_chol,
  cor.cut = 0.6,
  datatype = "unstranded",
  filename = file.path(diretorio_resultados, "correlacao_amostras.png")
)

# A normalização e a filtragem seguem o fluxo apresentado na vinheta de análise.
dados_normalizados <- TCGAanalyze_Normalization(
  tabDF = dados_preparados,
  geneInfo = geneInfoHT,
  method = "gcContent"
)

dados_filtrados <- TCGAanalyze_Filtering(
  tabDF = dados_normalizados,
  method = "quantile",
  qnt.cut = 0.25
)


# 8. EXPRESSÃO DIFERENCIAL -----------------------------------------------------

# A própria função do pacote recupera novamente os dois grupos a partir dos
# códigos de barras presentes na matriz processada.
grupo_normal <- TCGAquery_SampleTypes(
  barcode = colnames(dados_filtrados),
  typesample = "NT"
)

grupo_tumor <- TCGAquery_SampleTypes(
  barcode = colnames(dados_filtrados),
  typesample = "TP"
)

# TCGAanalyze_DEA() executa a análise de expressão diferencial com edgeR.
genes_diferenciais <- TCGAanalyze_DEA(
  mat1 = dados_filtrados[, grupo_normal],
  mat2 = dados_filtrados[, grupo_tumor],
  Cond1type = "Normal",
  Cond2type = "Tumor",
  fdr.cut = 1,
  logFC.cut = 0,
  method = "glmLRT"
)

head(genes_diferenciais)

# Aplicamos os pontos de corte depois da análise para manter todos os genes no
# volcano plot e uma tabela separada com os genes diferencialmente expressos.
genes_significativos <- genes_diferenciais[
  genes_diferenciais$FDR < 0.05 & abs(genes_diferenciais$logFC) > 1,
]

genes_diferenciais_nivel <- TCGAanalyze_LevelTab(
  FC_FDR_table_mRNA = genes_significativos,
  typeCond1 = "Tumor",
  typeCond2 = "Normal",
  TableCond1 = dados_filtrados[, grupo_tumor],
  TableCond2 = dados_filtrados[, grupo_normal]
)

head(genes_diferenciais_nivel)


# 9. VOLCANO PLOT --------------------------------------------------------------

# O TCGAbiolinks fornece a tabela estatística por TCGAanalyze_DEA(), mas não
# exporta uma função TCGAvisualize específica para volcano plot. Construímos o
# gráfico diretamente a partir das colunas logFC e FDR produzidas pelo pacote.
cores_volcano <- rep("grey60", nrow(genes_diferenciais))
cores_volcano[
  genes_diferenciais$FDR < 0.05 & genes_diferenciais$logFC > 1
] <- "#D95F5F"
cores_volcano[
  genes_diferenciais$FDR < 0.05 & genes_diferenciais$logFC < -1
] <- "#5B8DB8"

Volcano_plot <- plot(
  genes_diferenciais$logFC,
  -log10(genes_diferenciais$FDR),
  pch = 19,
  col = cores_volcano,
  xlab = "log2 fold change",
  ylab = "-log10(FDR)",
  main = "TCGA-CHOL: Tumor versus Normal"
)


# 10. BOXPLOT DOS GENES DE INTERESSE ------------------------------------------

# Selecionamos genes relacionados ao tecido biliar/hepático e usamos TPM em
# escala log2. A soma de 1 permite transformar também valores iguais a zero.
genes_interesse <- c("KRT19", "EPCAM", "ALB")
expressao_genes <- log2(expressao_tpm[genes_interesse, , drop = FALSE] + 1)

# Identificamos o grupo de cada amostra.
grupo_boxplot <- rep("Tumor", ncol(expressao_genes))
grupo_boxplot[colnames(expressao_genes) %in% amostras_normal] <- "Normal"

# Organizamos os dados no formato longo: cada linha representa a expressão de
# um gene em uma amostra.
dados_boxplot <- data.frame(
  expressao = as.vector(t(expressao_genes)),
  gene = rep(rownames(expressao_genes), each = ncol(expressao_genes)),
  grupo = rep(grupo_boxplot, times = nrow(expressao_genes))
)

head(dados_boxplot)

# O boxplot resume a distribuição e os pontos representam as amostras.

grafico_boxplot <- boxplot(
  expressao ~ interaction(gene, grupo, sep = " - "),
  data = dados_boxplot,
  col = rep(c("#5B8DB8", "#D95F5F"), times = length(genes_interesse)),
  xlab = "Gene e tipo de amostra",
  ylab = "log2(TPM + 1)",
  main = "Expressão de genes selecionados - TCGA-CHOL",
  las = 2,
  outline = FALSE
)

# 11. PCA COM FUNÇÃO DO TCGABIOLINKS ------------------------------------------

# A função TCGAvisualize_PCA() representa a separação entre os grupos usando os
# genes diferencialmente expressos encontrados nas etapas anteriores.
TCGAvisualize_PCA(
  dataFilt = dados_filtrados,
  dataDEGsFiltLevel = genes_diferenciais_nivel,
  ntopgenes = 20,
  group1 = grupo_normal,
  group2 = grupo_tumor
)

# Referências:
# - TCGAbiolinks (Bioconductor):
#   https://bioconductor.org/packages/TCGAbiolinks/
# - Genomic Data Commons (National Cancer Institute):
#   https://portal.gdc.cancer.gov/
# - SummarizedExperiment:
#   https://bioconductor.org/packages/SummarizedExperiment/
