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

    return $previous
}

if ($PSBoundParameters.ContainsKey('N')) {
    $value = Get-Fibonacci -N $N
    Write-Output "Fibonacci($N) = $value"
}
