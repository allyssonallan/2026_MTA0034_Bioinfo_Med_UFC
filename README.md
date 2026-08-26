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

Os arquivos `aulas/_aula_*.qmd` são fragmentos incluídos na página inicial. Não os renderize nem abra como páginas HTML independentes, pois os links relativos são resolvidos no contexto de `index.qmd`. Para conferir uma aula, use `quarto preview` e abra a página inicial.

## Antes do primeiro push

O endereço do repositório e do site já usa o usuário `allyssonallan` em `_quarto.yml`. Ajuste apenas os links de CV Lattes e Instagram em `index.qmd`.

As fotografias e os logos usados pela página ficam em `assets/`. A pasta `_site/` é gerada novamente a cada renderização e não deve receber edições manuais.

Se `_site/` já estiver sendo rastreada pelo Git, remova-a do índice uma única vez (os arquivos locais permanecem no computador):

```bash
git rm -r --cached _site
```

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

1. Antes da primeira execução do workflow, abra **Settings → Pages** no GitHub.
2. Em **Build and deployment → Source**, selecione **GitHub Actions** e salve.
3. Se o workflow já falhou com `Get Pages site failed`, abra **Actions → Publicar site Quarto**, selecione a execução com erro e use **Re-run all jobs**.
4. Nas próximas atualizações, faça commit das alterações e envie a branch `main` com `git push origin main`.

Acompanhe o workflow **Publicar site Quarto** na aba **Actions**.

O arquivo `.github/workflows/publish.yml` renderiza o projeto e publica `_site/` automaticamente em cada push para `main`. Ele também pode ser iniciado manualmente pela aba **Actions**.

O endereço padrão será:

```text
https://allyssonallan.github.io/2026_MTA0034_Bioinfo_Med_UFC/
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
