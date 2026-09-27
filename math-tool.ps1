<#
.SYNOPSIS
Writes a Fibonacci value to standard output.

.PARAMETER N
Required for direct execution; non-negative 64-bit integer index of the Fibonacci value to calculate.

.DESCRIPTION
Direct execution writes one line in the format Fibonacci(N) = value.
#>
[CmdletBinding()]
param(
    [ValidateScript({ $_ -ge 0 }, ErrorMessage = 'N must be a non-negative integer.')]
    [long]$N
)

$isDirectExecution = $MyInvocation.InvocationName -ne '.'
if ($isDirectExecution -and -not $PSBoundParameters.ContainsKey('N')) {
    throw 'The -N parameter is required when invoking this script directly.'
}

function Get-Fibonacci {
    <#
    .SYNOPSIS
    Returns the Fibonacci number at index N.

    .PARAMETER N
    Zero-based non-negative 64-bit integer index.

    .OUTPUTS
    System.Numerics.BigInteger
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateScript({ $_ -ge 0 }, ErrorMessage = 'N must be a non-negative integer.')]
        [long]$N
    )

    $previous = [System.Numerics.BigInteger]::Zero
    $current = [System.Numerics.BigInteger]::One
    [long]$index = 0
    while ($index -lt $N) {
        $next = $previous + $current
        $previous = $current
        $current = $next
        $index++
    }

    # After N iterations, $previous holds F(N).
    return $previous
}

if ($isDirectExecution) {
    $value = Get-Fibonacci -N $N
    Write-Output "Fibonacci($N) = $value"
}
