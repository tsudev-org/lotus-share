<#
.SYNOPSIS
  Lotus Share - chẩn đoán và sửa lỗi "các thiết bị không tìm thấy nhau" trên Windows.

.DESCRIPTION
  Kiểm tra lần lượt các nguyên nhân thường gặp khiến điện thoại và máy tính cùng mở Lotus Share nhưng không thấy nhau:
    1. Lotus Share có đang chạy và nghe cổng (mặc định 53317, TCP + UDP) không.
    2. Tường lửa Windows: có quy tắc CHO PHÉP chương trình chưa, có quy tắc CHẶN (Windows tự tạo khi bấm Hủy) không,
       chính sách nhóm có cấm quy tắc cục bộ không.
    3. Loại mạng: mạng "Công cộng" (Public) chặn kết nối đến nếu chưa có quy tắc.
    4. Card mạng: card ảo (WSL, Hyper-V, VirtualBox, VMware, Docker) và VPN đang bật.
    5. Quét mạng LAN (TCP cổng 53317 + /api/localsend/v2/info) tìm mọi thiết bị đang mở Lotus Share/LocalSend, đếm
       thiết bị thấy được qua bảng ARP để nhận ra bộ phát Wi-Fi "cách ly thiết bị" (client isolation).
    6. Không thấy ai: kết nối thử tới điện thoại theo địa chỉ IP hiện trên tab Nhận của điện thoại - phân biệt lỗi
       tường lửa máy này với lỗi mạng (Wi-Fi khách, cách ly thiết bị).
  Tìm thấy lỗi sửa được thì hỏi trước khi sửa; phần sửa cần quyền quản trị và tự xin quyền (UAC).

  Không gửi dữ liệu ra Internet. Chỉ kết nối tới địa chỉ IP trong mạng nội bộ do bạn nhập.

.PARAMETER Port
  Cổng của Lotus Share (Cài đặt > Mạng > Cổng). Mặc định 53317.

.PARAMETER Exe
  Đường dẫn lotus_share.exe. Mặc định: cùng thư mục với tệp này.

.PARAMETER PeerIp
  Địa chỉ IP của thiết bị kia để kết nối thử (bỏ trống thì hỏi).

.PARAMETER Fix
  Sửa ngay các lỗi tường lửa (dùng nội bộ khi tự nâng quyền).

.PARAMETER NoPause
  Không chờ bấm phím khi kết thúc (dùng trong kịch bản tự động).
#>
[CmdletBinding()]
param(
  [int]$Port = 53317,
  [string]$Exe = '',
  [string]$PeerIp = '',
  [switch]$Fix,
  [switch]$SetPrivate,
  [switch]$NoPause
)

$ErrorActionPreference = 'Continue'
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { }

$RuleName = 'Lotus Share'
if (-not $Exe) { $Exe = Join-Path $PSScriptRoot 'lotus_share.exe' }

$script:issues = New-Object System.Collections.Generic.List[string]
$script:fixFirewall = $false
$script:publicProfiles = @()

function Write-Ok([string]$m) { Write-Host "  [OK]   $m" -ForegroundColor Green }
function Write-Warn([string]$m) { Write-Host "  [!]    $m" -ForegroundColor Yellow; $script:issues.Add($m) }
function Write-Bad([string]$m) { Write-Host "  [LỖI]  $m" -ForegroundColor Red; $script:issues.Add($m) }
function Write-Info([string]$m) { Write-Host "         $m" -ForegroundColor Gray }
function Write-Step([string]$m) { Write-Host ''; Write-Host "== $m" -ForegroundColor Cyan }

function Test-Admin {
  $id = [Security.Principal.WindowsIdentity]::GetCurrent()
  return (New-Object Security.Principal.WindowsPrincipal $id).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Tên card mạng ảo/VPN - cùng danh sách với app/lib/provider/local_ip_provider.dart (isVirtualInterfaceName).
$VirtualPattern = '(?i)(^(docker|br-|veth|virbr|vmnet|vboxnet|tun|tap|wg|utun|ppp|zt|tailscale|ham)|vethernet|hyper-v|wsl|virtualbox|vmware|hamachi|radmin|zerotier|tailscale|wireguard|openvpn|nordlynx|vpn|bluetooth|npcap|loopback|pseudo)'

function Invoke-FirewallFix {
  if (-not (Test-Path $Exe)) {
    Write-Bad "Không thấy $Exe - không tạo được quy tắc theo chương trình."
    return
  }
  Write-Host "  Xóa quy tắc cũ gắn với $Exe (kể cả quy tắc Chặn)..."
  & netsh.exe advfirewall firewall delete rule name=all program="$Exe" | Out-Null
  foreach ($proto in 'TCP', 'UDP') {
    & netsh.exe advfirewall firewall add rule name="$RuleName" dir=in action=allow program="$Exe" protocol=$proto profile=any enable=yes | Out-Null
    if ($LASTEXITCODE -eq 0) { Write-Ok "Đã cho phép $proto đến cho Lotus Share (mọi loại mạng)." }
    else { Write-Bad "Không tạo được quy tắc $proto (mã $LASTEXITCODE)." }
  }
}

function Invoke-SetPrivate {
  foreach ($p in Get-NetConnectionProfile -ErrorAction SilentlyContinue) {
    if ($p.NetworkCategory -eq 'Public') {
      try {
        Set-NetConnectionProfile -InterfaceIndex $p.InterfaceIndex -NetworkCategory Private -ErrorAction Stop
        Write-Ok "Đã đổi mạng '$($p.Name)' ($($p.InterfaceAlias)) sang Riêng tư."
      } catch {
        Write-Bad "Không đổi được loại mạng '$($p.Name)': $($_.Exception.Message)"
      }
    }
  }
}

# Chế độ sửa (đã có quyền quản trị, gọi từ chính tệp này).
if ($Fix -or $SetPrivate) {
  Write-Host 'Lotus Share - sửa lỗi kết nối' -ForegroundColor Cyan
  if ($Fix) { Invoke-FirewallFix }
  if ($SetPrivate) { Invoke-SetPrivate }
  Write-Host ''
  Write-Host 'Xong. Mở lại Lotus Share trên cả hai thiết bị rồi bấm nút làm mới ở tab Gửi.' -ForegroundColor Cyan
  if (-not $NoPause) { Read-Host 'Bấm Enter để đóng' | Out-Null }
  exit 0
}

Write-Host 'Lotus Share - chẩn đoán kết nối mạng nội bộ' -ForegroundColor Cyan
Write-Host "Chương trình: $Exe"
Write-Host "Cổng: $Port"

# 1. Ứng dụng có chạy và nghe cổng không.
Write-Step '1. Lotus Share có đang chạy không'
$proc = Get-Process -Name 'lotus_share' -ErrorAction SilentlyContinue
if ($proc) { Write-Ok "Đang chạy (PID $(@($proc.Id) -join ', '))." }
else { Write-Warn 'Lotus Share chưa chạy. Mở ứng dụng trên máy này rồi chạy lại công cụ.' }

$tcp = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue
$udp = Get-NetUDPEndpoint -LocalPort $Port -ErrorAction SilentlyContinue
$owners = @(@($tcp) + @($udp) | Where-Object { $_ } | ForEach-Object { $_.OwningProcess } | Sort-Object -Unique)
if ($tcp) { Write-Ok "Có chương trình nghe TCP $Port." } else { Write-Bad "Không có chương trình nào nghe TCP $Port (máy chủ nhận tệp chưa bật hoặc đổi cổng)." }
if ($udp) { Write-Ok "Có chương trình nghe UDP $Port (khám phá thiết bị)." } else { Write-Bad "Không có chương trình nào nghe UDP $Port." }
foreach ($o in $owners) {
  $p = Get-Process -Id $o -ErrorAction SilentlyContinue
  if ($p -and $p.ProcessName -ne 'lotus_share') {
    Write-Warn "Cổng $Port đang bị '$($p.ProcessName)' (PID $o) dùng - có thể là LocalSend gốc. Hai ứng dụng cùng giao thức, chỉ mở một trong hai."
  }
}

# 2. Tường lửa.
Write-Step '2. Tường lửa Windows'
$fwProfiles = Get-NetFirewallProfile -PolicyStore ActiveStore -ErrorAction SilentlyContinue
foreach ($fp in $fwProfiles) {
  $state = if ($fp.Enabled) { 'BẬT' } else { 'tắt' }
  Write-Info "Hồ sơ $($fp.Name): $state, mặc định chiều vào: $($fp.DefaultInboundAction)"
  if ($fp.Enabled -and $fp.AllowLocalFirewallRules -eq 'False') {
    Write-Bad "Chính sách nhóm của tổ chức cấm quy tắc tường lửa cục bộ ở hồ sơ $($fp.Name). Nhờ quản trị mạng mở TCP/UDP $Port."
  }
}

$rules = @()
if (Test-Path $Exe) {
  $rules = @(Get-NetFirewallApplicationFilter -Program $Exe -ErrorAction SilentlyContinue | Get-NetFirewallRule -ErrorAction SilentlyContinue | Where-Object { $_.Direction -eq 'Inbound' })
} else {
  Write-Warn "Không thấy $Exe (bản di động ở thư mục khác?). Chạy lại với: -Exe 'đường\dẫn\lotus_share.exe'"
}
$portRules = @(Get-NetFirewallPortFilter -ErrorAction SilentlyContinue | Where-Object { $_.LocalPort -eq "$Port" } | Get-NetFirewallRule -ErrorAction SilentlyContinue | Where-Object { $_.Direction -eq 'Inbound' -and $_.Enabled -eq 'True' -and $_.Action -eq 'Allow' })

$blocks = @($rules | Where-Object { $_.Enabled -eq 'True' -and $_.Action -eq 'Block' })
$allows = @($rules | Where-Object { $_.Enabled -eq 'True' -and $_.Action -eq 'Allow' })
foreach ($r in $blocks) {
  Write-Bad "Quy tắc CHẶN '$($r.DisplayName)' (hồ sơ $($r.Profile)) - thường do bấm Hủy ở hộp thoại tường lửa. Quy tắc chặn thắng mọi quy tắc cho phép."
  $script:fixFirewall = $true
}
if ($allows.Count -gt 0) {
  foreach ($r in $allows) {
    $proto = (Get-NetFirewallPortFilter -AssociatedNetFirewallRule $r -ErrorAction SilentlyContinue).Protocol
    Write-Ok "Quy tắc cho phép '$($r.DisplayName)' ($proto, hồ sơ $($r.Profile))."
    if ($r.Profile -ne 'Any' -and "$($r.Profile)" -notmatch 'Public') {
      Write-Warn "Quy tắc '$($r.DisplayName)' không áp dụng cho mạng Công cộng."
      $script:fixFirewall = $true
    }
  }
} elseif ($portRules.Count -gt 0) {
  Write-Ok "Có quy tắc cho phép theo cổng $Port ($(@($portRules | ForEach-Object { $_.DisplayName } | Sort-Object -Unique) -join ', '))."
} else {
  Write-Bad 'Chưa có quy tắc cho phép Lotus Share nhận kết nối đến: điện thoại sẽ không thấy máy này.'
  $script:fixFirewall = $true
}

# 3. Loại mạng.
Write-Step '3. Loại mạng đang kết nối'
foreach ($p in Get-NetConnectionProfile -ErrorAction SilentlyContinue) {
  $line = "'$($p.Name)' qua $($p.InterfaceAlias): $($p.NetworkCategory)"
  if ($p.NetworkCategory -eq 'Public') {
    Write-Warn "$line (Công cộng). Ở nhà/văn phòng tin cậy nên đặt Riêng tư."
    $script:publicProfiles += $p
  } else { Write-Ok $line }
}

# 4. Card mạng.
Write-Step '4. Card mạng IPv4'
$configs = @(Get-NetIPConfiguration -ErrorAction SilentlyContinue | Where-Object { $_.IPv4Address -and $_.NetAdapter.Status -eq 'Up' })
$real = 0
foreach ($c in $configs) {
  $ip = @($c.IPv4Address | ForEach-Object { "$($_.IPAddress)/$($_.PrefixLength)" }) -join ', '
  $gw = if ($c.IPv4DefaultGateway) { " cổng mạng $($c.IPv4DefaultGateway.NextHop)" } else { '' }
  $desc = "$($c.InterfaceAlias) [$($c.InterfaceDescription)]"
  if ("$($c.InterfaceAlias) $($c.InterfaceDescription)" -match $VirtualPattern) {
    Write-Info "ảo/VPN: $desc - $ip$gw"
    if ("$($c.InterfaceDescription)" -match '(?i)vpn|wireguard|tailscale|zerotier|hamachi|radmin|openvpn|nordlynx' -and $c.IPv4DefaultGateway) {
      Write-Warn "VPN '$($c.InterfaceAlias)' đang giữ đường mặc định - có thể chặn mạng nội bộ. Tắt VPN hoặc bật 'cho phép truy cập LAN' rồi thử lại."
    }
  } else {
    $real++
    Write-Ok "$desc - $ip$gw"
    foreach ($a in $c.IPv4Address) {
      if ($a.IPAddress -like '169.254.*') { Write-Warn "$($c.InterfaceAlias) chỉ có địa chỉ 169.254.x.x (không nhận được IP từ bộ phát Wi-Fi)." }
    }
  }
}
if ($real -eq 0) { Write-Bad 'Không có card mạng thật nào đang kết nối (chỉ có card ảo/VPN). Kết nối Wi-Fi/Ethernet cùng mạng với điện thoại.' }
elseif ($real -gt 1) { Write-Info 'Có nhiều mạng thật cùng lúc: điện thoại phải ở cùng một trong các mạng trên.' }

# 5. Quét mạng tìm thiết bị đang mở Lotus Share / LocalSend (kết nối ĐI, không bị tường lửa máy này chặn).
function Get-PeerInfo([string]$ip) {
  foreach ($scheme in 'https', 'http') {
    try {
      $r = Invoke-RestMethod -Uri "${scheme}://${ip}:$Port/api/localsend/v2/info" -TimeoutSec 3 -ErrorAction Stop
      if ($r.alias) { return "$($r.alias) ($($r.deviceModel), $($r.deviceType), $scheme)" }
    } catch { }
  }
  return $null
}

function Test-Hosts([string[]]$ips, [int]$timeoutMs) {
  $pending = @()
  foreach ($ip in $ips) {
    $c = New-Object System.Net.Sockets.TcpClient
    try { $pending += [pscustomobject]@{ Ip = $ip; Client = $c; Ar = $c.BeginConnect($ip, $Port, $null, $null) } } catch { $c.Close() }
  }
  Start-Sleep -Milliseconds $timeoutMs
  $open = @()
  foreach ($x in $pending) {
    if ($x.Ar.IsCompleted -and $x.Client.Connected) { $open += $x.Ip }
    $x.Client.Close()
  }
  return $open
}

Write-Step '5. Quét mạng tìm thiết bị đang mở Lotus Share / LocalSend'
# Chứng thư của thiết bị là tự ký (định danh bằng dấu vân tay), chỉ đọc /info công khai nên bỏ kiểm chứng thư ở bước này.
try { [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true } } catch { }
try { [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12 } catch { }
$myIps = @()
foreach ($c in $configs) {
  if ("$($c.InterfaceAlias) $($c.InterfaceDescription)" -match $VirtualPattern) { continue }
  foreach ($a in $c.IPv4Address) { if ($a.IPAddress -notlike '169.254.*') { $myIps += $a.IPAddress } }
}
$found = 0
foreach ($me in $myIps) {
  $prefix = ($me -split '\.')[0..2] -join '.'
  Write-Info "Quét $prefix.1-254 cổng TCP $Port..."
  $targets = 1..254 | ForEach-Object { "$prefix.$_" } | Where-Object { $_ -ne $me }
  $open = Test-Hosts $targets 1500
  foreach ($ip in $open) {
    $info = Get-PeerInfo $ip
    if ($info) { Write-Ok "Thấy ${ip}: $info"; $found++ }
    else { Write-Info "${ip}:$Port mở nhưng không trả lời như Lotus Share/LocalSend." }
  }
  # Sau khi quét, bảng ARP cho biết máy này "thấy" bao nhiêu thiết bị cùng mạng. Chỉ thấy cổng mạng => bộ phát Wi-Fi
  # nhiều khả năng cách ly thiết bị (client isolation) - khi đó không ứng dụng chia sẻ nội bộ nào hoạt động được.
  $neighbors = @(Get-NetNeighbor -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object { $_.IPAddress -like "$prefix.*" -and $_.State -in 'Reachable', 'Stale', 'Delay', 'Probe' } | Select-Object -ExpandProperty IPAddress -Unique)
  if ($neighbors.Count -le 1) {
    Write-Warn "Mạng $prefix.x: máy này chỉ thấy $($neighbors.Count) thiết bị khác - bộ phát Wi-Fi có thể đang cách ly thiết bị."
  } else {
    Write-Info "Mạng $prefix.x không cách ly: máy này thấy $($neighbors.Count) thiết bị khác."
  }
}
if ($myIps.Count -gt 0 -and $found -eq 0) {
  Write-Warn 'Không thấy thiết bị nào khác đang mở Lotus Share/LocalSend trong mạng của máy này.'
  Write-Info 'Nếu điện thoại đang mở ứng dụng mà vẫn không thấy: điện thoại ở mạng khác (Wi-Fi khách, dữ liệu di động, Wi-Fi'
  Write-Info 'băng tần khác bị tách mạng) hoặc bộ phát Wi-Fi bật "cách ly thiết bị" (AP/client isolation, hay gặp ở Wi-Fi cơ quan,'
  Write-Info 'quán cà phê). Cách nhanh: bật điểm phát Wi-Fi trên điện thoại cho máy tính kết nối vào (hoặc ngược lại).'
}

# 6. Kết nối thử tới một địa chỉ cụ thể.
if ($found -eq 0) {
  Write-Step '6. Kết nối thử tới địa chỉ IP của điện thoại (tùy chọn)'
  if (-not $PeerIp -and -not $NoPause) {
    Write-Info 'Mở Lotus Share trên điện thoại, tab Nhận, bấm biểu tượng (i) để xem địa chỉ IP.'
    $PeerIp = Read-Host '  Nhập địa chỉ IP của điện thoại (Enter để bỏ qua)'
  }
  $PeerIp = "$PeerIp".Trim()
  if ($PeerIp -match '^\d{1,3}(\.\d{1,3}){3}$') {
    if (@(Test-Hosts @($PeerIp) 3000).Count -gt 0) {
      Write-Ok "Máy này kết nối được tới ${PeerIp}:$Port - mạng thông. $(Get-PeerInfo $PeerIp)"
      Write-Info 'Nếu điện thoại vẫn không thấy máy này thì nguyên nhân ở chiều ngược lại: tường lửa máy này (mục 2).'
      Write-Info 'Trên máy tính có thể bấm "Gửi tới địa chỉ IP" ở tab Gửi và nhập IP trên.'
    } else {
      Write-Bad "Không kết nối được tới ${PeerIp}:$Port."
      Write-Info 'Kiểm tra điện thoại đang mở Lotus Share, cùng mạng Wi-Fi, không phải Wi-Fi khách; bộ phát Wi-Fi không bật cách ly thiết bị.'
    }
  } elseif ($PeerIp) {
    Write-Warn "'$PeerIp' không phải địa chỉ IPv4 hợp lệ, bỏ qua bước này."
  }
}

# Tổng kết + đề nghị sửa.
Write-Step 'Kết quả'
if ($script:issues.Count -eq 0) {
  Write-Ok 'Không thấy lỗi trên máy này. Nếu vẫn không thấy nhau: kiểm tra điện thoại (quyền "Thiết bị ở gần"/"Mạng cục bộ", cùng Wi-Fi) và bộ phát Wi-Fi.'
} else {
  Write-Host "  Tìm thấy $($script:issues.Count) vấn đề." -ForegroundColor Yellow
}

$args2 = @()
if ($script:fixFirewall -and -not $NoPause) {
  $a = Read-Host '  Tạo quy tắc tường lửa cho Lotus Share và xóa quy tắc chặn? Cần quyền quản trị (C/k)'
  if ($a -eq '' -or $a -match '^(c|y)') { $args2 += '-Fix' }
}
if ($script:publicProfiles.Count -gt 0 -and -not $NoPause) {
  $a = Read-Host '  Đổi mạng Công cộng sang Riêng tư? Chỉ đồng ý nếu đây là mạng nhà/văn phòng tin cậy (c/K)'
  if ($a -match '^(c|y)') { $args2 += '-SetPrivate' }
}
if ($args2.Count -gt 0) {
  if (Test-Admin) {
    $local = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $PSCommandPath, '-Port', "$Port", '-Exe', $Exe) + $args2
    & powershell.exe @local
  } else {
    # Start-Process ghép ArgumentList thành một dòng lệnh: đường dẫn có dấu cách phải tự bọc nháy kép.
    $argList = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$PSCommandPath`"", '-Port', "$Port", '-Exe', "`"$Exe`"") + $args2
    try { Start-Process -FilePath 'powershell.exe' -ArgumentList $argList -Verb RunAs -Wait }
    catch { Write-Bad 'Không được cấp quyền quản trị, chưa sửa gì.' }
  }
}

if (-not $NoPause) { Read-Host 'Bấm Enter để đóng' | Out-Null }
if ($script:issues.Count -gt 0) { exit 1 } else { exit 0 }
