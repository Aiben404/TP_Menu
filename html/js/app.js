/* ═══════════════════════════════════════════════
   SNOWMAN TP MENU — app.js
   ═══════════════════════════════════════════════ */
'use strict';

// ─────────────────────────────────────────────
//  State
// ─────────────────────────────────────────────
let locations   = [];
let history     = [];
let favorites   = loadFavorites();   // persisted in localStorage
let activeTab   = 'all';
let features    = {};
let isAdmin     = false;

// ─────────────────────────────────────────────
//  Resource name (safe — no self-call)
// ─────────────────────────────────────────────
var _nativeGPRN = (typeof GetParentResourceName !== 'undefined') ? GetParentResourceName : null;
function getResourceName() {
    if (_nativeGPRN && _nativeGPRN !== getResourceName) return _nativeGPRN();
    return 'snowman_tpmenu';
}

// ─────────────────────────────────────────────
//  NUI message handler
// ─────────────────────────────────────────────
window.addEventListener('message', function (e) {
    const d = e.data;
    if (!d || !d.action) return;

    switch (d.action) {
        case 'open':
            locations = d.locations || [];
            history   = d.history   || [];
            features  = d.features  || {};
            isAdmin   = d.isAdmin   || false;
            applyPosition(d.position || 'top-left');
            buildTabs();
            setTab('all');
            clearSearch();
            showMenu();            break;
        case 'close':
            hideMenu();
            break;
        case 'historyData':
            history = d.data || [];
            if (activeTab === 'history') renderList();
            break;    }
});

// ─────────────────────────────────────────────
//  Favorites (localStorage)
// ─────────────────────────────────────────────
function loadFavorites() {
    try { return JSON.parse(localStorage.getItem('snowman_tp_favorites') || '[]'); }
    catch(e) { return []; }
}
function saveFavorites() {
    try { localStorage.setItem('snowman_tp_favorites', JSON.stringify(favorites)); }
    catch(e) {}
}
function isFav(id) { return favorites.includes(id); }
function toggleFav(id, e) {
    e.stopPropagation();
    if (isFav(id)) {
        favorites = favorites.filter(f => f !== id);
    } else {
        favorites.push(id);
    }
    saveFavorites();
    renderList();
}

// ─────────────────────────────────────────────
//  Position
// ─────────────────────────────────────────────
function applyPosition(pos) {
    const el = document.getElementById('overlay');
    el.className = el.className.split(' ').filter(c => !c.startsWith('pos-')).join(' ');
    el.classList.add('pos-' + pos);
}

// ─────────────────────────────────────────────
//  Show / Hide
// ─────────────────────────────────────────────
function showMenu() {
    const w = document.getElementById('menuWrapper');
    w.classList.remove('closing');
    document.getElementById('overlay').classList.add('visible');
    setTimeout(() => document.getElementById('searchInput').focus(), 60);
}
function hideMenu() {
    const w = document.getElementById('menuWrapper');
    w.classList.add('closing');
    setTimeout(() => {
        document.getElementById('overlay').classList.remove('visible');
        w.classList.remove('closing');
    }, 180);
}
function closeMenu() {
    hideMenu();
    fetch(`https://${getResourceName()}/close`, {
        method: 'POST', headers: {'Content-Type':'application/json'},
        body: JSON.stringify({})
    });
}

// ─────────────────────────────────────────────
//  Teleport — single click, no confirm
// ─────────────────────────────────────────────
function teleportTo(id, el) {
    const loc = locations.find(l => l.id === id);
    if (!loc) return;
    if (loc.onCooldown) return;

    el.classList.add('flash');
    setTimeout(() => el.classList.remove('flash'), 200);
    hideMenu();

    fetch(`https://${getResourceName()}/teleport`, {
        method: 'POST', headers: {'Content-Type':'application/json'},
        body: JSON.stringify({ id: id, withVehicle: loc.withVehicle || false })
    });
}

// ─────────────────────────────────────────────
//  Build tabs dynamically based on features
// ─────────────────────────────────────────────
function buildTabs() {
    const bar = document.getElementById('tabBar');
    const tabs = [
        { id: 'all',     label: 'All',      icon: '🗺' },
        { id: 'city',    label: 'City',     icon: '🏙' },
        { id: 'jobs',    label: 'Jobs',     icon: '💼' },
        { id: 'vip',     label: 'VIP',      icon: '👑' },
        { id: 'admin',   label: 'Admin',    icon: '🔧', adminOnly: true },
    ];
    if (features.favorites) tabs.splice(1, 0, { id: 'favorites', label: 'Favorites', icon: '⭐' });
    if (features.tpHistory && isAdmin) tabs.push({ id: 'history', label: 'History', icon: '📋', adminOnly: true });

    bar.innerHTML = tabs
        .filter(t => !t.adminOnly || isAdmin)
        .map(t => `<div class="tab" data-cat="${t.id}" onclick="setTab('${t.id}')">
            <span class="tab-icon">${t.icon}</span>${t.label}
        </div>`).join('');
}

// ─────────────────────────────────────────────
//  Tab switching
// ─────────────────────────────────────────────
function setTab(cat) {
    activeTab = cat;
    document.querySelectorAll('.tab').forEach(t => {
        t.classList.toggle('active', t.dataset.cat === cat);
    });
    // Hide search on history tab
    const searchBar = document.getElementById('searchBar');
    searchBar.classList.toggle('hidden', cat === 'history');
    clearSearch();
    renderList();
}

// ─────────────────────────────────────────────
//  Render
// ─────────────────────────────────────────────
function renderList(query) {
    query = query !== undefined ? query : document.getElementById('searchInput').value;
    const q    = query.trim().toLowerCase();
    const list = document.getElementById('locationList');

    document.getElementById('searchClear').classList.toggle('visible', q.length > 0);

    // History tab
    if (activeTab === 'history') {
        renderHistory(list);
        return;
    }

    // Favorites tab
    let pool = locations;
    if (activeTab === 'favorites') {
        pool = locations.filter(l => isFav(l.id));
    } else if (activeTab !== 'all') {
        pool = locations.filter(l => l.cat === activeTab);
    }

    if (q) pool = pool.filter(l =>
        l.name.toLowerCase().includes(q) || l.label.toLowerCase().includes(q)
    );

    if (!pool.length) {
        list.innerHTML = `<div class="empty-state">
            <div class="empty-icon">${activeTab === 'favorites' ? '⭐' : '⊘'}</div>
            <div>${activeTab === 'favorites' ? 'No favorites yet — click ⭐ on any location' : 'No locations found'}</div>
        </div>`;
        return;
    }

    let html = '';
    if (activeTab === 'all') {
        const groups = {};
        pool.forEach(l => {
            const g = l.cat.toUpperCase();
            if (!groups[g]) groups[g] = [];
            groups[g].push(l);
        });
        for (const [name, items] of Object.entries(groups)) {
            html += `<div class="section-label">${name}</div>`;
            items.forEach(l => { html += buildRow(l); });
        }
    } else {
        pool.forEach(l => { html += buildRow(l); });
    }

    list.innerHTML = html;

    // Attach click events
    list.querySelectorAll('.location-item').forEach(el => {
        el.addEventListener('click', function () {
            teleportTo(parseInt(this.dataset.id), this);
        });
    });
}

function buildRow(loc) {
    const fav     = isFav(loc.id);
    const onCd    = loc.onCooldown;
    const cdClass = onCd ? 'on-cooldown' : '';
    const starBtn = features.favorites
        ? `<button class="item-star ${fav ? 'starred' : ''}" onclick="toggleFav(${loc.id}, event)" title="${fav ? 'Remove favorite' : 'Add to favorites'}">${fav ? '★' : '☆'}</button>`
        : '';
    const costBadge = (features.cost && loc.cost > 0)
        ? `<span class="item-cost">$${loc.cost}</span>` : '';
    const cdBadge = onCd
        ? `<span class="item-cooldown-badge">⏱ ${loc.remaining}s</span>` : '';

    return `
    <div class="location-item ${cdClass}" data-id="${loc.id}">
        <div class="item-dot dot-${esc(loc.dot)}"></div>
        <div class="item-info">
            <div class="item-name">${esc(loc.name)}</div>
            <div class="item-meta">
                <span class="item-coords">${esc(loc.coords)}</span>
                ${costBadge}${cdBadge}
            </div>
        </div>
        <div class="item-tag tag-${esc(loc.tag)}">${esc(loc.label)}</div>
        ${starBtn}
        <div class="item-arrow">›</div>
    </div>`;
}

function renderHistory(list) {
    if (!history.length) {
        list.innerHTML = `<div class="empty-state"><div class="empty-icon">📋</div><div>No teleport history yet</div></div>`;
        return;
    }
    list.innerHTML = history.map(h => `
        <div class="history-item">
            <div class="history-time">${esc(h.time)}</div>
            <div class="history-info">
                <div class="history-name">${esc(h.name)}</div>
                <div class="history-player">${esc(h.coords || '')}${h.playerName ? ' · ' + esc(h.playerName) : ''}</div>
            </div>
        </div>`).join('');
}

function esc(s) {
    return String(s||'')
        .replace(/&/g,'&amp;').replace(/</g,'&lt;')
        .replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

// ─────────────────────────────────────────────
//  Search
// ─────────────────────────────────────────────
function filterLocations(val) { renderList(val); }
function clearSearch() {
    document.getElementById('searchInput').value = '';
    renderList('');
}


// ─────────────────────────────────────────────
//  Keyboard
// ─────────────────────────────────────────────
document.addEventListener('keydown', function (e) {
    if (!document.getElementById('overlay').classList.contains('visible')) return;
    if (e.key === 'Escape') { {
            closeMenu();
        }
    }
});

document.getElementById('closeBtn').addEventListener('click', closeMenu);
