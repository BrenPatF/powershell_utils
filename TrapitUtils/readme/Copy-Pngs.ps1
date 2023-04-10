$pngs = @("mountains.png",
		  "Math Function UT DP - HL Flow.png",
		  "MFUTDP - Flow-Ext.png",
		  "powershell_utils-JSD-HW.png",
		  "groups - helloworld.png",
		  "CSD-HW.png",
		  "scenarios - helloworld.png",
		  "powershell_utils-JSD-CG.png",
		  "groups - colgroup.png",
		  "CSD-CG.png",
		  "scenarios - colgroup.png",
		  "powershell_utils-JSD-UT.png",
		  "groups - ut.png",
		  "CSD-UT.png",
		  "scenarios - ut.png",
		  "folders.png")
$gh_path = "C:\Users\Brend\OneDrive\Documents\GitHub\powershell_utils\TrapitUtils\png"
$pngs | %{Copy-Item $_ $gh_path}