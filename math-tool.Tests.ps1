BeforeAll {
    $implementationPath = Join-Path $PSScriptRoot 'math-tool.ps1'
    . $implementationPath

    function Invoke-MathToolProcess {
        param([int]$N)

        $startInfo = [System.Diagnostics.ProcessStartInfo]::new()
        $startInfo.FileName = (Get-Process -Id $PID).Path
        $startInfo.UseShellExecute = $false
        $startInfo.RedirectStandardOutput = $true
        $startInfo.RedirectStandardError = $true
        foreach ($argument in @('-NoLogo', '-NoProfile', '-File', $implementationPath, '-N', "$N")) {
            [void]$startInfo.ArgumentList.Add($argument)
        }

        $process = [System.Diagnostics.Process]::new()
        $process.StartInfo = $startInfo
        try {
            [void]$process.Start()
            $stdoutTask = $process.StandardOutput.ReadToEndAsync()
            $stderrTask = $process.StandardError.ReadToEndAsync()
            $process.WaitForExit()

            [pscustomobject]@{
                ExitCode = $process.ExitCode
                Stdout   = $stdoutTask.GetAwaiter().GetResult()
                Stderr   = $stderrTask.GetAwaiter().GetResult()
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
    ) {
        param($N, $Expected)

        $result = @(Get-Fibonacci -N $N)
        $result.Count | Should -Be 1
        $result[0] | Should -BeOfType [System.Numerics.BigInteger]
        $result[0] | Should -Be ([System.Numerics.BigInteger]$Expected)
    }
}

Describe 'math-tool CLI' {
    It 'writes exactly one result line and exits successfully for N=<N>' -TestCases @(
        @{ N = 0; Expected = 0 }
        @{ N = 1; Expected = 1 }
        @{ N = 10; Expected = 55 }
    ) {
        param($N, $Expected)

        $result = Invoke-MathToolProcess -N $N
        $result.ExitCode | Should -Be 0
        $result.Stdout | Should -Be "Fibonacci($N) = $Expected$([Environment]::NewLine)"
        $result.Stderr | Should -Be ''
    }
}
