# 2026_MTA0034_Bioinfo_Med_UFC

Site acadêmico da disciplina **MTA0034 · Biotecnologia Computacional**, oferecida como **Bioinformática aplicada à medicina** no Programa de Pós-Graduação em Medicina Translacional da Universidade Federal do Ceará.

## Tecnologia

O site usa [Quarto](https://quarto.org/) e pode ser editado no RStudio. A publicação está configurada para GitHub Pages por GitHub Actions.

## Pré visualização local

1. Instale o Quarto e, opcionalmente, o RStudio.
2. Abra `2026_MTA0034_Bioinfo_Med_UFC.Rproj` no RStudio.
3. No Terminal, execute:

```bash
quarto preview
```

Para gerar todo o site:

```bash
quarto render
```

## Antes do primeiro push

Substitua `SEU_USUARIO` em `_quarto.yml` pelo usuário ou organização do GitHub. Depois ajuste os links de CV Lattes e Instagram em `index.qmd`.

Troque os arquivos de `assets/logos/` pelos logos oficiais e os arquivos de `assets/professores/` pelas fotografias. Você pode manter os mesmos nomes de arquivo para não alterar o código.

## Como liberar uma nova aula

O `index.qmd` contém as Aulas 03 a 08 como blocos HTML comentados. Antes de liberar uma aula, localize o bloco `AULA_XX_START`, preencha `COLE_AQUI_A_URL` com os links reais de slides, exercícios e material de apoio e remova apenas os marcadores de comentário daquele bloco.

Como alternativa, use o script auxiliar:

```bash
Rscript scripts/liberar_aula.R 3
```

O exemplo acima libera as aulas até a Aula 03.

## Como criar um novo tutorial

Copie `tutoriais/modelo_tutorial.qmd`, renomeie o arquivo e adicione o novo tutorial a `tutoriais/index.qmd`. Para criar um link a partir de uma aula, use:

```markdown
[Nome do tutorial](tutoriais/nome_do_tutorial.qmd)
```

## Publicar no GitHub Pages

1. Crie o repositório `2026_MTA0034_Bioinfo_Med_UFC` no GitHub.
2. Faça o primeiro push para a branch `main`.
3. Em **Settings → Pages**, selecione **Source: GitHub Actions**, se essa opção ainda não estiver ativa.
4. O workflow `.github/workflows/publish.yml` renderiza o Quarto e publica `_site` automaticamente em cada push para `main`.

O endereço padrão será:

```text
https://SEU_USUARIO.github.io/2026_MTA0034_Bioinfo_Med_UFC/
```

## Estrutura

```text
.
├── _quarto.yml
├── index.qmd
├── programa.qmd
├── avaliacao.qmd
├── aulas/
├── tutoriais/
├── assets/
│   ├── css/
│   ├── js/
│   ├── logos/
│   └── professores/
├── scripts/
└── .github/workflows/publish.yml
```
