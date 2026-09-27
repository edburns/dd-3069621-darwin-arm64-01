<#
.SYNOPSIS
Writes a math operation result to standard output.

.PARAMETER N
Required for direct execution; non-negative 64-bit integer index of the Fibonacci value to calculate.

.PARAMETER Operation
Math operation to calculate. Defaults to fibonacci.

.DESCRIPTION
Direct execution writes one line in the format Fibonacci(N) = value or Factorial(N) = value.
#>
[CmdletBinding()]
param(
    [ValidateScript({ $_ -ge 0 }, ErrorMessage = 'N must be a non-negative integer.')]
    [long]$N,

    [ValidateSet('fibonacci', 'factorial')]
    [string]$Operation = 'fibonacci'
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

function Get-Factorial {
    <#
    .SYNOPSIS
    Returns the factorial of N.

    .PARAMETER N
    Non-negative 64-bit integer. The accepted input is bounded by this parameter type; the result accumulates in BigInteger.

    .OUTPUTS
    System.Numerics.BigInteger
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateScript({ $_ -ge 0 }, ErrorMessage = 'N must be a non-negative integer.')]
        [long]$N
    )

    $result = [System.Numerics.BigInteger]::One
    $limit = [System.Numerics.BigInteger]$N
    $factor = [System.Numerics.BigInteger]2
    while ($factor -le $limit) {
        $result *= $factor
        $factor += [System.Numerics.BigInteger]::One
    }

    return $result
}

if ($isDirectExecution) {
    switch ($Operation) {
        'fibonacci' {
            $value = Get-Fibonacci -N $N
            Write-Output "Fibonacci($N) = $value"
        }
        'factorial' {
            $value = Get-Factorial -N $N
            Write-Output "Factorial($N) = $value"
        }
        default {
            throw "Unsupported operation '$Operation'."
        }
    }
}
