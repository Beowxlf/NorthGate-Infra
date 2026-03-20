$ErrorActionPreference = 'Stop'
& "$env:SystemRoot\System32\Sysprep\Sysprep.exe" /oobe /generalize /shutdown /mode:vm
