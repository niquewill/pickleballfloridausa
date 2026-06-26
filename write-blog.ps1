# write-blog.ps1
# Writes a clean blog.html directly to pages\blog.html
# Run from: C:\Users\edupg\Documents\pickleballfloridausa

$html = @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>The Coastal Circle Chronicles - Florida Pickleball Lifestyle Blog | Pickleball Florida USA</title>
<meta name="description" content="The Coastal Circle Chronicles - a Florida pickleball lifestyle blog following four women from Palm Beach, Naples, The Villages, and Sarasota." />
<link rel="canonical" href="https://pickleballfloridausa.com/pages/blog.html" />
<link rel="icon" type="image/x-icon" href="../images/pfufavicon.ico">
<link rel="preconnect" href="https://fonts.googleapis.com" />
<link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,400;0,700;1,400&family=Montserrat:wght@300;400;500&display=swap" rel="stylesheet" />
<style>
* { margin: 0; padding: 0; box-sizing: border-box; }
:root { --coral: #FF6F61; --turquoise: #2CCCD3; --green: #2E8B57; --cream: #FFF7EB; --navy: #16324F; }
body { font-family: 'Montserrat', sans-serif; background: var(--cream); color: var(--navy); overflow-x: hidden; }
nav { background: var(--navy); padding: 1.2rem 2.5rem; display: flex; justify-content: space-between; align-items: center; position: relative; }
.logo-text { font-family: 'Playfair Display', serif; font-size: 1.3rem; color: var(--cream); letter-spacing: 1px; text-decoration: none; }
.logo-sub { font-size: 0.6rem; color: var(--turquoise); letter-spacing: 4px; text-transform: uppercase; display: block; margin-top: 2px; }
.nav-links { display: flex; gap: 2rem; }
.nav-links a { color: var(--cream); text-decoration: none; font-size: 0.75rem; letter-spacing: 2px; text-transform: uppercase; opacity: 0.8; }
.nav-links a:hover, .nav-links a.active { opacity: 1; color: var(--turquoise); }
.nav-toggle { display: none; flex-direction: column; gap: 5px; background: none; border: none; cursor: pointer; padding: 4px; z-index: 200; }
.nav-toggle span { display: block; width: 24px; height: 2px; background: var(--cream); border-radius: 2px; transition: transform 0.25s, opacity 0.25s; }
.nav-toggle.open span:nth-child(1) { transform: translateY(7px) rotate(45deg); }
.nav-toggle.open span:nth-child(2) { opacity: 0; }
.nav-toggle.open span:nth-child(3) { transform: translateY(-7px) rotate(-45deg); }
.mobile-menu { display: none; position: absolute; top: 100%; left: 0; right: 0; background: var(--navy); border-top: 1px solid rgba(255,255,255,0.1); flex-direction: column; z-index: 100; padding: 1rem 0; }
.mobile-menu.open { display: flex; }
.mobile-menu a { color: var(--cream); text-decoration: none; font-size: 0.8rem; letter-spacing: 2px; text-transform: uppercase; opacity: 0.8; padding: 0.75rem 2.5rem; border-bottom: 1px solid rgba(255,255,255,0.05); }
.mobile-menu a:last-child { border-bottom: none; }
.mobile-menu a:hover, .mobile-menu a.active { opacity: 1; color: var(--turquoise); }
.blog-hero { background: var(--navy); padding: 4rem 2.5rem; text-align: center; }
.blog-hero-eyebrow { font-size: 0.7rem; letter-spacing: 5px; text-transform: uppercase; color: var(--turquoise); margin-bottom: 1rem; }
.blog-hero h1 { font-family: 'Playfair Display', serif; font-size: 3rem; color: var(--cream); font-weight: 400; margin-bottom: 1rem; line-height: 1.2; }
.blog-hero h1 em { font-style: italic; color: var(--coral); }
.blog-hero-desc { color: var(--cream); opacity: 0.7; font-size: 0.9rem; max-width: 600px; margin: 0 auto; line-height: 1.8; font-weight: 300; }
.wave { display: block; background: var(--navy); line-height: 0; }
.wave svg { display: block; width: 100%; }
.intro-section { max-width: 1100px; margin: 0 auto; padding: 2.5rem 2.5rem 0; }
.intro-section p { font-size: 0.88rem; line-height: 1.9; color: var(--navy); opacity: 0.8; font-weight: 300; }
.writers-strip { background: #fff; padding: 3rem 2.5rem; text-align: center; border-bottom: 1px solid rgba(22,50,79,0.08); }
.writers-strip > p { font-size: 0.65rem; letter-spacing: 5px; text-transform: uppercase; color: var(--turquoise); margin-bottom: 2rem; }
.writers-grid { display: flex; justify-content: center; gap: 3rem; flex-wrap: wrap; }
.writer-pill { display: flex; flex-direction: column; align-items: center; gap: 0.5rem; cursor: pointer; transition: transform 0.2s; }
.writer-pill:hover { transform: translateY(-3px); }
.writer-avatar { width: 120px; height: 120px; border-radius: 50%; border: 3px solid transparent; transition: border-color 0.2s; overflow: hidden; }
.writer-pill:hover .writer-avatar { border-color: var(--coral); }
.writer-name { font-family: 'Playfair Display', serif; font-size: 0.9rem; color: var(--navy); font-weight: 400; }
.writer-location { font-size: 0.65rem; letter-spacing: 2px; text-transform: uppercase; color: var(--turquoise); }
#persona-overlay { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.55); z-index: 9999; align-items: center; justify-content: center; }
.modal-box { background: white; border-radius: 16px; width: 500px; max-width: 94vw; max-height: 90vh; overflow-y: auto; position: relative; }
.modal-header { padding: 1.5rem; display: flex; gap: 16px; align-items: center; border-bottom: 1px solid #f0f0f0; position: relative; }
.modal-header img { width: 72px; height: 72px; border-radius: 50%; object-fit: cover; border: 2px solid #f0f0f0; flex-shrink: 0; }
.modal-header-text { flex: 1; }
.modal-header-text h3 { font-family: 'Playfair Display', serif; font-size: 1.1rem; font-weight: 400; color: #1a1a1a; margin: 0 0 3px; }
.modal-header-text .m-sub { font-size: 12px; color: #888; margin: 0 0 4px; }
.modal-header-text .m-hood { font-size: 12px; color: #2a7a5a; margin: 0; font-weight: 500; }
.modal-close { position: absolute; top: 1rem; right: 1rem; background: none; border: none; font-size: 22px; cursor: pointer; color: #aaa; line-height: 1; padding: 4px 8px; }
.modal-body { padding: 1.25rem 1.5rem; }
.stat-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; margin-bottom: 1.25rem; }
.stat-box { background: #f8f8f6; border-radius: 8px; padding: 10px 12px; }
.stat-label { font-size: 10px; color: #999; text-transform: uppercase; letter-spacing: 0.05em; margin: 0 0 3px; }
.stat-val { font-size: 14px; font-weight: 600; margin: 0; color: #1a1a1a; }
.modal-section-label { font-size: 10px; color: #999; text-transform: uppercase; letter-spacing: 0.06em; margin: 0 0 8px; }
.pill-row { display: flex; flex-wrap: wrap; gap: 6px; margin-bottom: 1.25rem; }
.pill { font-size: 12px; padding: 3px 10px; border-radius: 999px; border: 1px solid #e8e8e8; color: #666; background: #f8f8f6; }
.modal-quote { font-size: 13px; color: #666; border-left: 2px solid #ddd; padding-left: 12px; margin: 0; line-height: 1.65; font-style: italic; font-family: 'Playfair Display', serif; }
.blog-section { max-width: 1100px; margin: 0 auto; padding: 4rem 2.5rem; }
.blog-section-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 3rem; flex-wrap: wrap; gap: 1rem; }
.blog-section-header h2 { font-family: 'Playfair Display', serif; font-size: 1.8rem; font-weight: 400; color: var(--navy); }
.blog-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(460px, 1fr)); gap: 2rem; }
.blog-card { background: #fff; border-radius: 4px; overflow: hidden; border: 1px solid rgba(22,50,79,0.08); transition: transform 0.2s, box-shadow 0.2s; }
.blog-card:hover { transform: translateY(-4px); box-shadow: 0 12px 40px rgba(22,50,79,0.1); }
.blog-card-header { padding: 1.5rem 2rem 0; display: flex; align-items: center; gap: 1rem; }
.card-avatar { width: 48px; height: 48px; border-radius: 50%; overflow: hidden; flex-shrink: 0; }
.card-avatar img { width: 100%; height: 100%; object-fit: cover; border-radius: 50%; }
.card-meta { flex: 1; }
.card-author { font-family: 'Playfair Display', serif; font-size: 1rem; font-weight: 400; color: var(--navy); margin-bottom: 2px; }
.card-location { font-size: 0.65rem; letter-spacing: 2px; text-transform: uppercase; color: var(--turquoise); }
.card-date { font-size: 0.7rem; color: var(--navy); opacity: 0.4; letter-spacing: 1px; }
.blog-card-body { padding: 1.5rem 2rem 1rem; }
.blog-card-title { font-family: 'Playfair Display', serif; font-size: 1.2rem; font-weight: 400; color: var(--navy); margin-bottom: 1rem; line-height: 1.4; }
.blog-card-title em { font-style: italic; color: var(--coral); }
.blog-card-text { font-size: 0.85rem; line-height: 1.9; color: var(--navy); opacity: 0.8; font-weight: 300; }
.blog-card-text p { margin-bottom: 1rem; }
.blog-card-text p:last-child { margin-bottom: 0; }
.blog-card-footer { padding: 1rem 2rem 1.5rem; display: flex; justify-content: space-between; align-items: center; }
.card-tag { font-size: 0.65rem; letter-spacing: 2px; text-transform: uppercase; color: var(--coral); border: 1px solid var(--coral); padding: 0.3rem 0.75rem; border-radius: 2px; }
.location-tag { font-size: 0.65rem; letter-spacing: 2px; text-transform: uppercase; color: var(--navy); opacity: 0.4; }
.archive-toggle { width: 100%; background: none; border: none; border-top: 1px solid rgba(22,50,79,0.08); padding: 0.9rem 2rem; display: flex; justify-content: space-between; align-items: center; cursor: pointer; font-family: 'Montserrat', sans-serif; font-size: 0.7rem; letter-spacing: 2px; text-transform: uppercase; color: var(--navy); opacity: 0.5; transition: opacity 0.2s; }
.archive-toggle:hover { opacity: 1; }
.archive-toggle .arrow { transition: transform 0.3s; }
.archive-toggle.open .arrow { transform: rotate(180deg); }
.archive-drawer { display: none; border-top: 1px solid rgba(22,50,79,0.06); background: #fafaf7; }
.archive-drawer.open { display: block; }
.archive-post { padding: 1.25rem 2rem; border-bottom: 1px solid rgba(22,50,79,0.06); }
.archive-post:last-child { border-bottom: none; }
.archive-post-date { font-size: 0.65rem; letter-spacing: 2px; text-transform: uppercase; color: var(--turquoise); margin-bottom: 0.4rem; }
.archive-post-title { font-family: 'Playfair Display', serif; font-size: 1rem; font-weight: 400; color: var(--navy); margin-bottom: 0.5rem; line-height: 1.4; }
.archive-post-excerpt { font-size: 0.8rem; line-height: 1.8; color: var(--navy); opacity: 0.65; font-weight: 300; }
.section-divider { border: none; border-top: 1px solid rgba(22,50,79,0.08); margin: 0 2.5rem; }
.related-section { background: var(--navy); padding: 3rem 2.5rem; text-align: center; }
.related-section h2 { font-family: 'Playfair Display', serif; font-size: 1.5rem; color: var(--cream); font-weight: 400; margin-bottom: 0.5rem; }
.related-section p { color: var(--cream); opacity: 0.6; font-size: 0.85rem; margin-bottom: 2rem; font-weight: 300; }
.related-links { display: flex; justify-content: center; gap: 1rem; flex-wrap: wrap; }
.related-link { color: var(--cream); text-decoration: none; font-size: 0.72rem; letter-spacing: 2px; text-transform: uppercase; border: 1px solid rgba(255,255,255,0.3); padding: 0.6rem 1.2rem; border-radius: 2px; }
.related-link:hover { background: var(--coral); border-color: var(--coral); }
.email-strip { background: var(--navy); padding: 4rem 2.5rem; text-align: center; }
.email-strip h2 { font-family: 'Playfair Display', serif; font-size: 2rem; color: var(--cream); font-weight: 400; margin-bottom: 0.75rem; }
.email-strip p { color: var(--cream); opacity: 0.7; font-size: 0.85rem; margin-bottom: 2rem; font-weight: 300; }
.email-form { display: flex; max-width: 420px; margin: 0 auto; border-radius: 2px; overflow: hidden; }
.email-form input { flex: 1; padding: 0.85rem 1.2rem; border: none; font-size: 0.85rem; font-family: 'Montserrat', sans-serif; background: var(--cream); color: var(--navy); min-width: 0; }
.email-form button { background: var(--coral); color: #fff; border: none; padding: 0.85rem 1.5rem; font-size: 0.7rem; letter-spacing: 2px; text-transform: uppercase; cursor: pointer; font-family: 'Montserrat', sans-serif; white-space: nowrap; }
#blog-success-msg { display: none; color: var(--turquoise); margin-top: 1rem; letter-spacing: 2px; text-transform: uppercase; font-size: 0.85rem; }
.footer { background: #0d2035; padding: 2.5rem; text-align: center; }
.footer .logo-text { display: block; margin-bottom: 1rem; color: var(--cream); font-family: 'Playfair Display', serif; font-size: 1.1rem; }
.footer-social { display: flex; justify-content: center; gap: 1.5rem; margin-bottom: 1.5rem; flex-wrap: wrap; }
.footer-social a { color: var(--cream); opacity: 0.5; text-decoration: none; font-size: 0.7rem; letter-spacing: 2px; text-transform: uppercase; display: flex; align-items: center; gap: 0.4rem; }
.footer-links { display: flex; gap: 2rem; justify-content: center; flex-wrap: wrap; margin-bottom: 1.5rem; }
.footer-links a { color: var(--cream); opacity: 0.5; font-size: 0.7rem; letter-spacing: 2px; text-transform: uppercase; text-decoration: none; }
.footer p { color: var(--cream); opacity: 0.3; font-size: 0.75rem; }
@media (max-width: 900px) {
  .nav-links { display: none; }
  .nav-toggle { display: flex; }
  nav { padding: 1rem 1.5rem; }
  .blog-hero { padding: 3rem 1.5rem; }
  .blog-hero h1 { font-size: 2rem; }
  .writers-grid { gap: 1.5rem; }
  .writer-avatar { width: 80px; height: 80px; }
  .blog-section { padding: 2.5rem 1rem; }
  .blog-grid { grid-template-columns: 1fr; }
  .blog-card-header { padding: 1.2rem 1.2rem 0; }
  .blog-card-body { padding: 1.2rem 1.2rem 0.75rem; }
  .blog-card-footer { padding: 0.75rem 1.2rem 1.2rem; }
  .archive-toggle { padding: 0.9rem 1.2rem; }
  .archive-post { padding: 1rem 1.2rem; }
  .email-strip { padding: 3rem 1.5rem; }
  .email-form { flex-direction: column; }
  .email-form input { border-radius: 2px 2px 0 0; }
  .email-form button { border-radius: 0 0 2px 2px; }
  .intro-section { padding: 2rem 1.5rem 0; }
}
</style>
</head>
<body>
<nav>
  <a href="../index.html">
    <span class="logo-text">Pickleball Florida USA</span>
    <span class="logo-sub">Coastal Lifestyle Collection</span>
  </a>
  <div class="nav-links">
    <a href="shop.html">Shop</a>
    <a href="gear.html">Gear</a>
    <a href="courts.html">Courts</a>
    <a href="tournaments.html">Tournaments</a>
    <a href="blog.html" class="active">Blog</a>
    <a href="learn.html">Learn</a>
    <a href="about.html">About</a>
  </div>
  <button class="nav-toggle" id="navToggle" aria-label="Toggle menu">
    <span></span><span></span><span></span>
  </button>
  <div class="mobile-menu" id="mobileMenu">
    <a href="shop.html">Shop</a>
    <a href="gear.html">Gear</a>
    <a href="courts.html">Courts</a>
    <a href="tournaments.html">Tournaments</a>
    <a href="blog.html" class="active">Blog</a>
    <a href="learn.html">Learn</a>
    <a href="about.html">About</a>
  </div>
</nav>
<div class="blog-hero">
  <p class="blog-hero-eyebrow">The Coastal Circle Chronicles</p>
  <h1>Four Women.<br>Four Cities.<br><em>One Obsession.</em></h1>
  <p class="blog-hero-desc">Court-side dispatches from Palm Beach, Naples, The Villages, and Sarasota. Real courts, real people, real Florida pickleball life served with a side of gossip.</p>
</div>
<div class="wave"><svg viewBox="0 0 1440 60" xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="none" height="60"><path d="M0,0 C360,60 1080,0 1440,40 L1440,60 L0,60 Z" fill="#FFF7EB"/></svg></div>
<div class="intro-section">
  <p>The Coastal Circle Chronicles follows four real women living, playing, and gossiping their way through Florida's most vibrant pickleball communities. Patrice reports from Palm Beach. Nicolette dispatches from Pelican Bay in Naples. Vivian covers the legendary courts of The Villages. Stella brings Sarasota energy every week. New dispatches published weekly.</p>
</div>
<div class="writers-strip">
  <p>Meet Your Correspondents</p>
  <div class="writers-grid">
    <div class="writer-pill" onclick="openPersonaModal('patrice')">
      <div class="writer-avatar"><img src="../images/patrice.png" style="width:100%;height:100%;object-fit:cover;border-radius:50%;" alt="Patrice" /></div>
      <span class="writer-name">Patrice</span>
      <span class="writer-location">Palm Beach</span>
    </div>
    <div class="writer-pill" onclick="openPersonaModal('nicolette')">
      <div class="writer-avatar"><img src="../images/nicolette.png" style="width:100%;height:100%;object-fit:cover;border-radius:50%;" alt="Nicolette" /></div>
      <span class="writer-name">Nicolette</span>
      <span class="writer-location">Naples</span>
    </div>
    <div class="writer-pill" onclick="openPersonaModal('vivian')">
      <div class="writer-avatar"><img src="../images/vivian.png" style="width:100%;height:100%;object-fit:cover;border-radius:50%;" alt="Vivian" /></div>
      <span class="writer-name">Vivian</span>
      <span class="writer-location">The Villages</span>
    </div>
    <div class="writer-pill" onclick="openPersonaModal('stella')">
      <div class="writer-avatar"><img src="../images/stella.png" style="width:100%;height:100%;object-fit:cover;border-radius:50%;" alt="Stella" /></div>
      <span class="writer-name">Stella</span>
      <span class="writer-location">Sarasota</span>
    </div>
  </div>
</div>
<div id="persona-overlay" onclick="handleOverlayClick(event)">
  <div class="modal-box">
    <div class="modal-header">
      <img id="m-photo" src="" alt="" />
      <div class="modal-header-text">
        <h3 id="m-name"></h3>
        <p class="m-sub" id="m-sub"></p>
        <p class="m-hood" id="m-hood"></p>
      </div>
      <button class="modal-close" onclick="closeModal()">X</button>
    </div>
    <div class="modal-body">
      <div class="stat-grid">
        <div class="stat-box"><p class="stat-label">DUPR Rating</p><p class="stat-val" id="m-dupr"></p></div>
        <div class="stat-box"><p class="stat-label">Playing Style</p><p class="stat-val" id="m-style"></p></div>
        <div class="stat-box"><p class="stat-label">Preferred Side</p><p class="stat-val" id="m-side"></p></div>
        <div class="stat-box"><p class="stat-label">Paddle of Choice</p><p class="stat-val" id="m-paddle"></p></div>
      </div>
      <p class="modal-section-label">Favorite Spots</p>
      <div class="pill-row" id="m-spots"></div>
      <p class="modal-section-label">Always on Court With</p>
      <div class="pill-row" id="m-gear"></div>
      <p class="modal-quote" id="m-quote"></p>
    </div>
  </div>
</div>
<div class="blog-section">
  <div class="blog-section-header">
    <h2>Latest Dispatches</h2>
    <span class="location-tag">June 2026</span>
  </div>
  <div class="blog-grid">
    <div class="blog-card">
      <div class="blog-card-header">
        <div class="card-avatar"><img src="../images/patrice.png" alt="Patrice" /></div>
        <div class="card-meta">
          <div class="card-author">Patrice Waverly-Fontaine</div>
          <div class="card-location">Palm Beach, FL</div>
        </div>
        <div class="card-date">Jun 9</div>
      </div>
      <div class="blog-card-body">
        <h3 class="blog-card-title">The Week Bunny Served Straight Into Lady Ashford's Hermes</h3>
        <div class="blog-card-text">
          <p>Darlings, where do I even BEGIN with this week? Monday morning at Phipps was absolutely electric and I am not just talking about the humidity that required three touch-ups of my Chantecaille foundation by noon. Bunny and I were paired against the Ashford twins and during the most crucial point of the third game, Bunny executed what can only be described as a demonic serve that ricocheted off the net and somehow ended up lodging itself in Lady Ashford's Kelly bag courtside. The silence. The DRAMA. I simply stood there clutching my new JOOLA Ben Johns Hyperion paddle trying not to absolutely die laughing.</p>
          <p>Wednesday I finally debuted my Coastal Court Tote paired with my new Loro Piana tennis whites. Even Mitzi Caldwell asked where I got it during our cooldown at The Bath and Tennis Club. And speaking of next week, wait until you hear what happened when the new pro showed up from Boca with a rather interesting proposition about mixed doubles.</p>
        </div>
      </div>
      <div class="blog-card-footer">
        <span class="card-tag">Palm Beach</span>
        <span class="location-tag">Courts and Social</span>
      </div>
      <button class="archive-toggle" onclick="toggleArchive(this)" aria-expanded="false">Past Dispatches from Patrice <span class="arrow">v</span></button>
      <div class="archive-drawer">
        <div class="archive-post">
          <div class="archive-post-date">May 26</div>
          <div class="archive-post-title">The Courts Are Back and So Are We</div>
          <div class="archive-post-excerpt">The Phipps Ocean Park courts got resurfaced and Bunny called me before my coffee was even finished. By nine o'clock we were out there and I will say the new surface is extraordinary. I wore my new Loro Piana sun hat and not a single person commented on it.</div>
        </div>
        <div class="archive-post">
          <div class="archive-post-date">May 12</div>
          <div class="archive-post-title">Geoffrey Finally Watched a Full Match and Had Opinions</div>
          <div class="archive-post-excerpt">Against all reasonable expectations, Geoffrey sat through our entire Tuesday round robin and afterward declared that pickleball was more strategic than it looks. I have been saying this for three years. He has since purchased a paddle. We are monitoring the situation.</div>
        </div>
        <div class="archive-post">
          <div class="archive-post-date">Apr 28</div>
          <div class="archive-post-title">The Charity Tournament at The Breakers</div>
          <div class="archive-post-excerpt">The annual spring charity tournament was as always an exercise in Palm Beach doing Palm Beach things. Everyone was very competitive and also wearing something from Net-a-Porter. Bunny and I made it to the semifinals. I am choosing to be proud of that.</div>
        </div>
        <div class="archive-post">
          <div class="archive-post-date">Apr 14</div>
          <div class="archive-post-title">Carlos Says I Need More Spin. Carlos Is Not Wrong.</div>
          <div class="archive-post-excerpt">My trainer Carlos has crossed fully from fitness advisor into pickleball coach and I have mixed feelings. On one hand he has genuinely improved my third shot drop. On the other hand he now has opinions about my grip and expressed them in front of Margaux.</div>
        </div>
      </div>
    </div>
    <div class="blog-card">
      <div class="blog-card-header">
        <div class="card-avatar"><img src="../images/nicolette.png" alt="Nicolette" /></div>
        <div class="card-meta">
          <div class="card-author">Nicolette Hargrove</div>
          <div class="card-location">Naples, FL</div>
        </div>
        <div class="card-date">Jun 8</div>
      </div>
      <div class="blog-card-body">
        <h3 class="blog-card-title">Court Drama, Crosscourt Dreams, and the Creamiest Burrata I Have Had All Month</h3>
        <div class="blog-card-text">
          <p>Honestly this week has been an absolute whirlwind of pickleball and pure Naples magic. Tuesday morning started with the most glorious sunrise session at Naples Grande. Thomas had me working on my third shot drops until my legs were absolutely screaming but I cannot even complain because afterwards Camille and I treated ourselves to lunch at The French on Fifth. The burrata with heirloom tomatoes was life-changing.</p>
          <p>Derek joined us for mixed doubles on Thursday and I wore my new Pickleball Florida USA moisture-wicking dress paired with my favorite Vuori leggings. We grabbed Rosie afterward and walked through Venetian Village where she charmed every single person on the sidewalk as usual.</p>
        </div>
      </div>
      <div class="blog-card-footer">
        <span class="card-tag">Naples</span>
        <span class="location-tag">Lifestyle and Food</span>
      </div>
      <button class="archive-toggle" onclick="toggleArchive(this)" aria-expanded="false">Past Dispatches from Nicolette <span class="arrow">v</span></button>
      <div class="archive-drawer">
        <div class="archive-post">
          <div class="archive-post-date">May 25</div>
          <div class="archive-post-title">Derek Found His People and I Found a New Restaurant</div>
          <div class="archive-post-excerpt">Derek came home, looked up three YouTube videos on the third shot drop, and asked me if we could hit some balls before dinner. We have been married twenty-two years and this man has never once suggested physical activity before dinner. We went to Pelican Bay and honestly he is not terrible.</div>
        </div>
        <div class="archive-post">
          <div class="archive-post-date">May 11</div>
          <div class="archive-post-title">Thomas Told Me I Am Ready for the 3.5 Tournament</div>
          <div class="archive-post-excerpt">Thursday lesson with Thomas ended with him saying very casually that he thought I was ready to enter the 3.5 bracket at Naples Grande next month. I smiled and said thank you and then called Camille from the parking lot and had a complete meltdown.</div>
        </div>
        <div class="archive-post">
          <div class="archive-post-date">Apr 27</div>
          <div class="archive-post-title">The Snowbird Exodus and What It Does to Court Availability</div>
          <div class="archive-post-excerpt">It is officially post-season in Naples which means the snowbirds have returned north and suddenly we have actual court time before 10am again. Camille and I celebrated by booking Pelican Bay for Tuesday and Thursday morning for the next six weeks.</div>
        </div>
        <div class="archive-post">
          <div class="archive-post-date">Apr 13</div>
          <div class="archive-post-title">Camille Won the Round Robin and I Made Peace With It</div>
          <div class="archive-post-excerpt">Camille won the Naples Grande monthly round robin and I am genuinely completely one hundred percent happy for her. I am also switching to a heavier paddle next week. We celebrated at Vanderbilt Beach and the sunset was so beautiful that I briefly forgot I lost in the quarterfinals.</div>
        </div>
      </div>
    </div>
    <div class="blog-card">
      <div class="blog-card-header">
        <div class="card-avatar"><img src="../images/vivian.png" alt="Vivian" /></div>
        <div class="card-meta">
          <div class="card-author">Vivian Kowalski-Reed</div>
          <div class="card-location">The Villages, FL</div>
        </div>
        <div class="card-date">Jun 7</div>
      </div>
      <div class="blog-card-body">
        <h3 class="blog-card-title">Kenny Called a Foot Fault on Dottie. Now We Are in a Cold War.</h3>
        <div class="blog-card-text">
          <p>Listen, I have been playing pickleball in this retirement paradise for three years now and I thought I had seen everything. But this week Kenny called a foot fault on Dottie during our Tuesday morning game. Honey, you could have heard a pin drop across all of Lake Sumter Landing. Dottie is from Jersey. She does not forget and she sure as heck does not forgive. Now she has got me driving our golf cart the long way to courts just to avoid passing his driveway.</p>
          <p>The rest of the week was actually pretty great once I stopped getting text messages from Dottie with increasingly creative nicknames for Kenny. I finally broke down and ordered one of those Pickleball Florida USA paddle covers and honey it has been a practical delight. Thursday we played at Tierra Del Sol and Frank and I celebrated with Key lime pie from Katie Belle's.</p>
        </div>
      </div>
      <div class="blog-card-footer">
        <span class="card-tag">The Villages</span>
        <span class="location-tag">Community and Courts</span>
      </div>
      <button class="archive-toggle" onclick="toggleArchive(this)" aria-expanded="false">Past Dispatches from Vivian <span class="arrow">v</span></button>
      <div class="archive-drawer">
        <div class="archive-post">
          <div class="archive-post-date">May 24</div>
          <div class="archive-post-title">Kenny Moved Up a Level and Now It Is Personal</div>
          <div class="archive-post-excerpt">Kenny self-rated to 4.0 and signed up for the advanced round robin on Wednesday mornings. Frank found out from Dottie who found out from the sign-up sheet and called me while I was in the Publix on Rolling Acres. I had to put down my cantaloupe.</div>
        </div>
        <div class="archive-post">
          <div class="archive-post-date">May 10</div>
          <div class="archive-post-title">The Knudson Morning Crew Gets a New Member</div>
          <div class="archive-post-excerpt">A new couple moved into Buttonwood neighborhood last week and showed up at Knudson Tuesday morning with matching outfits and brand new Selkirk paddles still in the packaging. Dottie said bless their hearts in that way she has. They were actually quite good. We have revised our opinions.</div>
        </div>
        <div class="archive-post">
          <div class="archive-post-date">Apr 26</div>
          <div class="archive-post-title">Frank Wants to Enter a Tournament and I Have Questions</div>
          <div class="archive-post-excerpt">Frank came home from his 7am game and announced he wants to enter the senior men's doubles tournament at Hacienda Hills next month. I said Frank you have been playing for eight months. He said Vivian I have been practicing. These are two different things.</div>
        </div>
        <div class="archive-post">
          <div class="archive-post-date">Apr 12</div>
          <div class="archive-post-title">Marge Came to Watch and Now She Wants to Play</div>
          <div class="archive-post-excerpt">In thirty-seven years of knowing Marge I have never seen her express interest in a sport of any kind. She came to watch our Tuesday game because her book club got cancelled. Forty-five minutes later she asked if there was a beginner clinic. Dottie says we created a monster. I think we created a teammate.</div>
        </div>
      </div>
    </div>
    <div class="blog-card">
      <div class="blog-card-header">
        <div class="card-avatar"><img src="../images/stella.png" alt="Stella" /></div>
        <div class="card-meta">
          <div class="card-author">Stella Marchetti</div>
          <div class="card-location">Sarasota, FL</div>
        </div>
        <div class="card-date">Jun 6</div>
      </div>
      <div class="blog-card-body">
        <h3 class="blog-card-title">The Week I Played Through a Meltdown Mine Not Marco's For Once</h3>
        <div class="blog-card-text">
          <p>Here is the thing. I thought moving to Sarasota would mellow me out. Six years later I am standing at Pompano Park on Tuesday morning having what can only be described as a graphic designer's existential crisis over paddle grip colors while Diane patiently waits for me to serve. Last month I lectured everyone for fifteen minutes about kerning after someone made a tournament flyer in Papyrus. PAPYRUS.</p>
          <p>Monday at Urfer was brutal. Marco came along and proceeded to hit perfect third-shot drops while I shanked balls into the next county. Then Wednesday happened. Diane and I absolutely demolished a doubles match at Bay Front and suddenly I remembered why I am obsessed. We stopped at Piccolo Italian Market after because winning requires prosciutto. It is science.</p>
        </div>
      </div>
      <div class="blog-card-footer">
        <span class="card-tag">Sarasota</span>
        <span class="location-tag">Community and Gear</span>
      </div>
      <button class="archive-toggle" onclick="toggleArchive(this)" aria-expanded="false">Past Dispatches from Stella <span class="arrow">v</span></button>
      <div class="archive-drawer">
        <div class="archive-post">
          <div class="archive-post-date">May 23</div>
          <div class="archive-post-title">The Tuesday Crew Survives Another Florida Summer</div>
          <div class="archive-post-excerpt">Here is the thing about playing pickleball in Sarasota in May. You either commit fully or you move somewhere with a functioning atmosphere. Marco wore a hat for the first time in his life because I threatened consequences. I finally caved and got the JOOLA Ben Johns paddle that Diane has been quietly evangelizing about and I owe her a full apology.</div>
        </div>
        <div class="archive-post">
          <div class="archive-post-date">May 9</div>
          <div class="archive-post-title">Gabi Talked Me Into a 6am Game and I Am Still Not Over It</div>
          <div class="archive-post-excerpt">Gabi texted at 10pm to ask if I wanted to beat the heat with a 6am session at Urfer. I said yes because I am weak and she is persuasive. Marco materialized at 6:05 with coffee which is the only reason I forgave him for being annoyingly good at a sport he claims not to care about.</div>
        </div>
        <div class="archive-post">
          <div class="archive-post-date">Apr 25</div>
          <div class="archive-post-title">I Entered a Tournament and Told No One Until Afterward</div>
          <div class="archive-post-excerpt">I entered the Urfer Family Park spring tournament under the reasoning that if I did not tell anyone and I lost badly it would be like it never happened. I did not lose badly. I made it to the final and lost to a woman named Carol from Bradenton who was sixty-one years old and absolutely merciless at the net.</div>
        </div>
        <div class="archive-post">
          <div class="archive-post-date">Apr 11</div>
          <div class="archive-post-title">Diane Has Been Right About Everything and I Am Formally Acknowledging It</div>
          <div class="archive-post-excerpt">A partial list of things Diane has been right about that I initially dismissed includes the JOOLA paddle, the ASICS court shoes, arriving ten minutes early to warm up, and Piccolo Italian Market. I am a graphic designer with strong opinions and a long history of being wrong about things that Diane is quietly correct about.</div>
        </div>
      </div>
    </div>
  </div>
</div>
<hr class="section-divider" />
<div class="related-section">
  <h2>Explore More Florida Pickleball</h2>
  <p>Find courts, gear up, and follow the full Florida pickleball scene.</p>
  <div class="related-links">
    <a href="courts.html" class="related-link">Find Florida Courts</a>
    <a href="tournaments.html" class="related-link">Florida Tournaments</a>
    <a href="gear.html" class="related-link">Pickleball Gear Guide</a>
    <a href="learn.html" class="related-link">Learn to Play</a>
    <a href="shop.html" class="related-link">Shop the Collection</a>
  </div>
</div>
<div class="email-strip">
  <h2>Join The Coastal Circle</h2>
  <p>Get the Chronicles delivered weekly plus Florida court guides, tournament alerts, and members-only offers.</p>
  <form id="blog-signup-form" method="POST" action="https://c8fbe7fc.sibforms.com/serve/MUIFAP3xhPHl9UFeyPIz2ya1etYh9nOvZY_of12LhroK1z8rlPiWQiB4y16Lu4a7mS_G3xcSbhIb9_rS3z_AJbnkfhKqtizT6pNgqIR_8yfJc1PaawrZ01y94EJoZWWEDGuxdBpmf0RI85w8CPVy39LlvVBrZHrvPwLSe7as4Fe893wiNtQVrrBOQs-1X7TFa6TznK2Z6AuxbAmy0w==" onsubmit="return handleBlogSubmit(event)" class="email-form">
    <input type="text" id="BLOG_EMAIL" name="EMAIL" autocomplete="off" placeholder="Your email address" required />
    <input type="text" name="email_address_check" value="" style="display:none;">
    <input type="hidden" name="locale" value="en">
    <button type="submit">Join</button>
  </form>
  <p id="blog-success-msg">You are in! Welcome to the Coastal Circle.</p>
</div>
<div class="footer">
  <span class="logo-text">Pickleball Florida USA</span>
  <div class="footer-social">
    <a href="https://www.instagram.com/pickleballfloridausa" target="_blank">Instagram</a>
    <a href="https://www.facebook.com/pickleballfloridausa" target="_blank">Facebook</a>
    <a href="https://www.pinterest.com/pickleballfloridausa" target="_blank">Pinterest</a>
  </div>
  <div class="footer-links">
    <a href="shop.html">Shop</a>
    <a href="courts.html">Courts</a>
    <a href="tournaments.html">Tournaments</a>
    <a href="blog.html">Blog</a>
    <a href="about.html">About</a>
    <a href="#">Contact</a>
    <a href="#">Privacy</a>
  </div>
  <p>2026 PickleballFloridaUSA.com Coastal Pickleball Lifestyle</p>
</div>
<script>
document.getElementById('navToggle').addEventListener('click', function() {
  this.classList.toggle('open');
  document.getElementById('mobileMenu').classList.toggle('open');
});
document.querySelectorAll('#mobileMenu a').forEach(function(link) {
  link.addEventListener('click', function() {
    document.getElementById('navToggle').classList.remove('open');
    document.getElementById('mobileMenu').classList.remove('open');
  });
});
function toggleArchive(btn) {
  var drawer = btn.nextElementSibling;
  var isOpen = drawer.classList.contains('open');
  drawer.classList.toggle('open', !isOpen);
  btn.classList.toggle('open', !isOpen);
  btn.setAttribute('aria-expanded', String(!isOpen));
}
var personaData = {
  patrice: { photo:'../images/patrice.png', name:'Patrice Waverly-Fontaine', sub:'Palm Beach, Age 61', hood:'South Ocean Blvd, Palm Beach Island', dupr:'4.012', style:'Dinker', side:'Even right', paddle:'HEAD Radical Pro', spots:['Ta-boo','Cafe Boulud','Worth Avenue','The Breakers','Greens Pharmacy'], gear:['Loro Piana sun hat','K-Swiss Ultrashot','Coastal Circle Tee','Hermes court bag'], quote:'Bunny called me at seven this morning to tell me the Phipps courts were completely redone. I told her I needed at least forty minutes because I was not going to show up looking like I had rolled out of bed.' },
  nicolette: { photo:'../images/nicolette.png', name:'Nicolette Hargrove', sub:'Naples, Age 54', hood:'Pelican Bay, Naples', dupr:'3.541', style:'All-court', side:'Odd left', paddle:'Selkirk AMPED Epic', spots:['The French on Fifth','Mediterrano','Mercato','Seed to Table','Vanderbilt Beach'], gear:['Alo set','Vuori shorts','Palm Paddle Tee','JOOLA bag'], quote:'Derek showed up to his first clinic in basketball shorts and a University of Michigan shirt from 2003. Thomas bless that man did not even flinch.' },
  vivian: { photo:'../images/vivian.png', name:'Vivian Kowalski-Reed', sub:'The Villages, Age 68', hood:'Brownwood Paddock Square, The Villages', dupr:'3.489', style:'Dinker', side:'Even right', paddle:'Selkirk AMPED', spots:['Lake Sumter Landing','Katie Belles','Brownwood Square','Publix on Rolling Acres'], gear:['Coastal Circle Hat','Selkirk AMPED','Franklin X-40 balls','Cooling towel'], quote:'I am not a gossip. I am a community historian. There is a difference. Frank understands this. Marge does not.' },
  stella: { photo:'../images/stella.png', name:'Stella Marchetti', sub:'Sarasota, Age 47', hood:'Rosemary District, Sarasota', dupr:'4.187', style:'All-court', side:'Odd left', paddle:'JOOLA Ben Johns Hyperion', spots:['Piccolo Italian Market','Indigenous','Burns Court','Siesta Key','Ringling Museum'], gear:['JOOLA Ben Johns paddle','Coastal Serve Tank','ASICS court shoes','Coastal Court Tote'], quote:'Here is the thing. I waited three months to try the JOOLA because I thought Diane was being dramatic. I owe her a full apology and possibly lunch.' }
};
function openPersonaModal(id) {
  var p = personaData[id];
  document.getElementById('m-photo').src = p.photo;
  document.getElementById('m-name').textContent = p.name;
  document.getElementById('m-sub').textContent = p.sub;
  document.getElementById('m-hood').textContent = p.hood;
  document.getElementById('m-dupr').textContent = p.dupr;
  document.getElementById('m-style').textContent = p.style;
  document.getElementById('m-side').textContent = p.side;
  document.getElementById('m-paddle').textContent = p.paddle;
  document.getElementById('m-spots').innerHTML = p.spots.map(function(s){ return '<span class="pill">'+s+'</span>'; }).join('');
  document.getElementById('m-gear').innerHTML = p.gear.map(function(g){ return '<span class="pill">'+g+'</span>'; }).join('');
  document.getElementById('m-quote').textContent = p.quote;
  document.getElementById('persona-overlay').style.display = 'flex';
  document.body.style.overflow = 'hidden';
}
function closeModal() {
  document.getElementById('persona-overlay').style.display = 'none';
  document.body.style.overflow = '';
}
function handleOverlayClick(e) {
  if (e.target === document.getElementById('persona-overlay')) closeModal();
}
function handleBlogSubmit(e) {
  e.preventDefault();
  var form = document.getElementById('blog-signup-form');
  fetch(form.action, { method:'POST', body: new FormData(form), mode:'no-cors' }).then(function() {
    form.style.display = 'none';
    document.getElementById('blog-success-msg').style.display = 'block';
  });
  return false;
}
</script>
</body>
</html>
'@

[System.IO.File]::WriteAllText(
  (Join-Path (Get-Location) "pages\blog.html"),
  $html,
  [System.Text.Encoding]::UTF8
)
Write-Host "blog.html written successfully!" -ForegroundColor Green
Write-Host "Now run:" -ForegroundColor Cyan
Write-Host "  git add pages/blog.html" -ForegroundColor Yellow
Write-Host "  git commit -m 'Clean blog.html rewrite'" -ForegroundColor Yellow
Write-Host "  git push" -ForegroundColor Yellow