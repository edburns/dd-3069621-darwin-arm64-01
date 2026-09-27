<#
.SYNOPSIS
Writes a Fibonacci value to standard output.

.PARAMETER N
Required for direct execution; non-negative integer index of the Fibonacci value to calculate.

.DESCRIPTION
Direct execution writes one line in the format Fibonacci(N) = value.
#>
[CmdletBinding()]
param(
    [ValidateScript({ $_ -ge 0 }, ErrorMessage = 'N must be a non-negative integer.')]
    [System.Numerics.BigInteger]$N
)

if ($MyInvocation.InvocationName -ne '.' -and -not $PSBoundParameters.ContainsKey('N')) {
    throw 'The -N parameter is required when invoking this script directly.'
}

function Get-Fibonacci {
    <#
    .SYNOPSIS
    Returns the Fibonacci number at index N.

    .PARAMETER N
    Zero-based non-negative integer index.

    .OUTPUTS
    System.Numerics.BigInteger
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateScript({ $_ -ge 0 }, ErrorMessage = 'N must be a non-negative integer.')]
        [System.Numerics.BigInteger]$N
    )

    $previous = [System.Numerics.BigInteger]::Zero
    $current = [System.Numerics.BigInteger]::One
    $index = [System.Numerics.BigInteger]::Zero
    while ($index -lt $N) {
        $next = $previous + $current
        $previous = $current
        $current = $next
        $index = $index + [System.Numerics.BigInteger]::One
    }

    # After N iterations, $previous holds F(N).
    return $previous
}

if ($MyInvocation.InvocationName -ne '.') {
    $value = Get-Fibonacci -N $N
    Write-Output "Fibonacci($N) = $value"
}
