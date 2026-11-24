Add-Type -AssemblyName System.Drawing

$src = 'c:\Users\Lenovo\develop\Nongki\assets\logo\logo_icon.png'
$base = 'c:\Users\Lenovo\develop\Nongki\android\app\src\main\res'

$sizes = @(
    @{ dir = 'mipmap-mdpi';    size = 48  },
    @{ dir = 'mipmap-hdpi';    size = 72  },
    @{ dir = 'mipmap-xhdpi';   size = 96  },
    @{ dir = 'mipmap-xxhdpi';  size = 144 },
    @{ dir = 'mipmap-xxxhdpi'; size = 192 }
)

$original = [System.Drawing.Image]::FromFile($src)

foreach ($entry in $sizes) {
    $dir  = Join-Path $base $entry.dir
    $size = $entry.size

    # ic_launcher.png
    $bmp = New-Object System.Drawing.Bitmap($size, $size)
    $g   = [System.Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.DrawImage($original, 0, 0, $size, $size)
    $g.Dispose()
    $bmp.Save((Join-Path $dir 'ic_launcher.png'), [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()

    # ic_launcher_round.png (same image, Android clips it to circle)
    $bmp2 = New-Object System.Drawing.Bitmap($size, $size)
    $g2   = [System.Drawing.Graphics]::FromImage($bmp2)
    $g2.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g2.DrawImage($original, 0, 0, $size, $size)
    $g2.Dispose()
    $bmp2.Save((Join-Path $dir 'ic_launcher_round.png'), [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp2.Dispose()

    # ic_launcher_foreground.png
    $bmp3 = New-Object System.Drawing.Bitmap($size, $size)
    $g3   = [System.Drawing.Graphics]::FromImage($bmp3)
    $g3.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g3.DrawImage($original, 0, 0, $size, $size)
    $g3.Dispose()
    $bmp3.Save((Join-Path $dir 'ic_launcher_foreground.png'), [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp3.Dispose()

    Write-Output "[OK] $($entry.dir) - ${size}x${size}px"
}

$original.Dispose()
Write-Output ""
Write-Output "Semua mipmap berhasil digenerate dari logo_icon.png!"
