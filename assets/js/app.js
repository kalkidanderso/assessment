// assets/js/app.js

// Import Phoenix dependencies
import "phoenix_html"
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import topbar from "../vendor/topbar"

// Initialize CodeMirror editor when present
const initCodeEditor = () => {
  const editor = document.getElementById('editor')
  if (editor) {
    // Will implement CodeMirror later
    editor.style.height = 'calc(100vh - 40px)'
    editor.addEventListener('input', (e) => {
      // Auto-resize textarea
      e.target.style.height = 'auto'
      e.target.style.height = e.target.scrollHeight + 'px'
    })
  }
}

// LiveView hooks configuration
const Hooks = {
  MarkdownEditor: {
    mounted() {
      initCodeEditor()
      this.handleEvent("update-preview", ({ content }) => {
        document.getElementById('preview').innerHTML = content
      })
    }
  },
  Clipboard: {
    mounted() {
      this.handleEvent("copy-to-clipboard", ({ content }) => {
        navigator.clipboard.writeText(content)
          .then(() => this.pushEvent("copy-success"))
          .catch(() => this.pushEvent("copy-error"))
      })
    }
  }
}

// LiveSocket configuration
const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
const liveSocket = new LiveSocket("/live", Socket, {
  hooks: Hooks,
  params: { _csrf_token: csrfToken },
  dom: {
    // Preserve editor content during updates
    onBeforeElUpdated(from, to) {
      if (from.id === "editor") return false
    }
  }
})

// Show progress bar on navigation
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

// Initialize on page load
document.addEventListener("DOMContentLoaded", () => {
  initCodeEditor()
})