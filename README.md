# Projeto Robot Framework

Este é um projeto de automação de testes utilizando o **Robot Framework**. O objetivo deste projeto é fornecer uma estrutura organizada para testes de APIs, interface do usuário e outros tipos de testes funcionais.

---

## Status dos Testes

[![CI](https://github.com/AnaCarolinaSantos-qa/robot_framework_qa_starter/actions/workflows/ci_completo.yml/badge.svg)](…)

| Categoria       | Status |
|-----------------|--------|
| 🚀 API          | ![API](https://img.shields.io/badge/API-passing-brightgreen) |
| 🖥️ UI (Selenium) | ![UI](https://img.shields.io/badge/UI-passing-brightgreen) |
| 📱 Mobile       | ![Mobile](https://img.shields.io/badge/Mobile-passing-brightgreen) |
| 🌐 Acessibilidade| ![A11y](https://img.shields.io/badge/A11y-failing-red) |
| 📊 Performance  | ![Perf](https://img.shields.io/badge/Performance-passing-brightgreen) |

---

## Estrutura do Projeto

Esta é a estrutura de pastas do projeto:

```
Project │ 
├── .gitignore
├── README.md
├── requirements.txt
├── tests/
│   ├── acceptance_tests/
│   ├── functional_tests/
│   ├── regression_tests/
│   ├── performance_tests/
│   ├── API_tests/
│   │   └── api_test.robot
│   ├── UI_tests/
│   │   └── ui_test.robot
│   └── suites/
│       └── smoke_tests.robot
├── resources/
│   ├── keywords/
│   │   └── custom_keywords.robot
│   ├── variables/
│   │   └── global_variables.robot
│   └── libraries/
│       └── custom_library.py
├── config/
│   └── config.yaml
├── data/
│   └── test_data.json
└── reports/
    ├── logs/
    ├── reports/
    └── screenshots/
```
---

## Requisitos

Para executar este projeto, certifique-se de ter o [Python](https://www.python.org/) instalado em sua máquina. Você pode instalar as dependências do projeto usando o gerenciador de pacotes `pip`. Para isso, execute o seguinte comando:

```bash
pip install -r requirements.txt
```

### Explicações para cada Dependência:

- **robotframework:** A versão principal do Robot Framework, usada para escrever e executar suítes de teste.
- **robotframework-appiumlibrary:** Biblioteca para integrar o Appium no Robot Framework, permitindo testes de aplicações móveis.
- **appium-Python-Client:** Client oficial para o Appium que possibilita a automação de testes em aplicativos móveis.
- **robotframework-seleniumlibrary:** Suporte para automação de testes web com Selenium.
- **requests:** Usada para realizar requisições HTTP ao interagir com serviços web durante os testes.
- **pyyaml:** Facilita a manipulação de arquivos YAML, especialmente útil para configuração.
- **robotframework-requests:** Recursos avançados para requisições HTTP.
- **robotframework-jsonlibrary:** Utilitários para manipulação de dados JSON.
- **robotframework-processlibrary:** Manipulação de processos externos (utilizado para K6).

---

## Testes de Performance com K6

O projeto inclui integração com K6 para testes de performance, que deve ser instalado separadamente:

- Instruções de instalação do K6: [k6.io](https://k6.io/)

O arquivo `tests/performance_tests/performance_k6_test.robot` demonstra como:

- Gerar scripts de teste K6 dinamicamente.
- Executar testes de carga contra APIs.
- Analisar métricas de performance.
- Validar resultados contra critérios pré-definidos.

---

## Execução dos Testes

Para executar os testes, utilize o seguinte comando na linha de comando na raiz do projeto:

```bash
robot --outputdir results --exclude performance tests/
```

Para executar os testes de API, você pode usar:

```bash
robot tests/API_tests/api_test.robot
```

Os relatórios e logs da execução dos testes serão gerados na pasta `reports/`.

---

## Estrutura dos Testes

Os testes estão organizados em diferentes diretórios e arquivos de acordo com seus propósitos:

- **acceptance_tests/:** Testes de aceitação do sistema.
- **functional_tests/:** Testes que garantem que as funcionalidades funcionam como esperado.
- **regression_tests/:** Testes que garantem que funcionalidades existentes não são quebradas por novas alterações.
- **performance_tests/:** Testes que avaliam o desempenho do sistema.
- **API_tests/:** Testes específicos para as APIs do sistema.
- **UI_tests/:** Testes que validam a interface do usuário.
- **suites/:** Conjuntos de testes para facilitar a execução de grupos de testes relacionados.

---

## Boas Práticas

- Mantenha os testes independentes entre si.
- Separe dados de teste da lógica dos testes.
- Crie keywords reutilizáveis para ações comuns.
- Mantenha os relatórios de execução para análise histórica.
- Utilize padrões como Page Object para testes de UI.

---

## Relatórios

Após a execução, os relatórios são gerados nas seguintes pastas:

- **reports/reports/** - Relatórios HTML detalhados.
- **reports/logs/** - Logs de execução.
- **reports/screenshots/** - Capturas de tela em caso de falhas em testes de UI.

---

## Contribuição

Contribuições são bem-vindas! Para contribuir:

1. Faça um fork do repositório.
2. Crie uma branch para sua feature: `git checkout -b feature/nova-feature`.
3. Commit suas alterações: `git commit -m 'Adiciona nova feature'`.
4. Push para a branch: `git push origin feature/nova-feature`.
5. Abra um Pull Request.

---
