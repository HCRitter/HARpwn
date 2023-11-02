# HARpwn

## HARToken Extraction and Sanitization Module

HARpwn is a PowerShell module designed to streamline the extraction and sanitization of HARTokens from HTTP Archive (HAR) files. Simplify the process of retrieving valuable data and ensure your HAR files are safe and secure with HARpwn, where HARTokens meet 'pwnage' with a touch of humor.
![HARpwn-Logo](https://github.com/HCRitter/HARpwn/blob/main/HARpwn-Logo.jpg?raw=true?raw=true)

## use cases

- Secure Sharing of HAR Files: Before sharing HAR files with third parties for debugging or analysis, users can employ HARpwn to sanitize the files by replacing tokens with placeholders, ensuring sensitive information remains protected.
- Educational Purposes: Students and educators can use HARpwn for hands-on learning and teaching about web traffic analysis, security, and token extraction.

## usage

1. Installation
    - download or clone this repo
    - Import the module into your PowerShell session using the following command:

    ```powershell
    Import-Module .\HARpwn.psm1
    ```

2. Extract HARTokens
    - Use Get-HARToken to extract HARTokens from a HAR file.
    - Example
  
    ```powershell
    Get-HARToken -type Graph -filePath 'C:\path\to\example.har'
    ```

3. Sanitize HARTokens
   - Use Remove-HARToken to sanitize a HAR file by replacing sensitive tokens with a specified word (default is "Removed").
   - Example
  
  ```powershell
  Remove-HARToken -type Graph -filePath 'C:\path\to\example.har' -SantinzeWord 'Redacted'
  ```
  