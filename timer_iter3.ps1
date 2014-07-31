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
Add-Type -TypeDefinition @"


/*
Professional Windows GUI Programming Using C#
by Jay Glynn, Csaba Torok, Richard Conway, Wahid Choudhury, 
   Zach Greenvoss, Shripad Kulkarni, Neil Whitlow

Publisher: Peer Information
ISBN: 1861007663
*/
using System;
using System.Drawing;
using System.Collections;
using System.ComponentModel;
using System.Windows.Forms;
using System.Data;

namespace MyClock
{
    /// <summary>
    /// Summary description for MyClockForm.
    /// </summary>
    public class MyClockForm : System.Windows.Forms.Form
    {
        private IWin32Window caller = null ; 

        public System.Timers.Timer timer1;
        private System.Windows.Forms.Label label1;
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.Container components = null;

        public MyClockForm()
        {
            //
            // Required for Windows Form Designer support
            //

            InitializeComponent();

            //
            // TODO: Add any constructor code after InitializeComponent call
            //
        }

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        protected override void Dispose( bool disposing )
        {
            if( disposing )
            {
                if (components != null) 
                {
                    components.Dispose();
                }
            }
            base.Dispose( disposing );
        }

        #region Windows Form Designer generated code
        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
         this.timer1 = new System.Timers.Timer();
         this.label1 = new System.Windows.Forms.Label();
         ((System.ComponentModel.ISupportInitialize)(this.timer1)).BeginInit();
         this.SuspendLayout();
         // 
         // timer1
         // 
         this.timer1.Enabled = true;
         this.timer1.SynchronizingObject = this;
         this.timer1.Elapsed += new System.Timers.ElapsedEventHandler(this.OnTimerElapsed);
         // 
         // label1
         // 
         this.label1.Font = new System.Drawing.Font("Microsoft Sans Serif", 14.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((System.Byte)(0)));
         this.label1.ForeColor = System.Drawing.SystemColors.Highlight;
         this.label1.Location = new System.Drawing.Point(24, 8);
         this.label1.Name = "label1";
         this.label1.Size = new System.Drawing.Size(224, 48);
         this.label1.TabIndex = 0;
         this.label1.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
         // 
         // MyClockForm
         // 
         this.AutoScaleBaseSize = new System.Drawing.Size(5, 13);
         this.ClientSize = new System.Drawing.Size(292, 69);
         this.Controls.AddRange(new System.Windows.Forms.Control[] {
                                                                      this.label1});
         this.Name = "MyClockForm";
         
         this.Text = "My Clock";
         this.Load += new System.EventHandler(this.MyClockForm_Load);
         ((System.ComponentModel.ISupportInitialize)(this.timer1)).EndInit();
         this.ResumeLayout(false);

      }
        #endregion

        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main() 
        {
            Application.Run(new MyClockForm());
        }

        private void MyClockForm_Load(object sender, System.EventArgs e)
        {
            // Set the interval time ( 1000 ms == 1 sec )
            // after which the timer function is activated
            timer1.Interval = 1000 ;
            // Start the Timer
            timer1.Start();
            // Enable the timer. The timer starts now
            timer1.Enabled = true ; 
            if (caller != null){
               Console.WriteLine( caller.ToString()); 
            }
        }

        private void OnTimerElapsed(object sender, System.Timers.ElapsedEventArgs e)
        {
            // The interval has elapsed and this timer function is called after 1 second
            // Update the time now.
            label1.Text = DateTime.Now.ToString();
            
            label1.Text = String.Format("My Clock {0} {1}", caller.ToString(), caller.GetHashCode() );

        }


    public new DialogResult ShowDialog(IWin32Window caller){
        this.caller = caller ; 
        return base.ShowDialog(caller); 
    }
    }
}

"@ -ReferencedAssemblies 'System.Windows.Forms.dll', 'System.Drawing.dll', 'System.Data.dll', 'System.ComponentModel.dll'

Add-Type -TypeDefinition @"
using System;
using System.Windows.Forms;
public class Win32Window : IWin32Window
{
    private IntPtr _hWnd;
    private int _data;
    private string _message;

    public int Data
    {
        get { return _data; }
        set { _data = value; }
    }
    public string Message
    {
        get { return _message; }
        set { _message = value; }
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


function promptForContinueAuto(
	[Object] $caller= $null
	)
{

$f = New-Object System.Windows.Forms.Form 
$f.Text = $title

$timer1 = new-object System.Timers.Timer
$label1 = new-object System.Windows.Forms.Label

$f.SuspendLayout()
$components = new-object System.ComponentModel.Container 
$label1.Font = new-object System.Drawing.Font("Microsoft Sans Serif", 14.25, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Point, [System.Byte]0);
$label1.ForeColor = [System.Drawing.SystemColors]::Highlight
$label1.Location = new-object System.Drawing.Point(24, 8)
$label1.Name = "label1"
$label1.Size = new-object System.Drawing.Size(224, 48) 
$label1.TabIndex = 0
$label1.Text = [System.DateTime]::Now.ToString()
$label1.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter


$f.AutoScaleBaseSize = new-object System.Drawing.Size(5, 13)
$f.ClientSize = new-object System.Drawing.Size(292, 69) 
$f.Controls.AddRange(@( $label1))
$f.Name = 'MyClockForm';
$f.Text = 'My Clock';

# This was added - it does not belong to the original Form
$eventMethod=$label1.add_click
$eventMethod.Invoke({$f.Text="You clicked my label $((Get-Date).ToString('G'))"})

# This silently ceases to work 
$f.Add_Load({
  param ([Object] $sender, [System.EventArgs] $eventArgs )
    $timer1.Interval = 1000 
    $timer1.Start()
    $timer1.Enabled = $true

}) 

$timer1.Add_Elapsed({
     $label1.Text = [System.DateTime]::Now.ToString()
})

# This loudly ceases to start the timer "theTimer"
$global:timer = New-Object System.Timers.Timer
$global:timer.Interval = 1000
Register-ObjectEvent -InputObject $global:timer -EventName Elapsed -SourceIdentifier theTimer -Action {AddToLog('') }
$global:timer.Start()
$global:timer.Enabled = $true


function AddToLog()
{
param ([string] $text )

     $label1.Text = [System.DateTime]::Now.ToString()
}

$f.ResumeLayout($false)
$f.Topmost = $True

$caller = New-Object Win32Window -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)

$f.Add_Shown( { $f.Activate() } )

[void] $f.ShowDialog([Win32Window ] ($caller) )


}

promptForContinueAuto