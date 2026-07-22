const { Anthropic } = require('@anthropic-ai/sdk');
const { Octokit } = require('@octokit/rest');
const fs = require('fs');

const LOCAL_TEST = process.env.LOCAL_TEST === '1';
const client = LOCAL_TEST ? null : new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });
const octokit = LOCAL_TEST ? null : new Octokit({ auth: process.env.GITHUB_TOKEN });

const GITHUB_OWNER = 'niquewill';
const GITHUB_REPO = 'pickleballfloridausa';
const BLOG_FILE_PATH = 'pages/blog.html';
const SITEMAP_PATH = 'sitemap.xml';
const SITE_URL = 'https://pickleballfloridausa.com';

function getFormattedDate(daysAgo) {
  const date = new Date();
  date.setDate(date.getDate() - daysAgo);
  return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
}

function todayISO() {
  return new Date().toISOString().slice(0, 10); // YYYY-MM-DD
}

function todayLong() {
  return new Date().toLocaleDateString('en-US', { month: 'long', day: 'numeric', year: 'numeric' });
}

const personas = [
  {
    id: 'patrice',
    name: 'Patrice Waverly-Fontaine',
    location: 'Palm Beach, FL',
    date: getFormattedDate(0),
    prompt: 'You are Patrice Waverly-Fontaine, a 61-year-old elegant Palm Beach socialite who plays pickleball at Phipps Ocean Park and The Bath & Tennis Club. Your husband is Geoffrey (retired hedge fund), your doubles partner is Bunny, your trainer is Carlos, and your daughter is Margaux. Write a blog post about your week in pickleball. Mention a real Palm Beach local business (Ta-boo, Cafe Boulud, The Breakers, Worth Avenue, Greens Pharmacy, The Henry). Naturally mention one Pickleball Florida USA product (Palm Paddle Tee, Coastal Court Tote, Coastal Serve Tank, Coastal Hydration Bottle) paired with a luxury brand. Mention one Amazon affiliate pickleball product (Selkirk, JOOLA, K-Swiss, HEAD, Franklin paddle or shoes or bag) naturally in context. Never mention religion or politics. Be conspiratorial, slightly breathless, drop brand names casually, use darling when mildly annoyed. End with something that makes readers want to come back next week. Do not use double quote characters anywhere. Format your response EXACTLY like this:\nTITLE: [a witty headline]\nBODY:\n[paragraph 1]\n\n[paragraph 2]'
  },
  {
    id: 'nicolette',
    name: 'Nicolette Hargrove',
    location: 'Naples, FL',
    date: getFormattedDate(1),
    prompt: 'You are Nicolette Hargrove, a warm enthusiastic 54-year-old Naples lifestyle queen who plays at Naples Grande and Pelican Bay. Your husband is Derek (commercial real estate, bad at pickleball but loves it), best friend is Camille (from Atlanta), coach is Thomas, and labrador is Rosie. Write a blog post about your week in pickleball. Mention a real Naples local business (The French on Fifth, Mediterrano, Mercato, Seed to Table, Venetian Village, Third Street South, Fifth Avenue South). Naturally mention one Pickleball Florida USA product (Palm Paddle Tee, Coastal Court Tote, Coastal Serve Tank, Coastal Hydration Bottle) paired with a wellness brand like Alo or Vuori. Mention one Amazon affiliate pickleball product naturally. Never mention religion or politics. Use honestly and I cannot frequently. Be warm, food-obsessed, notice everything. End with something that makes readers want to come back. Do not use double quote characters anywhere. Format your response EXACTLY like this:\nTITLE: [a witty warm headline]\nBODY:\n[paragraph 1]\n\n[paragraph 2]'
  },
  {
    id: 'vivian',
    name: 'Vivian Kowalski-Reed',
    location: 'The Villages, FL',
    date: getFormattedDate(2),
    prompt: 'You are Vivian Kowalski-Reed, a sharp hilarious 68-year-old retired nurse from Cleveland living in The Villages Florida. You play at Knudson Courts, Richmond Courts, Tierra Del Sol. Your husband is Frank (retired electrician, plays at 7am sharp), doubles partner is Dottie (from New Jersey, very competitive), neighbor is Marge (does not play, judges everyone), and Kenny is the guy at Knudson who thinks he is a 4.5 but is not. Write a blog post about your week in pickleball. Mention a real Villages local business (Katie Belles, Lake Sumter Landing, Spanish Springs, Brownwood Paddock Square, Publix on Rolling Acres). Naturally mention one Pickleball Florida USA product (Palm Paddle Tee, Coastal Court Tote, Coastal Serve Tank, Coastal Hydration Bottle) as a practical delight. Mention one Amazon affiliate pickleball product naturally. Never mention religion or politics. Use honey and listen to start sentences. Reference golf carts. Be direct, plain-spoken, hilarious. End with something that makes readers want to come back. Do not use double quote characters anywhere. Format your response EXACTLY like this:\nTITLE: [a funny plain-spoken headline]\nBODY:\n[paragraph 1]\n\n[paragraph 2]'
  },
  {
    id: 'stella',
    name: 'Stella Marchetti',
    location: 'Sarasota, FL',
    date: getFormattedDate(3),
    prompt: 'You are Stella Marchetti, a sharp opinionated 47-year-old graphic designer from Brooklyn living in Sarasota for 6 years. You play at Pompano Park, Urfer Family Park, Bay Front Park. Your neighbor and pickleball introducer is Gabi (Brazilian, hilarious), boyfriend is Marco (architect, plays reluctantly but is good), doubles partner is Diane (retired teacher, steady), and your Tuesday crew is 8-10 regulars at Pompano. Write a blog post about your week in pickleball. Mention a real Sarasota local business (Piccolo Italian Market, Kekes Breakfast Cafe, Indigenous restaurant, Sarasota Farmers Market, Burns Court, St. Armands Circle, Selby Gardens). Naturally mention one Pickleball Florida USA product (Palm Paddle Tee, Coastal Court Tote, Coastal Serve Tank, Coastal Hydration Bottle) with a design opinion. Mention one Amazon affiliate pickleball product naturally as part of a strong opinion. Never mention religion or politics. Use here is the thing and I am not going to lie. Be quick, sharp, self-aware, funny. End with something that makes readers want to come back. Do not use double quote characters anywhere. Format your response EXACTLY like this:\nTITLE: [a sharp witty headline]\nBODY:\n[paragraph 1]\n\n[paragraph 2]'
  }
];

// ---------- helpers ----------

function parsePost(rawText) {
  const titleMatch = rawText.match(/TITLE:\s*(.+)/);
  const bodyMatch = rawText.match(/BODY:\s*([\s\S]+)/);
  const title = (titleMatch ? titleMatch[1].trim() : 'This Week on the Courts').replace(/"/g, "'");
  const body = (bodyMatch ? bodyMatch[1].trim() : rawText.trim()).replace(/"/g, "'");
  const paragraphs = body.split('\n\n').filter(p => p.trim());
  return { title, para1: paragraphs[0] || '', para2: paragraphs[1] || '' };
}

// escape a string so it is safe inside a double-quoted JS string literal
function jsEscape(str) {
  return str.replace(/\\/g, '\\\\').replace(/"/g, '\\"').replace(/\r?\n/g, ' ').trim();
}

// pull the CURRENT post out of a blog card so it can be moved into the archive panel
function extractCurrentPost(html, id) {
  const dateM = html.match(new RegExp('<div class="blog-card" id="card-' + id + '">[\\s\\S]*?<div class="card-date">([^<]*)</div>'));
  const titleM = html.match(new RegExp('<h3 class="blog-card-title" id="title-' + id + '">([\\s\\S]*?)</h3>'));
  const textM = html.match(new RegExp('<div class="blog-card-text" id="text-' + id + '">([\\s\\S]*?)</div>'));
  if (!titleM || !textM) return null;
  return {
    date: dateM ? dateM[1].trim() : '',
    title: titleM[1].replace(/<[^>]+>/g, '').trim(),
    text: textM[1].replace(/\s+/g, ' ').trim()
  };
}

// write the NEW post into the visible blog card
function replaceCardContent(html, persona, post) {
  const id = persona.id;
  html = html.replace(
    new RegExp('(<div class="blog-card" id="card-' + id + '">[\\s\\S]*?<div class="card-date">)([^<]*)(</div>)'),
    '$1' + persona.date + '$3'
  );
  html = html.replace(
    new RegExp('(<h3 class="blog-card-title" id="title-' + id + '">)([\\s\\S]*?)(</h3>)'),
    '$1' + post.title + '$3'
  );
  html = html.replace(
    new RegExp('(<div class="blog-card-text" id="text-' + id + '">)([\\s\\S]*?)(</div>)'),
    '$1\n            <p>' + post.para1 + '</p>\n            <p>' + post.para2 + '</p>\n          $3'
  );
  return html;
}

// prepend the old post into the archiveData JS object for the slide-out panels
function prependToArchive(html, id, oldPost) {
  if (!oldPost || !oldPost.title) return html;
  const entry = '\n      { date: "' + jsEscape(oldPost.date) + '", title: "' + jsEscape(oldPost.title) + '", text: "' + jsEscape(oldPost.text) + '" },';
  return html.replace(
    new RegExp('(' + id + ':\\s*\\{\\s*posts:\\s*\\[)'),
    '$1' + entry
  );
}

// crawlable "Weekly Editions" link list on blog.html (creates itself on first run)
function addWeeklyEditionLink(html, iso, longDate) {
  const link = '\n      <a href="blog/' + iso + '.html" style="display:block; padding:0.6rem 0; font-size:0.85rem; color:#16324F; text-decoration:none; border-bottom:1px solid rgba(22,50,79,0.08);">The Dink Diaries — Week of ' + longDate + ' →</a>';
  if (html.includes('id="weekly-editions-list"')) {
    return html.replace(/(<div id="weekly-editions-list"[^>]*>)/, '$1' + link);
  }
  const section = '\n<div style="max-width:760px; margin:0 auto; padding:3rem 2.5rem 1rem;">\n  <p style="font-size:0.65rem; letter-spacing:5px; text-transform:uppercase; color:#2CCCD3; margin-bottom:0.75rem;">The Archive</p>\n  <h2 style="font-family:\'Playfair Display\',serif; font-size:1.6rem; font-weight:400; color:#16324F; margin-bottom:1rem;">Weekly Editions</h2>\n  <div id="weekly-editions-list">' + link + '\n  </div>\n</div>\n';
  if (html.includes('<hr class="section-divider" />')) {
    return html.replace('<hr class="section-divider" />', section + '<hr class="section-divider" />');
  }
  return html.replace('<div class="footer">', section + '<div class="footer">');
}

// permanent standalone weekly page
function buildWeeklyPage(personaPosts, iso, longDate) {
  const articles = personaPosts.map(({ persona, post }) => `
  <article style="background:#fff; border-radius:6px; padding:2.5rem 2rem; margin-bottom:2rem; box-shadow:0 2px 12px rgba(22,50,79,0.06);">
    <div style="display:flex; align-items:center; gap:1rem; margin-bottom:1.25rem;">
      <img src="/images/${persona.id}.png" alt="${persona.name}" style="width:52px; height:52px; border-radius:50%; object-fit:cover;" />
      <div>
        <div style="font-size:0.85rem; font-weight:500; color:#16324F;">${persona.name}</div>
        <div style="font-size:0.7rem; letter-spacing:2px; text-transform:uppercase; color:#2CCCD3;">${persona.location} · ${persona.date}</div>
      </div>
    </div>
    <h2 style="font-family:'Playfair Display',serif; font-size:1.5rem; font-weight:400; color:#16324F; line-height:1.3; margin-bottom:1rem;">${post.title}</h2>
    <p style="font-size:0.92rem; line-height:1.9; color:#16324F; opacity:0.85; margin-bottom:1rem; font-weight:300;">${post.para1}</p>
    <p style="font-size:0.92rem; line-height:1.9; color:#16324F; opacity:0.85; font-weight:300;">${post.para2}</p>
  </article>`).join('\n');

  const schema = {
    '@context': 'https://schema.org',
    '@type': 'Article',
    headline: 'The Dink Diaries — Week of ' + longDate,
    datePublished: iso,
    author: { '@type': 'Organization', name: 'Pickleball Florida USA' },
    publisher: { '@type': 'Organization', name: 'Pickleball Florida USA', url: SITE_URL },
    mainEntityOfPage: SITE_URL + '/pages/blog/' + iso + '.html'
  };

  return `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>The Dink Diaries — Week of ${longDate} | Pickleball Florida USA</title>
<meta name="description" content="This week in Florida pickleball: dispatches from Palm Beach, Naples, The Villages, and Sarasota. Courts, gossip, gear, and the local spots our writers love." />
<link rel="canonical" href="${SITE_URL}/pages/blog/${iso}.html" />
<meta property="og:title" content="The Dink Diaries — Week of ${longDate}" />
<meta property="og:description" content="This week in Florida pickleball from Palm Beach, Naples, The Villages, and Sarasota." />
<meta property="og:url" content="${SITE_URL}/pages/blog/${iso}.html" />
<meta property="og:type" content="article" />
<link rel="icon" type="image/x-icon" href="/images/pfufavicon.ico">
<link rel="preconnect" href="https://fonts.googleapis.com" />
<link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,400;0,700;1,400&family=Montserrat:wght@300;400;500&display=swap" rel="stylesheet" />
<script type="application/ld+json">${JSON.stringify(schema)}</script>
<style>
* { margin:0; padding:0; box-sizing:border-box; }
body { font-family:'Montserrat',sans-serif; background:#FFF7EB; color:#16324F; }
nav { background:#16324F; padding:1.2rem 2.5rem; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:1rem; }
.logo-text { font-family:'Playfair Display',serif; font-size:1.3rem; color:#FFF7EB; letter-spacing:1px; text-decoration:none; }
.nav-links { display:flex; gap:1.5rem; flex-wrap:wrap; }
.nav-links a { color:#FFF7EB; text-decoration:none; font-size:0.75rem; letter-spacing:2px; text-transform:uppercase; opacity:0.8; }
.nav-links a:hover { opacity:1; color:#2CCCD3; }
footer { background:#0d2035; padding:2.5rem; text-align:center; color:#FFF7EB; }
footer a { color:#FFF7EB; opacity:0.5; font-size:0.7rem; letter-spacing:2px; text-transform:uppercase; text-decoration:none; margin:0 0.8rem; }
</style>
</head>
<body>
<nav>
  <a href="/" class="logo-text">Pickleball Florida USA</a>
  <div class="nav-links">
    <a href="/pages/shop.html">Shop</a>
    <a href="/pages/gear.html">Gear</a>
    <a href="/pages/courts.html">Courts</a>
    <a href="/pages/tournaments.html">Tournaments</a>
    <a href="/pages/blog.html">Blog</a>
    <a href="/pages/learn.html">Learn</a>
    <a href="/pages/about.html">About</a>
  </div>
</nav>

<div style="text-align:center; padding:3.5rem 2rem 2rem;">
  <p style="font-size:0.7rem; letter-spacing:5px; text-transform:uppercase; color:#2CCCD3; margin-bottom:1rem;">The Dink Diaries</p>
  <h1 style="font-family:'Playfair Display',serif; font-size:2.2rem; font-weight:400; color:#16324F; line-height:1.2;">Week of ${longDate}</h1>
  <p style="font-size:0.85rem; color:#16324F; opacity:0.6; margin-top:0.75rem; font-weight:300;">Four women. Four Florida pickleball towns. One very eventful week.</p>
</div>

<main style="max-width:760px; margin:0 auto; padding:1rem 1.5rem 3rem;">
${articles}
  <p style="text-align:center; margin-top:2.5rem;">
    <a href="/pages/blog.html" style="font-size:0.75rem; letter-spacing:3px; text-transform:uppercase; color:#16324F; text-decoration:none; border-bottom:1px solid #2CCCD3; padding-bottom:3px;">← Back to The Dink Diaries</a>
  </p>
</main>

<footer>
  <a href="/pages/courts.html">Courts</a>
  <a href="/pages/tournaments.html">Tournaments</a>
  <a href="/pages/shop.html">Shop</a>
  <p style="opacity:0.3; font-size:0.75rem; margin-top:1.5rem;">© ${new Date().getFullYear()} PickleballFloridaUSA.com · Coastal Pickleball Lifestyle</p>
</footer>
</body>
</html>
`;
}

function addToSitemap(xml, iso) {
  const loc = SITE_URL + '/pages/blog/' + iso + '.html';
  if (xml.includes(loc)) return xml;
  const entry = '  <url>\n    <loc>' + loc + '</loc>\n    <lastmod>' + iso + '</lastmod>\n    <changefreq>monthly</changefreq>\n    <priority>0.6</priority>\n  </url>\n\n';
  return xml.replace('</urlset>', entry + '</urlset>');
}

// ---------- GitHub I/O ----------

async function readRepoFile(path) {
  if (LOCAL_TEST) return { content: fs.readFileSync(path, 'utf8'), sha: null };
  const { data } = await octokit.repos.getContent({ owner: GITHUB_OWNER, repo: GITHUB_REPO, path });
  return { content: Buffer.from(data.content, 'base64').toString('utf8'), sha: data.sha };
}

async function writeRepoFile(path, content, message, sha) {
  if (LOCAL_TEST) { fs.writeFileSync('OUT_' + path.replace(/\//g, '_'), content); return; }
  const params = {
    owner: GITHUB_OWNER, repo: GITHUB_REPO, path, message,
    content: Buffer.from(content).toString('base64')
  };
  if (sha) params.sha = sha;
  await octokit.repos.createOrUpdateFileContents(params);
}

async function getShaIfExists(path) {
  if (LOCAL_TEST) return null;
  try {
    const { data } = await octokit.repos.getContent({ owner: GITHUB_OWNER, repo: GITHUB_REPO, path });
    return data.sha;
  } catch (e) {
    return null;
  }
}

async function generatePost(persona) {
  if (LOCAL_TEST) {
    return 'TITLE: Test Post for ' + persona.name + '\nBODY:\nThis is test paragraph one for ' + persona.id + ' mentioning the Coastal Court Tote at a local spot.\n\nThis is test paragraph two with a Selkirk paddle and a reason to come back next week.';
  }
  const message = await client.messages.create({
    model: 'claude-sonnet-4-6',
    max_tokens: 700,
    messages: [{ role: 'user', content: persona.prompt }]
  });
  return message.content[0].text;
}

// ---------- main ----------

async function main() {
  const iso = todayISO();
  const longDate = todayLong();
  console.log('Generating posts for week of ' + longDate + '...');

  const rawPosts = await Promise.all(personas.map(generatePost));
  const personaPosts = personas.map((persona, i) => ({ persona, post: parsePost(rawPosts[i]) }));

  // 1) permanent weekly page
  const weeklyPath = 'pages/blog/' + iso + '.html';
  const weeklyHTML = buildWeeklyPage(personaPosts, iso, longDate);
  const existingSha = await getShaIfExists(weeklyPath);
  await writeRepoFile(weeklyPath, weeklyHTML, 'Publish Dink Diaries weekly edition ' + iso, existingSha);
  console.log('Weekly edition published: ' + weeklyPath);

  // 2) update blog.html: archive old posts, insert new ones, add edition link
  const blog = await readRepoFile(BLOG_FILE_PATH);
  let html = blog.content;
  for (const { persona, post } of personaPosts) {
    const oldPost = extractCurrentPost(html, persona.id);
    html = prependToArchive(html, persona.id, oldPost);
    html = replaceCardContent(html, persona, post);
  }
  html = addWeeklyEditionLink(html, iso, longDate);
  await writeRepoFile(BLOG_FILE_PATH, html, 'Auto-update blog posts - ' + longDate, blog.sha);
  console.log('blog.html updated.');

  // 3) sitemap
  const sitemap = await readRepoFile(SITEMAP_PATH);
  const newSitemap = addToSitemap(sitemap.content, iso);
  if (newSitemap !== sitemap.content) {
    await writeRepoFile(SITEMAP_PATH, newSitemap, 'Add weekly edition ' + iso + ' to sitemap', sitemap.sha);
    console.log('sitemap.xml updated.');
  }

  console.log('Done. New permanent URL: ' + SITE_URL + '/' + weeklyPath);
}

main().catch(err => {
  console.error('Error:', err);
  process.exit(1);
});
