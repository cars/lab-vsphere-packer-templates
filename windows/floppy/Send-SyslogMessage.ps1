function Send-SyslogMessage {

    [CMDLetBinding()]
    Param(
      [String] $Server,
      [Parameter(mandatory=$true)] [String] $Message,
      [String] $Hostname,
      [String] $Timestamp,
      [int] $UDPPort = 514
    )
    
    If ($PSBoundParameters.ContainsKey('Server')) {
        $SyslogServer = $Server
    } else {
         $SyslogServer= $ENV:SYSLOG_SERVER
    }

    # Create a UDP Client Object
    $UDPCLient = New-Object System.Net.Sockets.UdpClient
    $UDPCLient.Connect($SyslogServer, $UDPPort)

    # Evaluate the facility and severity based on the enum types
    $Facility_Number = 23
    $Severity_Number = 5

    # Calculate the priority
    $Priority = ($Facility_Number * 8) + $Severity_Number
    

    # If no hostname parameter specified, then set it
    if (($Hostname -eq "") -or ($Hostname -eq $null)){
      $Hostname = Hostname
    }

    # I the hostname hasn't been specified, then we will use the current date and time
    if (($Timestamp -eq "") -or ($Timestamp -eq $null)){
      $Timestamp = Get-Date -Format "yyyy:MM:dd:-HH:mm:ss zzz"
    }

    # Assemble the full syslog formatted message
    $FullSyslogMessage = "<{0}>{1} {2} {3}" -f $Priority, $Timestamp, $Hostname, $Message

    # create an ASCII Encoding object
    $Encoding = [System.Text.Encoding]::ASCII

    # Convert into byte array representation
    $ByteSyslogMessage = $Encoding.GetBytes($FullSyslogMessage)

    # If the message is too long, shorten it
    if ($ByteSyslogMessage.Length -gt 1024){
        $ByteSyslogMessage = $ByteSyslogMessage.SubString(0, 1024)
    }

    # Send the Message
    $UDPCLient.Send($ByteSyslogMessage, $ByteSyslogMessage.Length)

}