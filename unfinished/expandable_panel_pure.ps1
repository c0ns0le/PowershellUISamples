$global:button_panel_height = 25
$global:button_panel_width = 200

Add-Type -TypeDefinition @"

// "
using System;
using System.Windows.Forms;
public class Win32Window : IWin32Window
{
    private IntPtr _hWnd;
    private string _data;

    public String Data
    {
        get { return _data; }
        set { _data = value; }
    }

    public Win32Window(IntPtr handle)
    {
        _hWnd = handle;
    }

    public IntPtr Handle
    {
        get { return _hWnd; }
    }
}

"@ -ReferencedAssemblies 'System.Windows.Forms.dll'


[scriptblock]$add_button_with_ref = {
  param(
    [System.Management.Automation.PSReference]$object_ref,
    [System.Management.Automation.PSReference]$result_ref,
    [int]$cnt # unused 
  )

  $debug = $false
  if ($DebugPreference -eq 'Continue') {
    Write-Host 'Object keys'
    Write-Host $object_ref.Value.Keys
    Write-Host 'Caller  keys'
    Write-Host $object_ref.Value.Values
  }
  $data = $object_ref.Value

  #  TODO: assert ?

  $local:b = $result_ref.Value 
  $local:b.BackColor = [System.Drawing.Color]::Silver
  $local:b.Dock = [System.Windows.Forms.DockStyle]::Top
  $local:b.FlatAppearance.BorderColor = [System.Drawing.Color]::DarkGray
  $local:b.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
  $local:b.Location = New-Object System.Drawing.Point (0,($global:button_panel_height * $data['cnt']))
  $local:b.Size = New-Object System.Drawing.Size ($global:button_panel_width,$global:button_panel_height)
  $local:b.TabIndex = 3
  $local:b.Name = $data['name']
  $local:b.Text = $data['text']
  $local:b.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
  $local:b.UseVisualStyleBackColor = $false
  $result_ref.Value = $local:b
}



$caller = New-Object -TypeName 'Win32Window' -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)

@( 'System.Drawing','System.Windows.Forms') | ForEach-Object { [void][System.Reflection.Assembly]::LoadWithPartialName($_) }

$f = New-Object -TypeName 'System.Windows.Forms.Form'
$f.Text = $title
$f.SuspendLayout()

$p = New-Object System.Windows.Forms.Panel
$m = New-Object System.Windows.Forms.Panel
$p_3 = New-Object System.Windows.Forms.Panel
$b_3_3 = New-Object System.Windows.Forms.Button
$b_3_2 = New-Object System.Windows.Forms.Button
$b_3_1 = New-Object System.Windows.Forms.Button
$g_3 = New-Object System.Windows.Forms.Button
$p_2 = New-Object System.Windows.Forms.Panel

$b_2_4 = New-Object System.Windows.Forms.Button
$b_2_3 = New-Object System.Windows.Forms.Button
$b_2_2 = New-Object System.Windows.Forms.Button
$b_2_1 = New-Object System.Windows.Forms.Button
$g_2 = New-Object System.Windows.Forms.Button
$p_1 = New-Object System.Windows.Forms.Panel
$b_1_2 = New-Object System.Windows.Forms.Button
$b_1_1 = New-Object System.Windows.Forms.Button
$g_1 = New-Object System.Windows.Forms.Button
$lblMenu = New-Object System.Windows.Forms.Label
$m.SuspendLayout()
$p_3.SuspendLayout()
$p_2.SuspendLayout()
$p_1.SuspendLayout()
$p.SuspendLayout()

#  Menu Panel
$m.Controls.AddRange(@( $p_3,$p_2,$p_1))
$m.Controls.Add($lblMenu)
$m.Dock = [System.Windows.Forms.DockStyle]::Left
$m.Location = New-Object System.Drawing.Point (0,0)
$m.Name = "pnlMenu"
$m.Size = New-Object System.Drawing.Size ($global:button_panel_width,449)
$m.TabIndex = 1

#  Menu 3 Panel
$p_3.Controls.AddRange(@( $b_3_3,$b_3_2,$b_3_1,$g_3))
$p_3.Dock = [System.Windows.Forms.DockStyle]::Top
$p_3.Location = New-Object System.Drawing.Point (0,231)
$p_3.Name = "p_3"
# $p_3.Size = New-Object System.Drawing.Size ($global:button_panel_width,109)
$p_3.TabIndex = 3

$global:menu3_buttons = 3
#  Menu 3 button 3
$b_3_3_data = @{ 'cnt' = 3; 'text' = 'Menu 3 Sub Menu 3'; 'name' = 'b_3_3'; }
  Invoke-Command $s -ArgumentList ([ref]$b_3_3_data),([ref]$b_3_3)
  $b_3_3_click = $b_3_3.add_Click
  $b_3_3_click.Invoke({

      param([object]$sender,[string]$message)
      $caller.Data = $sender.Text
      [System.Windows.Forms.MessageBox]::Show(('{0} clicked!' -f $sender.Text))
    })


#  Menu 3 button 2
$b_3_2_data = @{ 'cnt' = 2; 'text' = 'Menu 3 Sub Menu 2'; 'name' = 'b_3_2'; }
  Invoke-Command $s -ArgumentList ([ref]$b_3_2_data),([ref]$b_3_2)
  $b_3_2_click = $b_3_2.add_Click
  $b_3_2_click.Invoke({

      param([object]$sender,[string]$message)
      $caller.Data = $sender.Text
      [System.Windows.Forms.MessageBox]::Show(('{0} clicked!' -f $sender.Text))
    })


#  Menu 3 button 1
$b_3_1_data = @{ 'cnt' = 1; 'text' = 'Menu 3 Sub Menu 1'; 'name' = 'b_3_1'; }
  Invoke-Command $s -ArgumentList ([ref]$b_3_1_data),([ref]$b_3_1)
  $b_3_1_click = $b_3_1.add_Click
  $b_3_1_click.Invoke({

      param([object]$sender,[string]$message)
      $caller.Data = $sender.Text
      [System.Windows.Forms.MessageBox]::Show(('{0} clicked!' -f $sender.Text))
    })


#  Menu 3 button group
$g_3.BackColor = [System.Drawing.Color]::Gray
$g_3.Dock = [System.Windows.Forms.DockStyle]::Top
$g_3.FlatAppearance.BorderColor = [System.Drawing.Color]::Gray
$g_3.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$g_3.ImageAlign = [System.Drawing.ContentAlignment]::MiddleRight
$g_3.Location = New-Object System.Drawing.Point (0,0)
$g_3.Name = "g_3"
$g_3.Size = New-Object System.Drawing.Size ($global:button_panel_width,$global:button_panel_height)
$g_3.TabIndex = 0
$g_3.Text = "Menu Group 3"
$g_3.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
$g_3.UseVisualStyleBackColor = $false

$g_3_click = $g_3.add_Click
$g_3_click.Invoke({
    param(
      [object]$sender,
      [System.EventArgs]$eventargs
    )


    $ref_panel = ([ref]$p_3)
    $ref_button_menu_group = ([ref]$g_3)
    $num_buttons = $global:menu3_buttons + 1
    # use the current height of the element as indicator of its state.
    if ($ref_panel.Value.Height -eq $global:button_panel_height)
    {
      $ref_panel.Value.Height = ($global:button_panel_height * $num_buttons) + 2
      $ref_button_menu_group.Value.Image = New-Object System.Drawing.Bitmap ("C:\developer\sergueik\powershell_ui_samples\unfinished\up.png")
    }
    else
    {
      $ref_panel.Value.Height = $global:button_panel_height
      $ref_button_menu_group.Value.Image = New-Object System.Drawing.Bitmap ("C:\developer\sergueik\powershell_ui_samples\unfinished\down.png")
    }


  })

# Menu 2 Panel
$p_2.Controls.AddRange(@( $b_2_4,$b_2_3,$b_2_2,$b_2_1,$g_2))
$p_2.Dock = [System.Windows.Forms.DockStyle]::Top
$p_2.Location = New-Object System.Drawing.Point (0,127)
$p_2.Name = "p_2"
# $p_2.Size = New-Object System.Drawing.Size ($global:button_panel_widt,129)
$p_2.TabIndex = 2

# Menu 2 button 4
$b_2_4_data = @{ 'cnt' = 4; 'text' = 'Menu 2 Sub Menu 4'; 'name' = 'b_2_4'; }
  Invoke-Command $s -ArgumentList ([ref]$b_2_4_data),([ref]$b_2_4)
  $b_2_4_click = $b_2_4.add_Click
  $b_2_4_click.Invoke({

      param([object]$sender,[string]$message)
      $caller.Data = $sender.Text
      [System.Windows.Forms.MessageBox]::Show(('{0} clicked!' -f $sender.Text))
    })

# Menu 2 button 3
$b_2_3_data = @{ 'cnt' = 3; 'text' = 'Menu 2 Sub Menu 3'; 'name' = 'b_2_3'; }
  Invoke-Command $s -ArgumentList ([ref]$b_2_3_data),([ref]$b_2_3)
  $b_2_3_click = $b_2_3.add_Click
  $b_2_3_click.Invoke({

      param([object]$sender,[string]$message)
      $caller.Data = $sender.Text
      [System.Windows.Forms.MessageBox]::Show(('{0} clicked!' -f $sender.Text))
    })

# Menu 2 button 2
$b_2_2_data = @{ 'cnt' = 2; 'text' = 'Menu 2 Sub Menu 2'; 'name' = 'b_2_2'; }
  Invoke-Command $s -ArgumentList ([ref]$b_2_2_data),([ref]$b_2_2)
  $b_2_3_click = $b_2_2.add_Click
  $b_2_3_click.Invoke({

      param([object]$sender,[string]$message)
      $caller.Data = $sender.Text
      [System.Windows.Forms.MessageBox]::Show(('{0} clicked!' -f $sender.Text))
    })

# Menu 2 button 1
$b_2_1_data = @{ 'cnt' = 1; 'text' = 'Menu 2 Sub Menu 1'; 'name' = 'b_2_1'; }
  Invoke-Command $s -ArgumentList ([ref]$b_2_1_data),([ref]$b_2_1)
  $b_2_1_click = $b_2_1.add_Click
  $b_2_1_click.Invoke({

      param([object]$sender,[string]$message)
      $caller.Data = $sender.Text
      [System.Windows.Forms.MessageBox]::Show(('{0} clicked!' -f $sender.Text))
    })

#  Menu 2 button group
$g_2.BackColor = [System.Drawing.Color]::Gray
$g_2.Dock = [System.Windows.Forms.DockStyle]::Top
$g_2.FlatAppearance.BorderColor = [System.Drawing.Color]::Gray
$g_2.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$g_2.ImageAlign = [System.Drawing.ContentAlignment]::MiddleRight
$g_2.Location = New-Object System.Drawing.Point (0,0)
$g_2.Name = "g_2"
$g_2.Size = New-Object System.Drawing.Size ($global:button_panel_width,$global:button_panel_height)
$g_2.TabIndex = 0
$g_2.Text = "Menu Group 2"
$g_2.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
$g_2.UseVisualStyleBackColor = $false

$g_2_click = $g_2.add_Click
$g_2_click.Invoke({
    param(
      [object]$sender,
      [System.EventArgs]$eventargs
    )

    $ref_panel = ([ref]$p_2)
    $ref_button_menu_group = ([ref]$g_2)
    $num_buttons = 5
    # use the current height of the element as indicator of its state.
    if ($ref_panel.Value.Height -eq $global:button_panel_height)
    {
      $ref_panel.Value.Height = ($global:button_panel_height * $num_buttons) + 2
      $ref_button_menu_group.Value.Image = New-Object System.Drawing.Bitmap ("C:\developer\sergueik\powershell_ui_samples\unfinished\up.png")
    }
    else
    {
      $ref_panel.Value.Height = $global:button_panel_height
      $ref_button_menu_group.Value.Image = New-Object System.Drawing.Bitmap ("C:\developer\sergueik\powershell_ui_samples\unfinished\down.png")
    }


  })

#  Panel Menu 1
$p_1.Controls.AddRange(@( $b_1_2,$b_1_1,$g_1))
$p_1.Dock = [System.Windows.Forms.DockStyle]::Top
$p_1.Location = New-Object System.Drawing.Point (0,23)
$p_1.Name = "p_1"
$p_1.TabIndex = 1

# Menu 1 button 1
$b_1_1_data = @{ 'cnt' = 1; 'text' = 'Menu 1 Sub Menu 1'; 'name' = 'b_1_1'; }
  Invoke-Command $s -ArgumentList ([ref]$b_1_1_data),([ref]$b_1_1)
  $b_1_1_click = $b_1_1.add_Click
  $b_1_1_click.Invoke({

      param([object]$sender,[string]$message)
      $caller.Data = $sender.Text
      [System.Windows.Forms.MessageBox]::Show(('{0} clicked!' -f $sender.Text))
    })

#  Menu 1 button 2
$b_1_2_data = @{ 'cnt' = 2; 'text' = 'Menu 1 Sub Menu 2'; 'name' = 'b_1_2'; }
  Invoke-Command $s -ArgumentList ([ref]$b_1_2_data),([ref]$b_1_2)
  $b_1_2_click = $b_1_2.add_Click
  $b_1_2_click.Invoke({

      param([object]$sender,[string]$message)
      $caller.Data = $sender.Text
      [System.Windows.Forms.MessageBox]::Show(('{0} clicked!' -f $sender.Text))
    })


#  Menu 1 button group 
$g_1.BackColor = [System.Drawing.Color]::Gray
$g_1.Dock = [System.Windows.Forms.DockStyle]::Top
$g_1.FlatAppearance.BorderColor = [System.Drawing.Color]::Gray
$g_1.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$g_1.ImageAlign = [System.Drawing.ContentAlignment]::MiddleRight
$g_1.Location = New-Object System.Drawing.Point (0,0)
$g_1.Name = "g_1"
$g_1.Size = New-Object System.Drawing.Size ($global:button_panel_width,$global:button_panel_height)
$g_1.TabIndex = 0
$g_1.Text = "Menu Group 1"
$g_1.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
$g_1.UseVisualStyleBackColor = $false
$g_1_click = $g_1.add_Click
$g_1_click.Invoke({
    param(
      [object]$sender,
      [System.EventArgs]$eventargs
    )

    $ref_panel = ([ref]$p_1)
    $ref_button_menu_group = ([ref]$g_1)
    $num_buttons = 3
    # use the current height of the element as indicator of its state.
    if ($ref_panel.Value.Height -eq $global:button_panel_height)
    {
      $ref_panel.Value.Height = ($global:button_panel_height * $num_buttons) + 2
      $ref_button_menu_group.Value.Image = New-Object System.Drawing.Bitmap ("C:\developer\sergueik\powershell_ui_samples\unfinished\up.png")
    }
    else
    {
      $ref_panel.Value.Height = $global:button_panel_height
      $ref_button_menu_group.Value.Image = New-Object System.Drawing.Bitmap ("C:\developer\sergueik\powershell_ui_samples\unfinished\down.png")
    }
  })



#  
#  lblMenu
#  
$lblMenu.BackColor = [System.Drawing.Color]::DarkGray
$lblMenu.Dock = [System.Windows.Forms.DockStyle]::Top
$lblMenu.ForeColor = [System.Drawing.Color]::White
$lblMenu.Location = New-Object System.Drawing.Point (0,0)
$lblMenu.Name = "lblMenu"
$lblMenu.Size = New-Object System.Drawing.Size (200,23)
$lblMenu.TabIndex = 0
$lblMenu.Text = "Main Menu"
$lblMenu.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter


$p.ClientSize = New-Object System.Drawing.Size (200,449)
$p.Controls.Add($m)
$p_1.Height = $global:button_panel_height
$p_2.Height = $global:button_panel_height
$p_3.Height = $global:button_panel_height

$g_1.Image =
$g_2.Image =
$g_3.Image = New-Object System.Drawing.Bitmap ("C:\developer\sergueik\powershell_ui_samples\unfinished\down.png")

$m.ResumeLayout($false)
$p_3.ResumeLayout($false)
$p_2.ResumeLayout($false)
$p_1.ResumeLayout($false)
$p.ResumeLayout($false)


$f.Controls.Add($p)
#  Form1
$f.AutoScaleDimensions = New-Object System.Drawing.SizeF (6.0,13.0)
$f.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Font
$f.ClientSize = New-Object System.Drawing.Size (210,280)
$f.Controls.Add($c1)
$f.Controls.Add($p)
$f.Controls.Add($b1)
$f.Name = "Form1"
$f.Text = "ProgressCircle"
$f.ResumeLayout($false)

$f.Topmost = $True

$f.Add_Shown({ $f.Activate() })

[void]$f.ShowDialog([win32window]($caller))

$f.Dispose()

