class TokenType : System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        $Script:TokenTypes = @{ 
            'graph.microsoft'     = 'https://graph.microsoft.com/'
            'graph'               = 'https://graph.microsoft.com/' #legacy value for parameter
            'portal.office'       = 'https://portal.office.com/'
            'substrate.office'    = 'https://substrate.office.com/'
            'my.sharepoint'       = 'my.sharepoint.com'
        }
        return ($Script:TokenTypes).Keys
    }
}

function Get-HARToken {
    <#
    .SYNOPSIS
    Extracts HARTokens from an HTTP Archive (HAR) file.

    .DESCRIPTION
    The Get-HARToken function extracts HARTokens from an HTTP Archive (HAR) file, specifically designed for the 'Graph' token type. It processes the HAR file, filters for 'Bearer' tokens with 'graph' scope, and provides information about the tokens, including scopes, access tokens, refresh tokens, and expiration times.

    .PARAMETER type
    Specifies the type of token to extract. Currently, only 'Graph' is supported.

    .PARAMETER filePath
    Specifies the path to the HAR file from which tokens will be extracted.

    .EXAMPLE
    Get-HARToken -type Graph -filePath 'C:\path\to\example.har'

    This example extracts 'Graph' tokens from the specified HAR file and provides details about the tokens.

    .NOTES
    File paths must be specified as absolute paths, and the HAR file should be in JSON format.
    #>
    [CmdletBinding()]
    param (
        [ValidateSet([TokenType],ErrorMessage="Value '{0}' is invalid. Try one of: {1}")]
        [string[]]$type,
        [string]
        $filePath,
        [switch]$all
    )
    
    begin {
        $Har = Get-Content -Path $filePath | ConvertFrom-Json
        $Responses = $har.log.entries.response.content.text

    }
    
    process {
        $TokenSets = foreach($Response in $Responses){
            try{
                $Response | ConvertFrom-Json -ErrorAction SilentlyContinue | Where-Object { $_.token_type -eq 'Bearer'}
            
            }catch{}
        }
        if($all){
            $TokenSets |ForEach-Object{
                [PSCustomObject]@{
                    Scopes = -split$_.scope 
                    Token = $_.access_token
                    RefreshToken = $_.refresh_token
                    ExpiresIn = $_.Expires_In
                    Type = 'all'
                }
            }
            return
        }
        foreach($typeElement in $type){
            $TokenSets|Where-Object{ $_.Scope.contains($script:TokenTypes[$typeElement])} | ForEach-Object{
                [PSCustomObject]@{
                    Scopes = -split$_.scope | Where-Object{$_.contains($script:TokenTypes[$typeElement])}|ForEach-Object{([uri]$_).absolutePath-replace"/"}
                    Token = $_.access_token
                    RefreshToken = $_.refresh_token
                    ExpiresIn = $_.Expires_In
                    Type = $typeElement
                }
            }
        }
    }
    
    end {
        
    }
}

function Remove-HARToken {
    <#
    .SYNOPSIS
    Sanitizes HARTokens in an HTTP Archive (HAR) file.

    .DESCRIPTION
    The Remove-HARToken function sanitizes HARTokens in an HTTP Archive (HAR) file by replacing the tokens with a specified word (default is "Removed"). It creates a sanitized version of the HAR file without sensitive tokens, allowing for secure sharing or analysis.

    .PARAMETER type
    Specifies the type of token to sanitize. Currently, only 'Graph' is supported.

    .PARAMETER filePath
    Specifies the path to the HAR file to sanitize.

    .PARAMETER SantinzeWord
    Specifies the word to replace the sensitive tokens with. The default value is "Removed."

    .EXAMPLE
    Remove-HARToken -type Graph -filePath 'C:\path\to\example.har' -SantinzeWord 'Redacted'

    This example sanitizes 'Graph' tokens in the specified HAR file, replacing them with the word 'Redacted' and creates a sanitized version of the file.

    .NOTES
    File paths must be specified as absolute paths, and the HAR file should be in JSON format.
    #>
    [CmdletBinding()]
    param (
        [ValidateSet('Graph')]
        $type,
        [string]
        $filePath,
        $SantinzeWord ="Removed"
    )
    
    process {
        $NewFile = Get-ChildItem -file -Path $filePath 
        $HarContent = Get-Content -Path $filePath
        $NewFileName = $($NewFile.FullName -replace ".har","_Santinzed.har")
        
        (Get-HARToken -type $Type -filePath $filePath).Token.ForEach({
            $HarContent = $HarContent -Replace $_,$SantinzeWord
        })
        $HarContent | Out-File -FilePath $NewFileName -Force
        Write-Verbose -Message "New File: $NewFileName"
    }
}