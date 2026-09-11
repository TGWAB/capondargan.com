(function () {
  var toggle = document.querySelector(".nav-toggle");
  var nav = document.querySelector(".site-nav");
  if (toggle && nav) {
    toggle.addEventListener("click", function () {
      var open = nav.classList.toggle("is-open");
      toggle.setAttribute("aria-expanded", open ? "true" : "false");
    });
  }
  var year = document.getElementById("footer-year");
  if (year) year.textContent = String(new Date().getFullYear());

  var video = document.querySelector(".hero-video");
  if (video && window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
    video.removeAttribute("autoplay");
    var freeze = function () {
      video.pause();
      try { video.currentTime = 0; } catch (e) {}
    };
    if (video.readyState >= 2) freeze();
    else video.addEventListener("loadeddata", freeze, { once: true });
  }
})();
