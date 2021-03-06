#Copyright (c) 2015 Serguei Kouzmine
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.


# http://www.codeproject.com/Articles/37055/Working-with-MS-Excel-xls-xlsx-Using-MDAC-and-Oled
#  http://forums.asp.net/t/1976281.aspx?OdbcConnection+Microsoft+Excel+Driver+reading+only+first+row+first+column

param(
  [string]$format = 'excel',
  [switch]$pause,
  [switch]$show
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
    $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf(''))
  }
}

$data_name = 'TestConfiguration.xls'
[string]$filename = ('{0}\{1}' -f (Get-ScriptDirectory),$data_name)

$sheet_name = 'Sailings$'
[string]$oledb_provider = 'Provider=Microsoft.Jet.OLEDB.4.0'
$data_source = ('Data Source = {0}' -f $filename)
$ext_arg = "Extended Properties=Excel 8.0"
# HDR=YES
# TODO: sample queries
[string]$query = "Select * from [${sheet_name}] where [id] <> 0"
[System.Data.OleDb.OleDbConnection]$connection = New-Object System.Data.OleDb.OleDbConnection ("$oledb_provider;$data_source;$ext_arg")
$connection.open()

# Retrieve Schema Information of Excel Workbook
# https://msdn.microsoft.com/en-us/library/system.data.oledb.oledbconnection.getoledbschematable%28v=vs.110%29.aspx
[System.Data.DataTable]$dt_schema = $null
$dt_schema = $connection.GetOleDbSchemaTable([System.Data.OleDb.OleDbSchemaGuid]::Tables,[object[]]@( $null,$null,$null,"TABLE"))
# $dt_schema.TABLE_NAME
$sheet_name = $dt_schema.Rows[0].TABLE_NAME
write-output ('Data sheet name : {0}' -f $sheet_name )
# https://msdn.microsoft.com/en-us/library/system.data.oledb.oledbschemaguid_fields%28v=vs.110%29.aspx
# https://support.microsoft.com/en-us/kb/309488/#bookmark-6
[System.Data.DataTable]$dc_schema = $null
$dc_schema = $connection.GetOleDbSchemaTable([System.Data.OleDb.OleDbSchemaGuid]::Columns,[object[]]@( $null,$null,$sheet_name,$null))
$columns = @()
$tags_enum = @()
$dc_schema.Rows | ForEach-Object { $dc_row = $_
  $columns += $dc_row.COLUMN_NAME
  $tags_enum += $dc_row.DATA_TYPE
}
write-output 'Columns:'
$columns

write-output 'Data types:'

$tags_enum

# TODO: map $tags_enum to $tags required for sorting
# https://social.msdn.microsoft.com/Forums/en-US/81bef8f4-a648-48dd-8566-92a9fc3836c5/getschema-datatype
# https://msdn.microsoft.com/en-us/library/cc668763%28v=vs.110%29.aspx
Write-Output (0 + [System.Data.Odbc.OdbcType]::Date)

$connection.Close()
