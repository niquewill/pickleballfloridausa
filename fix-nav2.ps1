# fix-nav2.ps1
# Injects hamburger JS into all pages that are missing it
# Run from: C:\Users\edupg\Documents\pickleballfloridausa

$navJS = @'
<script>
(function() {
  var toggle = document.getElementById('navToggle');
  var menu = document.getElementById('mobileMenu');
  if (!toggle || !menu) return;
  toggle.addEventListener('click', function() {
    toggle.classList.toggle('open');
    menu.classList.toggle('open');
  });
  menu.querySelectorAll('a').forEach(function(link) {
    link.addEventListener('click', function() {
      toggle.classList.remove('open');
      menu.classList.remove('open');
    });
  });
})();
</script>
'@

$files = @(
  "pages\shop.html"
  "pages\gear.html"
  "pages\courts.html"
  "pages\learn.html"
  "pages\about.html"
  "pages\tournaments.html"
  "pages\blog.html"
)

foreach ($file in $files) {
  $content = Get-Content $file -Raw -Encoding UTF8

  # Only inject if the JS listener isn't already there
  if ($content -notmatch 'addEventListener.*click.*toggle\.classList') {
    Write-Host "Injecting JS into $file ..." -ForegroundColor Cyan
    $content = $content -replace '(</body>)', "$navJS`$1"
    [System.IO.File]::WriteAllText((Resolve-Path $file), $content, [System.Text.Encoding]::UTF8)
    Write-Host "  Done." -ForegroundColor Green
  } else {
    Write-Host "$file already has JS - skipping." -ForegroundColor Gray
  }
}

Write-Host ""
Write-Host "All done! Now run:" -ForegroundColor Cyan
Write-Host "  git add pages/" -ForegroundColor Yellow
Write-Host "  git commit -m 'Fix hamburger nav JS on all pages'" -ForegroundColor Yellow
Write-Host "  git push" -ForegroundColor Yellow