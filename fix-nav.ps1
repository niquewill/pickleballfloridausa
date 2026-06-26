# fix-nav.ps1
# Run from: C:\Users\edupg\Documents\pickleballfloridausa
# Usage: powershell -ExecutionPolicy Bypass -File fix-nav.ps1

$navCSS = @'
  /* ── HAMBURGER NAV ── */
  .nav-toggle { display: none; flex-direction: column; gap: 5px; background: none; border: none; cursor: pointer; padding: 4px; z-index: 200; }
  .nav-toggle span { display: block; width: 24px; height: 2px; background: #FFF7EB; border-radius: 2px; transition: transform 0.25s, opacity 0.25s; }
  .nav-toggle.open span:nth-child(1) { transform: translateY(7px) rotate(45deg); }
  .nav-toggle.open span:nth-child(2) { opacity: 0; }
  .nav-toggle.open span:nth-child(3) { transform: translateY(-7px) rotate(-45deg); }
  .mobile-menu { display: none; position: absolute; top: 100%; left: 0; right: 0; background: #16324F; border-top: 1px solid rgba(255,255,255,0.1); flex-direction: column; z-index: 100; padding: 1rem 0; }
  .mobile-menu.open { display: flex; }
  .mobile-menu a { color: #FFF7EB; text-decoration: none; font-size: 0.8rem; letter-spacing: 2px; text-transform: uppercase; opacity: 0.8; padding: 0.75rem 2.5rem; border-bottom: 1px solid rgba(255,255,255,0.05); }
  .mobile-menu a:last-child { border-bottom: none; }
  .mobile-menu a:hover, .mobile-menu a.active { opacity: 1; color: #2CCCD3; }
  @media (max-width: 900px) {
    .nav-links { display: none !important; }
    .nav-toggle { display: flex !important; }
    nav { padding: 1rem 1.5rem; }
  }
'@

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

# Each page: which link gets class="active"
$pages = @{
  "pages\about.html"       = "about.html"
  "pages\courts.html"      = "courts.html"
  "pages\gear.html"        = "gear.html"
  "pages\learn.html"       = "learn.html"
  "pages\shop.html"        = "shop.html"
  "pages\tournaments.html" = "tournaments.html"
}

foreach ($file in $pages.Keys) {
  $active = $pages[$file]
  Write-Host "Patching $file ..."

  $content = Get-Content $file -Raw -Encoding UTF8

  # 1. Inject CSS before </style> (first occurrence)
  if ($content -notmatch 'nav-toggle') {
    $content = $content -replace '(</style>)', "$navCSS`$1"
  }

  # 2. Add position:relative to nav if not present
  $content = $content -replace '(nav\s*\{)', '$1 position: relative;'

  # 3. Inject hamburger button + mobile menu after </nav> closing tag
  # Build the mobile menu with the correct active link
  $mobileLinks = @"
  <button class="nav-toggle" id="navToggle" aria-label="Toggle menu">
    <span></span><span></span><span></span>
  </button>
  <div class="mobile-menu" id="mobileMenu">
    <a href="../index.html">Home</a>
    <a href="shop.html"$(if($active -eq 'shop.html'){' class="active"'})>Shop</a>
    <a href="gear.html"$(if($active -eq 'gear.html'){' class="active"'})>Gear</a>
    <a href="courts.html"$(if($active -eq 'courts.html'){' class="active"'})>Courts</a>
    <a href="tournaments.html"$(if($active -eq 'tournaments.html'){' class="active"'})>Tournaments</a>
    <a href="blog.html"$(if($active -eq 'blog.html'){' class="active"'})>Blog</a>
    <a href="learn.html"$(if($active -eq 'learn.html'){' class="active"'})>Learn</a>
    <a href="about.html"$(if($active -eq 'about.html'){' class="active"'})>About</a>
  </div>
"@

  if ($content -notmatch 'mobileMenu') {
    # Insert button + mobile menu before closing </nav>
    $content = $content -replace '(</nav>)', "$mobileLinks`$1"
  }

  # 4. Inject JS before </body>
  if ($content -notmatch 'navToggle') {
    $content = $content -replace '(</body>)', "$navJS`$1"
  }

  # Write back
  [System.IO.File]::WriteAllText((Resolve-Path $file), $content, [System.Text.Encoding]::UTF8)
  Write-Host "  Done." -ForegroundColor Green
}

# 5. Fix blog.html breakpoint from 768px to 900px
Write-Host "Fixing blog.html breakpoint..."
$blog = Get-Content "pages\blog.html" -Raw -Encoding UTF8
$blog = $blog -replace 'max-width: 768px', 'max-width: 900px'
[System.IO.File]::WriteAllText((Resolve-Path "pages\blog.html"), $blog, [System.Text.Encoding]::UTF8)
Write-Host "  Done." -ForegroundColor Green

Write-Host ""
Write-Host "All pages patched! Now run:" -ForegroundColor Cyan
Write-Host "  git add pages/" -ForegroundColor Yellow
Write-Host "  git commit -m 'Hamburger nav on all pages, landscape fix'" -ForegroundColor Yellow
Write-Host "  git push" -ForegroundColor Yellow