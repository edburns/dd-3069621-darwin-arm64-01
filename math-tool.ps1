<#
.SYNOPSIS
Writes a Fibonacci value to standard output.

.PARAMETER N
Non-negative integer index of the Fibonacci value to calculate.

.DESCRIPTION
Direct execution writes one line in the format Fibonacci(N) = value.
#>
[CmdletBinding()]
param(
    [ValidateRange(0, [int]::MaxValue)]
    [int]$N
)

function Get-Fibonacci {
    <#
    .SYNOPSIS
    Returns the Fibonacci number at index N.

    .PARAMETER N
    Zero-based non-negative index.

    .OUTPUTS
    System.Numerics.BigInteger
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$N
    )

    $previous = [System.Numerics.BigInteger]::Zero
    $current = [System.Numerics.BigInteger]::One
    for ($index = 0; $index -lt $N; $index++) {
        $next = $previous + $current
        $previous = $current
        $current = $next
    }

    # After N iterations, $previous holds F(N).
    return $previous
}

if ($PSBoundParameters.ContainsKey('N')) {
    $value = Get-Fibonacci -N $N
    Write-Output "Fibonacci($N) = $value"
}
