#!/usr/bin/env bash
set -euo pipefail

BRANCH="chore/pipeline-robot"
git checkout -b "$BRANCH" || git checkout "$BRANCH" || true

mkdir -p .github/workflows tests/api tests/mobile resources

cat > requirements.txt <<'EOF'
robotframework==7.0
robotframework-requests==0.9.6
Appium-Python-Client==3.2.1
robotframework-appiumlibrary==2.0.0
EOF

cat > tests/api/sample_api_test.robot <<'EOF'
*** Settings ***
Library           RequestsLibrary
Suite Setup       Create Session    api    https://httpbin.org

*** Test Cases ***
GET /status 200 deve responder OK
    ${resp}=    GET On Session    api    /status/200
    Should Be Equal As Integers    ${resp.status_code}    200
EOF

cat > tests/mobile/sample_mobile_test.robot <<'EOF'
*** Settings ***
Library    AppiumLibrary

*** Variables ***
${APPIUM_SERVER_URL}    %{APPIUM_SERVER_URL}
${APPIUM_CAPS_JSON}     %{APPIUM_CAPS_JSON}

*** Keywords ***
Open App
    ${caps}=    Evaluate    __import__('json').loads(r'''${APPIUM_CAPS_JSON}''')
    Open Application    ${APPIUM_SERVER_URL}    ${caps}

*** Test Cases ***
Abrir aplicativo e fechar
    Open App
    Sleep    2s
    Close Application
EOF

cat > .github/workflows/robot-ci-reusable.yml <<'EOF'
# --- REUSABLE WORKFLOW ---
name: Reusable Robot Test Pipeline
on:
  workflow_call:
    inputs:
      run_api:          {description: "Executar testes de API?", type: boolean, default: true}
      run_mobile:       {description: "Executar testes Mobile (Appium)?", type: boolean, default: false}
      python_version:   {description: "Versão do Python", type: string,  default: "3.11"}
      requirements_path:{description: "Requirements path", type: string,  default: "requirements.txt"}
      api_tests_path:   {description: "Pasta suites API",  type: string,  default: "tests/api"}
      mobile_tests_path:{description: "Pasta suites Mobile",type: string,  default: "tests/mobile"}
      extra_robot_args: {description: "Args extras p/ Robot", type: string, default: ""}
      email_to:         {description: "Emails destino", type: string, default: ""}
      email_subject:    {description: "Assunto", type: string, default: "Relatório de Testes - Robot"}
      suite_name:       {description: "Nome da execução", type: string, default: "Testes Automatizados"}
    secrets:
      SMTP_SERVER:      {required: false}
      SMTP_PORT:        {required: false}
      SMTP_USERNAME:    {required: false}
      SMTP_PASSWORD:    {required: false}
      EMAIL_FROM:       {required: false}
      APPIUM_SERVER_URL:{required: false}
      APPIUM_CAPS_JSON: {required: false}

jobs:
  prepare:
    runs-on: ubuntu-latest
    outputs:
      has_api:    ${{ inputs.run_api }}
      has_mobile: ${{ inputs.run_mobile }}
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with: { python-version: ${{ inputs.python_version }} }
      - uses: actions/cache@v4
        with:
          path: ~/.cache/pip
          key: ${{ runner.os }}-pip-${{ hashFiles(inputs.requirements_path) }}
          restore-keys: ${{ runner.os }}-pip-
      - run: |
          python -m pip install --upgrade pip
          pip install -r "${{ inputs.requirements_path }}"
      - name: Sumário inicial
        run: |
          {
            echo "## 🚀 Execução de Testes"
            echo "- Suite: **${{ inputs.suite_name }}**"
            echo "- API: **${{ inputs.run_api }}** | Mobile: **${{ inputs.run_mobile }}**"
          } >> $GITHUB_STEP_SUMMARY

  api:
    if: ${{ needs.prepare.outputs.has_api == 'true' }}
    needs: prepare
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with: { python-version: ${{ inputs.python_version }} }
      - uses: actions/cache@v4
        with:
          path: ~/.cache/pip
          key: ${{ runner.os }}-pip-${{ hashFiles(inputs.requirements_path) }}
          restore-keys: ${{ runner.os }}-pip-
      - run: |
          python -m pip install --upgrade pip
          pip install -r "${{ inputs.requirements_path }}"
      - name: Robot API
        run: |
          mkdir -p reports/api
          robot -d reports/api -N "${{ inputs.suite_name }} - API" ${{ inputs.extra_robot_args }} "${{ inputs.api_tests_path }}"
      - uses: actions/upload-artifact@v4
        with:
          name: robot-api-reports
          path: |
            reports/api/output.xml
            reports/api/log.html
            reports/api/report.html
          retention-days: 7

  mobile:
    if: ${{ needs.prepare.outputs.has_mobile == 'true' }}
    needs: prepare
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with: { python-version: ${{ inputs.python_version }} }
      - uses: actions/cache@v4
        with:
          path: ~/.cache/pip
          key: ${{ runner.os }}-pip-${{ hashFiles(inputs.requirements_path) }}
          restore-keys: ${{ runner.os }}-pip-
      - name: Vars Appium
        run: |
          echo "APPIUM_SERVER_URL=${{ secrets.APPIUM_SERVER_URL }}" >> $GITHUB_ENV
          echo "APPIUM_CAPS_JSON=${{ secrets.APPIUM_CAPS_JSON }}" >> $GITHUB_ENV
      - name: Robot Mobile
        env:
          APPIUM_SERVER_URL: ${{ env.APPIUM_SERVER_URL }}
          APPIUM_CAPS_JSON:  ${{ env.APPIUM_CAPS_JSON }}
        run: |
          mkdir -p reports/mobile
          robot -d reports/mobile -N "${{ inputs.suite_name }} - Mobile" \
            --variable APPIUM_SERVER_URL:$APPIUM_SERVER_URL \
            --variable APPIUM_CAPS_JSON:$APPIUM_CAPS_JSON \
            ${{ inputs.extra_robot_args }} "${{ inputs.mobile_tests_path }}"
      - uses: actions/upload-artifact@v4
        with:
          name: robot-mobile-reports
          path: |
            reports/mobile/output.xml
            reports/mobile/log.html
            reports/mobile/report.html
          retention-days: 7

  merge-and-summary:
    needs: [prepare, api, mobile]
    if: always()
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/download-artifact@v4
        with: { path: reports_all }
        continue-on-error: true
      - uses: actions/setup-python@v5
        with: { python-version: ${{ inputs.python_version }} }
      - run: |
          python -m pip install --upgrade pip
          pip install robotframework==7.0
      - name: Merge outputs
        run: |
          mkdir -p summary
          files=$(find reports_all -name "output.xml" | tr '\n' ' ')
          if [ -n "$files" ]; then
            rebot --merge $files -o summary/output.xml -l summary/log.html -r summary/report.html -N "${{ inputs.suite_name }}"
          else
            echo "Sem outputs para merge."
          fi
      - name: Step Summary
        run: |
          python - << 'PY'
import xml.etree.ElementTree as ET, os, datetime
p="summary/output.xml"; passed=failed=0; start=end=None
if os.path.exists(p):
    root=ET.parse(p).getroot()
    for s in root.findall(".//statistics/total/stat"):
        if s.get("label")=="All Tests":
            passed=int(s.get("pass")); failed=int(s.get("fail"))
    sattr=root.find(".//suite").get("starttime"); eattr=root.find(".//suite").get("endtime")
    try:
        parse=lambda ts: datetime.datetime.strptime(ts,"%Y%m%d %H%M%S.%f")
        start=parse(sattr); end=parse(eattr)
    except Exception: pass
with open(os.environ["GITHUB_STEP_SUMMARY"],"a") as f:
    f.write("### 📊 Resultado consolidado\n\n")
    if start and end: f.write(f"- Duração: **{(end-start)}**\n")
    f.write(f"- Passaram: **{passed}**\n- Falharam: **{failed}**\n\n")
    f.write("> 🔴 Há falhas. Consulte os relatórios.\n" if failed>0 else "> 🟢 Sem falhas.\n")
PY
      - uses: actions/upload-artifact@v4
        with:
          name: robot-merged-reports
          path: |
            summary/output.xml
            summary/log.html
            summary/report.html
          retention-days: 14
      - name: Zip para email
        run: |
          cd summary || mkdir -p summary && cd summary
          zip -r ../robot_reports.zip . || true
          cd ..
      - name: E-mail (opcional)
        if: ${{ inputs.email_to != '' && secrets.SMTP_SERVER != '' && secrets.EMAIL_FROM != '' }}
        uses: dawidd6/action-send-mail@v3
        with:
          server_address: ${{ secrets.SMTP_SERVER }}
          server_port: ${{ secrets.SMTP_PORT }}
          username: ${{ secrets.SMTP_USERNAME }}
          password: ${{ secrets.SMTP_PASSWORD }}
          subject: ${{ inputs.email_subject }}
          from: ${{ secrets.EMAIL_FROM }}
          to: ${{ inputs.email_to }}
          secure: true
          html_body: |
            <h3>${{ inputs.suite_name }}</h3>
            <p>Relatórios em anexo e artefatos desta execução.</p>
            <ul><li><a href="${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}">Ver execução</a></li></ul>
          attachments: |
            summary/report.html
            summary/log.html
            robot_reports.zip
EOF

cat > .github/workflows/robot-ci-direct.yml <<'EOF'
# --- DIRECT WORKFLOW (usa o reutilizável deste repo) ---
name: Robot CI (Direto)
on:
  push:
    branches: [ "main", "develop", "feature/**" ]
  pull_request:
    branches: [ "main", "develop" ]
  workflow_dispatch:
    inputs:
      run_api:      { description: "Executar API?",   type: boolean, default: true }
      run_mobile:   { description: "Executar Mobile?",type: boolean, default: false }
      extra_robot_args: { description: "Args extras p/ Robot", type: string, default: "" }

jobs:
  call-reusable:
    uses: ./.github/workflows/robot-ci-reusable.yml
    with:
      run_api:        ${{ inputs.run_api || true }}
      run_mobile:     ${{ inputs.run_mobile || false }}
      extra_robot_args: ${{ inputs.extra_robot_args || '' }}
      suite_name: "CI Direto"
EOF

git add .
git commit -m "chore(ci): pipeline Robot reutilizável (API+Mobile), reports e e-mail"
git push -u origin "$BRANCH"
echo "✅ Branch $BRANCH criada e enviada."
