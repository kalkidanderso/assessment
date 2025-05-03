// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

// Define hooks for LiveView
const Hooks = {
  CopyToClipboard: {
    mounted() {
      this.el.addEventListener("click", () => {
        const previewContent = document.getElementById("preview").innerHTML;
        this.pushEvent("copy_html", {});
      });

      this.handleEvent("copy-to-clipboard", ({ content }) => {
        navigator.clipboard.writeText(content)
          .then(() => console.log("Content copied to clipboard"))
          .catch(err => console.error("Could not copy text: ", err));
      });
    }
  },
  
  ExportPdf: {
    mounted() {
      this.handleEvent("export-pdf", ({ html }) => {
        // Create a hidden iframe for PDF generation
        const iframe = document.createElement('iframe');
        iframe.style.position = 'absolute';
        iframe.style.top = '-10000px';
        iframe.style.left = '-10000px';
        document.body.appendChild(iframe);
        
        // Write content to iframe
        const iframeDoc = iframe.contentDocument || iframe.contentWindow.document;
        iframeDoc.open();
        iframeDoc.write(`
          <!DOCTYPE html>
          <html>
          <head>
            <title>Markdown Export</title>
            <style>
              body { font-family: system-ui, -apple-system, sans-serif; margin: 2cm; }
              h1, h2, h3 { color: #333; }
              pre { background: #f5f5f5; padding: 0.5em; border-radius: 4px; }
              code { font-family: monospace; }
              blockquote { border-left: 4px solid #ccc; padding-left: 1em; font-style: italic; }
              table { border-collapse: collapse; width: 100%; }
              th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
              a { color: #0066cc; text-decoration: none; }
            </style>
          </head>
          <body>
            ${html}
          </body>
          </html>
        `);
        iframeDoc.close();
        
        // Give time for styles to apply
        setTimeout(() => {
          // Notify user
          const button = this.el;
          const originalText = button.innerText;
          button.innerText = "Preparing PDF...";
          
          // Print to PDF
          iframe.contentWindow.print();
          
          // Cleanup
          setTimeout(() => {
            document.body.removeChild(iframe);
            button.innerText = originalText;
          }, 1000);
        }, 500);
      });
    }
  },
  
  MarkdownPreview: {
    mounted() {
      // For preserving scroll position between updates
      let scrollPosition = 0;
      
      // Update content when the data-html-content attribute changes
      const observer = new MutationObserver(mutations => {
        mutations.forEach(mutation => {
          if (mutation.type === 'attributes' && mutation.attributeName === 'data-html-content') {
            scrollPosition = this.el.scrollTop;
            this.el.innerHTML = this.el.getAttribute('data-html-content');
            this.el.scrollTop = scrollPosition;
          }
        });
      });
      
      observer.observe(this.el, { attributes: true });
    }
  }
};

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: Hooks
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket