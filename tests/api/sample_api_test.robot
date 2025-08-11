*** Settings ***
Library           RequestsLibrary
Suite Setup       Create Session    api    https://httpbin.org

*** Test Cases ***
GET /status 200 deve responder OK
    ${resp}=    GET On Session    api    /status/200
    Should Be Equal As Integers    ${resp.status_code}    200
