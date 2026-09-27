BeforeAll {
    $script:implementationPath = Join-Path $PSScriptRoot 'math-tool.ps1'
    . $script:implementationPath

    function script:Invoke-MathToolProcess {
        param(
            [long]$N,
            [string]$Operation
        )

        $startInfo = [System.Diagnostics.ProcessStartInfo]::new()
        $startInfo.FileName = Get-Command pwsh -CommandType Application -ErrorAction Stop |
            Select-Object -First 1 -ExpandProperty Source
        $startInfo.UseShellExecute = $false
        $startInfo.RedirectStandardOutput = $true
        $startInfo.RedirectStandardError = $true
        $arguments = @('-NoLogo', '-NoProfile', '-File', $script:implementationPath)
        if ($PSBoundParameters.ContainsKey('N')) {
            $arguments += @('-N', "$N")
        }
        if ($PSBoundParameters.ContainsKey('Operation')) {
            $arguments += @('-Operation', $Operation)
        }
        foreach ($argument in $arguments) {
            [void]$startInfo.ArgumentList.Add($argument)
        }

        $process = [System.Diagnostics.Process]::new()
        $process.StartInfo = $startInfo
        try {
            [void]$process.Start()
            $stdoutTask = $process.StandardOutput.ReadToEndAsync()
            $stderrTask = $process.StandardError.ReadToEndAsync()
            $stdout = $stdoutTask.GetAwaiter().GetResult()
            $stderr = $stderrTask.GetAwaiter().GetResult()
            $process.WaitForExit()

            [pscustomobject]@{
                ExitCode = $process.ExitCode
                Stdout   = $stdout
                Stderr   = $stderr
            }
        }
        finally {
            $process.Dispose()
        }
    }
}

Describe 'Get-Factorial' {
    It 'returns only the numeric factorial value for N=<N>' -TestCases @(
        @{ N = 0; Expected = 1 }
        @{ N = 1; Expected = 1 }
        @{ N = 5; Expected = 120 }
    ) {
        param($N, $Expected)

        $result = @(Get-Factorial -N $N)
        $result.Count | Should -Be 1
        $result[0] | Should -BeOfType [System.Numerics.BigInteger]
        $result[0] | Should -Be ([System.Numerics.BigInteger]$Expected)
    }
}

Describe 'Get-Fibonacci' {
    It 'returns only the numeric Fibonacci value for N=<N>' -TestCases @(
        @{ N = 0; Expected = 0 }
        @{ N = 1; Expected = 1 }
        @{ N = 10; Expected = 55 }
        @{ N = 100; Expected = '354224848179261915075' }
    ) {
        param($N, $Expected)

        $result = @(Get-Fibonacci -N $N)
        $result.Count | Should -Be 1
        $result[0] | Should -BeOfType [System.Numerics.BigInteger]
        $result[0] | Should -Be ([System.Numerics.BigInteger]$Expected)
    }

    It 'rejects negative indices with a clear validation message' {
        { Get-Fibonacci -N -1 } | Should -Throw '*N must be a non-negative integer.*'
    }
}

Describe 'math-tool CLI' {
    It 'writes exactly one Fibonacci result line by default and exits successfully for N=<N>' -TestCases @(
        @{ N = 0; Expected = 0 }
        @{ N = 1; Expected = 1 }
        @{ N = 10; Expected = 55 }
        @{ N = 100; Expected = '354224848179261915075' }
    ) {
        param($N, $Expected)

        $result = Invoke-MathToolProcess -N $N
        $result.ExitCode | Should -Be 0
        $result.Stdout | Should -Be "Fibonacci($N) = $Expected$([Environment]::NewLine)"
        $result.Stderr | Should -Be ''
    }

    It 'writes exactly one factorial result line for explicit factorial dispatch' {
        $result = Invoke-MathToolProcess -Operation factorial -N 5
        $result.ExitCode | Should -Be 0
        $result.Stdout | Should -Be "Factorial(5) = 120$([Environment]::NewLine)"
        $result.Stdout | Should -Not -Match 'Fibonacci'
        $result.Stderr | Should -Be ''
    }

    It 'dispatches operation <Operation> to the correct calculation and label' -TestCases @(
        @{ Operation = 'fibonacci'; N = 5; Expected = 'Fibonacci(5) = 5'; Unexpected = 'Factorial' }
        @{ Operation = 'factorial'; N = 5; Expected = 'Factorial(5) = 120'; Unexpected = 'Fibonacci' }
    ) {
        param($Operation, $N, $Expected, $Unexpected)

        $result = Invoke-MathToolProcess -Operation $Operation -N $N
        $result.ExitCode | Should -Be 0
        $result.Stdout | Should -Be "$Expected$([Environment]::NewLine)"
        $result.Stdout | Should -Not -Match $Unexpected
        $result.Stderr | Should -Be ''
    }

    It 'fails with a clear error when N is negative' {
        $result = Invoke-MathToolProcess -N -1
        $result.ExitCode | Should -Not -Be 0
        $result.Stdout | Should -Be ''
        $result.Stderr | Should -Match 'N must be a non-negative integer.'
    }

    It 'fails with a clear error when N is omitted' {
        $result = Invoke-MathToolProcess
        $result.ExitCode | Should -Not -Be 0
        $result.Stdout | Should -Be ''
        $result.Stderr | Should -Match 'The -N parameter is required when invoking this script directly.'
    }
}
