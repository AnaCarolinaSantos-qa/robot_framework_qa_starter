# Robot Framework QA Starter

Template para iniciar automação de API, interface web, mobile, acessibilidade e performance com Robot Framework.

[![CI](https://github.com/AnaCarolinaSantos-qa/robot_framework_qa_starter/actions/workflows/ci_completo.yml/badge.svg)](https://github.com/AnaCarolinaSantos-qa/robot_framework_qa_starter/actions/workflows/ci_completo.yml) · [Dashboard de resultados](https://anacarolinasantos-qa.github.io/robot_framework_qa_starter/)

> Os testes API e UI incluídos são exemplos “Hello World”; o mobile contém um exemplo simulado e outro para BrowserStack. Adapte URLs, dados, seletores e capacidades ao seu produto antes de usar como suíte de projeto.

## Comece em poucos minutos

Requer Python 3.11 ou superior.

```bash
git clone https://github.com/AnaCarolinaSantos-qa/robot_framework_qa_starter.git
cd robot_framework_qa_starter
python -m venv .venv
```

Ative o ambiente virtual e instale as dependências:

```bash
# Linux/macOS
source .venv/bin/activate

# Windows PowerShell (use esta alternativa no Windows)
# .venv\Scripts\Activate.ps1

python -m pip install -r requirements.txt
robot --outputdir results/api tests/api
```

Abra `results/api/report.html` para o resumo ou `results/api/log.html` para os detalhes. As saídas em `results/` são locais e ignoradas pelo Git.

## Guia de onboarding

Veja [Guia de uso e adaptação](docs/guia-de-uso.md) para configurar o ambiente, executar cada tipo de teste, substituir os exemplos pelos testes do seu produto, gerar dashboards e entender o CI.

## Relatórios

- [Dashboard publicado](https://anacarolinasantos-qa.github.io/robot_framework_qa_starter/) — resultados mais recentes publicados pela branch `main`.
- [Opções de reporte](docs/reporting-options.md) — saídas nativas do Robot, JUnit, Rebot, Allure, ReportPortal e Dashboard.

O Dashboard hospedado é público. Não publique credenciais, dados pessoais ou informações internas nos testes e relatórios.
