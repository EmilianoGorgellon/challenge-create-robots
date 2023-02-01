*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.
Resource    ./resources/commonFuncionallity.robot     
Library    OperatingSystem
Library    String
Library    RPA.PDF  
Library    RPA.HTTP
Library    RPA.Archive

*** Tasks ***
Create Your Own Robot By Orders
    [Setup]    commonFuncionallity.Open The Website And Go To Orders
    Read Data From CSV And Save Robots
    [Teardown]    commonFuncionallity.Close the intranet wesbsite

*** Keywords ***
Accept Modal
    Wait Until Element Is Visible    css=#root > div > div.modal > div > div > div > div > div > button.btn.btn-dark
    Click Element    css=#root > div > div.modal > div > div > div > div > div > button.btn.btn-dark
    Maximize Browser Window
Read Data From CSV And Save Robots
    Download     https://robotsparebinindustries.com/orders.csv  overwrite=True
    ${files}=    Get File    orders.csv
    @{data}=    Create List    ${files}
    @{list}=    Split To Lines    @{data}    1
    FOR    ${element}    IN    @{list}    
        Run Keyword And Continue On Failure    Fill Form With Data And Save Robot    ${element}
    END
    Create ZIP With All Data

Fill Form With Data And Save Robot
    [Arguments]    ${element}
    @{arraySeparatedByCommas}=    Split String    ${element}    ,
    Wait Until Element Is Visible    css=#root > div > div.container > div > div.col-sm-7 > form > div:nth-child(1)
    Select From List By Value    id=head    ${arraySeparatedByCommas}[1]
    Wait Until Keyword Succeeds    1x    0.1 sec    Wait Until Element Is Visible    id=id-body-${arraySeparatedByCommas[2]}   
    Click Element    id=id-body-${arraySeparatedByCommas[2]}
    Input Text    xpath=/html/body/div/div/div[1]/div/div[1]/form/div[3]/input   ${arraySeparatedByCommas[3]}
    Input Text    id=address    ${arraySeparatedByCommas}[4]
    Preview Of The Robot
    Submit The Order
    Take Screenshot Of Robot    ${arraySeparatedByCommas}[0]
    Make PDF Receipts    ${arraySeparatedByCommas}[0]
    IF    ${getErrorFromServer} == True
        Create PDF With Receipt And screenshot    ${arraySeparatedByCommas}[0]
        Order Another Robot
        Accept Modal
    END

Preview Of The Robot
    Click Button    id=preview
Submit The Order
    Click Button    id=order
Make PDF Receipts
    [Arguments]    ${order}
    ${getErrorFromServer}=    Run Keyword And Return Status    Wait Until Element Is Visible    id=receipt
    Set Global Variable    ${getErrorFromServer}
    IF    ${getErrorFromServer} == True
        ${receipt_html}=    Get Element Attribute    id=receipt    outerHTML
        Html To Pdf    ${receipt_html}    ${OUTPUT_DIR}${/}PDFS/receipt-order-${order}.pdf
    END
Take Screenshot Of Robot
    [Arguments]    ${order}
    Wait Until Keyword Succeeds    2x    0.1 sec    Wait Until Element Is Visible    css=#robot-preview-image > img:nth-child(1)
    Wait Until Keyword Succeeds    2x    0.1 sec    Wait Until Element Is Visible    css=#robot-preview-image > img:nth-child(2)
    Wait Until Keyword Succeeds    2x    0.1 sec    Wait Until Element Is Visible    css=#robot-preview-image > img:nth-child(3)
    Screenshot    robot-preview-image    ${OUTPUT_DIR}${/}Screenshots/robot-order-${order}.png    

Order Another Robot
    Wait Until Element Is Visible    order-another
    Click Button    order-another
Create PDF With Receipt And Screenshot
    [Arguments]    ${order}
    Add Watermark Image To PDF
    ...    image_path=${OUTPUT_DIR}${/}Screenshots/robot-order-${order}.png
    ...    source_path=${OUTPUT_DIR}${/}PDFS/receipt-order-${order}.pdf
    ...    output_path=${OUTPUT_DIR}${/}ReceiptAndScreenshot/ReceiptAndScreen-${order}.pdf

Create ZIP With All Data
    Archive Folder With Zip    ${OUTPUT_DIR}${/}ReceiptAndScreenshot    ${OUTPUT_DIR}${/}allPDF.zip