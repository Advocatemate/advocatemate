// AdvocateMate admin portal behaviour. No inline scripts (strict Content-Security-Policy).
(function () {
  "use strict";
  var root = document.documentElement;
  var body = document.body;

  function store(key, value) { try { localStorage.setItem(key, value); } catch (e) { /* ignore */ } }

  // ---------------------------------------------------------------- CSRF for every HTMX request
  var csrfMeta = document.querySelector('meta[name="csrf-token"]');
  document.addEventListener("htmx:configRequest", function (e) {
    if (csrfMeta) e.detail.headers["X-CSRF-Token"] = csrfMeta.content;
  });

  // ---------------------------------------------------------------- sidebar
  if (root.classList.contains("pre-collapsed")) body.classList.add("side-collapsed");
  var toggle = document.getElementById("sidebar-toggle");
  if (toggle) {
    toggle.addEventListener("click", function () {
      if (window.matchMedia("(max-width: 1100px)").matches) {
        body.classList.toggle("side-open");
        return;
      }
      var collapsed = body.classList.toggle("side-collapsed");
      toggle.setAttribute("aria-expanded", String(!collapsed));
      store("am-admin-sidebar", collapsed ? "collapsed" : "expanded");
    });
  }

  // ---------------------------------------------------------------- theme: system -> light -> dark
  var themeBtn = document.getElementById("theme-toggle");
  function currentTheme() { return root.getAttribute("data-theme") || "system"; }
  function labelTheme() {
    if (!themeBtn) return;
    var t = currentTheme();
    themeBtn.setAttribute("aria-label", "Theme: " + t + " (change)");
    themeBtn.setAttribute("title", "Theme: " + t);
    themeBtn.dataset.theme = t;
  }
  if (themeBtn) {
    labelTheme();
    themeBtn.addEventListener("click", function () {
      var next = { system: "light", light: "dark", dark: "system" }[currentTheme()];
      if (next === "system") root.removeAttribute("data-theme"); else root.setAttribute("data-theme", next);
      store("am-admin-theme", next);
      labelTheme();
    });
  }

  // ---------------------------------------------------------------- profile menu
  var profileBtn = document.getElementById("profile-button");
  var profileMenu = document.getElementById("profile-menu");
  if (profileBtn && profileMenu) {
    profileBtn.addEventListener("click", function (e) {
      e.stopPropagation();
      var open = profileMenu.classList.toggle("open");
      profileBtn.setAttribute("aria-expanded", String(open));
    });
    document.addEventListener("click", function (e) {
      if (!profileMenu.contains(e.target)) { profileMenu.classList.remove("open"); profileBtn.setAttribute("aria-expanded", "false"); }
    });
    document.addEventListener("keydown", function (e) { if (e.key === "Escape") profileMenu.classList.remove("open"); });
  }

  // ---------------------------------------------------------------- toasts (server sends HX-Trigger: {"toast": {...}})
  var toastBox = document.getElementById("toasts");
  function toast(kind, message) {
    if (!toastBox || !message) return;
    var el = document.createElement("div");
    el.className = "toast " + (kind || "info");
    el.setAttribute("role", kind === "error" ? "alert" : "status");
    el.textContent = message;
    toastBox.appendChild(el);
    setTimeout(function () { el.remove(); }, kind === "error" ? 8000 : 4500);
  }
  document.addEventListener("toast", function (e) {
    toast(e.detail.kind, e.detail.message);
    // Clear a submitting form once the server confirms success (e.g. "Add admin").
    var form = e.target && e.target.closest ? e.target.closest("form[data-reset-on-success]") : null;
    if (form && e.detail.kind === "success") form.reset();
  });
  document.addEventListener("htmx:responseError", function () { toast("error", "The request failed. Please try again."); });
  document.addEventListener("htmx:sendError", function () { toast("error", "The server could not be reached."); });

  // ---------------------------------------------------------------- confirmation dialog for hx-confirm
  var dialog = document.getElementById("confirm-dialog");
  document.addEventListener("htmx:confirm", function (e) {
    var question = e.detail.question;
    if (!question || !dialog) return;
    e.preventDefault();
    var trigger = e.detail.elt;
    dialog.querySelector("[data-confirm-title]").textContent = trigger.dataset.confirmTitle || "Please confirm";
    dialog.querySelector("[data-confirm-text]").textContent = question;
    var ok = dialog.querySelector("[data-confirm-ok]");
    ok.textContent = trigger.dataset.confirmOk || "Confirm";
    ok.className = "btn " + (trigger.dataset.confirmTone === "danger" ? "btn-danger" : "btn-primary");
    dialog.returnValue = "";
    dialog.showModal();
    dialog.addEventListener("close", function onClose() {
      dialog.removeEventListener("close", onClose);
      if (dialog.returnValue === "ok") e.detail.issueRequest(true);
    });
  });
  // Plain (non-HTMX) forms that need confirmation carry data-confirm
  document.addEventListener("submit", function (e) {
    var form = e.target;
    if (!form.dataset || !form.dataset.confirm || form.dataset.confirmed === "1" || !dialog) return;
    e.preventDefault();
    dialog.querySelector("[data-confirm-title]").textContent = form.dataset.confirmTitle || "Please confirm";
    dialog.querySelector("[data-confirm-text]").textContent = form.dataset.confirm;
    var ok = dialog.querySelector("[data-confirm-ok]");
    ok.textContent = form.dataset.confirmOk || "Confirm";
    ok.className = "btn " + (form.dataset.confirmTone === "danger" ? "btn-danger" : "btn-primary");
    dialog.returnValue = "";
    dialog.showModal();
    dialog.addEventListener("close", function onClose() {
      dialog.removeEventListener("close", onClose);
      if (dialog.returnValue === "ok") { form.dataset.confirmed = "1"; form.requestSubmit(); }
    });
  });
})();
