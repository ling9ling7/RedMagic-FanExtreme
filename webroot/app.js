
//环境兼容拦截
if (typeof ksu === 'undefined') {
    window.ksu = { exec: function (cmd) { console.log('[ksu模拟]', cmd); return ''; } };
}
//双语翻译
var I18N_EN = {
    //启动遮罩
    "点击屏幕跳过": "Tap anywhere to skip",
    "确认": "Confirm",
    "每行一个包名，如\ncom.tencent.tmgp.sgame\ncom.miHoYo.Yuanshen": "One package name per line, e.g.\ncom.tencent.tmgp.sgame\ncom.miHoYo.Yuanshen",
    //头部/仪表盘
    "RUNNING": "RUNNING",
    "STANDBY": "STANDBY",
    "温度": "Temp",
    "功率": "Power",
    "触控": "Touch",
    //卡片标题
    "风扇极速": "Fan Gear",
    "充电分离": "Charge Separation",
    "触控优化": "Touch Boost",
    "液冷控制": "Liquid Cooling",
    "振动增强": "Vibration Control",
    "频率控制": "Freq Control",
    //通用控件
    "档位": "Level",
    "挡位": "Level",
    "应用": "Apply",
    "设定": "Set",
    "保存": "Save",
    "恢复默认": "Reset",
    "确认修改": "Confirm",
    "取消": "Cancel",
    "关闭": "Close",
    "阈值": "Threshold",
    "增益": "Gain",
    "时长": "Duration",
    "上限": "Limit",
    "小核": "Little",
    "中核": "Mid",
    "大核": "Big",
    "调度器": "Governor",
    "省电": "Power Save",
    "熄屏保持开启": "Keep on when screen off",
    "温度联动": "Thermal Link",
    "触发温度": "Trigger Temp",
    "自动开启": "Auto",
    "自定义开启": "Custom",
    "全局": "Global",
    "指定应用": "Per-App",
    //频率选择器
    "↑ 上下滑动查看更多挡位 ↑": "↑ Scroll for more levels ↑",
    " 频率挡位": " Freq Levels",
    " 个可选挡位": " levels available",
    "频率挡位加载中，请稍后": "Loading frequency levels...",
    //危险警告弹窗
    "危险操作警告": "DANGER WARNING",
    "确认 (30s)": "Confirm (30s)",
    "修改 CPU/GPU 最高频率和调度策略属于低层硬件操作，设置不当可能导致：<br><br>• 系统不稳定、莫名重启或死机<br>• 过热降频/烧毁硬件<br>• 开机卡 logo 无法进系统<br>• 需要重新刷机或恢复备份才能救回<br><br><b>作者不对因使用本功能导致的任何数据丢失、硬件损坏或系统变砖承担任何责任。</b>请确保你已完全理解上述风险并愿意自行承担后果。":
        "Modifying CPU/GPU max frequencies and governors is a low-level hardware operation. Misconfiguration may cause:<br><br>• System instability, random reboots or freezes<br>• Overheating / thermal throttling / hardware damage<br>• Boot loop (stuck at logo)<br>• Reflashing or backup restore required<br><br><b>The author takes NO responsibility for any data loss, hardware damage or bricking caused by this feature.</b>Proceed only if you fully understand and accept these risks.",
    //底部导航
    "日志": "Logs",
    "社群": "Community",
    "支持": "Sponsor",
    "感谢支持": "Thanks for your support",
    "保存到相册": "Save to Gallery",
    "赞助": "Sponsor",
    "请放入赞助图片": "Add sponsor image",
    //关于页
    "作者 & 维护者": "Author & Maintainer",
    "项目地址：": "Repository:",
    "官网：": "Website:",
    "TG频道：": "TG Channel:",
    "版本：": "Version:",
    "内核模块 · 仅限红魔设备": "KernelSU Module · RedMagic devices only",
    "贡献者": "Contributors",
    //CPU 调度器说明
    "关于 CPU 调度器": "About CPU Governors",
    "CPU 调度器决定处理器频率如何根据负载自动升降，不同的调度策略会影响手机的流畅度和耗电。": "The CPU governor decides how frequencies scale with load, affecting smoothness and battery life.",
    "（默认）：高通 WALT 调度，比 schedutil 更跟手省电": " (default): Qualcomm WALT, more responsive & efficient than schedutil",
    "：根据实时负载智能调节，兼顾省电与流畅": ": Smart scaling by real-time load, balanced",
    "：始终锁定最高频率，性能最强但明显费电发热": ": Locks max frequency, best performance but hot & power-hungry",
    "：始终锁定最低频率，极致省电但会卡顿": ": Locks min frequency, extreme battery saving but laggy",
    "：缓慢升降频率曲线，偏向省电保守": ": Slow ramping curve, conservative & battery-friendly",
    //动态状态文案
    "待应用: LV.": "Pending: LV.",
    "正在写入内核...": "Writing to kernel...",
    "内核对齐中...": "Syncing kernel...",
    "同步内核中...": "Syncing kernel...",
    "正在应用新阈值...": "Applying threshold...",
    "正在同步振动参数...": "Syncing vibration params...",
    "参数已修改，请点击保存": "Modified, tap Save",
    "运行中": "Running",
    "待机": "Standby",
    "已分离 · 供电模式": "Separated · Power supply mode",
    "阈值 ": "Threshold ",
    "960Hz · 按应用": "960Hz · Per-App",
    "960Hz · 游戏模式": "960Hz · Game Mode",
    "需开启温控移除": "Requires thermal removal",
    "温控联动 · 自动": "Thermal Link · Auto",
    "待设定: 阈值 ": "Pending: Threshold ",
    "默认：增益": "Default: Gain ",
    "温控联动 · ≥": "Thermal Link · ≥",
    " · 运行中": " · Running",
    "% 时长": "% Dur ",
    "ms 上限": "ms Max ",
    //Toast 消息
    "风扇已开启": "Fan ON",
    "风扇已关闭": "Fan OFF",
    "风扇档位已设为 LV.": "Fan level set to LV.",
    "熄屏保持已开启": "Screen-off keep ON",
    "熄屏保持已关闭": "Screen-off keep OFF",
    "温度联动已关闭": "Thermal link OFF",
    "温度联动待配置 · 请选择模式后应用": "Thermal link pending · pick a mode and apply",
    "自动温度联动已应用": "Auto thermal link applied",
    "触发温度已设为 ": "Trigger temp set to ",
    "充电分离已开启": "Charge separation ON",
    "充电分离已关闭": "Charge separation OFF",
    "阈值范围 20-100": "Threshold range: 20-100",
    "阈值已设定: ": "Threshold set: ",
    "振动增强已开启": "Vibration boost ON",
    "振动增强已关闭": "Vibration boost OFF",
    "振动参数已同步给内核": "Vibration params synced to kernel",
    "液冷控制已开启": "Liquid cooling ON",
    "液冷控制已关闭": "Liquid cooling OFF",
    "液冷控制挡位已设为 LV.": "Pump level set to LV.",
    "液冷熄屏保持已开启": "Pump screen-off keep ON",
    "液冷熄屏保持已关闭": "Pump screen-off keep OFF",
    "液冷温度联动已关闭": "Pump thermal link OFF",
    "液冷温度联动待配置 · 请选择模式后应用": "Pump thermal link pending · pick a mode and apply",
    "液冷自动温度联动已应用": "Pump auto thermal link applied",
    "液冷触发温度已设为 ": "Pump trigger temp set to ",
    "触控优化已开启": "Touch boost ON",
    "触控优化已关闭": "Touch boost OFF",
    "应用列表已保存": "App list saved",
    "频率控制已开启": "Freq control ON",
    "频率控制已关闭": "Freq control OFF",
    "请先开启频率控制": "Enable Freq Control first",
    "请在 config.txt 中先开启温控移除": "Enable thermal removal in config.txt first",
    "已有调度确认中，请先完成或取消": "A confirmation is already pending",
    "请等待 15 秒冷静期结束后再确认": "Please wait for the 15s cooldown",
    "调度已确认，已生效": "Profile confirmed and applied",
    "已恢复系统默认调度": "Restored system defaults",
    "已取消，未修改调度": "Cancelled, no changes made",
    "已选择「": "Preset \"",
    "」预设，请点击应用": "\" selected, tap Apply",
    "调试日志已生成在下载目录": "Debug log saved to Downloads",
    "日志生成失败，请重试": "Log generation failed, retry",
    "正在打开QQ群...": "Opening QQ group...",
    "正在打开浏览器...": "Opening browser...",
    "已保存到相册": "Saved to gallery"
};
var LANG = localStorage.getItem('fex_lang') || ((navigator.language || 'zh').toLowerCase().indexOf('zh') === 0 ? 'zh' : 'en');
function t(s) { return (LANG === 'en' && I18N_EN[s]) ? I18N_EN[s] : s; }
function applyLang() {
    document.querySelectorAll('[data-i18n]').forEach(function (el) {
        if (!el.dataset.zh) el.dataset.zh = el.textContent.trim();
        el.textContent = (LANG === 'en' && I18N_EN[el.dataset.zh]) ? I18N_EN[el.dataset.zh] : el.dataset.zh;
    });
    document.querySelectorAll('[data-i18n-html]').forEach(function (el) {
        if (!el.dataset.zhHtml) el.dataset.zhHtml = el.innerHTML;
        var key = el.dataset.zhHtml.replace(/\s+/g, ' ').trim();
        el.innerHTML = (LANG === 'en' && I18N_EN[key]) ? I18N_EN[key] : el.dataset.zhHtml;
    });
    document.querySelectorAll('[data-i18n-ph]').forEach(function (el) {
        if (!el.dataset.zhPh) el.dataset.zhPh = el.placeholder;
        el.placeholder = (LANG === 'en' && I18N_EN[el.dataset.zhPh]) ? I18N_EN[el.dataset.zhPh] : el.dataset.zhPh;
    });
    var hint = document.getElementById('skipHint');
    if (hint) hint.textContent = t('点击屏幕跳过');
    document.documentElement.lang = (LANG === 'en') ? 'en' : 'zh-CN';
}
function toggleLang() {
    LANG = (LANG === 'zh') ? 'en' : 'zh';
    localStorage.setItem('fex_lang', LANG);
    applyLang();
    var btn = document.getElementById('langBtn');
    if (btn) btn.textContent = (LANG === 'zh') ? 'EN' : '中';
}
document.addEventListener('DOMContentLoaded', function () {
    try {
        var header = document.querySelector('.header');
        if (header && !document.getElementById('langBtn')) {
            var sd = header.querySelector('.status-dot');
            var wrap = document.createElement('div');
            wrap.style.cssText = 'display:flex;align-items:center;gap:10px';
            var lb = document.createElement('button');
            lb.id = 'langBtn';
            lb.className = 'lang-btn';
            lb.textContent = (LANG === 'zh') ? 'EN' : '中';
            lb.onclick = toggleLang;
            if (sd) { wrap.appendChild(sd); }
            wrap.appendChild(lb);
            header.appendChild(wrap);
        }
        applyLang();
    } catch (e) { console.error('i18n init error:', e); }
});
//切换页面交互
let gaugeAnimating = false;
let introSkipped = false;
let currentPage = 0;
const totalPages = 3;
const pageContainer = document.getElementById('pageContainer');
function getDots() { return document.querySelectorAll('.indicator-dot'); }
function goToPage(index) {
    if (index < 0 || index >= totalPages) return;
    currentPage = index;
    pageContainer.style.transform = `translateX(-${currentPage * (100 / totalPages)}%)`;
    updateDots();
}
function updateDots() {
    getDots().forEach((dot, i) => { dot.classList.toggle('active', i === currentPage); });
}
let touchStartX = 0, touchStartY = 0, touchMoved = false;
const wrapper = document.getElementById('pageWrapper');
wrapper.addEventListener('touchstart', (e) => {
    touchStartX = e.touches[0].clientX; touchStartY = e.touches[0].clientY; touchMoved = false;
}, { passive: false });
wrapper.addEventListener('touchmove', (e) => {
    if (e.target.tagName === 'INPUT' && e.target.type === 'range') return;
    if (!touchMoved) {
        const dx = e.touches[0].clientX - touchStartX;
        const dy = e.touches[0].clientY - touchStartY;
        if (Math.abs(dx) > Math.abs(dy) && Math.abs(dx) > 10) { touchMoved = true; e.preventDefault(); }
    }
}, { passive: false });
wrapper.addEventListener('touchend', (e) => {
    if (e.target.tagName === 'INPUT' && e.target.type === 'range') return;
    if (!touchMoved) return;
    const dx = e.changedTouches[0].clientX - touchStartX;
    if (Math.abs(dx) > 50) {
        if (dx < 0 && currentPage < totalPages - 1) goToPage(currentPage + 1);
        else if (dx > 0 && currentPage > 0) goToPage(currentPage - 1);
    }
    touchMoved = false;
});
document.addEventListener('DOMContentLoaded', function () {
    try {
        var mp = ksu.exec('cat /data/adb/modules/FanExtreme/module.prop 2>/dev/null');
        if (mp) {
            var vm = mp.match(/^version=v?(.+)$/m);
            if (vm && vm[1]) {
                var ver = 'v' + vm[1].replace(/\s/g, '');
                var bv = document.getElementById('brandVersion');
                var av = document.getElementById('aboutVersion');
                if (bv) bv.textContent = ver;
                if (av) av.textContent = ver;
            }
        }
    } catch (e) { }
    var pi = document.getElementById('pageIndicator');
    if (pi) pi.addEventListener('click', function (e) {
        var dot = e.target.closest('.indicator-dot');
        if (dot) goToPage(parseInt(dot.getAttribute('data-page')));
    });
});
//启动动画（打字机）
function skipIntro() {
    if (introSkipped) return;
    introSkipped = true;
    const overlay = document.getElementById('introOverlay');
    clearInterval(introTimer);
    overlay.style.opacity = '0';
    overlay.style.transform = 'translateY(-30px)';
    overlay.addEventListener('transitionend', function handler() {
        overlay.removeEventListener('transitionend', handler);
        overlay.remove();
        showMainContent();
    });
}
function showMainContent() {
    document.querySelectorAll('.ctrl-card').forEach((card, i) => {
        setTimeout(() => card.classList.add('visible'), i * 120);
    });
    document.querySelectorAll('.btm-btn').forEach((btn, i) => { setTimeout(() => btn.classList.add('visible'), 360 + i * 80); }); document.querySelectorAll('.perf-preset-btn').forEach((btn, i) => { setTimeout(() => btn.classList.add('visible'), 500 + i * 100); }); var dpi = document.querySelector('.floating-dock .page-indicator'); if (dpi) dpi.classList.add('visible'); var df = document.querySelector('.floating-dock .footer'); if (df) df.classList.add('visible');
    playGaugeAnimation();
}
let introTimer;
(function playIntro() {
    const overlay = document.getElementById('introOverlay');
    const textEl = document.getElementById('introText');
    const skipHint = document.getElementById('skipHint');
    const word = 'FanExtreme';
    const charDelay = 750 / word.length;
    let i = 0;
    overlay.addEventListener('click', skipIntro);
    setTimeout(() => skipHint.classList.add('visible'), 300);
    introTimer = setInterval(() => {
        textEl.textContent += word[i++];
        if (i === word.length) {
            clearInterval(introTimer);
            textEl.style.borderRight = 'none';
            textEl.style.animation = 'none';
            setTimeout(() => { if (!introSkipped) skipIntro(); }, 150);
        }
    }, charDelay);
})();
//仪表启动动画
function easeInOutCubic(t) { return t < .5 ? 4 * t * t * t : 1 - Math.pow(-2 * t + 2, 3) / 2; }
function animateNumber(el, maxValue, durationUp, durationPause, durationDown, suffix, callback) {
    let startTime = null, animId = null;
    const step = (timestamp) => {
        if (!startTime) startTime = timestamp;
        const elapsed = timestamp - startTime;
        if (elapsed <= durationUp) {
            el.textContent = Math.round(easeInOutCubic(elapsed / durationUp) * maxValue) + suffix;
        } else if (elapsed <= durationUp + durationPause) {
            el.textContent = maxValue + suffix;
        } else if (elapsed <= durationUp + durationPause + durationDown) {
            el.textContent = Math.round((1 - easeInOutCubic((elapsed - durationUp - durationPause) / durationDown)) * maxValue) + suffix;
        } else {
            el.textContent = '0' + suffix;
            cancelAnimationFrame(animId);
            if (callback) callback();
            return;
        }
        animId = requestAnimationFrame(step);
    };
    el.textContent = '0' + suffix;
    animId = requestAnimationFrame(step);
}
function startGaugeAnimation(callback) {
    const el = document.getElementById('gaugeFill');
    const pctEl = document.getElementById('batPct');
    const circ = 2 * Math.PI * 65;
    let startTime = null, animId = null;
    const update = (pct) => {
        el.style.strokeDasharray = circ;
        el.style.strokeDashoffset = circ - (pct / 100) * circ;
        el.style.stroke = pct >= 100 ? '#27ae60' : pct > 60 ? '#4caf50' : pct > 20 ? '#e17055' : '#d63031';
        pctEl.textContent = Math.round(pct);
    };
    const step = (timestamp) => {
        if (!startTime) startTime = timestamp;
        const elapsed = timestamp - startTime;
        if (elapsed <= 600) update(easeInOutCubic(elapsed / 600) * 100);
        else if (elapsed <= 900) update(100);
        else if (elapsed <= 1500) update((1 - easeInOutCubic((elapsed - 900) / 600)) * 100);
        else { update(0); cancelAnimationFrame(animId); if (callback) callback(); return; }
        animId = requestAnimationFrame(step);
    };
    update(0); animId = requestAnimationFrame(step);
}
function playGaugeAnimation() {
    if (gaugeAnimating) return;
    gaugeAnimating = true;
    let completed = 0;
    function onComplete() { if (++completed === 4) restoreRealData(); }
    startGaugeAnimation(onComplete);
    animateNumber(document.getElementById('batTemp'), 100, 400, 200, 400, '°', onComplete);
    animateNumber(document.getElementById('chgPower'), 100, 400, 200, 400, 'W', onComplete);
    animateNumber(document.getElementById('touchRate'), 1000, 500, 300, 500, 'Hz', onComplete);
}
function restoreRealData() {
    try {
        var raw = ksu.exec('cat ' + STATUS + ' 2>/dev/null');
        if (!raw) { gaugeAnimating = false; refresh(); return; }
        var s = JSON.parse(raw);
        var el = document.getElementById('gaugeFill');
        var circ = 2 * Math.PI * 65;
        el.style.transition = 'stroke .6s cubic-bezier(.4,0,.2,1), stroke-dashoffset .6s cubic-bezier(.4,0,.2,1)';
        setGauge(parseInt(s.battery) || 0);
        var animCount = 0;
        function onAnimDone() { if (++animCount >= 3) { el.style.transition = 'none'; gaugeAnimating = false; refresh(); } }
        animateNumber(document.getElementById('batTemp'), s.temp_deg || 0, 600, 0, 0, '°', onAnimDone);
        animateNumber(document.getElementById('chgPower'), s.power || 0, 600, 0, 0, 'W', onAnimDone);
        animateNumber(document.getElementById('touchRate'), s.touch_boost ? 960 : 0, 600, 0, 0, 'Hz', onAnimDone);
    } catch (e) { gaugeAnimating = false; refresh(); }
}
//动态背景
(function () {
    var c = document.getElementById('bg'), ctx = c.getContext('2d'), W, H;
    function resize() { W = c.width = window.innerWidth; H = c.height = window.innerHeight; }
    resize(); window.addEventListener('resize', resize);
    var blobs = [
        { x: 0, y: 0, vx: .0012, vy: .0009, r: .7, hue: 340, sat: 50 }, { x: .5, y: 0, vx: -.0008, vy: .0011, r: .65, hue: 220, sat: 40 },
        { x: 1, y: .5, vx: -.001, vy: -.0007, r: .6, hue: 160, sat: 35 }, { x: 0, y: 1, vx: .0009, vy: -.001, r: .55, hue: 30, sat: 45 },
        { x: .5, y: 1, vx: .0011, vy: .0008, r: .5, hue: 270, sat: 30 }
    ];
    function draw() {
        ctx.clearRect(0, 0, W, H); ctx.fillStyle = '#f2efe8'; ctx.fillRect(0, 0, W, H);
        for (var i = 0; i < blobs.length; i++) {
            var b = blobs[i]; b.x += b.vx; b.y += b.vy;
            if (b.x < -b.r) b.x = 1 + b.r; if (b.x > 1 + b.r) b.x = -b.r; if (b.y < -b.r) b.y = 1 + b.r; if (b.y > 1 + b.r) b.y = -b.r;
            var cx = b.x * W, cy = b.y * H, r = b.r * Math.max(W, H);
            var grad = ctx.createRadialGradient(cx, cy, 0, cx, cy, r);
            grad.addColorStop(0, 'hsla(' + b.hue + ',' + b.sat + '%,68%,.5)');
            grad.addColorStop(.5, 'hsla(' + (b.hue + 20) + ',' + (b.sat - 10) + '%,75%,.2)');
            grad.addColorStop(1, 'hsla(' + b.hue + ',' + b.sat + '%,82%,0)');
            ctx.fillStyle = grad; ctx.fillRect(0, 0, W, H);
        }
        requestAnimationFrame(draw);
    }
    draw();
})();
//状态机和路径配置
var CMD = '/data/adb/modules/FanExtreme/webui_cmd';
var STATUS = '/data/adb/modules/FanExtreme/webui_status';
var LOG_PATH = '/sdcard/Download/FanExtreme_debug.log';
//前端解耦状态机：拦截内核旧数据对前端输入状态的强行覆盖
var uiState = {
    fanLevel: { pending: null, applying: null },
    threshold: { pending: null, applying: null },
    vibeGain: { pending: null, applying: null },
    vibeDur: { pending: null, applying: null },
    vibeVmax: { pending: null, applying: null },
    pumpLevel: { pending: null, applying: null },
    tempControl: { pending: false, applying: false, mode: 'auto', threshold: '40' },
    pumpTempControl: { pending: false, applying: false, mode: 'auto', threshold: '40' }
};
var locks = { fan: 0, fanScreenOff: 0, charge: 0, touch: 0, vibe: 0, touchMode: 0, pump: 0, pumpScreenOff: 0, tempCtl: 0, pumpTempCtl: 0 };
var expect = { fan: null, fanScreenOff: null, charge: null, touch: null, vibe: null, touchMode: null, pump: null, pumpScreenOff: null, tempCtl: null, pumpTempCtl: null };
var logDebounceTimer = null;
function sh(s) { ksu.exec('{ ' + s + '; } 2>/dev/null'); }
var MDIR = '/data/adb/modules/FanExtreme';
var FAN_SYS = '/sys/kernel/fan';
var AF = MDIR + '/auto_fan';
var AFS = MDIR + '/auto_fan_screen_off';
var ATC = MDIR + '/auto_temp_control';
var ATCM = MDIR + '/temp_control_mode';
var ATCT = MDIR + '/temp_control_threshold';
var ACH = MDIR + '/auto_charge';
var AT = MDIR + '/auto_touch';
var AV = MDIR + '/auto_vibe';
var AP = MDIR + '/auto_pump';
var APSS = MDIR + '/auto_pump_screen_off';
var PATC = MDIR + '/auto_pump_temp_control';
var PATCM = MDIR + '/pump_temp_control_mode';
var PATCT = MDIR + '/pump_temp_control_threshold';
var VG = MDIR + '/vibe_gain';
var VD = MDIR + '/vibe_duration';
var VV = MDIR + '/vibe_vmax';
var VBE = '/sys/class/leds/vibrator';
var THR = MDIR + '/threshold';
var TM = MDIR + '/touch_mode';
var TA = MDIR + '/touch_apps';
var TAC = MDIR + '/.touch_active';
function cmd(a, v) {
    var d = JSON.stringify({ action: a, value: v || '' });
    ksu.exec("echo '" + d + "' >> " + CMD);
}
function toast(m) {
    var t = document.getElementById('toast');
    t.innerHTML = '';
    t.textContent = m; t.className = 'toast show';
    clearTimeout(t._timeout);
    t._timeout = setTimeout(function () { t.className = 'toast'; }, 2000);
}
function sw(el, on) { el.className = 'ctrl-toggle ' + (on ? 'on' : ''); }
function dot(el, on, color) {
    el.style.background = on ? color : 'var(--txt3)';
    el.style.color = on ? color : 'var(--txt3)';
    if (on) el.classList.add('on'); else el.classList.remove('on');
}
//组件交互逻辑
function handleFanToggle(e) {
    e.stopPropagation();
    var el = document.getElementById('fanSw');
    var on = el.classList.contains('on'),
        nxt = !on;
    expect.fan = nxt; sw(el, nxt);
    if (nxt) sh('touch ' + AF + '; su system -c "chmod 644 ' + FAN_SYS + '/fan_speed_level ' + FAN_SYS + '/fan_enable; echo 1 > ' + FAN_SYS + '/fan_enable; echo 5 > ' + FAN_SYS + '/fan_speed_level; chmod 444 ' + FAN_SYS + '/fan_speed_level"');
    else sh('rm -f ' + AF + '; su system -c "chmod 644 ' + FAN_SYS + '/fan_enable; echo 0 > ' + FAN_SYS + '/fan_enable"');
    locks.fan = Date.now() + 1000;
    cmd('auto_fan', on ? 'off' : 'on');
    toast(on ? t('风扇已关闭') : t('风扇已开启'));
    triggerCardJelly(e.currentTarget, e);
}
function handleFanScreenOffToggle(e) {
    e.stopPropagation();
    var el = document.getElementById('fanScreenOffSw');
    var on = el.classList.contains('on'),
        nxt = !on;
    expect.fanScreenOff = nxt; sw(el, nxt);
    sh(nxt ? 'touch ' + AFS : 'rm -f ' + AFS);
    locks.fanScreenOff = Date.now() + 4000;
    cmd('auto_fan_screen_off', on ? 'off' : 'on');
    toast(on ? t('熄屏保持已关闭') : t('熄屏保持已开启'));
    triggerCardJelly(e.currentTarget, e);
}
function handleTempCtrlToggle(e) {
    e.stopPropagation();
    var el = document.getElementById('tempCtrlSw');
    var on = el.classList.contains('on'),
        nxt = !on;
    sw(el, nxt);
    if (on) {
        sh('rm -f ' + ATC + ' ' + ATCM + ' ' + ATCT + '; su system -c "chmod 644 ' + FAN_SYS + '/fan_enable; echo 0 > ' + FAN_SYS + '/fan_enable"');
        locks.tempCtl = Date.now() + 4000;
        cmd('temp_control', 'off');
        document.getElementById('tempCtrlOpts').classList.remove('open');
        document.getElementById('tempApplyBtn').style.display = 'none';
        uiState.tempControl.pending = false;
        expect.tempCtl = false;
        toast(t('温度联动已关闭'));
    } else {
        locks.tempCtl = Date.now() + 4000;
        document.getElementById('tempCtrlOpts').classList.add('open');
        applyTempCtrlUI(uiState.tempControl.mode);
        uiState.tempControl.pending = true;
        document.getElementById('tempApplyBtn').style.display = 'inline-block';
        expect.tempCtl = true;
        toast(t('温度联动待配置 · 请选择模式后应用'));
    }
    triggerCardJelly(e.currentTarget, e);
}
function applyTempCtrlUI(mode) {
    document.getElementById('tempCtrlAuto').classList.toggle('active', mode === 'auto');
    document.getElementById('tempCtrlCustom').classList.toggle('active', mode === 'custom');
    document.getElementById('tempCtrlCustomWrap').classList.toggle('open', mode === 'custom');
}
function setTempCtrlMode(mode) {
    applyTempCtrlUI(mode);
    document.getElementById('tempApplyBtn').style.display = 'inline-block';
    uiState.tempControl.mode = mode;
    uiState.tempControl.pending = true;
}
function onTempThrInput() {
    var val = document.getElementById('tempCtrlThr').value;
    document.getElementById('tempApplyBtn').style.display = 'inline-block';
    uiState.tempControl.threshold = val;
    uiState.tempControl.pending = true;
}
function handleTempApply(e) {
    e.stopPropagation();
    var mode = uiState.tempControl.mode;
    var thr = document.getElementById('tempCtrlThr').value || '40';
    if (mode === 'auto') {
        sh('touch ' + ATC + '; echo auto > ' + ATCM);
        cmd('temp_control', 'auto');
        toast(t('自动温度联动已应用'));
    } else {
        uiState.tempControl.threshold = thr;
        sh('touch ' + ATC + '; echo custom > ' + ATCM + '; echo ' + thr + ' > ' + ATCT);
        cmd('temp_control', 'custom|' + thr);
        toast(t('触发温度已设为 ') + thr + '°C');
    }
    locks.tempCtl = Date.now() + 4000;
    document.getElementById('tempApplyBtn').style.display = 'none';
    uiState.tempControl.pending = false;
    uiState.tempControl.applying = true;
    document.getElementById('cFan').classList.remove('pending');
    triggerCardJelly(e.currentTarget, e);
}
function onFanRangeInput() {
    var val = document.getElementById('fanRange').value;
    document.getElementById('fanRv').textContent = val;
    uiState.fanLevel.pending = val;
    document.getElementById('fanDesc').textContent = t('待应用: LV.') + val;
    document.getElementById('cFan').classList.add('pending');
}
function handleFanApply(e) {
    e.stopPropagation();
    var v = document.getElementById('fanRange').value;
    sh('su system -c "chmod 644 ' + FAN_SYS + '/fan_speed_level; echo ' + v + ' > ' + FAN_SYS + '/fan_speed_level; chmod 444 ' + FAN_SYS + '/fan_speed_level"');
    uiState.fanLevel.applying = v;
    uiState.fanLevel.pending = null;
    document.getElementById('fanDesc').textContent = t('正在写入内核...');
    cmd('fan_level', v);
    toast(t('风扇档位已设为 LV.') + v);
    triggerCardJelly(e.currentTarget, e);
}
function handleChargeToggle(e) {
    e.stopPropagation();
    var el = document.getElementById('chargeSw');
    var on = el.classList.contains('on'),
        nxt = !on;
    expect.charge = nxt; sw(el, nxt);
    if (nxt) sh('touch ' + ACH);
    else sh('rm -f ' + ACH + '; settings put global charge_separation_switch 0');
    locks.charge = Date.now() + 1000;
    cmd('auto_charge', on ? 'off' : 'on');
    toast(on ? t('充电分离已关闭') : t('充电分离已开启'));
    triggerCardJelly(e.currentTarget, e);
}
function onThrInput() {
    var val = document.getElementById('thrVal').value;
    uiState.threshold.pending = val;
    document.getElementById('chargeDesc').textContent = t('待设定: 阈值 ') + val + '%';
    document.getElementById('cCharge').classList.add('pending');
}
function handleThrApply(e) {
    e.stopPropagation();
    var v = document.getElementById('thrVal').value;
    if (!v || v < 20 || v > 100) { toast(t('阈值范围 20-100')); return; }
    sh('echo ' + v + ' > ' + THR);
    uiState.threshold.applying = v;
    uiState.threshold._t = Date.now();
    uiState.threshold.pending = null;
    document.getElementById('chargeDesc').textContent = t('正在应用新阈值...');
    cmd('threshold', v);
    toast(t('阈值已设定: ') + v + '%');
    triggerCardJelly(e.currentTarget, e);
}
function handleVibeToggle(e) {
    e.stopPropagation();
    var el = document.getElementById('vibeSw');
    var on = el.classList.contains('on'),
        nxt = !on;
    expect.vibe = nxt; sw(el, nxt);
    sh(nxt ? 'touch ' + AV : 'rm -f ' + AV);
    locks.vibe = Date.now() + 1000;
    cmd('vibe_boost', on ? 'off' : 'on');
    toast(on ? t('振动增强已关闭') : t('振动增强已开启'));
    triggerCardJelly(e.currentTarget, e);
}
function onVibeInput(key) {
    var val = document.getElementById(key).value;
    uiState[key].pending = val;
    document.getElementById('cVibe').classList.add('pending');
    document.getElementById('vibeDesc').textContent = t('参数已修改，请点击保存');
}
function saveVibeAll(e) {
    e.stopPropagation();
    var g = document.getElementById('vibeGain').value || '168';
    var d = document.getElementById('vibeDur').value || '18';
    var v = document.getElementById('vibeVmax').value || '128';
    sh('echo ' + g + ' > ' + VG + '; echo ' + d + ' > ' + VD + '; echo ' + v + ' > ' + VV + '; printf 0x%x ' + g + ' > ' + VBE + '/gain; printf 0x%x ' + d + ' > ' + VBE + '/duration_aw; printf 0x%x ' + v + ' > ' + VBE + '/vmax');
    uiState.vibeGain.applying = g; uiState.vibeGain.pending = null;
    uiState.vibeDur.applying = d; uiState.vibeDur.pending = null;
    uiState.vibeVmax.applying = v; uiState.vibeVmax.pending = null;
    cmd('vibe_gain', g);
    document.getElementById('vibeDesc').textContent = t('正在同步振动参数...');
    toast(t('振动参数已同步给内核'));
    triggerCardJelly(e.currentTarget, e);
}
function handlePumpToggle(e) {
    e.stopPropagation();
    var el = document.getElementById('pumpSw');
    var on = el.classList.contains('on'),
        nxt = !on;
    expect.pump = nxt; sw(el, nxt);
    if (nxt) sh('touch ' + AP);
    else sh('rm -f ' + AP + '; echo 0 > /proc/driver/micropump/enable');
    locks.pump = Date.now() + 1000;
    cmd('auto_pump', on ? 'off' : 'on');
    toast(on ? t('液冷控制已关闭') : t('液冷控制已开启'));
    triggerCardJelly(e.currentTarget, e);
}
function handlePumpScreenOffToggle(e) {
    e.stopPropagation();
    var el = document.getElementById('pumpScreenOffSw');
    var on = el.classList.contains('on'),
        nxt = !on;
    expect.pumpScreenOff = nxt; sw(el, nxt);
    sh(nxt ? 'touch ' + APSS : 'rm -f ' + APSS);
    locks.pumpScreenOff = Date.now() + 4000;
    cmd('auto_pump_screen_off', on ? 'off' : 'on');
    toast(on ? t('液冷熄屏保持已关闭') : t('液冷熄屏保持已开启'));
    triggerCardJelly(e.currentTarget, e);
}
function onPumpRangeInput() {
    var val = document.getElementById('pumpRange').value;
    document.getElementById('pumpRv').textContent = val;
    uiState.pumpLevel.pending = val;
    document.getElementById('pumpDesc').textContent = t('待应用: LV.') + val;
    document.getElementById('cPump').classList.add('pending');
}
function handlePumpApply(e) {
    e.stopPropagation();
    var v = document.getElementById('pumpRange').value;
    var spd = { 1: 40, 2: 60, 3: 80, 4: 90 }[v] || 90;
    sh('su system -c "chmod 644 /proc/driver/micropump/enable /proc/driver/micropump/freq /proc/driver/micropump/speed; echo 1 > /proc/driver/micropump/enable; echo 4 > /proc/driver/micropump/freq; echo ' + spd + ' > /proc/driver/micropump/speed; chmod 444 /proc/driver/micropump/speed"');
    uiState.pumpLevel.applying = v;
    uiState.pumpLevel.pending = null;
    document.getElementById('pumpDesc').textContent = t('正在写入内核...');
    cmd('pump_level', v);
    toast(t('液冷控制挡位已设为 LV.') + v);
    triggerCardJelly(e.currentTarget, e);
}
function handlePumpTempCtrlToggle(e) {
    e.stopPropagation();
    var el = document.getElementById('pumpTempCtrlSw');
    var on = el.classList.contains('on'),
        nxt = !on;
    sw(el, nxt);
    if (on) {
        sh('rm -f ' + PATC + ' ' + PATCM + ' ' + PATCT + '; echo 0 > /proc/driver/micropump/enable');
        locks.pumpTempCtl = Date.now() + 4000;
        cmd('pump_temp_control', 'off');
        document.getElementById('pumpTempCtrlOpts').classList.remove('open');
        document.getElementById('pumpTempApplyBtn').style.display = 'none';
        uiState.pumpTempControl.pending = false;
        expect.pumpTempCtl = false;
        toast(t('液冷温度联动已关闭'));
    } else {
        locks.pumpTempCtl = Date.now() + 4000;
        document.getElementById('pumpTempCtrlOpts').classList.add('open');
        applyPumpTempCtrlUI(uiState.pumpTempControl.mode);
        uiState.pumpTempControl.pending = true;
        document.getElementById('pumpTempApplyBtn').style.display = 'inline-block';
        expect.pumpTempCtl = true;
        toast(t('液冷温度联动待配置 · 请选择模式后应用'));
    }
    triggerCardJelly(e.currentTarget, e);
}
function applyPumpTempCtrlUI(mode) {
    document.getElementById('pumpTempCtrlAuto').classList.toggle('active', mode === 'auto');
    document.getElementById('pumpTempCtrlCustom').classList.toggle('active', mode === 'custom');
    document.getElementById('pumpTempCtrlCustomWrap').classList.toggle('open', mode === 'custom');
}
function setPumpTempMode(mode) {
    applyPumpTempCtrlUI(mode);
    document.getElementById('pumpTempApplyBtn').style.display = 'inline-block';
    uiState.pumpTempControl.mode = mode;
    uiState.pumpTempControl.pending = true;
}
function onPumpTempThrInput() {
    var val = document.getElementById('pumpTempCtrlThr').value;
    document.getElementById('pumpTempApplyBtn').style.display = 'inline-block';
    uiState.pumpTempControl.threshold = val;
    uiState.pumpTempControl.pending = true;
}
function handlePumpTempApply(e) {
    e.stopPropagation();
    var mode = uiState.pumpTempControl.mode;
    var thr = document.getElementById('pumpTempCtrlThr').value || '40';
    if (mode === 'auto') {
        sh('touch ' + PATC + '; echo auto > ' + PATCM);
        cmd('pump_temp_control', 'auto');
        toast(t('液冷自动温度联动已应用'));
    } else {
        uiState.pumpTempControl.threshold = thr;
        sh('touch ' + PATC + '; echo custom > ' + PATCM + '; echo ' + thr + ' > ' + PATCT);
        cmd('pump_temp_control', 'custom|' + thr);
        toast(t('液冷触发温度已设为 ') + thr + '°C');
    }
    locks.pumpTempCtl = Date.now() + 4000;
    document.getElementById('pumpTempApplyBtn').style.display = 'none';
    uiState.pumpTempControl.pending = false;
    uiState.pumpTempControl.applying = true;
    document.getElementById('cPump').classList.remove('pending');
    triggerCardJelly(e.currentTarget, e);
}
function setTouchMode(mode) {
    document.getElementById('touchModeGlobal').classList.toggle('active', mode === 'global');
    document.getElementById('touchModePerapp').classList.toggle('active', mode === 'perapp');
    document.getElementById('touchAppsWrap').classList.toggle('open', mode === 'perapp');
    if (mode === 'perapp') {
        sh('echo perapp > ' + TM + '; rm -f ' + TAC);
    } else {
        sh('rm -f ' + TM + ' ' + TAC);
    }
    cmd('touch_mode', mode);
    var apps = document.getElementById('touchApps').value;
    if (apps) { var v = apps.replace(/\n/g, ',').replace(/\s/g, ''); setTimeout(function () { cmd('touch_apps', v); }, 1200); }
}
function saveTouchApps(e) {
    e.stopPropagation();
    var val = document.getElementById('touchApps').value;
    val = val.replace(/\n/g, ',').replace(/\s/g, '');
    cmd('touch_apps', val);
    var mode = document.getElementById('touchModePerapp').classList.contains('active') ? 'perapp' : 'global';
    if (mode === 'perapp') {
        sh('echo perapp > ' + TM + '; rm -f ' + TAC);
    } else {
        sh('rm -f ' + TM + ' ' + TAC);
    }
    setTimeout(function () { cmd('touch_mode', mode); }, 1200);
    document.getElementById('touchApps').value = val.replace(/,/g, '\n');
    toast(t('应用列表已保存'));
    triggerCardJelly(e.currentTarget, e);
}
function handleTouchToggle(e) {
    e.stopPropagation();
    var el = document.getElementById('touchSw');
    var on = el.classList.contains('on'),
        nxt = !on;
    expect.touch = nxt; sw(el, nxt);
    if (nxt) sh('touch ' + AT + '; [ -e /proc/touchscreen/tp_report_rate ] && { echo 4 > /proc/touchscreen/tp_report_rate; echo 1 > /proc/touchscreen/play_game; echo 4 > /proc/touchscreen/follow_hand_level; }; settings put system touch_sampling_rate 960');
    else sh('rm -f ' + AT + '; [ -e /proc/touchscreen/tp_report_rate ] && { echo 1 > /proc/touchscreen/tp_report_rate; echo 0 > /proc/touchscreen/play_game; echo 1 > /proc/touchscreen/follow_hand_level; }; settings delete system touch_sampling_rate');
    locks.touch = Date.now() + 1000;
    cmd('touch_boost', on ? 'off' : 'on');
    toast(on ? t('触控优化已关闭') : t('触控优化已开启'));
    triggerCardJelly(e.currentTarget, e);
}
function handleLogClick(e) { triggerCardJelly(e.currentTarget, e); try { genLog(); } catch (err) { } }
function handleQQClick(e) { triggerCardJelly(e.currentTarget, e); try { joinQQ(); } catch (err) { } }
function handleSponsorClick(e) { triggerCardJelly(e.currentTarget, e); try { showSponsor(); } catch (err) { } }
//按钮卡片点击立体果冻效果
function triggerCardJelly(btn, e) {
    const card = btn.closest('.ctrl-card') || btn;
    if (card.classList.contains('disabled')) return;
    const clientX = e.clientX || (e.touches && e.touches[0] ? e.touches[0].clientX : 0);
    const clientY = e.clientY || (e.touches && e.touches[0] ? e.touches[0].clientY : 0);
    const rect = card.getBoundingClientRect();
    const dx = clientX - (rect.left + rect.width / 2);
    const dy = clientY - (rect.top + rect.height / 2);
    card.style.transition = 'none';
    card.style.transform = `perspective(800px) rotateX(${-(dy / (rect.height / 2)) * 8}deg) rotateY(${(dx / (rect.width / 2)) * 8}deg) scale3d(.94,.94,1)`;
    card.offsetHeight;
    card.style.transition = 'transform .5s cubic-bezier(.34,1.56,.64,1)';
    card.style.transform = '';
}
function setGauge(pct) {
    var circ = 2 * Math.PI * 65;
    var el = document.getElementById('gaugeFill');
    el.style.strokeDasharray = circ;
    el.style.strokeDashoffset = circ - (pct / 100) * circ;
    el.style.stroke = pct >= 100 ? '#27ae60' : pct > 60 ? '#4caf50' : pct > 20 ? '#e17055' : '#d63031';
    document.getElementById('batPct').textContent = pct;
}
//高精度隔离对齐刷新引擎
function refresh() {
    if (gaugeAnimating) return;
    try {
        var raw = ksu.exec('cat ' + STATUS + ' 2>/dev/null');
        if (!raw) return;
        var s = JSON.parse(raw);
        //仪表盘基础状态更新
        if (s.battery) setGauge(parseInt(s.battery));
        if (s.temp_deg) document.getElementById('batTemp').textContent = s.temp_deg + '°';
        document.getElementById('chgPower').textContent = s.power ? s.power + 'W' : '--';
        //FAN刷新保护
        var cFan = document.getElementById('cFan');
        if (s.fan_enabled === 1) {
            cFan.classList.remove('disabled');
            var fanOn = s.auto_fan === 1;
            if (Date.now() < locks.fan && expect.fan !== null && fanOn === expect.fan) { expect.fan = null; }
            if (Date.now() >= locks.fan) sw(document.getElementById('fanSw'), fanOn);
            dot(document.getElementById('fanDot'), fanOn, 'var(--gauge-green)');
            if (fanOn) cFan.classList.add('active'); else cFan.classList.remove('active');
            var fanScreenOffOn = s.auto_fan_screen_off === 1;
            if (Date.now() < locks.fanScreenOff && expect.fanScreenOff !== null && fanScreenOffOn === expect.fanScreenOff) { expect.fanScreenOff = null; }
            if (Date.now() >= locks.fanScreenOff) sw(document.getElementById('fanScreenOffSw'), fanScreenOffOn);
            var tempCtrlOn = s.temp_control === 1;
            if (Date.now() < locks.tempCtl && expect.tempCtl !== null && tempCtrlOn === expect.tempCtl) { expect.tempCtl = null; }
            if (uiState.tempControl.pending) {
                document.getElementById('tempApplyBtn').style.display = 'inline-block';
            } else {
                if (Date.now() >= locks.tempCtl) {
                    sw(document.getElementById('tempCtrlSw'), tempCtrlOn);
                    document.getElementById('tempCtrlOpts').classList.toggle('open', tempCtrlOn);
                    if (tempCtrlOn) {
                        var tcm = s.temp_ctrl_mode || 'auto';
                        document.getElementById('tempCtrlAuto').classList.toggle('active', tcm === 'auto');
                        document.getElementById('tempCtrlCustom').classList.toggle('active', tcm === 'custom');
                        document.getElementById('tempCtrlCustomWrap').classList.toggle('open', tcm === 'custom');
                        document.getElementById('tempCtrlThr').value = s.temp_ctrl_threshold || '40';
                        uiState.tempControl.mode = tcm;
                        uiState.tempControl.threshold = s.temp_ctrl_threshold || '40';
                    }
                    document.getElementById('tempApplyBtn').style.display = 'none';
                }
            }
            if (uiState.tempControl.applying && !uiState.tempControl.pending) {
                uiState.tempControl.applying = false;
            }
            //检查写入是否完成对齐
            if (uiState.fanLevel.applying !== null && String(s.fan_level) === String(uiState.fanLevel.applying)) {
                uiState.fanLevel.applying = null;
            }
            //控制权展现分配
            if (uiState.fanLevel.pending !== null) {
                document.getElementById('fanRv').textContent = uiState.fanLevel.pending;
            } else if (uiState.fanLevel.applying !== null) {
                document.getElementById('fanRv').textContent = uiState.fanLevel.applying;
                document.getElementById('fanRange').value = uiState.fanLevel.applying;
                document.getElementById('fanDesc').textContent = t('内核对齐中...');
            } else {
                document.getElementById('fanRv').textContent = s.fan_level || '--';
                document.getElementById('fanRange').value = s.fan_level || 5;
                document.getElementById('fanDesc').textContent = (s.temp_control === 1) ? (s.temp_ctrl_mode === 'auto' ? t('温控联动 · 自动') : t('温控联动 · ≥') + (s.temp_ctrl_threshold || '40') + '°C LV.5') : (fanOn ? 'LV.' + s.fan_level + t(' · 运行中') : t('待机'));
                cFan.classList.remove('pending');
            }
        } else { cFan.classList.add('disabled'); }
        //CHARGE刷新保护
        var cCharge = document.getElementById('cCharge');
        if (s.charge_enabled === 1) {
            cCharge.classList.remove('disabled');
            var chargeOn = s.auto_charge === 1;
            if (Date.now() < locks.charge && expect.charge !== null && chargeOn === expect.charge) { expect.charge = null; }
            if (Date.now() >= locks.charge) sw(document.getElementById('chargeSw'), chargeOn);
            var sep = s.cs === '1';
            dot(document.getElementById('chargeDot'), sep, 'var(--gauge-green)');
            if (sep) cCharge.classList.add('active'); else cCharge.classList.remove('active');
            //检查写入是否完成对齐
            if (uiState.threshold.applying !== null && String(s.threshold) === String(uiState.threshold.applying)) {
                uiState.threshold.applying = null;
            }
            //超时兜底：5秒未对齐则放弃，避免永久卡同步
            if (uiState.threshold.applying !== null && Date.now() - (uiState.threshold._t || 0) > 5000) {
                uiState.threshold.applying = null;
            }
            if (uiState.threshold.pending !== null) {
                //打字编辑中不做覆盖
            } else if (uiState.threshold.applying !== null) {
                document.getElementById('thrVal').value = uiState.threshold.applying;
                document.getElementById('chargeDesc').textContent = t('同步内核中...');
            } else {
                document.getElementById('thrVal').value = s.threshold || '';
                document.getElementById('chargeDesc').textContent = sep ? t('已分离 · 供电模式') : t('阈值 ') + (s.threshold || '100') + '%';
                cCharge.classList.remove('pending');
            }
        } else { cCharge.classList.add('disabled'); }
        //VIBE刷新保护
        var cVibe = document.getElementById('cVibe');
        if (s.vibe_enabled === 1) {
            cVibe.classList.remove('disabled');
            var vibeOn = s.auto_vibe === 1;
            if (Date.now() < locks.vibe && expect.vibe !== null && vibeOn === expect.vibe) { expect.vibe = null; }
            if (Date.now() >= locks.vibe) sw(document.getElementById('vibeSw'), vibeOn);
            dot(document.getElementById('vibeDot'), vibeOn, 'var(--gauge-green)');
            if (vibeOn) cVibe.classList.add('active'); else cVibe.classList.remove('active');
            if (uiState.vibeGain.applying !== null && String(s.vibe_gain) === String(uiState.vibeGain.applying)) uiState.vibeGain.applying = null;
            if (uiState.vibeDur.applying !== null && String(s.vibe_duration) === String(uiState.vibeDur.applying)) uiState.vibeDur.applying = null;
            if (uiState.vibeVmax.applying !== null && String(s.vibe_vmax) === String(uiState.vibeVmax.applying)) uiState.vibeVmax.applying = null;
            var isAnyPending = (uiState.vibeGain.pending !== null || uiState.vibeDur.pending !== null || uiState.vibeVmax.pending !== null);
            var isAnyApplying = (uiState.vibeGain.applying !== null || uiState.vibeDur.applying !== null || uiState.vibeVmax.applying !== null);
            if (isAnyPending) {
                //输入中不做任何轮询打扰
            } else if (isAnyApplying) {
                document.getElementById('vibeDesc').textContent = t('内核对齐中...');
                if (uiState.vibeGain.applying !== null) document.getElementById('vibeGain').value = uiState.vibeGain.applying;
                if (uiState.vibeDur.applying !== null) document.getElementById('vibeDur').value = uiState.vibeDur.applying;
                if (uiState.vibeVmax.applying !== null) document.getElementById('vibeVmax').value = uiState.vibeVmax.applying;
            } else {
                document.getElementById('vibeGain').value = s.vibe_gain || '';
                document.getElementById('vibeDur').value = s.vibe_duration || '';
                document.getElementById('vibeVmax').value = s.vibe_vmax || '';
                document.getElementById('vibeDesc').textContent = vibeOn ? (t('默认：增益') + (s.vibe_gain_def || '168') + t('% 时长') + (s.vibe_dur_def || '18') + t('ms 上限') + (s.vibe_vmax_def || '128')) : t('待机');
                cVibe.classList.remove('pending');
            }
        } else { cVibe.classList.add('disabled'); }
        //PUMP刷新保护
        var cPump = document.getElementById('cPump');
        if (s.pump_available === 1) {
            cPump.classList.remove('disabled');
            var pumpOn = s.auto_pump === 1;
            if (Date.now() < locks.pump && expect.pump !== null && pumpOn === expect.pump) { expect.pump = null; }
            if (Date.now() >= locks.pump) sw(document.getElementById('pumpSw'), pumpOn);
            dot(document.getElementById('pumpDot'), pumpOn, 'var(--gauge-green)');
            if (pumpOn) cPump.classList.add('active'); else cPump.classList.remove('active');
            var pumpScreenOffOn = s.auto_pump_screen_off === 1;
            if (Date.now() < locks.pumpScreenOff && expect.pumpScreenOff !== null && pumpScreenOffOn === expect.pumpScreenOff) { expect.pumpScreenOff = null; }
            if (Date.now() >= locks.pumpScreenOff) sw(document.getElementById('pumpScreenOffSw'), pumpScreenOffOn);
            var pumpTempCtrlOn = s.pump_temp_control === 1;
            if (Date.now() < locks.pumpTempCtl && expect.pumpTempCtl !== null && pumpTempCtrlOn === expect.pumpTempCtl) { expect.pumpTempCtl = null; }
            if (uiState.pumpTempControl.pending) {
                document.getElementById('pumpTempApplyBtn').style.display = 'inline-block';
            } else {
                if (Date.now() >= locks.pumpTempCtl) {
                    sw(document.getElementById('pumpTempCtrlSw'), pumpTempCtrlOn);
                    document.getElementById('pumpTempCtrlOpts').classList.toggle('open', pumpTempCtrlOn);
                    if (pumpTempCtrlOn) {
                        var ptcm = s.pump_temp_ctrl_mode || 'auto';
                        document.getElementById('pumpTempCtrlAuto').classList.toggle('active', ptcm === 'auto');
                        document.getElementById('pumpTempCtrlCustom').classList.toggle('active', ptcm === 'custom');
                        document.getElementById('pumpTempCtrlCustomWrap').classList.toggle('open', ptcm === 'custom');
                        document.getElementById('pumpTempCtrlThr').value = s.pump_temp_ctrl_threshold || '40';
                        uiState.pumpTempControl.mode = ptcm;
                        uiState.pumpTempControl.threshold = s.pump_temp_ctrl_threshold || '40';
                    }
                    document.getElementById('pumpTempApplyBtn').style.display = 'none';
                }
            }
            if (uiState.pumpTempControl.applying && !uiState.pumpTempControl.pending) {
                uiState.pumpTempControl.applying = false;
            }
            if (uiState.pumpLevel.applying !== null && String(s.pump_level) === String(uiState.pumpLevel.applying)) {
                uiState.pumpLevel.applying = null;
            }
            if (uiState.pumpLevel.pending !== null) {
                document.getElementById('pumpRv').textContent = uiState.pumpLevel.pending;
            } else if (uiState.pumpLevel.applying !== null) {
                document.getElementById('pumpRv').textContent = uiState.pumpLevel.applying;
                document.getElementById('pumpRange').value = uiState.pumpLevel.applying;
                document.getElementById('pumpDesc').textContent = t('内核对齐中...');
            } else {
                document.getElementById('pumpRv').textContent = s.pump_level || '--';
                document.getElementById('pumpRange').value = s.pump_level || 4;
                document.getElementById('pumpDesc').textContent = (s.pump_temp_control === 1) ? (s.pump_temp_ctrl_mode === 'auto' ? t('温控联动 · 自动') : t('温控联动 · ≥') + (s.pump_temp_ctrl_threshold || '40') + '°C') : (pumpOn ? 'LV.' + s.pump_level + t(' · 运行中') : t('待机'));
                cPump.classList.remove('pending');
            }
        } else { cPump.classList.add('disabled'); }
        //TOUCH刷新分支
        var cTouch = document.getElementById('cTouch');
        if (s.touch_enabled === 1) {
            cTouch.classList.remove('disabled');
            var touchOn = s.touch_boost === 1;
            if (Date.now() < locks.touch && expect.touch !== null && touchOn === expect.touch) { expect.touch = null; }
            if (Date.now() >= locks.touch) sw(document.getElementById('touchSw'), touchOn);
            dot(document.getElementById('touchDot'), touchOn, 'var(--gauge-green)');
            if (touchOn) cTouch.classList.add('active'); else cTouch.classList.remove('active');
            document.getElementById('touchDesc').textContent = touchOn ? (typeof touchModeInited === 'undefined' && s.touch_mode === 'perapp' ? t('960Hz · 按应用') : t('960Hz · 游戏模式')) : t('待机');
            if (typeof touchModeInited === 'undefined') {
                touchModeInited = true;
                var tm = s.touch_mode === 'perapp' ? 'perapp' : 'global';
                document.getElementById('touchModeGlobal').classList.toggle('active', tm === 'global');
                document.getElementById('touchModePerapp').classList.toggle('active', tm === 'perapp');
                document.getElementById('touchAppsWrap').classList.toggle('open', tm === 'perapp');
                if (tm === 'perapp' && s.touch_apps) document.getElementById('touchApps').value = s.touch_apps.replace(/,/g, '\n');
            }
            document.getElementById('touchRate').textContent = touchOn ? '960Hz' : '--';
        } else { cTouch.classList.add('disabled'); }
        //PERF主开关刷新
        if (typeof s.perf_enabled !== 'undefined') {
            perfThermalOk = s.thermal_enabled === 1;
            if (!perfThermalOk) {
                document.getElementById('cPerfMaster').classList.add('disabled');
                document.getElementById('perfMasterDesc').textContent = t('需开启温控移除');
            } else {
                document.getElementById('cPerfMaster').classList.remove('disabled');
            }
            var perfOn = s.perf_enabled === 1;
            if (Date.now() < perfLocks.master && perfExpect.master !== null && perfOn === perfExpect.master) { perfExpect.master = null; }
            if (Date.now() >= perfLocks.master) sw(document.getElementById('perfSw'), perfOn);
            dot(document.getElementById('perfMasterDot'), perfOn, 'var(--gauge-green)');
            document.getElementById('perfMasterDesc').textContent = perfOn ? t('运行中') : 'STANDBY';
            if (perfOn) document.getElementById('cPerfMaster').classList.add('active');
            else document.getElementById('cPerfMaster').classList.remove('active');
        }
        //每轮刷新更新频率挡位
        if (s.cpu0_steps) perfStepLists.cpu0 = s.cpu0_steps.split(',').map(Number).sort(function (a, b) { return a - b; });
        if (s.cpu4_steps) perfStepLists.cpu4 = s.cpu4_steps.split(',').map(Number).sort(function (a, b) { return a - b; });
        if (s.cpu7_steps) perfStepLists.cpu7 = s.cpu7_steps.split(',').map(Number).sort(function (a, b) { return a - b; });
        if (s.gpu_steps) perfStepLists.gpu = s.gpu_steps.split(',').map(Number).sort(function (a, b) { return a - b; });
    } catch (e) { console.error('refresh error:', e); }
    try { loadPerfStatus(); } catch (e) { }
    try {
        if (typeof s.cpu_cur !== 'undefined') {
            var cpuMax = parseInt(s.cpu7_max) || parseInt(s.cpu4_max) || parseInt(s.cpu0_max) || 0;
            var gpuMax = parseInt(s.gpu_max) || 903000000;
            updatePerfGauges(cpuMax, parseInt(s.cpu_cur) || 0, gpuMax, parseInt(s.gpu_cur) || 0, s.perf_enabled === 1);
        }
    } catch (e) { }
}
function openFreqPicker(fieldId, label) {
    var steps = perfStepLists[fieldId === 'cpu0Max' ? 'cpu0' : fieldId === 'cpu4Max' ? 'cpu4' : fieldId === 'cpu7Max' ? 'cpu7' : 'gpu'];
    if (!steps || steps.length === 0) { toast(t('频率挡位加载中，请稍后')); return; }
    freqPickerTarget = fieldId;
    var isGpu = fieldId === 'gpuMax';
    var div = isGpu ? 1000000 : 1000;
    document.getElementById('freqOvTitle').textContent = t(label) + t(' 频率挡位');
    document.getElementById('freqOvSub').textContent = steps.length + t(' 个可选挡位');
    var grid = document.getElementById('freqOvGrid');
    var curVal = parseInt(document.getElementById(fieldId).value) || 0;
    steps.sort(function (a, b) { return b - a; });
    var html = '';
    for (var i = 0; i < steps.length; i++) {
        var displayVal = Math.round(steps[i] / div);
        var cls = 'freq-opt';
        if (displayVal === curVal) cls += ' current';
        html += '<button class="' + cls + '" onclick="selectFreq(' + steps[i] + ')">' + displayVal + '</button>';
    }
    grid.innerHTML = html;
    document.getElementById('freqOv').classList.add('show');
    var hint = document.getElementById('freqScrollHint');
    if (hint && steps.length > 8) { setTimeout(function () { hint.classList.add('show'); }, 400); }
    grid.scrollTop = 0;
}
function selectFreq(val) {
    if (!freqPickerTarget) return;
    var isGpu = freqPickerTarget === 'gpuMax';
    var div = isGpu ? 1000000 : 1000;
    document.getElementById(freqPickerTarget).value = Math.round(val / div);
    onPerfInput();
    closeFreqPicker();
} function closeFreqPicker() {
    document.querySelectorAll('.page').forEach(function (p) { p.style.overflow = ''; }); document.getElementById('freqOv').classList.remove('show');
    freqPickerTarget = '';
}
var perfInitialized = false;
var perfInputsSet = false;
var perfRetry = 0;
function loadPerfStatus() {
    if (perfInitialized) return;
    try {
        var raw = ksu.exec('cat ' + STATUS + ' 2>/dev/null');
        if (!raw) return;
        var s = JSON.parse(raw);
        if (typeof s.perf_enabled === 'undefined') return;
        if (typeof s.cluster_count !== 'undefined') {
            clusterCount = parseInt(s.cluster_count) || 3;
            var showMid = clusterCount >= 3;
            var r4 = document.getElementById('cpu4Row'); if (r4) r4.style.display = showMid ? '' : 'none';
            var h4 = document.getElementById('cpu4Hint'); if (h4) h4.style.display = showMid ? '' : 'none';
        }
        perfThermalOk = s.thermal_enabled === 1;
        if (!perfThermalOk) {
            document.getElementById('cPerfMaster').classList.add('disabled');
            document.getElementById('perfMasterDesc').textContent = t('需开启温控移除');
        }
        var perfOn = s.perf_enabled === 1;
        if (Date.now() >= perfLocks.master) sw(document.getElementById('perfSw'), perfOn);
        dot(document.getElementById('perfMasterDot'), perfOn, 'var(--gauge-green)');
        document.getElementById('perfMasterDesc').textContent = perfOn ? t('运行中') : 'STANDBY';
        if (perfOn) document.getElementById('cPerfMaster').classList.add('active');
        //从后端加载频率步进列表
        if (s.cpu0_steps) perfStepLists.cpu0 = s.cpu0_steps.split(',').map(Number).sort(function (a, b) { return a - b; });
        if (s.cpu4_steps) perfStepLists.cpu4 = s.cpu4_steps.split(',').map(Number).sort(function (a, b) { return a - b; });
        if (s.cpu7_steps) perfStepLists.cpu7 = s.cpu7_steps.split(',').map(Number).sort(function (a, b) { return a - b; });
        if (s.gpu_steps) perfStepLists.gpu = s.gpu_steps.split(',').map(Number).sort(function (a, b) { return a - b; });
        if (s.cpu0_hw_max) {
            perfHw = {
                cpu0_max: parseInt(s.cpu0_hw_max), cpu0_min: parseInt(s.cpu0_hw_min),
                cpu4_max: parseInt(s.cpu4_hw_max) || parseInt(s.cpu7_hw_max), cpu4_min: parseInt(s.cpu4_hw_min) || parseInt(s.cpu7_hw_min),
                cpu7_max: parseInt(s.cpu7_hw_max), cpu7_min: parseInt(s.cpu7_hw_min),
                gpu_max: parseInt(s.gpu_hw_max), gpu_min: parseInt(s.gpu_hw_min)
            };
            var c0max = Math.round(perfHw.cpu0_max / 1000);
            var c0min = Math.round(perfHw.cpu0_min / 1000);
            var c4max = Math.round(perfHw.cpu4_max / 1000);
            var c4min = Math.round(perfHw.cpu4_min / 1000);
            var c7max = Math.round(perfHw.cpu7_max / 1000);
            var c7min = Math.round(perfHw.cpu7_min / 1000);
            var gmax = Math.round(perfHw.gpu_max / 1000000);
            var gmin = Math.round(perfHw.gpu_min / 1000000);
            var cpu0El = document.getElementById('cpu0Max');
            var cpu4El = document.getElementById('cpu4Max');
            var cpu7El = document.getElementById('cpu7Max');
            var gpuEl = document.getElementById('gpuMax');
            cpu0El.min = c0min; cpu0El.max = c0max;
            cpu4El.min = c4min; cpu4El.max = c4max;
            cpu7El.min = c7min; cpu7El.max = c7max;
            gpuEl.min = gmin; gpuEl.max = gmax;
            document.querySelectorAll('.perf-range-hint')[0].textContent = c0min + ' ~ ' + c0max + ' MHz';
            document.querySelectorAll('.perf-range-hint')[1].textContent = c4min + ' ~ ' + c4max + ' MHz';
            document.querySelectorAll('.perf-range-hint')[2].textContent = c7min + ' ~ ' + c7max + ' MHz';
            document.querySelectorAll('.perf-range-hint')[3].textContent = gmin + ' ~ ' + gmax + ' MHz';
        }
        if (!s.cpu0_max) return;
        var cpu0 = Math.round(parseInt(s.cpu0_max) / 1000);
        var cpu4 = Math.round(parseInt(s.cpu4_max) / 1000);
        var cpu7 = Math.round(parseInt(s.cpu7_max) / 1000);
        var gpu = Math.round(parseInt(s.gpu_max) / 1000000);
        var cpuCur = parseInt(s.cpu_cur) || 0;
        var gpuCur = parseInt(s.gpu_cur) || 0;
        var cpuMax = parseInt(s.cpu7_max) || parseInt(s.cpu4_max) || parseInt(s.cpu0_max);
        var gpuMax = parseInt(s.gpu_max) || 903000000;
        if (!perfInputsSet) {
            document.getElementById('cpu0Max').value = Math.round(snapToStep(parseInt(s.cpu0_max) || 0, perfStepLists.cpu0) / 1000);
            if (clusterCount >= 3) document.getElementById('cpu4Max').value = Math.round(snapToStep(parseInt(s.cpu4_max) || 0, perfStepLists.cpu4) / 1000);
            document.getElementById('cpu7Max').value = Math.round(snapToStep(parseInt(s.cpu7_max) || 0, perfStepLists.cpu7) / 1000);
            document.getElementById('gpuMax').value = Math.round(snapToStep(parseInt(s.gpu_max) || 0, perfStepLists.gpu) / 1000000);
        }
        if (perfRetry < 3 && !perfInputsSet) {
            var govSel = document.getElementById('cpuGov');
            var availGov = s.cpu_avail_gov || '';
            if (availGov && govSel.options.length === 0) {
                availGov.split(',').forEach(function (g) {
                    if (!g) return;
                    var o = document.createElement('option');
                    o.value = g; o.textContent = g;
                    govSel.appendChild(o);
                });
            }
            document.getElementById('cpuGov').value = s.cpu_gov || 'schedutil';
        }
        if (perfRetry > 0) { perfRetry--; if (perfRetry === 0) { perfInputsSet = true; perfInitialized = true; } }
        else { perfInputsSet = true; perfInitialized = true; }
        updatePerfGauges(cpuMax, cpuCur, gpuMax, gpuCur, perfOn);
        if (s.perf_profile && s.perf_profile !== 'custom') {
            updatePerfPresetBtns(s.perf_profile);
            perfActiveProfile = s.perf_profile;
        }
    } catch (e) { }
}
//频率控制（不要动）
var perfTimer = null;
var perfCountdownId = null;
var perfPendingPayload = null;
var perfActiveProfile = '';
var perfLocks = { master: 0 };
var clusterCount = 3;
var perfStepLists = { cpu0: [], cpu4: [], cpu7: [], gpu: [] };
var freqPickerTarget = '';
var perfExpect = { master: null };
var perfThermalOk = false;
var PERF_DEFAULTS = {
    powersave: { min: true, gov: 'powersave', label: '省电' }
};
var perfHw = { cpu0_max: 2265600, cpu4_max: 3148800, cpu7_max: 3052800, gpu_max: 903000000 };
function snapToStep(val, steps) {
    if (!steps || steps.length === 0) return val;
    var best = steps[0], bestDiff = Math.abs(val - best);
    for (var i = 1; i < steps.length; i++) {
        var d = Math.abs(val - steps[i]);
        if (d < bestDiff) { bestDiff = d; best = steps[i]; }
    }
    return best;
}
function fillPerfInputs(prof) {
    var d = PERF_DEFAULTS[prof];
    var c0, c4, c7, g;
    if (d.min) { var sl = perfStepLists; c0 = sl.cpu0 && sl.cpu0.length ? sl.cpu0[0] : 364000; c4 = sl.cpu4 && sl.cpu4.length ? sl.cpu4[0] : 499000; c7 = sl.cpu7 && sl.cpu7.length ? sl.cpu7[0] : 480000; g = sl.gpu && sl.gpu.length ? sl.gpu[0] : 231000000; }
    else { c0 = Math.round(perfHw.cpu0_max * d.pct); c4 = Math.round(perfHw.cpu4_max * d.pct); c7 = Math.round(perfHw.cpu7_max * d.pct); g = Math.round(perfHw.gpu_max * d.pct); }
    document.getElementById('cPerf').classList.add('pending');
    document.getElementById('cpu0Max').value = Math.round(c0 / 1000);
    document.getElementById('cpu4Max').value = Math.round(c4 / 1000);
    document.getElementById('cpu7Max').value = Math.round(c7 / 1000);
    document.getElementById('gpuMax').value = Math.round(g / 1000000);
    document.getElementById('cpuGov').value = d.gov;
}
function applyPerfProfile(prof, e) {
    e.stopPropagation();
    perfActiveProfile = prof;
    fillPerfInputs(prof);
    updatePerfPresetBtns(prof);
    toast(t('已选择「') + t(PERF_DEFAULTS[prof].label) + t('」预设，请点击应用'));
    triggerCardJelly(document.getElementById('cPerf'), e);
}
function updatePerfPresetBtns(active) {
    var btn = document.getElementById('prefPowersave'); if (btn) btn.classList.toggle('active', active === 'powersave');
}
function onPerfInput() {
    perfActiveProfile = '';
    updatePerfPresetBtns('');
    document.getElementById('cPerf').classList.add('pending');
}
function handlePerfToggle(e) {
    e.stopPropagation();
    var el = document.getElementById('perfSw');
    var on = el.classList.contains('on');
    perfExpect.master = !on; sw(el, !on);
    if (on) sh('rm -f ' + MDIR + '/perf_enabled');
    else sh('touch ' + MDIR + '/perf_enabled');
    cmd('perf_enabled', on ? 'off' : 'on');
    perfLocks.master = Date.now() + 4000;
    toast(on ? t('频率控制已关闭') : t('频率控制已开启'));
    triggerCardJelly(e.currentTarget, e);
}
function applyPerf(e) {
    e.stopPropagation();
    if (perfCountdownId) { toast(t('已有调度确认中，请先完成或取消')); return; }
    var el = document.getElementById('perfSw');
    if (!el.classList.contains('on')) { toast(t('请先开启频率控制')); return; }
    if (!perfThermalOk) { toast(t('请在 config.txt 中先开启温控移除')); return; }
    var cpu0, cpu4, cpu7, gpu, gov, profile;
    if (perfActiveProfile && PERF_DEFAULTS[perfActiveProfile]) {
        var d = PERF_DEFAULTS[perfActiveProfile];
        if (d.min) { var sl = perfStepLists; cpu0 = sl.cpu0 && sl.cpu0.length ? sl.cpu0[0] : 364000; cpu4 = clusterCount >= 3 ? (sl.cpu4 && sl.cpu4.length ? sl.cpu4[0] : 499000) : ''; cpu7 = sl.cpu7 && sl.cpu7.length ? sl.cpu7[0] : 480000; gpu = sl.gpu && sl.gpu.length ? sl.gpu[0] : 231000000; }
        else { cpu0 = Math.round(perfHw.cpu0_max * d.pct); cpu4 = clusterCount >= 3 ? Math.round(perfHw.cpu4_max * d.pct) : ''; cpu7 = Math.round(perfHw.cpu7_max * d.pct); gpu = Math.round(perfHw.gpu_max * d.pct); }
        gov = d.gov;
        profile = perfActiveProfile;
    } else {
        cpu0 = (parseInt(document.getElementById('cpu0Max').value) || 2266) * 1000;
        cpu4 = clusterCount >= 3 ? (parseInt(document.getElementById('cpu4Max').value) || 3149) * 1000 : '';
        cpu7 = (parseInt(document.getElementById('cpu7Max').value) || 3053) * 1000;
        gpu = (parseInt(document.getElementById('gpuMax').value) || 903) * 1000000;
        gov = document.getElementById('cpuGov').value || 'schedutil';
        profile = 'custom';
    }
    perfPendingPayload = [cpu0, cpu4, cpu7, gpu, gov, profile].join('|');
    document.getElementById('cPerf').classList.remove('pending');
    document.getElementById('perfOv').classList.add('show');
    startPerfCountdown();
    triggerCardJelly(e.currentTarget, e);
} function startPerfCountdown() {
    var sec = 15;
    var btn = document.getElementById('perfConfirmBtn');
    var cd = document.getElementById('perfOvCountdown');
    cd.textContent = sec;
    cd.style.color = 'var(--red)';
    btn.disabled = true;
    btn.style.opacity = '0.5';
    btn.style.cursor = 'not-allowed';
    btn.textContent = t('确认') + ' (' + sec + 's)';
    clearInterval(perfCountdownId);
    perfCountdownId = setInterval(function () {
        sec--;
        if (sec <= 0) {
            clearInterval(perfCountdownId);
            perfCountdownId = null;
            cd.textContent = '✓';
            cd.style.color = 'var(--green)';
            btn.disabled = false;
            btn.style.opacity = '1';
            btn.style.cursor = 'pointer';
            btn.textContent = t('确认修改');
        } else {
            cd.textContent = sec;
            btn.textContent = t('确认') + ' (' + sec + 's)';
        }
    }, 1000);
}
function confirmPerf() {
    if (perfCountdownId) { toast(t('请等待 15 秒冷静期结束后再确认')); return; }
    clearInterval(perfCountdownId);
    perfCountdownId = null;
    cmd('perf_apply', perfPendingPayload);
    document.getElementById('perfOv').classList.remove('show');
    toast(t('调度已确认，已生效'));
    setTimeout(function () {
        perfInitialized = true;
        perfInputsSet = true;
        perfRetry = 0;
    }, 3000);
}
function resetPerf(e) { e.stopPropagation(); cmd('perf_reset'); perfInitialized = false; perfInputsSet = false; perfRetry = 3; perfActiveProfile = ''; updatePerfPresetBtns(''); toast(t('已恢复系统默认调度')); triggerCardJelly(e.currentTarget, e); }
function cancelPerf() {
    clearInterval(perfCountdownId);
    perfCountdownId = null;
    perfInitialized = false;
    perfInputsSet = false;
    perfRetry = 3;
    document.getElementById('perfOv').classList.remove('show');
    toast(t('已取消，未修改调度'));
}
function updatePerfGauges(cpuMax, cpuCur, gpuMax, gpuCur, perfOn) {
    var circ = 2 * Math.PI * 42;
    var cpuHw = perfHw.cpu7_max || 3052800;
    var gpuHw = perfHw.gpu_max || 903000000;
    var cpuPct, gpuPct, cpuCenter, gpuCenter;
    cpuPct = cpuCur > 0 ? Math.min(100, Math.round(cpuCur / cpuHw * 100)) : 0;
    gpuPct = gpuCur > 0 ? Math.min(100, Math.round(gpuCur / gpuHw * 100)) : 0;
    cpuCenter = cpuCur || cpuMax;
    gpuCenter = gpuCur || gpuMax;
    var cpuGHz = cpuCenter > 0 ? (cpuCenter / 1000000).toFixed(2) : '--';
    var gpuMHz = Math.round(gpuCenter / 1000000);
    var cpuRing = document.getElementById('cpuRing');
    var gpuRing = document.getElementById('gpuRing');
    if (cpuRing) {
        cpuRing.style.strokeDasharray = circ;
        cpuRing.style.strokeDashoffset = circ - (cpuPct / 100) * circ;
    }
    if (gpuRing) {
        gpuRing.style.strokeDasharray = circ;
        gpuRing.style.strokeDashoffset = circ - (gpuPct / 100) * circ;
    }
    var ep = document.getElementById('cpuPct'); if (ep) ep.textContent = cpuGHz;
    var ep2 = document.getElementById('gpuPct'); if (ep2) ep2.textContent = gpuMHz || '--';
    var eu = document.getElementById('cpuUnit'); if (eu) eu.textContent = 'GHz';
    var eu2 = document.getElementById('gpuUnit'); if (eu2) eu2.textContent = 'MHz';
}
//日志生成逻辑
function genLog() {
    if (logDebounceTimer) clearTimeout(logDebounceTimer);
    logDebounceTimer = setTimeout(function () {
        logDebounceTimer = null;
        try {
            var log = LOG_PATH;
            ksu.exec('echo "=== FanExtreme v3.1.10 调试日志 ===" > ' + log);
            ksu.exec('echo "时间: $(date)" >> ' + log);
            ksu.exec('echo "" >> ' + log);
            ksu.exec('echo "[module.prop]" >> ' + log);
            ksu.exec('cat /data/adb/modules/FanExtreme/module.prop >> ' + log);
            ksu.exec('echo "" >> ' + log);
            ksu.exec('echo "[config.txt]" >> ' + log);
            ksu.exec('cat /data/adb/modules/FanExtreme/config.txt >> ' + log);
            ksu.exec('echo "" >> ' + log);
            ksu.exec('echo "[webui_status]" >> ' + log);
            ksu.exec('cat ' + STATUS + ' >> ' + log);
            ksu.exec('echo "" >> ' + log);
            ksu.exec('echo "[service.sh进程]" >> ' + log);
            ksu.exec('ps -ef | grep FanExtreme >> ' + log);
            ksu.exec('echo "" >> ' + log);
            ksu.exec('echo "[sysfs充电节点]" >> ' + log);
            ksu.exec('cat /sys/class/qcom-battery/restrict_cur /sys/class/qcom-battery/restrict_chg /sys/class/qcom-battery/charging_enabled /sys/class/qcom-battery/charge_mode >> ' + log);
            ksu.exec('echo "" >> ' + log);
            ksu.exec('echo "[充电分离状态]" >> ' + log);
            ksu.exec('cat /data/adb/modules/FanExtreme/.cs_cache 2>/dev/null >> ' + log);
            ksu.exec('echo "" >> ' + log);
            ksu.exec('echo "[GPU]" >> ' + log);
            ksu.exec('cat /sys/kernel/gpu/gpu_model /sys/kernel/gpu/gpu_clock /sys/kernel/gpu/gpu_max_clock /sys/kernel/gpu/gpu_min_clock /sys/kernel/gpu/gpu_busy >> ' + log);
            ksu.exec('echo "" >> ' + log);
            ksu.exec('echo "[风扇]" >> ' + log);
            ksu.exec('cat /sys/kernel/fan/fan_speed_level /sys/kernel/fan/fan_enable >> ' + log);
            ksu.exec('echo "" >> ' + log);
            ksu.exec('echo "[设备信息]" >> ' + log);
            ksu.exec('getprop ro.serialno >> ' + log);
            ksu.exec('{ pkg=$(pm list packages 2>/dev/null | grep -iE "sukisu|resukisu|kernelsu" | head -1 | sed "s/package://"); ksud=$(getprop init.svc.ksud); kv=$(getprop ro.ksu.version); if [ "$ksud" = "running" ] || { [ -d /data/adb/ksu ] && [ "$kv" != "APatch" ]; }; then case "$pkg" in *ultra*) rm=SuKeMiSu_Ultra;; *sukisu*) rm=SuKeMiSu;; *resukisu*) rm=ReSuKiSu;; *next*) rm=KernelSU_Next;; *) rm=KernelSU;; esac; kver=$(/data/adb/ksud --version 2>/dev/null | head -1 | awk "{print \\\$2}" | cut -d- -f1); [ -n "$kver" ] && rm="$rm v$kver"; elif [ -d /data/adb/ap ]; then rm=APatch; elif [ -d /data/adb/magisk ]; then rm="Magisk v$(getprop ro.magisk.version)"; else rm=unknown; fi; echo "root_manager=$rm" >> ' + log + '; } 2>/dev/null');
            ksu.exec('getprop ro.product.model >> ' + log);
            ksu.exec('getprop ro.product.board >> ' + log);
            ksu.exec('getprop ro.build.version.release >> ' + log);
            ksu.exec('getprop ro.build.version.sdk >> ' + log);
            ksu.exec('uname -r >> ' + log);
            ksu.exec('echo "" >> ' + log);
            ksu.exec('echo "[CPU]" >> ' + log);
            ksu.exec('echo "governor: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)" >> ' + log);
            ksu.exec('for c in /sys/devices/system/cpu/cpu*/cpufreq; do echo "$(basename $(dirname $c)): cur=$(cat $c/scaling_cur_freq 2>/dev/null) min=$(cat $c/scaling_min_freq 2>/dev/null) max=$(cat $c/scaling_max_freq 2>/dev/null)"; done >> ' + log);
            ksu.exec('echo "" >> ' + log);
            ksu.exec('echo "[模块错误日志]" >> ' + log);
            ksu.exec('cat /data/adb/modules/FanExtreme/.last_error 2>/dev/null >> ' + log);
            ksu.exec('echo "" >> ' + log);
            ksu.exec('echo "[模块节点状态]" >> ' + log);
            ksu.exec('echo fan_enable=$(cat /sys/kernel/fan/fan_enable 2>/dev/null) fan_level=$(cat /sys/kernel/fan/fan_speed_level 2>/dev/null) >> ' + log);
            ksu.exec('echo restrict_cur=$(cat /sys/class/qcom-battery/restrict_cur 2>/dev/null) restrict_chg=$(cat /sys/class/qcom-battery/restrict_chg 2>/dev/null) >> ' + log);
            ksu.exec('echo tp_report_rate=$(cat /proc/touchscreen/tp_report_rate 2>/dev/null) touch_sampling=$(settings get system touch_sampling_rate 2>/dev/null) >> ' + log);
            ksu.exec('echo vibe_gain=$(cat /sys/class/leds/vibrator/gain 2>/dev/null) vibe_dur=$(cat /sys/class/leds/vibrator/duration_aw 2>/dev/null) vibe_vmax=$(cat /sys/class/leds/vibrator/vmax 2>/dev/null) >> ' + log);
            ksu.exec('echo gpu_clock=$(cat /sys/kernel/gpu/gpu_clock 2>/dev/null) gpu_min=$(cat /sys/kernel/gpu/gpu_min_clock 2>/dev/null) gpu_max=$(cat /sys/kernel/gpu/gpu_max_clock 2>/dev/null) >> ' + log);
            ksu.exec('echo charge_sep=$(cat /data/adb/modules/FanExtreme/.cs_cache 2>/dev/null) cube_dir=$(ls /data/system/cube/* 2>/dev/null | wc -l) >> ' + log);
            ksu.exec('echo "" >> ' + log);
            ksu.exec('echo "[频率控制]" >> ' + log);
            ksu.exec('echo cpu0_max=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq 2>/dev/null) cpu0_gov=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null) >> ' + log);
            ksu.exec('echo cpu4_max=$(cat /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq 2>/dev/null) cpu4_gov=$(cat /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor 2>/dev/null) >> ' + log);
            ksu.exec('echo cpu7_max=$(cat /sys/devices/system/cpu/cpu7/cpufreq/scaling_max_freq 2>/dev/null) cpu7_gov=$(cat /sys/devices/system/cpu/cpu7/cpufreq/scaling_governor 2>/dev/null) >> ' + log);
            ksu.exec('echo gpu_max=$(cat /sys/class/kgsl/kgsl-3d0/devfreq/max_freq 2>/dev/null) gpu_cur=$(cat /sys/class/kgsl/kgsl-3d0/devfreq/cur_freq 2>/dev/null) gpu_gov=$(cat /sys/class/kgsl/kgsl-3d0/devfreq/governor 2>/dev/null) >> ' + log);
            toast(t('调试日志已生成在下载目录'));
        } catch (e) { console.error(e); toast(t('日志生成失败，请重试')); }
    }, 500);
}
function joinQQ() { ksu.exec('am start -a android.intent.action.VIEW -d https://qm.qq.com/q/QCBSaor22k'); toast(t('正在打开QQ群...')); }
function openInBrowser(url) { ksu.exec('am start -a android.intent.action.VIEW -d ' + url); toast(t('正在打开浏览器...')); }
function saveSponsorToGallery() {
    var src = '/data/adb/modules/FanExtreme/webroot/sponsor.jpg';
    var dst = '/sdcard/Pictures/sponsor.jpg';
    ksu.exec('cp ' + src + ' ' + dst);
    ksu.exec('am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE -d file://' + dst);
    toast(t('已保存到相册'));
}
//撒花特效
function spawnConfetti() {
    const container = document.createElement('div');
    container.className = 'confetti-container';
    document.body.appendChild(container);
    const canvas = document.createElement('canvas');
    canvas.width = window.innerWidth; canvas.height = window.innerHeight;
    container.appendChild(canvas);
    const ctx = canvas.getContext('2d');
    const particles = [];
    const colors = ['#e17055', '#0984e3', '#27ae60', '#fdcb6e', '#6c5ce7', '#fd79a8'];
    const centerX = canvas.width / 2, bottomY = canvas.height - 10;
    for (let i = 0; i < 120; i++) {
        const angle = (Math.random() * 120 - 60) * Math.PI / 180 - Math.PI / 2;
        const speed = 4 + Math.random() * 12;
        particles.push({
            x: centerX + (Math.random() - .5) * 20, y: bottomY,
            vx: Math.cos(angle) * speed * (.5 + Math.random()),
            vy: Math.sin(angle) * speed * (.7 + Math.random() * .5),
            size: 2 + Math.random() * 6,
            color: colors[Math.floor(Math.random() * colors.length)],
            life: 1, decay: .008 + Math.random() * .015
        });
    }
    function draw() {
        if (particles.length === 0) { container.remove(); return; }
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        for (let i = particles.length - 1; i >= 0; i--) {
            const p = particles[i];
            p.x += p.vx; p.y += p.vy; p.vy += .15;
            p.life -= p.decay;
            if (p.life <= 0) { particles.splice(i, 1); continue; }
            ctx.globalAlpha = p.life; ctx.fillStyle = p.color;
            ctx.beginPath(); ctx.arc(p.x, p.y, p.size, 0, Math.PI * 2); ctx.fill();
        }
        requestAnimationFrame(draw);
    }
    draw();
}
function showSponsor() { document.getElementById('ov').classList.add('show'); spawnConfetti(); }
function hideSponsor() { document.getElementById('ov').classList.remove('show'); }
//启动高频平滑轮询
setInterval(refresh, 1000);
refresh();
