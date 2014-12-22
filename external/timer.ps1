#Copyright (c) 2014 Serguei Kouzmine
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


# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed
function Get-ScriptDirectory
{
  $Invocation = (Get-Variable MyInvocation -Scope 1).Value;
  if ($Invocation.PSScriptRoot)
  {
    $Invocation.PSScriptRoot;
  }
  elseif ($Invocation.MyCommand.Path)
  {
    Split-Path $Invocation.MyCommand.Path
  }
  else
  {
    $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf("\"));
  }
}

$so = [hashtable]::Synchronized(@{
    'Result' = [string]'';
    'Visible' = [bool]$false;
    'ScriptDirectory' = [string]'';
    'Form' = [System.Windows.Forms.Form]$null;
    'Timer' = [System.Windows.Forms.Timer]$null;
  })

$so.ScriptDirectory = Get-ScriptDirectory

$rs = [runspacefactory]::CreateRunspace()
$rs.ApartmentState = 'STA'
$rs.ThreadOptions = 'ReuseThread'
$rs.Open()
$rs.SessionStateProxy.SetVariable('so',$so)

$run_script = [powershell]::Create().AddScript({

    # http://poshcode.org/1192
    function GenerateForm {
      param(
        [int]$timeout_sec
      )

      @( 'System.Drawing','System.Windows.Forms') | ForEach-Object { [void][System.Reflection.Assembly]::LoadWithPartialName($_) }

      $f = New-Object System.Windows.Forms.Form
      $f.MaximumSize = $f.MinimumSize = New-Object System.Drawing.Size (220,65)
      $so.Form = $f
      $f.Text = 'Timer'
      $f.Name = 'form_main'
      $f.ShowIcon = $False
      $f.StartPosition = 1
      $f.DataBindings.DefaultDataSourceUpdateMode = 0
      $f.ClientSize = New-Object System.Drawing.Size (($f.MinimumSize.Width - 10),($f.MinimumSize.Height - 10))

      $components = New-Object System.ComponentModel.Container
      $f.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Font
      $f.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedToolWindow
      $f.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen

      $f.SuspendLayout()

      $r = New-Object System.Windows.Forms.Button
      $l = New-Object System.Windows.Forms.Label
      $t = New-Object System.Windows.Forms.Timer
      $so.Timer = $t
      $p = New-Object System.Windows.Forms.ProgressBar
      $p.DataBindings.DefaultDataSourceUpdateMode = 0
      $p.Maximum = $timeout_sec
      $p.Size = New-Object System.Drawing.Size (($f.ClientSize.Width-10),($f.ClientSize.Height-14))
      $p.Step = 1
      $p.TabIndex = 0
      $p.Location = New-Object System.Drawing.Point (5,5)
      $p.Style = 1
      $p.Name = 'progressBar1'

      $InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState

      $s = New-Object System.Windows.Forms.Button

      function start_timer {

        $t.Enabled = $true
        $t.Start()

      }

      $s_response = $s.add_click
      $s_Response.Invoke({
          param(
            [object]$sender,
            [System.EventArgs]$eventargs
          )
          $s.Text = 'Countdown Started.'
          start_timer ($sender,$eventargs)
        })

      function reset_timer {

        $t.Enabled = $false
        $p.Value = 0

      }

      $r_response = $r.add_click
      $r_Response.Invoke({
          param(
            [object]$sender,
            [System.EventArgs]$eventargs
          )
          reset_timer
          $s.Text = 'Start'
          $elapsed = New-TimeSpan -Seconds ($p.Maximum - $p.Value)
          $f.Text = $l.Text = ('{0:00}:{1:00}:{2:00}' -f $elapsed.Hours,$elapsed.Minutes,$elapsed.Seconds)

        })

      $t_OnTick = {
        $p.PerformStep()

        $time = $p.Maximum - $p.Value
        [char[]]$mins = "{0}" -f ($time / 60)
        $secs = "{0:00}" -f ($time % 60)

        $elapsed = New-TimeSpan -Seconds ($p.Maximum - $p.Value)
        $f.Text = $l.Text = ('{0:00}:{1:00}:{2:00}' -f $elapsed.Hours,$elapsed.Minutes,$elapsed.Seconds)


        if ($p.Value -eq $p.Maximum) {
          $t.Enabled = $false
          $s.Text = 'FINISHED!'
          $f.Close()
        }
      }

      $OnLoadForm_StateCorrection = {
        # Correct the initial state of the form to prevent the .Net maximized form issue
        $f.WindowState = $InitialFormWindowState
        $t.Start()

      }


      $r.TabIndex = 4
      $r.Name = 'button2'
      $r.Size = New-Object System.Drawing.Size (209,69)
      $r.UseVisualStyleBackColor = $True

      $r.Text = 'Reset'
      $r.Font = New-Object System.Drawing.Font ('Verdana',12,0,3,0)

      $r.Location = New-Object System.Drawing.Point (362,13)
      $r.DataBindings.DefaultDataSourceUpdateMode = 0
      $r.add_click($r_OnClick)

      # $f.Controls.Add($r)

      $l.TabIndex = 3
      $l.TextAlign = 32
      $l.Size = New-Object System.Drawing.Size (526,54)
      $elapsed = New-TimeSpan -Seconds ($p.Maximum - $p.Value)
      $f.Text = $l.Text = ('{0:00}:{1:00}:{2:00}' -f $elapsed.Hours,$elapsed.Minutes,$elapsed.Seconds)
      # $l.Font = New-Object System.Drawing.Font ("Courier New",20.25,1,3,0)
      $l.Font = New-Object System.Drawing.Font ('Arial',9.25,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,[System.Byte]0);
      $l.Location = New-Object System.Drawing.Point (45,89)
      # http://www.codeproject.com/Articles/31406/Add-the-Percent-or-Any-Text-into-a-Standard-Progre
      $l.Location = New-Object System.Drawing.Point (45,146)
      $l.DataBindings.DefaultDataSourceUpdateMode = 0
      $l.Name = 'label1'

      $f.Controls.Add($l)

      $s.TabIndex = 2
      $s.Name = 'button1'
      $s.Size = New-Object System.Drawing.Size (310,70)
      $s.UseVisualStyleBackColor = $True

      $s.Text = 'Start'
      $s.Font = New-Object System.Drawing.Font ("Verdana",12,0,3,0)

      $s.Location = New-Object System.Drawing.Point (45,12)
      $s.DataBindings.DefaultDataSourceUpdateMode = 0
      $s.add_click($s_OnClick)

      # $f.Controls.Add($s) 

      $f.Controls.Add($p)

      $t.Interval = 1000
      $t.add_tick($t_OnTick)

      $InitialFormWindowState = $f.WindowState
      $f.add_Load($OnLoadForm_StateCorrection)
      [void]$f.ShowDialog()

    }

    #Call the Function
    GenerateForm -timeout_sec 15


  })

Clear-Host
$run_script.Runspace = $rs

$handle = $run_script.BeginInvoke()
foreach ($cnt in @( 1,2,3,5,6,8,9,10)) {
  Write-Output ('Doing lengthy work step {0}' -f $cnt )
  Start-Sleep -Millisecond 1000
}
Write-Output 'Work done'
while (-not $handle.IsCompleted) {
  Write-Output 'waiting on timer to finish'
  Start-Sleep -Milliseconds 1000
}
$run_script.EndInvoke($handle)
$rs.Close()
return
