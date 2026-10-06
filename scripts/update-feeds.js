// Pickleball Florida USA: live feed engine
// Pulls pickleball news from Google News and organization RSS feeds, reads the
// verified tournament list in data/tournaments.json, and rebuilds the live
// sections of the site between <!-- FEED:name START --> / <!-- FEED:name END --> markers.
// No npm dependencies (Node 18+). Run: node scripts/update-feeds.js
// Offline test: FEEDS_FIXTURE=path/to/fixture.json node scripts/update-feeds.js

const fs = require('fs');
const path = require('path');

const ROOT = path.join(__dirname, '..');
const DATA_DIR = path.join(ROOT, 'data');
const FEEDS_JSON = path.join(DATA_DIR, 'feeds.json');
const TOURNAMENTS_JSON = path.join(DATA_DIR, 'tournaments.json');
const SITE_URL = 'https://pickleballfloridausa.com';

const gnews = q => 'https://news.google.com/rss/search?q=' + encodeURIComponent(q) + '&hl=en-US&gl=US&ceid=US:en';

// section: florida | tournaments | world | travel
const FEEDS = [
  { section: 'florida', url: gnews('pickleball Florida when:30d') },
  { section: 'florida', url: gnews('pickleball (Naples OR Sarasota OR Tampa OR Orlando OR Miami OR "The Villages" OR "Palm Beach" OR Jacksonville) when:30d') },
  { section: 'florida', url: 'https://sarasotapickleball.com/feed/', source: 'Sarasota Pickleball' },
  { section: 'tournaments', url: gnews('pickleball tournament Florida when:30d') },
  { section: 'tournaments', url: gnews('("PPA Tour" OR "APP Tour" OR "Major League Pickleball" OR "US Open Pickleball") when:21d') },
  { section: 'world', url: 'https://usapickleball.org/feed/', source: 'USA Pickleball' },
  { section: 'world', url: 'https://www.thedinkpickleball.com/rss/', source: 'The Dink' },
  { section: 'world', url: 'https://majorleaguepickleball.co/feed/', source: 'Major League Pickleball' },
  { section: 'world', url: 'https://pickleballengland.org/feed/', source: 'Pickleball England' },
  { section: 'world', url: 'https://pickleballcanada.org/feed/', source: 'Pickleball Canada' },
  { section: 'world', url: gnews('pickleball (Europe OR "PPA Tour Europe" OR international) when:30d') },
  { section: 'travel', url: gnews('("pickleball vacation" OR "pickleball trip" OR "pickleball resort" OR "pickleball cruise" OR "pickleball travel") when:45d') },
  { section: 'travel', url: gnews('pickleball (Italy OR Spain OR Portugal OR Croatia OR Greece) trip when:60d') },
];

const LIMITS = { florida: 8, tournaments: 6, world: 8, travel: 6 };
const MAX_AGE_DAYS = { florida: 30, tournaments: 30, world: 30, travel: 60 };

// ---------- helpers ----------
const esc = s => String(s || '').replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
const today = () => new Date().toISOString().slice(0, 10);

function decodeEntities(s) {
  return String(s || '')
    .replace(/<!\[CDATA\[([\s\S]*?)\]\]>/g, '$1')
    .replace(/&#(\d+);/g, (_, n) => String.fromCharCode(+n))
    .replace(/&#x([0-9a-f]+);/gi, (_, n) => String.fromCharCode(parseInt(n, 16)))
    .replace(/&quot;/g, '"').replace(/&apos;|&#39;/g, "'")
    .replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&nbsp;/g, ' ').replace(/&amp;/g, '&')
    .replace(/<[^>]+>/g, '').replace(/\s+/g, ' ').trim();
}

function tag(block, name) {
  const m = block.match(new RegExp('<' + name + '(?:\\s[^>]*)?>([\\s\\S]*?)</' + name + '>', 'i'));
  return m ? decodeEntities(m[1]) : '';
}

function parseFeed(xml, feed) {
  const items = [];
  const blocks = xml.match(/<item[\s>][\s\S]*?<\/item>/gi) || xml.match(/<entry[\s>][\s\S]*?<\/entry>/gi) || [];
  for (const b of blocks) {
    let title = tag(b, 'title');
    let link = tag(b, 'link');
    if (!link) { const m = b.match(/<link[^>]*href="([^"]+)"/i); if (m) link = m[1]; }
    const date = tag(b, 'pubDate') || tag(b, 'published') || tag(b, 'updated') || tag(b, 'dc:date');
    let source = feed.source || tag(b, 'source');
    // Google News titles end with " - Source Name"
    if (!feed.source && source && title.endsWith(' - ' + source)) title = title.slice(0, -(source.length + 3));
    if (!title || !/^https?:\/\//.test(link)) continue;
    const t = Date.parse(date);
    items.push({ title, link, source: source || 'News', date: isNaN(t) ? null : new Date(t).toISOString(), section: feed.section, org: !!feed.source });
  }
  return items;
}

async function fetchFeed(feed) {
  const ctrl = new AbortController();
  const timer = setTimeout(() => ctrl.abort(), 20000);
  try {
    const res = await fetch(feed.url, { signal: ctrl.signal, headers: { 'User-Agent': 'Mozilla/5.0 (compatible; PickleballFloridaUSA-FeedBot/1.0; +' + SITE_URL + ')', 'Accept': 'application/rss+xml, application/atom+xml, application/xml, text/xml' } });
    if (!res.ok) throw new Error('HTTP ' + res.status);
    const items = parseFeed(await res.text(), feed);
    console.log('  ok   ' + items.length + ' items  ' + (feed.source || feed.url.slice(0, 90)));
    return items;
  } catch (e) {
    console.log('  FAIL ' + (feed.source || feed.url.slice(0, 90)) + ' (' + e.message + ')');
    return null;
  } finally { clearTimeout(timer); }
}

const norm = t => t.toLowerCase().replace(/[^a-z0-9 ]/g, '').replace(/\s+/g, ' ').trim().slice(0, 70);

function buildSections(allItems, previous) {
  const sections = {};
  const seen = new Set();
  for (const key of Object.keys(LIMITS)) {
    const cutoff = Date.now() - MAX_AGE_DAYS[key] * 86400000;
    const fresh = allItems.filter(i => i.section === key)
      .filter(i => i.org || /pickle/i.test(i.title))
      .filter(i => !i.date || Date.parse(i.date) >= cutoff)
      .sort((a, b) => (Date.parse(b.date) || 0) - (Date.parse(a.date) || 0));
    const out = [];
    for (const i of fresh) {
      const k = norm(i.title);
      if (seen.has(k)) continue;
      seen.add(k); out.push({ title: i.title, link: i.link, source: i.source, date: i.date });
      if (out.length >= LIMITS[key]) break;
    }
    // if every feed for this section failed, keep last good items rather than going blank
    sections[key] = out.length ? out : ((previous && previous.sections && previous.sections[key]) || []);
  }
  return sections;
}

// ---------- tournaments ----------
const MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
function dateParts(e) {
  const [sy, sm, sd] = e.start.split('-').map(Number);
  const [ey, em, ed] = e.end.split('-').map(Number);
  const day = sm === em ? (sd === ed ? String(sd) : sd + '–' + ed) : sd + '+';
  const range = sm === em && sy === ey
    ? MONTHS[sm - 1] + ' ' + (sd === ed ? sd : sd + '–' + ed) + ', ' + sy
    : MONTHS[sm - 1] + ' ' + sd + (sy !== ey ? ', ' + sy : '') + ' – ' + MONTHS[em - 1] + ' ' + ed + ', ' + ey;
  return { month: MONTHS[sm - 1], day, range };
}

function upcomingEvents() {
  const data = JSON.parse(fs.readFileSync(TOURNAMENTS_JSON, 'utf8'));
  const t = today();
  return data.events.filter(e => e.end >= t).sort((a, b) => a.start.localeCompare(b.start));
}

const LEVEL_TAG = { pro: 'Pro Tour', major: 'Major', amateur: 'Amateur', europe: 'Europe' };
function eventCard(e) {
  const d = dateParts(e);
  const tags = '<span class="tournament-tag tag-major">' + LEVEL_TAG[e.level] + '</span>' + (e.florida ? '<span class="tournament-tag tag-florida">Florida</span>' : '');
  const where = [e.venue, e.city + ', ' + (e.region === 'FL' ? 'Florida' : e.region)].filter(Boolean).join(', ');
  return '      <div class="tournament-card">\n' +
    '        <div class="tournament-date-box"><div class="tournament-month">' + d.month + '</div><div class="tournament-day">' + d.day + '</div></div>\n' +
    '        <div class="tournament-info">' + tags + '<div class="tournament-name">' + esc(e.name) + '</div><div class="tournament-location">📍 ' + esc(where) + ' · ' + d.range + '</div><div class="tournament-desc">' + esc(e.desc || '') + '</div><a href="' + esc(e.url) + '" target="_blank" rel="noopener" class="tournament-link">Details &amp; Registration →</a></div>\n' +
    '      </div>\n';
}

function scheduleHTML(events) {
  const groups = [
    ['Florida Pro Tour Events &amp; Majors', e => e.florida && (e.level === 'pro' || e.level === 'major')],
    ['Florida Amateur Tournaments', e => e.florida && e.level === 'amateur'],
    ['National Majors', e => !e.florida && e.level === 'major'],
    ['PPA Tour Europe &amp; International', e => e.level === 'europe'],
  ];
  let html = '';
  for (const [title, fn] of groups) {
    const list = events.filter(fn);
    if (!list.length) continue;
    html += '      <h3 class="schedule-group" style="font-family:\'Playfair Display\',serif; font-size:1.3rem; font-weight:400; color:var(--navy); margin:2rem 0 1rem;">' + title + '</h3>\n' + list.map(eventCard).join('');
  }
  html += '      <p style="font-size:0.8rem; opacity:0.7; margin-top:1.5rem; line-height:1.7;">Looking for more local events? Search every sanctioned Florida tournament on <a href="https://pickleballtournaments.com" target="_blank" rel="noopener" style="color:var(--coral);">pickleballtournaments.com</a> and <a href="https://usapickleball.org/tournaments/" target="_blank" rel="noopener" style="color:var(--coral);">USA Pickleball</a>.</p>\n';
  return html;
}

function eventsSchema(events) {
  return events.slice(0, 15).map(e => '<script type="application/ld+json">' + JSON.stringify({
    '@context': 'https://schema.org', '@type': 'SportsEvent', name: e.name, startDate: e.start, endDate: e.end,
    eventStatus: 'https://schema.org/EventScheduled', eventAttendanceMode: 'https://schema.org/OfflineEventAttendanceMode', sport: 'Pickleball',
    location: { '@type': 'Place', name: e.venue || e.city, address: { '@type': 'PostalAddress', addressLocality: e.city, addressRegion: e.region.length === 2 ? e.region : undefined, addressCountry: e.region.length === 2 ? 'US' : e.region } },
    url: e.url, description: e.desc || undefined
  }) + '</script>').join('\n') + '\n';
}

// ---------- news renderers ----------
const shortDate = iso => { if (!iso) return ''; const d = new Date(iso); return MONTHS[d.getUTCMonth()] + ' ' + d.getUTCDate(); };
const stamp = updated => 'Updated ' + new Date(updated).toLocaleDateString('en-US', { month: 'long', day: 'numeric', year: 'numeric', timeZone: 'America/New_York' });

function newsList(items, title, updated) {
  if (!items.length) return '';
  return '        <div class="news-sources">\n          <div class="news-source-title">' + title + ' <span style="font-size:0.65rem; letter-spacing:1px; opacity:0.5; font-family:Montserrat,sans-serif;">· ' + stamp(updated) + '</span></div>\n' +
    items.map(i => '          <div class="news-link-item"><div class="news-link-source">' + esc(i.source) + (i.date ? ' · ' + shortDate(i.date) : '') + '</div><div class="news-link-title"><a href="' + esc(i.link) + '" target="_blank" rel="noopener nofollow">' + esc(i.title) + ' →</a></div></div>').join('\n') +
    '\n        </div>\n';
}

function cardList(items, updated, heading) {
  if (!items.length) return '';
  return '<div style="max-width:1000px; margin:0 auto; padding:1rem clamp(1rem, 4vw, 2.5rem) 2rem;">\n' +
    '  <p style="font-size:0.65rem; letter-spacing:5px; text-transform:uppercase; color:#2CCCD3; margin-bottom:0.5rem;">Live Feed · ' + stamp(updated) + '</p>\n' +
    '  <h2 style="font-family:\'Playfair Display\',serif; font-size:1.7rem; font-weight:400; color:#16324F; margin-bottom:1rem;">' + heading + '</h2>\n' +
    '  <ul style="list-style:none; border-top:1px solid rgba(22,50,79,0.12);">\n' +
    items.map(i => '    <li style="padding:0.9rem 0; border-bottom:1px solid rgba(22,50,79,0.12);"><div style="font-size:0.62rem; letter-spacing:2px; text-transform:uppercase; color:#FF6F61; margin-bottom:0.25rem;">' + esc(i.source) + (i.date ? ' · ' + shortDate(i.date) : '') + '</div><a href="' + esc(i.link) + '" target="_blank" rel="noopener nofollow" style="font-family:\'Playfair Display\',serif; font-size:1.05rem; color:#16324F; text-decoration:none; line-height:1.4;">' + esc(i.title) + ' →</a></li>').join('\n') +
    '\n  </ul>\n</div>\n';
}

function homeBlock(sections, events, updated) {
  const news = sections.florida.slice(0, 4);
  const next = events.filter(e => e.florida).slice(0, 3);
  if (!news.length && !next.length) return '';
  const ev = next.map(e => { const d = dateParts(e); return '<a href="/pages/tournaments.html" style="display:block; background:#fff; border-left:3px solid #FF6F61; border-radius:4px; padding:1rem 1.2rem; text-decoration:none; color:#16324F;"><div style="font-size:0.65rem; letter-spacing:2px; text-transform:uppercase; color:#FF6F61;">' + d.range + '</div><div style="font-family:\'Playfair Display\',serif; font-size:1.05rem; margin:0.3rem 0;">' + esc(e.name) + '</div><div style="font-size:0.78rem; opacity:0.65;">' + esc(e.city) + ', Florida</div></a>'; }).join('\n      ');
  const nw = news.map(i => '<li style="padding:0.7rem 0; border-bottom:1px solid rgba(22,50,79,0.1);"><div style="font-size:0.62rem; letter-spacing:2px; text-transform:uppercase; color:#2CCCD3;">' + esc(i.source) + (i.date ? ' · ' + shortDate(i.date) : '') + '</div><a href="' + esc(i.link) + '" target="_blank" rel="noopener nofollow" style="color:#16324F; text-decoration:none; font-size:0.95rem; line-height:1.45;">' + esc(i.title) + '</a></li>').join('\n        ');
  return '<div style="max-width:1100px; margin:0 auto; padding:3.5rem 2rem;">\n' +
    '  <p style="font-size:0.65rem; letter-spacing:5px; text-transform:uppercase; color:#2CCCD3; margin-bottom:0.75rem; text-align:center;">This Week In Florida Pickleball · ' + stamp(updated) + '</p>\n' +
    '  <h2 style="font-family:\'Playfair Display\',serif; font-size:2rem; font-weight:400; color:#16324F; text-align:center; margin-bottom:2rem;">Upcoming Tournaments &amp; Latest News</h2>\n' +
    '  <div style="display:grid; grid-template-columns:repeat(auto-fit, minmax(280px, 1fr)); gap:2rem;">\n' +
    '    <div style="display:grid; gap:1rem; align-content:start;">\n      ' + ev + '\n      <a href="/pages/tournaments.html" style="font-size:0.72rem; letter-spacing:3px; text-transform:uppercase; color:#16324F;">Full Florida Tournament Schedule →</a>\n    </div>\n' +
    '    <ul style="list-style:none; border-top:1px solid rgba(22,50,79,0.1);">\n        ' + nw + '\n    </ul>\n  </div>\n</div>\n';
}

// ---------- page injection ----------
function inject(html, name, content) {
  const re = new RegExp('(<!-- FEED:' + name + ' START -->)[\\s\\S]*?(<!-- FEED:' + name + ' END -->)');
  if (!re.test(html)) { console.log('  marker FEED:' + name + ' not found, skipped'); return html; }
  return html.replace(re, (_, a, b) => a + '\n' + content + b);
}

function updatePage(rel, blocks) {
  const file = path.join(ROOT, rel);
  if (!fs.existsSync(file)) return;
  const raw = fs.readFileSync(file, 'utf8');
  let html = raw;
  for (const [name, content] of Object.entries(blocks)) html = inject(html, name, content);
  if (html !== raw) { fs.writeFileSync(file, html); console.log('updated ' + rel); }
}

// ---------- main ----------
async function main() {
  const previous = fs.existsSync(FEEDS_JSON) ? JSON.parse(fs.readFileSync(FEEDS_JSON, 'utf8')) : null;
  let all = [];
  if (process.env.FEEDS_FIXTURE) {
    all = JSON.parse(fs.readFileSync(process.env.FEEDS_FIXTURE, 'utf8'));
  } else {
    console.log('Fetching ' + FEEDS.length + ' feeds...');
    const results = await Promise.all(FEEDS.map(fetchFeed));
    all = results.filter(Boolean).flat();
  }
  const sections = buildSections(all, previous);
  const updated = new Date().toISOString();
  fs.mkdirSync(DATA_DIR, { recursive: true });
  fs.writeFileSync(FEEDS_JSON, JSON.stringify({ updated, sections }, null, 2) + '\n');
  console.log('feeds.json: ' + Object.entries(sections).map(([k, v]) => k + '=' + v.length).join(' '));

  const events = upcomingEvents();
  updatePage('pages/tournaments.html', {
    'world-news': newsList(sections.world, 'Latest From Pickleball Organizations Worldwide', updated),
    'tour-news': newsList(sections.tournaments, 'Tour &amp; Tournament Headlines', updated),
    'florida-news': newsList(sections.florida, 'Florida Pickleball Headlines', updated),
    'schedule': scheduleHTML(events),
    'events-schema': eventsSchema(events),
  });
  updatePage('index.html', { 'home-news': homeBlock(sections, events, updated) });
  updatePage('pages/pickleball-vacations.html', {
    'travel-news': cardList(sections.travel, updated, 'Pickleball Travel News'),
    'europe-events': cardList(events.filter(e => e.level === 'europe').map(e => ({ title: e.name + ' · ' + e.city + ', ' + e.region + ' · ' + dateParts(e).range, link: e.url, source: 'PPA Tour Europe', date: null })), updated, 'Upcoming Pro Events in Europe'),
  });
}

main().catch(err => { console.error(err); process.exit(1); });
