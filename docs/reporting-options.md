# Opções de relatórios

Este projeto pode gerar relatórios locais, arquivos para CI, relatórios HTML interativos e resultados centralizados. As opções são independentes: comece pela saída nativa e adicione as integrações externas apenas quando houver necessidade.

## Comparação

| Opção | Saídas | Melhor uso | Requisitos adicionais |
|---|---|---|---|
| Robot Framework nativo | `report.html`, `log.html`, `output.xml` | Investigar uma execução local ou baixar os artefatos de um job | Nenhum |
| JUnit | `xunit.xml` junto com os arquivos nativos | Jenkins e outras ferramentas que consomem XML JUnit | Nenhum |
| Relatório combinado (Rebot) | Um `report.html` e `log.html` para múltiplas suítes | Visão consolidada de jobs ou diretórios | Nenhum |
| Allure | Dashboard HTML com passos, histórico e anexos | Relatórios mais navegáveis e metadados de teste | Pacote Python `allure-robotframework` e CLI Allure |
| ReportPortal | Dashboard centralizado, lançamentos e análise de histórico | Acompanhamento de execuções de vários ambientes | Instância ReportPortal, agente Python e credenciais |
| Robot Framework Dashboard | Dashboard HTML interativo, comparações e histórico SQLite | Comparar várias execuções Robot localmente ou acessar o site do CI | `robotframework-dashboard` incluído em `requirements.txt` |

## 1. Robot Framework nativo

O comando atual já gera `output.xml`, `report.html` e `log.html`. No CI, cada job publica sua pasta `results/<suite>` como artefato para download.

```bash
robot --outputdir results/native --exclude performance --exclude browserstack tests/
```

Use o `report.html` para o resumo e o `log.html` para examinar keywords, mensagens e falhas.

## 2. JUnit para integração com CI

O Robot Framework também pode gerar um XML compatível com consumidores JUnit. O restante das saídas nativas continua disponível:

```bash
robot --outputdir results/junit --xunit xunit.xml --exclude performance --exclude browserstack tests/
```

O arquivo será `results/junit/xunit.xml`. Configure o servidor de CI para coletar esse caminho como resultado de testes.

## 3. Relatório consolidado com Rebot

Rebot, incluído com Robot Framework, processa os `output.xml` de várias execuções e cria um resumo único. Exemplo usando os jobs de API e UI:

```bash
rebot --outputdir results/combined \
  --name "API e UI" \
  results/api/output.xml \
  results/ui/output.xml
```

Rebot também permite filtrar o relatório por tags, por exemplo `--include smoke`. Os XMLs de origem precisam estar disponíveis na mesma máquina antes da consolidação.

## 4. Allure

Allure fornece um relatório HTML interativo e suporta passos, metadados, links e anexos. Instale a integração Python e a CLI Allure conforme a [documentação oficial do Robot Framework](https://allurereport.org/docs/robotframework/).

```bash
python -m pip install allure-robotframework
robot --outputdir results/allure-robot \
  --listener allure_robotframework:results/allure-data \
  --exclude performance --exclude browserstack tests/
allure generate results/allure-data --clean --output results/allure-report
```

Abra `results/allure-report/index.html` após gerar o relatório. A CLI Allure deve estar instalada no sistema e disponível no `PATH`; mantenha os arquivos de resultados por execução caso queira construir histórico.

## 5. ReportPortal

ReportPortal envia os eventos da execução para um dashboard remoto. É uma opção para equipes que já tenham uma instância acessível pela máquina local ou pelo CI. Instale `robotframework-reportportal` e configure as credenciais como variáveis de ambiente/segredos do CI; não coloque tokens no repositório.

Exemplo de execução (ajuste endpoint e projeto para sua instância):

```bash
robot --outputdir results/reportportal \
  --listener robotframework_reportportal.listener \
  --variable RP_ENDPOINT:$RP_ENDPOINT \
  --variable RP_PROJECT:$RP_PROJECT \
  --variable RP_LAUNCH:"Robot Framework CI" \
  --variable RP_API_KEY:$RP_API_KEY \
  --exclude performance --exclude browserstack tests/
```

Consulte as instruções do [agente do ReportPortal para Robot Framework](https://github.com/reportportal/agent-Python-RobotFramework) para instalação, autenticação e configuração.

## 6. Robot Framework Dashboard

O Dashboard oficial do Robot Framework agrega `output.xml` em um banco SQLite e gera um HTML interativo. Instale as dependências do projeto:

```bash
python -m pip install -r requirements.txt
python scripts/generate_robot_dashboard.py --input results
```

O HTML e o banco são criados em `results/dashboard/`. O banco mantém o histórico entre gerações locais. Para criar saídas em outros caminhos:

```bash
python scripts/generate_robot_dashboard.py \
  --input results \
  --database results/dashboard/robot_results.db \
  --output results/dashboard/robot_dashboard.html
```

O CI agrega os resultados Robot das suítes executadas e publica `robot-dashboard-<run_id>` como artefato, com os logs detalhados daquela execução. Na branch `main`, também atualiza o Dashboard público no [GitHub Pages](https://anacarolinasantos-qa.github.io/robot_framework_qa_starter/). O cache do GitHub Actions preserva o histórico entre execuções do mesmo branch; ele tem retenção limitada, então não substitui uma instância centralizada para retenção permanente.

Consulte a [documentação oficial do Robot Framework Dashboard](https://docs.robotframework.org/docs/reporting_test_results/robot_framework_dashboard) e o [CLI do projeto](https://marketsquare.github.io/robotframework-dashboard/basic-command-line-interface-cli.html) para filtros, tags e configuração avançada.

## Caminho sugerido

1. Use o relatório nativo para qualquer execução: já está disponível sem novas dependências.
2. Habilite JUnit quando uma ferramenta de CI precisar interpretar resultados por teste.
3. Experimente Allure quando a equipe quiser uma apresentação mais elaborada e anexos.
4. Use Rebot para combinar resultados que já foram baixados ou coletados.
5. Use Robot Framework Dashboard para comparar execuções sem depender de um serviço externo.
6. Adote ReportPortal quando houver uma instância compartilhada e interesse em histórico entre execuções.

Allure e ReportPortal continuam opcionais e não alteram os jobs atuais. O Dashboard local e do CI usa a dependência incluída em `requirements.txt`; a página pública é atualizada pelo workflow principal após uma execução Robot em `main`.
