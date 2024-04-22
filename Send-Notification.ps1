function Show-Notification {
    [cmdletbinding()]
    Param (
        [string]$Title,
        [string]$Text,
        [string]$buttonText,
        [string]$buttonAction
    )

    $null = [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime]
    $null = [Windows.UI.Notifications.ToastNotification, Windows.UI.Notifications, ContentType = WindowsRuntime]
    $null = [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime]

$template = @"
<toast duration="long">
    <visual>
        <binding template="ToastGeneric">
            <text>$Title</text>
            <text>$Text</text>
        </binding>
    </visual>
    <actions>
        <action activationType="protocol" arguments="$buttonAction" content="$buttonText" />
    </actions>
</toast>
"@

    $AppID = "MSEdge"
    $xml = New-Object Windows.Data.Xml.Dom.XmlDocument
    $xml.LoadXml($template)
    $toast = New-Object Windows.UI.Notifications.ToastNotification $xml
    [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($AppID).Show($toast)
}

Show-Notification -Title "SENDER" -Text "MESSAGE" -buttonText "Click here" -buttonAction "https://www.google.com"
