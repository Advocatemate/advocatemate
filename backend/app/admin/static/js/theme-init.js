// Runs before first paint: apply the admin's saved theme (light / dark / system) without a flash.
(function () {
  try {
    var t = localStorage.getItem("am-admin-theme");
    if (t === "light" || t === "dark") document.documentElement.setAttribute("data-theme", t);
    if (localStorage.getItem("am-admin-sidebar") === "collapsed") document.documentElement.classList.add("pre-collapsed");
  } catch (e) { /* storage unavailable: follow the system theme */ }
})();
