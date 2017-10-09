Import-Module ActiveDirectory
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName PresentationFramework
$inputXML = @"
<Window x:Name="PasswordReset_Frm" x:Class="PasswordResetForm.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:PasswordResetForm"
        mc:Ignorable="d"
        Title="Password Reset" Height="575" Width="529.5" FontSize="24">
    <Grid>
        <TextBox x:Name="Search_Txt" HorizontalAlignment="Left" Height="36" Margin="10,10,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="373" FontSize="26" TextAlignment="Right"/>
        <Button x:Name="Search_Btn" Content="Search" HorizontalAlignment="Left" Margin="388,10,0,0" VerticalAlignment="Top" Width="123" Height="36" FontSize="24"/>
        <ListBox x:Name="Users_ListBox" HorizontalAlignment="Left" Height="415" Margin="10,51,0,0" VerticalAlignment="Top" Width="501" FontSize="24"/>
        <Button x:Name="Unlock_Btn" Content="Unlock" HorizontalAlignment="Left" Margin="10,476,0,10" VerticalAlignment="Center" Width="123" Height="46" FontSize="24"/>
        <Button x:Name="GenReset_Btn" Content="Generate &amp; Reset" HorizontalAlignment="Left" Margin="138,476,0,10" VerticalAlignment="Center" Width="206" Height="46" FontSize="24"/>
        <Button x:Name="SpecReset_Btn" Content="Specific Reset" HorizontalAlignment="Left" Margin="349,476,0,10" VerticalAlignment="Center" Width="162" Height="46" FontSize="24"/>
    </Grid>
</Window>
"@
$inputXML = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N' -replace '^<Win.*', '<Window'

[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = $inputXML
#Read XAML

$reader = (New-Object System.Xml.XmlNodeReader $xaml)
try{$PasswordReset_Frm = [Windows.Markup.XamlReader]::Load( $reader )}
catch{Write-Host "Unable to load Windows.Markup.XamlReader. Double-check syntax and ensure .net is installed."}

#===========================================================================
# Store Form Objects In PowerShell
#===========================================================================

$xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name "WPF$($_.Name)" -Value $PasswordReset_Frm.FindName($_.Name)}

Function Get-FormVariables{
if ($global:ReadmeDisplay -ne $true){Write-host "If you need to reference this display again, run Get-FormVariables" -ForegroundColor Yellow;$global:ReadmeDisplay = $true}


write-host "Found the following interactable elements from our form" -ForegroundColor Cyan
get-variable WPF*
}

Get-FormVariables
$PasswordReset_Frm.ShowDialog() | Out-Null