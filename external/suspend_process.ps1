# http://poshcode.org/5635
#requires -version 2.0

<#
    .Synopsis
        Output the results of a command in a Windows Form
    .Description
        Output the results of a command in a Windows Form with possibility to add buttons with actions 
    .Example
    
        out-form 
                 -title "Services" 
                 -data (get-service) 
                 -columnNames ("Name", "Status") 
                 -columnProperties ("DisplayName", "Status") 
                 -actions @{"Start" = {$_.start()}; "Stop" = {$_.stop()}; }
    #>
# http://stackoverflow.com/questions/11010165/how-to-suspend-resume-a-process-in-windows
# http://poshcode.org/2189

function Out-Form {
  param(
    $title = '', 
    $data = $null,
    $columnNames = $null,
    $columnTag,
    $columnProperties = $null,
    $actions = $null )

  @( 'System.Drawing','System.Windows.Forms') | ForEach-Object { [void][System.Reflection.Assembly]::LoadWithPartialName($_) }

  # a little data defaulting/validation
  if ($columnNames -eq $null) {
    $columnNames = $columnProperties
  }
  if ($columnProperties -eq $null -or
    $columnNames.Count -lt 1 -or
    $columnNames.Count -ne $columnNames.Count) {

    throw 'Data validation failed: column count mismatch'
  }
  $numCols = $columnNames.Count

  # figure out form width
  $width = $numCols * 200
  $actionWidth = $actions.Count * 100 + 40
  if ($actionWidth -gt $width) {
    $width = $actionWidth
  }

  # set up form. Use alternative syntax
  $form = New-Object System.Windows.Forms.Form
  $form.Text = $title
  $form.Size = New-Object System.Drawing.Size ($width,400)
  $panel = New-Object System.Windows.Forms.Panel
  $panel.Dock = 'Fill'
  $form.Controls.Add($panel)

  $lv = New-Object windows.forms.ListView
  $panel.Controls.Add($lv)

  # add the buttons
  $btnPanel = New-Object System.Windows.Forms.Panel
  $btnPanel.Height = 40
  $btnPanel.Dock = "Bottom"
  $panel.Controls.Add($btnPanel)

  $btns = New-Object System.Collections.ArrayList
  if ($actions -ne $null) {
    $btnOffset = 20
    foreach ($action in $actions.GetEnumerator()) {
      $btn = New-Object windows.forms.Button
      $btn.DialogResult = [System.Windows.Forms.DialogResult]"OK"
      $btn.Text = $action.Name
      $btn.Left = $btnOffset
      $btn.Width = 80
      $btn.Top = 10
      $exprString = '{$lv.SelectedItems | foreach-object { $_.Tag } | foreach-object {' + $action.Value + '}}'
      $scriptBlock = Invoke-Expression $exprString
      $btn.add_click($scriptBlock)
      $btnPanel.Controls.Add($btn)
      $btnOffset += 100
      $btns += $btn
    }
  }

  # create the columns
  $lv.View = [System.Windows.Forms.View]"Details"
  $lv.Size = New-Object System.Drawing.Size ($width,350)
  $lv.FullRowSelect = $true
  $lv.GridLines = $true
  $lv.Dock = "Fill"
  foreach ($col in $columnNames) {
    $lv.Columns.Add($col,200) > $null
  }

  # populate the view
  foreach ($d in $data) {
    $item =
    New-Object System.Windows.Forms.ListViewItem (
      (Invoke-Expression ('$d.' + $columnProperties[0])).ToString())

    for ($i = 1; $i -lt $columnProperties.Count; $i++) {
      $item.SubItems.Add(
        (Invoke-Expression ('$d.' + $columnProperties[$i])).ToString()) > $null
    }
    $item.Tag = $d
    $lv.Items.Add($item) > $null
  }

  # Added by Bar971.it  
  for ($i = 0; $i -lt $columnTag.Count; $i++) {

    $lv.Columns[$i].Tag = $columnTag[$i]

  }
  # http://www.java2s.com/Code/CSharp/GUI-Windows-Form/SortaListViewbyAnyColumn.htm
  # http://www.java2s.com/Code/CSharp/GUI-Windows-Form/UseRadioButtontocontroltheListViewdisplaystyle.htm
  $comparerClassString = @"

  using System;
  using System.Windows.Forms;
  using System.Drawing;
  using System.Collections;

  public class ListViewItemComparer : System.Collections.IComparer 
  { 
    public int col = 0;
    
    public System.Windows.Forms.SortOrder Order; // = SortOrder.Ascending;
  
    public ListViewItemComparer()
    {
        col = 0;        
    }
    
    public ListViewItemComparer(int column, bool asc)
    {
        col = column; 
        if (asc) 
        {Order = SortOrder.Ascending;}
        else
        {Order = SortOrder.Descending;}        
    }
    
    public int Compare(object x, object y) // IComparer Member     
    {   
        if (!(x is ListViewItem)) return (0);
        if (!(y is ListViewItem)) return (0);
            
        ListViewItem l1 = (ListViewItem)x;
        ListViewItem l2 = (ListViewItem)y;
            
        if (l1.ListView.Columns[col].Tag == null)
            {
                l1.ListView.Columns[col].Tag = "Text";
            }
        
        if (l1.ListView.Columns[col].Tag.ToString() == "Numeric") 
            {
                float fl1 = float.Parse(l1.SubItems[col].Text);
                float fl2 = float.Parse(l2.SubItems[col].Text);
                    
                if (Order == SortOrder.Ascending)
                    {
                        return fl1.CompareTo(fl2);
                    }
                else
                    {
                        return fl2.CompareTo(fl1);
                    }
             }
         else
             {
                string str1 = l1.SubItems[col].Text;
                string str2 = l2.SubItems[col].Text;
                    
                if (Order == SortOrder.Ascending)
                    {
                        return str1.CompareTo(str2);
                    }
                else
                    {
                        return str2.CompareTo(str1);
                    }
              }     
    }
} 
"@
  Add-Type -TypeDefinition $comparerClassString `
     -ReferencedAssemblies (`
       'System.Windows.Forms','System.Drawing')

  $bool = $true
  $columnClick =
  {
    $lv.ListViewItemSorter = New-Object ListViewItemComparer ($_.Column,$bool)

    $bool = !$bool
  }
  $lv.Add_ColumnClick($columnClick)
  # End Add by Bar971.it

  # display it
  $form.Add_Shown({ $form.Activate() })
  if ($btns.Count -gt 0) {
    $form.AcceptButton = $btns[0]
  }
  $form.ShowDialog()
}

function Suspend-Process {
  <#
    .EXAMPLE
        PS C:\> Suspend-Process 2008
    .EXAMPLE
        PS C:\> Suspend-Process 2008 -Resume
    .NOTES
        Author: greg zakharov
  #>
  param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
    [Int32]$ProcessId,
    
    [Parameter(Position=1)]
    [Switch]$Resume
  )
  # http://pinvoke.net/default.aspx/ntdll/NtSuspendProcess.html
  # http://www.developpez.net/forums/d397538/dotnet/langages/vb-net/vb-net-suspendre-process/

  begin {
    if (!(($cd = [AppDomain]::CurrentDomain).GetAssemblies() | ? {
      $_.FullName.Contains('Nt')
    })) {
      $attr = 'AnsiClass, Class, Public, Sealed, BeforeFieldInit'
      $type = (($cd.DefineDynamicAssembly(
        (New-Object Reflection.AssemblyName('Nt')), 'Run'
      )).DefineDynamicModule('Nt', $false)).DefineType('Suspend', $attr)
      [void]$type.DefinePInvokeMethod('NtSuspendProcess', 'ntdll.dll',
        'Public, Static, PinvokeImpl', 'Standard', [Int32],
        @([IntPtr]), 'WinApi', 'Auto'
      )
      [void]$type.DefinePInvokeMethod('NtResumeProcess', 'ntdll.dll',
        'Public, Static, PinvokeImpl', 'Standard', [Int32],
        @([IntPtr]), 'WinApi', 'Auto'
      )
      Set-Variable Nt -Value $type.CreateType() -Option ReadOnly -Scope global
    }
    
    $OpenProcess = [RegEx].Assembly.GetType(
      'Microsoft.Win32.NativeMethods'
    ).GetMethod('OpenProcess') #returns SafeProcessHandle type
    
    $PROCESS_SUSPEND_RESUME = 0x00000800
  }
  process {
    try {
      $sph = $OpenProcess.Invoke($null, @($PROCESS_SUSPEND_RESUME, $false, $ProcessId))
      if ($sph.IsInvalid) {
        Write-Warning "process with specified ID does not exist."
        return
      }
      $ptr = $sph.DangerousGetHandle()
      
      switch ($Resume) {
        $true  { [void]$Nt::NtResumeProcess($ptr) }
        $false { [void]$Nt::NtSuspendProcess($ptr) }
      }
    }
    catch { $_.Exception }
    finally {
      if ($sph -ne $null) { $sph.Close() }
    }
  }
  end {}
}




Out-Form -data (Get-Process) -columnNames ("Name","ID") -columnProperties ("Name","ID") -columnTag ("Text","Numeric") `
                 -actions @{"Suspend" = {Suspend-Process $_.Id}; "resume" = {Suspend-Process $_.Id -resume}; }

