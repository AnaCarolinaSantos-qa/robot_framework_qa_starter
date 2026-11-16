# Guia de uso e adaptação

Este guia acompanha uma pessoa de QA desde a preparação do ambiente até a adaptação deste starter para um produto. Os exemplos são pontos de partida: revise as URLs, dados de teste, seletores e capacidades antes de conectá-los a uma aplicação real.

## 1. O que vem no repositório

| Área | Local | O que existe hoje |
|---|---|---|
| API | `tests/api/` | Teste demonstrativo sem chamada HTTP; use como esqueleto para a API do produto. |
| Interface web | `tests/UI_tests/` | Teste demonstrativo; ainda não abre navegador nem valida uma página real. |
| Mobile | `tests/mobile/` | Um teste simulado sem Appium e um exemplo Android remoto para BrowserStack. |
| Acessibilidade | `tests/accessibility_tests/`, `resources/` | Verificações básicas sobre páginas HTML locais de exemplo. |
| Performance | `tests/performance_tests/`, `resources/keywords/` | Exemplos com K6; o teste Robot integrado usa Docker para iniciar K6. |
| Configuração K6 | `config/config.yaml` | Valores de exemplo para cenários de carga e stress. |
| CI | `.github/workflows/` | Workflows separados por área e um workflow principal que decide quais executar. |
| Dashboard | `scripts/generate_robot_dashboard.py` | Consolida arquivos `output.xml` em dashboard HTML e histórico SQLite local. |

## 2. Pré-requisitos

### Para iniciar e executar API e exemplos básicos

- Git;
- Python 3.11 ou superior;
- `pip` (incluído nas distribuições atuais do Python).

As dependências Python estão centralizadas em `requirements.txt`. Não é necessário instalar dependências opcionais de Dashboard separadamente.

### Requisitos por área

- **UI real:** navegador Chrome e driver compatível; Selenium Manager pode obter o driver conforme a configuração da máquina. O arquivo atual em `tests/UI_tests/` ainda não usa Selenium.
- **Mobile local:** servidor Appium, driver Appium adequado, Android SDK/emulador ou dispositivo conectado e capacidades ajustadas no teste. O teste `mobile_helloworld.robot` é simulado e não precisa desses componentes.
- **Mobile BrowserStack:** conta BrowserStack, aplicação carregada no serviço e variáveis `BROWSERSTACK_USERNAME` e `BROWSERSTACK_ACCESS_KEY`. O teste usa um identificador `BS_APP` de exemplo que deve ser substituído.
- **Performance:** K6 instalado para execução nativa. A integração Robot em `tests/performance_tests/` usa Docker; verifique que o daemon Docker esteja disponível. O workflow de CI instala K6 diretamente.

## 3. Preparar o ambiente

Clone o repositório e crie um ambiente virtual para isolar as dependências:

```bash
git clone https://github.com/AnaCarolinaSantos-qa/robot_framework_qa_starter.git
cd robot_framework_qa_starter
python -m venv .venv
```

Ative o ambiente e instale os pacotes:

```bash
# Linux/macOS
source .venv/bin/activate

# Windows PowerShell: execute esta linha em vez da anterior
# .venv\Scripts\Activate.ps1

python -m pip install --upgrade pip
python -m pip install -r requirements.txt
```

Confirme que o Robot Framework está acessível:

```bash
robot --version
```

## 4. Executar testes

Todos os exemplos geram resultados em `results/`, diretório ignorado pelo Git.

### Primeira execução: API demonstrativa

```bash
robot --outputdir results/api tests/api
```

Este teste apenas demonstra a estrutura de uma suíte e registra uma mensagem. Substitua-o por chamadas e validações do serviço real.

### Interface web

```bash
robot --outputdir results/ui tests/UI_tests
```

O exemplo atual não inicia navegador. Ao adicionar testes Selenium, importe a biblioteca e implemente setup/teardown e seletores da aplicação. O CI passa variáveis `BROWSER` e `CHROME_ARGS`; elas só terão efeito se a suíte as declarar e utilizar.

### Mobile

O exemplo simulado não precisa de Appium:

```bash
robot --outputdir results/mobile tests/mobile/mobile_helloworld.robot
```

Para executar o exemplo BrowserStack (após preencher `BS_APP` e configurar credenciais), use:

```bash
# Linux/macOS
export BROWSERSTACK_USERNAME="seu_usuario"
export BROWSERSTACK_ACCESS_KEY="sua_chave"
robot --outputdir results/mobile -i browserstack tests/mobile/mobile_example.robot
```

```powershell
# Windows PowerShell
$env:BROWSERSTACK_USERNAME = "seu_usuario"
$env:BROWSERSTACK_ACCESS_KEY = "sua_chave"
robot --outputdir results/mobile -i browserstack tests/mobile/mobile_example.robot
```

Não salve credenciais no repositório. No GitHub Actions, cadastre-as como Actions secrets e injete-as no job que executa BrowserStack.

### Acessibilidade

```bash
robot --outputdir results/accessibility -i a11y tests/accessibility_tests
```

Os arquivos `resources/a11y_urls.txt` e `resources/a11y_wcag_pages.txt` apontam para páginas locais de exemplo. Atualize esses arquivos com as URLs ou páginas que deseja avaliar. As verificações implementadas são exemplos básicos e não substituem uma avaliação completa de acessibilidade.

### Performance

O teste de integração Robot chama K6 através de Docker:

```bash
robot --outputdir results/performance -i performance tests/performance_tests
```

Revise os cenários em `config/config.yaml` e os scripts de K6 antes de apontar para um serviço. Para executar um script K6 diretamente, use `k6 run <caminho-do-script.js>` após instalar K6.

### Rodar exemplos locais sem BrowserStack nem integração K6/Docker

```bash
robot --outputdir results --exclude browserstack --exclude performance tests/
```

Esse comando inclui o exemplo mobile simulado e as suítes de acessibilidade local. `--exclude performance` exclui testes marcados com a tag `performance`; não substitua essa tag por suposição, confira as tags ao adicionar novos casos.

## 5. Adaptar o starter ao seu produto

1. **Defina o alvo e os ambientes.** Decida onde ficam URLs base, credenciais e dados por ambiente. Use variáveis de ambiente ou arquivos de configuração locais ignorados pelo Git para valores privados.
2. **Troque os casos demonstrativos.** Os casos de API e UI atuais só registram mensagens. Adicione keywords, chamadas, verificações e setup/teardown apropriados ao produto.
3. **Organize por capacidade.** Mantenha as suítes em `tests/` e keywords reutilizáveis em `resources/keywords/` ou bibliotecas Python em `resources/libraries/`.
4. **Use tags com intenção.** Tags como `smoke`, `regression`, `api`, `ui`, `mobile`, `a11y` e `performance` ajudam a selecionar execuções; mantenha alinhamento entre os casos e os comandos/ workflows que filtram essas tags.
5. **Inclua dados seguros e reproduzíveis.** Prefira dados sintéticos. Não inclua tokens, senhas, dados pessoais ou resultados que revelem informação interna.
6. **Valide localmente antes do CI.** Execute primeiro a suíte alterada, inspecione `report.html` e `log.html`, e então confirme o comportamento no workflow correspondente.

### Configuração de acessibilidade

Coloque uma URL ou caminho de arquivo por linha em `resources/a11y_urls.txt` e `resources/a11y_wcag_pages.txt`. Linhas iniciadas com `#` são comentários. Mantenha páginas locais de exemplo em `resources/pages/`; elas são fixtures versionadas, embora saídas Robot `*.html` sejam ignoradas pelo Git.

### BrowserStack

O exemplo Android em `tests/mobile/mobile_example.robot` define dispositivo, versão do Android e opções BrowserStack como variáveis no próprio arquivo. Ajuste-as ao dispositivo e à aplicação. `BS_APP` aceita uma variável Robot `-v BS_APP:bs://...`; armazene usuário e chave apenas no ambiente local ou nos secrets do GitHub.

## 6. Relatórios e Dashboard

Cada execução Robot normalmente produz:

- `output.xml`: resultado estruturado, usado para consolidar ou gerar dashboards;
- `report.html`: resumo da execução;
- `log.html`: passos, keywords e detalhes de falha.

Para consolidar execuções locais já existentes:

```bash
python scripts/generate_robot_dashboard.py --input results
```

Abra `results/dashboard/robot_dashboard.html`. O banco `results/dashboard/robot_results.db` mantém histórico no ambiente local. O comando requer dependências já instaladas pelo `requirements.txt` e pelo menos um `output.xml` dentro da pasta de entrada.

O [Dashboard publicado no GitHub Pages](https://anacarolinasantos-qa.github.io/robot_framework_qa_starter/) exibe os resultados Robot publicados pelo CI na branch `main`. Os jobs também disponibilizam artefatos da execução para download. Como o site é público, publique somente dados apropriados para acesso público. Consulte [Opções de reporte](reporting-options.md) para JUnit, Rebot, Allure e ReportPortal.

## 7. CI do GitHub Actions

O fluxo principal está em `.github/workflows/ci_completo.yml` e delega o trabalho aos workflows por área. Em push ou pull request, detecta os caminhos alterados e executa as áreas relacionadas; o acionamento manual permite rodar o fluxo completo. Os jobs usam Ubuntu 24.04 e Python 3.11. BrowserStack não faz parte da execução mobile padrão.

Para personalizar o CI:

- mantenha os comandos dos workflows coerentes com as tags e caminhos das suítes;
- adicione secrets em **Settings → Secrets and variables → Actions** para integrações externas;
- não publique logs ou dashboard com dados confidenciais;
- revise as permissões de escrita do workflow de publicação do Pages se mudar o processo de deploy.

## 8. Arquivos gerados e versionamento

Relatórios e resultados de execução não devem ser commitados. O `.gitignore` já exclui `results/`, `logs/`, `reports/`, arquivos `*.xml`, `*.report`, saídas HTML e bancos de Dashboard. As páginas HTML de fixture em `resources/pages/` são exceção intencional para permitir testes locais de acessibilidade.

Antes de abrir um pull request, confira:

```bash
git status --short
```

Confirme que apenas código, configuração e documentação pretendidos aparecem como alterados; retire do stage qualquer artefato de execução.

## 9. Próximos passos sugeridos

- adicionar uma chamada real à API de demonstração e validar status e conteúdo;
- conectar a suíte UI a uma aplicação de teste e criar seletores estáveis;
- documentar os ambientes e dados necessários para reproduzir cada fluxo;
- definir smoke tests rápidos e uma seleção de regressão adequada ao produto;
- integrar serviços externos somente quando o time tiver ambiente e secrets configurados.
