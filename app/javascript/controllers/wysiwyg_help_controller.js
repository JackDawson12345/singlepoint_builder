// app/javascript/controllers/wysiwyg_help_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["editor", "input"]

    async connect() {
        // Load Quill from CDN if not already loaded
        if (!window.Quill) {
            await this.loadQuill()
        }

        // Initialize Quill editor with extended toolbar
        this.quill = new window.Quill(this.editorTarget, {
            theme: 'snow',
            modules: {
                toolbar: [
                    [{ 'header': [1, 2, 3, 4, 5, 6, false] }],
                    ['bold', 'italic', 'underline', 'strike'],
                    [{ 'color': [] }, { 'background': [] }],
                    [{ 'list': 'ordered'}, { 'list': 'bullet' }],
                    [{ 'indent': '-1'}, { 'indent': '+1' }],
                    ['blockquote', 'code-block'],
                    ['link', 'image'],
                    [{ 'align': [] }],
                    ['clean']
                ]
            },
            placeholder: 'Start writing your help article...'
        })

        // Set initial content if exists
        if (this.inputTarget.value) {
            this.quill.root.innerHTML = this.inputTarget.value
        }

        // Apply custom styles to editor
        const editor = this.editorTarget.querySelector('.ql-editor')
        if (editor) {
            editor.style.fontFamily = '"Nata Sans", sans-serif'
            editor.style.fontSize = '0.875rem'
            editor.style.lineHeight = '1.5'
            editor.style.minHeight = '400px'
        }

        // Sync editor content to hidden input
        this.quill.on('text-change', () => {
            this.inputTarget.value = this.quill.root.innerHTML
        })
    }

    async loadQuill() {
        return new Promise((resolve, reject) => {
            // Check if already loaded
            if (document.querySelector('link[href*="quill.snow.css"]')) {
                resolve()
                return
            }

            // Load CSS
            const link = document.createElement('link')
            link.rel = 'stylesheet'
            link.href = 'https://cdn.jsdelivr.net/npm/quill@2.0.2/dist/quill.snow.css'
            document.head.appendChild(link)

            // Load JS
            const script = document.createElement('script')
            script.src = 'https://cdn.jsdelivr.net/npm/quill@2.0.2/dist/quill.js'
            script.onload = resolve
            script.onerror = reject
            document.head.appendChild(script)
        })
    }

    disconnect() {
        if (this.quill) {
            this.quill = null
        }
    }
}