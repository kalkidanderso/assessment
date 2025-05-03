// assets/js/app.js

import "phoenix_html"
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import topbar from "../vendor/topbar"

// Initialize editor resize observer
const initEditorResize = () => {
  const editor = document.getElementById('editor')
  if (editor) {
    editor.style.height = 'calc(100vh - 160px)'
    new ResizeObserver(entries => {
      entries.forEach(entry => {
        entry.target.style.height = 'calc(100vh - 160px)'
      })
    }).observe(editor)
  }
}

// Set up LiveView hooks
const Hooks = {
  CopyToClipboard: {
    mounted() {
      this.handleEvent("copy-to-clipboard", ({ content }) => {
        navigator.clipboard.writeText(content)
          .then(() => this.pushEvent("copy-success"))
          .catch(() => this.pushEvent("copy-error"))
      })
    }
  },
  MarkdownPreview: {
    mounted() {
      initEditorResize()
      this.handleEvent("update-preview", ({ html }) => {
        this.el.innerHTML = html
        Prism.highlightAllUnder(this.el)
      })
    }
  }
}

Hooks.PdfDownload = {
  mounted() {
    this.handleEvent("download-pdf", ({url, filename}) => {
      const link = document.createElement('a')
      link.href = url
      link.download = filename
      document.body.appendChild(link)
      link.click()
      document.body.removeChild(link)
    })
  }
}
// LiveSocket configuration
const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
const liveSocket = new LiveSocket("/live", Socket, {
  hooks: Hooks,
  params: { _csrf_token: csrfToken },
  dom: {
    onBeforeElUpdated(from, to) {
      if (from.dataset.preserve !== undefined) return false
    }
  }
})

// Progress bar configuration
topbar.config({
  barColors: { 0: "#3B82F6" },
  shadowColor: "rgba(0, 0, 0, 0.1)"
})

window.addEventListener("phx:page-loading-start", () => topbar.show(300))
window.addEventListener("phx:page-loading-stop", () => topbar.hide())

// Connect to LiveView
liveSocket.connect()

// Expose for debugging
window.liveSocket = liveSocket