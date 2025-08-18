*** Settings ***
Documentation     Performance Test - Hello World
...

*** Test Cases ***
Hello World Performance Test
    [Tags]    performance    smoke    regression
    Log    Hello, Performance World!
