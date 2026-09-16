$ErrorActionPreference = 'Stop'
Push-Location $PSScriptRoot
try {
    nerd check main.n
    if ($LASTEXITCODE -ne 0) { throw 'Check failed' }
    nerd build --output _bin/crafter main.n
    if ($LASTEXITCODE -ne 0) { throw 'Build failed' }

    function Run-Crafter([string[]] $Arguments, [int] $ExpectedExit = 0) {
        $output = (& ./_bin/crafter.exe @Arguments) -join "`n"
        if ($LASTEXITCODE -ne $ExpectedExit) {
            throw "Unexpected exit code ${LASTEXITCODE}: $output"
        }
        return $output
    }
    function Assert-Match([string] $Output, [string] $Pattern) {
        if ($Output -notmatch $Pattern) { throw "Missing pattern '$Pattern':`n$Output" }
    }
    function Assert-Absent([string] $Output, [string] $Pattern) {
        if ($Output -match $Pattern) { throw "Unexpected pattern '$Pattern':`n$Output" }
    }

    $output = Run-Crafter @('--stack', '64', 'atm10.txt', '*jetpack')
    Assert-Absent $output '(?m)^Tools |iron-ore-hammer|metallurgic-infuser|coal-generator'
    Assert-Match $output '    emerald-jetpack: 1'

    $output = Run-Crafter @('recipes.tools.test.txt', 'product')
    Assert-Match $output '(?s)^Tools .*    outer-tool\n.*    inner-tool\n\nIngredients:'
    Assert-Absent $output 'cyclic-tool'

    $output = Run-Crafter @('recipes.test.txt', 'tool-test')
    Assert-Match $output '(?s)^Tools .*raw-tool\n\nIngredients:'
    Assert-Match $output '    metal: 2'
    Assert-Match $output '    tool: 4'
    Assert-Match $output '    raw-tool: 3'

    $output = Run-Crafter @('recipes.test.txt', '-tool', 'tool-test', '-raw-tool', '-tool')
    Assert-Match $output 'tool \(already owned\)'
    Assert-Match $output '    material: 7'
    Assert-Absent $output '    (metal|tool|raw-tool):'
    Assert-Absent $output 'Stage 3:'

    $output = Run-Crafter @('recipes.test.txt', 'mixed-tool-test', '-tool')
    Assert-Match $output '    tool: 4'
    Assert-Match $output '    metal: 2'
    $output = Run-Crafter @('recipes.test.txt', 'tool', '-tool')
    Assert-Match $output '    tool: 2'
    Assert-Absent $output '(?m)^Tools '

    $output = Run-Crafter @('recipes.test.txt', 'tool-part-a', 'tool-part-b')
    if ([regex]::Matches($output, '(?m)^    tool$').Count -ne 1) {
        throw "Expected shared tool to be listed once:`n$output"
    }
    Assert-Match $output '(?m)^    raw-tool$'

    $output = Run-Crafter @('recipes.tools.test.txt', 'product', '-outer-tool')
    Assert-Match $output '    outer-tool \(already owned\)'
    Assert-Absent $output 'inner-tool|cyclic-tool'
    Assert-Match $output '    shared: 3'
    Assert-Absent $output '    (outer-tool|inner-tool|inner-material|dedicated):'
    Assert-Absent $output 'Stage 2:'
    $output = Run-Crafter @('recipes.tools.test.txt', 'cyclic-product', '-cyclic-tool')
    Assert-Match $output '    material: 1'
    $null = Run-Crafter @('recipes.tools.test.txt', 'cyclic-product') 1

    $output = Run-Crafter @('--stack', '64', 'atm10.txt', '*energy', '-metallurgic-infuser', '-coal-generator')
    Assert-Absent $output '    (metallurgic-infuser|coal-generator|furnace|machine-frame|red-torch|blue-dye|lapis-lazuli|cobblestone):'
    Assert-Match $output '    coal: 16'
    Assert-Match $output '    redstone: 1/38'

    $null = Run-Crafter @('recipes.test.txt', 'tool-test', '-missing') 2
    $null = Run-Crafter @('recipes.test.txt', 'tool-test', '-material') 2
    $null = Run-Crafter @('recipes.test.txt', '-tool') 2
    $null = Run-Crafter @('recipes.cycle.test.txt', 'a') 1
    $null = Run-Crafter @('recipes.invalid.test.txt', 'a') 1
    $output = Run-Crafter @('--stack', '64', 'recipes.test.txt', 'stack-test')
    Assert-Match $output '    loose-items: 1/36'
    Assert-Match $output '    exact-stack: 64'
    Write-Output 'All crafting regression checks passed.'
}
finally { Pop-Location }
