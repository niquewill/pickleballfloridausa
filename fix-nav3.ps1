# fix-nav3.ps1
# Fixes hamburger nav on index.html and blog.html
# Run from: C:\Users\edupg\Documents\pickleballfloridausa

$navCSS = @'
  .nav-toggle { display: none; flex-direction: column; gap: 5px; background: none; border: none; cursor: pointer; padding: 4px; z-index: 200; }
  .nav-toggle span { display: block; width: 24px; height: 2px; background: #FFF7EB; border-radius: 2px; transition: transform 0.25s, opacity 0.25s; }
  .nav-toggle.open span:nth-child(1) { transform: translateY(7px) rotate(45deg); }
  .nav-toggle.open span:nth-child(2) { opacity: 0; }
  .nav-toggle.open span:nth-child(3) { transform: translateY(-7px) rotate(-45deg); }
  .mobile-menu { display: none; position: absolute; top: 100%; left: 0; right: 0; background: #16324F; border-top: 1px solid rgba(255,255,255,0.1); flex-direction: column; z-index: 100; padding: 1rem 0; }
  .mobile-menu.open { display: flex; }
  .mobile-menu a { color: #FFF7EB; text-decoration: none; font-size: 0.8rem; letter-spacing: 2px; text-transform: uppercase; opacity: 0.8; padding: 0.75rem 2.5rem; border-bottom: 1px solid rgba(255,255,255,0.05); }
  .mobile-menu a:last-child { border-bottom: none; }
  .mobile-menu a:hover { opacity: 1; color: #2CCCD3; }
  @media (max-width: 900px) {
    .nav-links { display: none !important; }
    .nav-right { display: none !important; }
    .nav-toggle { display: flex !important; }
    nav { padding: 1rem 1.5rem; position: relative; }
  }
'@

$navButton = @'
  <button class="nav-toggle" id="navToggle" aria-label="Toggle menu">
    <span></span><span></span><span></span>
  </button>
  <div class="mobile-menu" id="mobileMenu">
    <a href="pages/shop.html">Shop</a>
    <a href="pages/gear.html">Gear</a>
    <a href="pages/courts.html">Courts</a>
    <a href="pages/tournaments.html">Tournaments</a>
    <a href="pages/blog.html">Blog</a>
    <a href="pages/learn.html">Learn</a>
    <a href="pages/about.html">About</a>
  </div>
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

# ── FIX INDEX.HTML ──
Write-Host "Patching index.html..." -ForegroundColor Cyan
$index = Get-Content "index.html" -Raw -Encoding UTF8

# Inject CSS before </style>
if ($index -notmatch 'nav-toggle') {
  $index = $index -replace '(</style>)', "$navCSS`$1"
}

# Inject button + mobile menu before closing </nav>
if ($index -notmatch 'mobileMenu') {
  $index = $index -replace '(</nav>)', "$navButton`$1"
}

# Inject JS before </body>
if ($index -notmatch 'toggle\.classList\.toggle') {
  $index = $index -replace '(</body>)', "$navJS`$1"
}

[System.IO.File]::WriteAllText((Resolve-Path "index.html"), $index, [System.Text.Encoding]::UTF8)
Write-Host "  Done." -ForegroundColor Green

# ── FIX BLOG.HTML ──
# Blog has the JS and button but something's broken - rebuild the nav block cleanly
Write-Host "Patching pages\blog.html..." -ForegroundColor Cyan
$blog = Get-Content "pages\blog.html" -Raw -Encoding UTF8

# Fix breakpoint
$blog = $blog -replace 'max-width:\s*768px', 'max-width: 900px'

# Make sure nav has position:relative
$blog = $blog -replace '(nav\s*\{)([^}]*?\})', {
  $match = $args[0]
  if ($match.Value -notmatch 'position') {
    $match.Value -replace '(\})', ' position: relative; }'
  } else {
    $match.Value
  }
}

[System.IO.File]::WriteAllText((Resolve-Path "pages\blog.html"), $blog, [System.Text.Encoding]::UTF8)
Write-Host "  Done." -ForegroundColor Green

Write-Host ""
Write-Host "All done! Now run:" -ForegroundColor Cyan
Write-Host "  git add index.html pages/blog.html" -ForegroundColor Yellow
Write-Host "  git commit -m 'Hamburger nav on index and blog fix'" -ForegroundColor Yellow
Write-Host "  git push" -ForegroundColor Yellow