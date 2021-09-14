// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"
import {Socket} from "phoenix"
import NProgress from "nprogress"
import {LiveSocket} from "phoenix_live_view"
import UIkit from 'uikit';
import Icons from 'uikit/dist/js/uikit-icons';
import "select2";
import "select2/dist/css/select2.css";
import $ from "jquery";
import jQuery from "jquery";

UIkit.use(Icons);

let Hooks = {};
Hooks.select2 = {
  initSelect2() {
    let hook = this,
      $select = jQuery(hook.el).find("select");

    $select
      .select2({
        dropdownParent: jQuery(hook.el).find("select").parent(),
        focus: true,
        paging: true,
      })
      .on("select2:open", (e) =>
        document.querySelector(".select2-search__field").focus()
      );

    return $select;
  },

  mounted() {
    this.initSelect2();
  },
};

Hooks.uk_icon = {
  mounted() {UIkit.icon(this.el, {})},
  updated() {UIkit.icon(this.el, {})}
}
Hooks.uk_nav = {
  mounted() {UIkit.nav(this.el, {})},
  updated() {UIkit.nav(this.el, {})}
}
Hooks.uk_navbar = {
  mounted() {UIkit.navbar(this.el, {})},
  updated() {UIkit.navbar(this.el, {})}
}
Hooks.uk_alert = {
  mounted() {UIkit.alert(this.el, {})},
  updated() {UIkit.alert(this.el, {})}
}
Hooks.uk_close = {
  mounted() {UIkit.close(this.el, {})},
  updated() {UIkit.close(this.el, {})}
}
Hooks.uk_tooltip = {
  mounted() {UIkit.tooltip(this.el, {})},
  updated() {UIkit.tooltip(this.el, {})}
}
Hooks.uk_overflow_auto = {
  mounted() {UIkit.overflowAuto(this.el, {})},
  updated() {UIkit.overflowAuto(this.el, {})}
}
Hooks.uk_sticky = {
  mounted() {UIkit.sticky(this.el, {})},
  updated() {UIkit.sticky(this.el, {})}
}
Hooks.uk_grid = {
  mounted() {UIkit.grid(this.el, {})},
  updated() {UIkit.grid(this.el, {})}
}
Hooks.uk_height_match = {
  mounted() {UIkit.heightMatch(this.el, {})},
  updated() {UIkit.heightMatch(this.el, {})}
}
Hooks.uk_accordion = {
  mounted() {UIkit.accordion(this.el, {})},
  updated() {UIkit.accordion(this.el, {})}
}
Hooks.uk_toggle = {
  mounted() {UIkit.toggle(this.el).toggle()},
  updated() {UIkit.toggle(this.el).toggle()}
}
Hooks.close_modal = {
  mounted() {
    document.addEventListener("click", e => {
      if(!e.target.closest('.uk-modal-dialog')){
        this.pushEvent("cancel", {});
      }
    })
  },
  updated() {
    document.addEventListener("click", e => {
      if(!e.target.closest('.uk-modal-dialog')){
        this.pushEvent("cancel", {});
      }
    })
  }
}
Hooks.infinite_scroll = {
  page() { return this.el.dataset.page },
  mounted(){
    this.pending = this.page()
    document.getElementById("content").addEventListener("scroll", e => {
      this.scrollAt = (e.srcElement.scrollTop / (e.srcElement.scrollHeight - e.srcElement.offsetHeight)) * 100;
      if(this.pending == this.page() && this.scrollAt > 90){
        this.pending = this.page() + 1
        this.pushEvent("load_more", {})
      }
    })
  },
  updated(){ this.pending = this.page() }
}
Hooks.infinite_scroll_modal = {
  page() { return this.el.dataset.page },
  scrollAt() { return (this.el.scrollTop / (this.el.scrollHeight - this.el.offsetHeight)) * 100 },
  mounted(){
    this.pending = this.page();
    this.height = this.el.scrollHeight;
    this.el.addEventListener("scroll", e => {
      if(this.pending == this.page() && Math.abs(this.top - this.el.scrollTop) > 50) {
        this.el.scrollTop = this.top;
        this.height = this.el.scrollHeight;
      } else if(this.pending == this.page() && Math.abs(this.top - this.el.scrollTop) > 20) {
        this.top = this.el.scrollTop;
      }
      if(this.pending == this.page() && this.scrollAt() > 90) {
        this.pending = this.page() + 1;
        this.top = this.el.scrollTop;
        this.pushEvent("load_more", {});
      };
    });
    UIkit.overflowAuto(this.el, {});
  },
  updated() {
    this.pending = this.page();
    UIkit.overflowAuto(this.el, {});
  }
}
Hooks.infinite_scroll_container = {
  page() { return this.el.dataset.page },
  scrollAt() { return (this.el.scrollTop / (this.el.scrollHeight - this.el.offsetHeight)) * 100 },
  mounted(){
    this.pending = this.page();
    this.height = this.el.scrollHeight;
    this.el.addEventListener("scroll", e => {
      if(this.pending == this.page() && this.scrollAt() > 90) {
        this.pending = this.page() + 1;
        this.pushEvent("load_more", {});
      };
    });
    UIkit.overflowAuto(this.el, {});
  },
  updated() {
    this.pending = this.page();
    UIkit.overflowAuto(this.el, {});
  }
}

Hooks.set_save = {
  mounted() {
    this.el.addEventListener("click", (e) => {
      document.getElementById("button-clicked").value = this.el.id
    })
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}, hooks: Hooks})

// Show progress bar on live navigation and form submits
window.addEventListener("phx:page-loading-start", info => NProgress.start())
window.addEventListener("phx:page-loading-stop", info => NProgress.done())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)
window.liveSocket = liveSocket
