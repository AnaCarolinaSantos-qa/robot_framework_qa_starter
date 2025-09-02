*** Settings ***
Documentation     API Test - Hello World
...

*** Test Cases ***
Hello World API Test
    [Tags]    api    smoke    regression
    Log    Hello, API World!

