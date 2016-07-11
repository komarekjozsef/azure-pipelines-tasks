[CmdletBinding()]
param()

# Arrange.
. $PSScriptRoot/../../lib/Initialize-Test.ps1
Microsoft.PowerShell.Core\Import-Module Microsoft.PowerShell.Security
$module = Microsoft.PowerShell.Core\Import-Module $PSScriptRoot/../../../Tasks/AzurePowerShell/ps_modules/VstsAzureHelpers_ -PassThru
$endpoint = @{
    Auth = @{
        Parameters = @{
            ServicePrincipalId = 'Some service principal ID'
            ServicePrincipalKey = 'Some service principal key'
            TenantId = 'Some tenant ID'
        }
        Scheme = 'ServicePrincipal'
    }
    Data = @{
        SubscriptionId = 'Some subscription ID'
        SubscriptionName = 'Some subscription name'
    }
}
$variableSets = @(
    @{ Version = [version]'0.9.9' }
    @{ Version = [version]'1.0' }
)
foreach ($variableSet in $variableSets) {
    Write-Verbose ('-' * 80)
    & $module { $script:azureModule = @{ Version = $args[0] } } $variableSet.Version

    Unregister-Mock Set-UserAgent
    Register-Mock Set-UserAgent
    # Act/Assert.
    Assert-Throws {
        & $module Initialize-AzureSubscription -Endpoint $endpoint
    } -MessagePattern "AZ_ServicePrincipalAuthNotSupportedAzureVersion0 $($variableSet.Version)"
}
