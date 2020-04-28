Function Get-WtScheme {
    <#
    .Description
    Returns color schemes from
    https://github.com/mbadolato/iTerm2-Color-Schemes/blob/master/windowsterminal
    .Parameter Url
    Url to the iTerm2 project.
    .Parameter Theme
    Specify the name of the theme that you want returned. All themes are returned by default
    .Example
    PS> Get-WtTheme
    Returns all available themes
    .Example
    PS> Get-WtTheme -Filter 'atom.json'
    Retrieves the atom.json theme.
    .Link
    https://github.com/mbadolato/iTerm2-Color-Schemes/blob/master/windowsterminal/
    .Link link to blogpost
    #>
    [cmdletbinding()]
    param(
        [string]
        $Theme = '*',

        [string]
        $Url = 'https://github.com/mbadolato/iTerm2-Color-Schemes/tree/master/windowsterminal'
    )

    $page = Invoke-WebRequest $Url -UseBasicParsing

    $links = $page.Links | Where-Object title -like "$Theme.json"

    Write-Verbose "$($links.count) links found matching $Theme"

    foreach ($link in $links) {
        # Use the raw url so raw results can be returned and output
        $base = 'https://raw.githubusercontent.com'
        $href = $link.href

        $rawUrl = $base + $href
        $rawUrl = $rawUrl.replace('/blob', '')

        Invoke-RestMethod $RawUrl
    }
}