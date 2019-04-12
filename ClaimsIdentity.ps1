# Add assembly for displaying message box
Add-Type –AssemblyName System.Windows.Forms

# Claims
$claims = New-Object System.Collections.Generic.List[System.Security.Claims.Claim]

# Add claims to claims list
$claims.Add(((New-Object System.Security.Claims.Claim([System.Security.Claims.ClaimTypes]::Email, "email@gmail.com"))))
$claims.Add(((New-Object System.Security.Claims.Claim("WebSite", "http://ntcoder.com"))))
$claims.Add(((New-Object System.Security.Claims.Claim("Primary Skill", "C++"))))
$claims.Add(((New-Object System.Security.Claims.Claim([System.Security.Claims.ClaimTypes]::Country, "India"))))
$claims.Add(((New-Object System.Security.Claims.Claim([System.Security.Claims.ClaimTypes]::Role, "CEO"))))

# Instantiate claims identity object
$cid = New-Object System.Security.Claims.ClaimsIdentity($claims, "Password")

# Assign principal
[System.Threading.Thread]::CurrentPrincipal =  New-Object System.Security.Claims.ClaimsPrincipal($cid)

Write-Host "Current Thread Principal: " -NoNewline
[System.Threading.Thread]::CurrentPrincipal | Select-Object -ExpandProperty Claims | Select-Object Issuer, Type, value | Format-Table -AutoSize

# Write authentication status
Write-Host "Authenticated: $($cid.IsAuthenticated)"

$tp = [System.Threading.Thread]::CurrentPrincipal

# Check if user is CEO, if yes then display a messagebox, check above role that we added 
if($tp.IsInRole("CEO"))
{
    $null = [System.Windows.Forms.MessageBox]::Show("Welcome CEO, opening CEO view...", "User", [System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Information)
}

# Check country of user, if India then display an Indian greeting message.
if($tp.HasClaim([System.Security.Claims.ClaimTypes]::Country, "India"))
{
    $null = [System.Windows.Forms.MessageBox]::Show("Namaskar!", "Greetings!", [System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Information)
}