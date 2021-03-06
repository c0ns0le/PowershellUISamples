param(
  [switch]$browser
)
# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed
function Get-ScriptDirectory
{
  $Invocation = (Get-Variable MyInvocation -Scope 1).Value
  if ($Invocation.PSScriptRoot) {
    $Invocation.PSScriptRoot
  }
  elseif ($Invocation.MyCommand.Path) {
    Split-Path $Invocation.MyCommand.Path
  } else {
    $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf(""))
  }
}
$shared_assemblies = @(
  "WebDriver.dll",
  "WebDriver.Support.dll",
  "Selenium.WebDriverBackedSelenium.dll",
  "nunit.core.dll",
  "nunit.framework.dll"
)

$env:SHARED_ASSEMBLIES_PATH = "c:\developer\sergueik\csharp\SharedAssemblies"
$shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
pushd $shared_assemblies_path
$shared_assemblies | ForEach-Object { Unblock-File -Path $_; Add-Type -Path $_; Write-Output ("Loaded {0} " -f $_) }
popd
$verificationErrors = New-Object System.Text.StringBuilder
$baseURL = "http://www.google.com"
$phantomjs_executable_folder = "C:\tools\phantomjs"
if ($PSBoundParameters["browser"]) {
  try {
    $connection = (New-Object Net.Sockets.TcpClient)
    $connection.Connect("127.0.0.1",4444)
    $connection.Close()
  } catch {
    Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "start cmd.exe /c c:\java\selenium\hub.cmd"
    Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "start cmd.exe /c c:\java\selenium\node.cmd"
    Start-Sleep -Seconds 10
  }
  $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Firefox()
  $uri = [System.Uri]("http://127.0.0.1:4444/wd/hub")
  $selenium = New-Object OpenQA.Selenium.Remote.RemoteWebDriver ($uri,$capability)
} else {
  $selenium = New-Object OpenQA.Selenium.PhantomJS.PhantomJSDriver ($phantomjs_executable_folder)
  $selenium.Capabilities.SetCapability("ssl-protocol","any")
  $selenium.Capabilities.SetCapability("ignore-ssl-errors",$true)
  $selenium.Capabilities.SetCapability("takesScreenshot",$true)
  $selenium.Capabilities.SetCapability("userAgent","Mozilla/5.0 (Windows NT 6.1) AppleWebKit/534.34 (KHTML, like Gecko) PhantomJS/1.9.7 Safari/534.34")
  $options = New-Object OpenQA.Selenium.PhantomJS.PhantomJSOptions
  $options.AddAdditionalCapability("phantomjs.executable.path",$phantomjs_executable_folder)
}
# WebDriver script generated by Selenium IDE formatter, tweaked manually
# $default_timeout = [OpenQA.Selenium.Remote.RemoteWebDriver]::DefaultCommandTimeout 
# write-output "-- $default_timeout --"

$selenium.Navigate().GoToUrl($baseURL + "")
$selenium.FindElement([OpenQA.Selenium.By]::Id("hplogo")).Click()
Start-Sleep 2
try {
  [NUnit.Framework.Assert]::IsTrue($selenium.findElements([OpenQA.Selenium.By]::CssSelector("input#gbqfq.gbqfif")).Count -ne 0)

} catch [NUnit.Framework.AssertionException]{
  $verificationErrors.Append($_.Exception.Message)
}
$selenium.FindElement([OpenQA.Selenium.By]::Id("gbqfq")).Clear()
$selenium.FindElementsByClassName("gbqfif")[0].Clear()

$selenium.FindElement([OpenQA.Selenium.By]::CssSelector("input#gbqfq.gbqfif")).SendKeys("selenium")
$selenium.FindElement([OpenQA.Selenium.By]::Id("gbqfb")).Click()
$selenium.Navigate().Back()
[NUnit.Framework.Assert]::IsTrue($selenium.findElements([OpenQA.Selenium.By]::Id("hplogo")).Count -ne 0)
try {
  $selenium.Quit()
} catch [exception]{
  # Ignore errors if unable to close the browser
}
[NUnit.Framework.Assert]::AreEqual($verificationErrors.Length,0)
