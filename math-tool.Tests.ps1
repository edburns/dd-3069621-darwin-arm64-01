BeforeAll {
    $script:implementationPath = Join-Path $PSScriptRoot 'math-tool.ps1'
    . $script:implementationPath

    function script:Invoke-MathToolProcess {
        param([long]$N)

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
    It 'writes exactly one result line and exits successfully for N=<N>' -TestCases @(
        @{ N = 0; Expected = 0 }
        @{ N = 1; Expected = 1 }
        @{ N = 10; Expected = 55 }
        @{ N = 100; Expected = '354224848179261915075' }
    ) {
        param($N, $Expected)

        $result = Invoke-MathToolProcess -N $N
        $result.ExitCode | Should -Be 0
        $expectedOutput = [regex]::Escape("Fibonacci($N) = $Expected")
        $result.Stdout | Should -Match "^$expectedOutput\r?\n$"
        $result.Stderr | Should -Be ''
    }

    It 'fails with a clear error when N is omitted' {
        $result = Invoke-MathToolProcess
        $result.ExitCode | Should -Not -Be 0
        $result.Stdout | Should -Be ''
        $result.Stderr | Should -Match 'The -N parameter is required when invoking this script directly.'
    }
}
