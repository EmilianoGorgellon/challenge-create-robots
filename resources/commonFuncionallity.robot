*** Settings ***
Library    RPA.Browser.Selenium

*** Variables ***
${base_url}    https://robotsparebinindustries.com/

*** Keywords ***
Open The Website And Go To Orders
    Open Available Browser    ${base_url}
    Maximize Browser Window
    Click Element    css=#root > header > div > ul > li:nth-child(2) > a
    Click Element    css=#root > div > div.modal > div > div > div > div > div > button.btn.btn-dark
Close the intranet wesbsite
    close browser
    