# Function to make API request to GoDaddy
function Get-DomainDetails {
    param(
        [string]$ApiKey,
        [string]$Secret,
        [string]$Domain
    )
    
    $baseUrl = "https://api.godaddy.com"
    $url = "$baseUrl/v1/domains/$Domain/records/A/@/"
    $headers = @{
        "Authorization" = "sso-key ${ApiKey}:${Secret}"
    }
    
    try {
        $response = Invoke-RestMethod -Uri $url -Method Get -Headers $headers
        Write-Output $response
    } catch {
        Write-Output "Error: $_"
    }
}

# Function to delete DNS record
function Remove-DNSRecord {
    param(
        [string]$ApiKey,
        [string]$Secret,
        [string]$Domain
    )
    
    $baseUrl = "https://api.godaddy.com"
    $url = "$baseUrl/v1/domains/$Domain/records/A/@/"
    $headers = @{
        "Authorization" = "sso-key ${ApiKey}:${Secret}"
    }
    
    try {
        Invoke-RestMethod -Uri $url -Method Delete -Headers $headers
        Write-Output "DNS @ A records deleted successfully."
    } catch {
        Write-Output "Error: $_"
    }
}

# Function to update DNS record
function Update-DNSRecord {
    param(
        [string]$ApiKey,
        [string]$Secret,
        [string]$Domain,
        [string]$Data
    )
    
    $baseUrl = "https://api.godaddy.com"
    $url = "$baseUrl/v1/domains/$Domain/records/A/@/"
    $headers = @{
        "Authorization" = "sso-key ${ApiKey}:${Secret}"
        "Content-Type" = "application/json"
    }
    # Create record object
    $record = @{
        type = "A"
        name = "@"
        data = $Data
        ttl = 600
    }
    
    # Convert record object to JSON
    $body = "[" + (ConvertTo-Json $record) + "]"
    
    try {
        Invoke-RestMethod -Uri $url -Method Put -Headers $headers -Body $body
        Write-Output "DNS record updated successfully."
    } catch {
        Write-Output "Error: $_"
    }
}

# Function to get external IP address
function Get-ExternalIPAddress {
    $ipInfo = Invoke-RestMethod -Uri "https://api.ipify.org?format=json"
    $externalIP = $ipInfo.ip
    return $externalIP
}

# Set your credentials and domain
$ApiKey = ""
$Secret = ""
$Domain = "austinlhoward.com"
$externalIP = Get-ExternalIPAddress
Write-Output "$externalIP"

# Call the function to get domain details
#Get-DomainDetails -ApiKey $ApiKey -Secret $Secret -Domain $Domain

# Call the function to delete a DNS record (replace $RecordId with the actual ID)
#Remove-DNSRecord -ApiKey $ApiKey -Secret $Secret -Domain $Domain

# Call the function to update a DNS record (replace $RecordId and $Data with the actual ID and IP)
Update-DNSRecord -ApiKey $ApiKey -Secret $Secret -Domain $Domain -Data $externalIP