// Help Popup Handler
class HelpPopup {
    constructor() {
        this.form = null;
        this.textarea = null;
        this.submitBtn = null;
        this.responseContainer = null;
        this.originalContent = null;
        this.lastResponse = null;

        this.initialize();
    }

    initialize() {
        // Find elements
        this.form = document.getElementById('quick-search-form');
        this.textarea = document.getElementById('quick-search-input');
        this.submitBtn = document.getElementById('help-submit-btn');
        this.responseContainer = document.getElementById('help_response');

        // Only initialize if all elements exist
        if (this.form && this.textarea && this.submitBtn && this.responseContainer) {
            this.init();
        }
    }

    init() {
        // Store original content for reset - THIS MUST BE FIRST
        this.originalContent = this.responseContainer.innerHTML;

        // Bind form submit - DON'T clone the form
        this.form.addEventListener('submit', (e) => this.handleSubmit(e), { once: false });

        // Add click handler for the back button
        const helpPopupBack = document.querySelector('.help-popup-back');
        if (helpPopupBack) {
            helpPopupBack.addEventListener('click', () => this.reset());
        }

        // Auto-resize textarea
        if (this.textarea) {
            this.textarea.addEventListener('input', () => this.autoResizeTextarea());
            this.textarea.addEventListener('focus', () => this.handleFocus());
        }
    }

    async handleSubmit(e) {
        e.preventDefault();

        // Get the value directly from DOM
        const textarea = document.getElementById('quick-search-input');
        const question = textarea ? textarea.value.trim() : '';

        console.log('=== SUBMIT DEBUG ===');
        console.log('Textarea element:', textarea);
        console.log('Question value:', question);

        if (!question) {
            this.showError('Please enter a question');
            return;
        }

        // Show loading state
        this.showLoading();

        this.changeStyle();

        try {
            // Get CSRF token
            const csrfToken = document.querySelector('input[name="authenticity_token"]');
            const csrfValue = csrfToken ? csrfToken.value : '';

            console.log('CSRF token:', csrfValue);

            // Build URL encoded body manually
            const body = `search=${encodeURIComponent(question)}&authenticity_token=${encodeURIComponent(csrfValue)}`;

            console.log('Request body:', body);
            console.log('Sending to:', this.form.action);

            const response = await fetch(this.form.action, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                    'Accept': 'application/json',
                    'X-Requested-With': 'XMLHttpRequest'
                },
                body: body
            });

            console.log('Response status:', response.status);

            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }

            const contentType = response.headers.get("content-type");
            if (!contentType || !contentType.includes("application/json")) {
                const text = await response.text();
                console.error('Non-JSON response:', text);
                throw new Error("Response was not JSON");
            }

            const data = await response.json();
            console.log('Response data:', data);

            // Show the response with animation and articles
            this.showResponse(
                data.response,
                question,
                data.articles || [],
                data.article_count || 0
            );

        } catch (error) {
            console.error('Error:', error);
            this.showError('Sorry, something went wrong. Please try again.');
        }
    }

    showLoading() {
        if (this.submitBtn) this.submitBtn.disabled = true;
        if (this.textarea) this.textarea.disabled = true;

        if (this.responseContainer) {
            this.responseContainer.innerHTML = `
        <div class="px-5 py-8 text-center">
          <div class="inline-flex items-center gap-3">
            <div class="animate-spin rounded-full h-6 w-6 border-b-2 border-green-500"></div>
            <p class="nata-sans text-sm text-gray-600">Thinking...</p>
          </div>
        </div>
      `;
        }
    }

    changeStyle(){

        const topHelp = document.querySelector('.help-popup-top');
        const topHelpTitle = document.querySelector('.help-popup-title');
        const helpPopupBack = document.querySelector('.help-popup-back');

        const bottomHelp = document.querySelector('.help-popup-bottom');
        const bottomHelpContact = document.querySelector('.help-contact-bottom');

        topHelp.classList.add('help-popup-top-active');
        bottomHelp.classList.add('help-popup-bottom-active');
        topHelpTitle.classList.add('hidden');
        bottomHelpContact.classList.add('hidden');
        helpPopupBack.classList.remove('hidden');


    }

    showResponse(response, question, articles = [], articleCount = 0) {
        if (!this.responseContainer) return;

        // Animate out the loading state
        this.responseContainer.style.opacity = '0';
        this.responseContainer.style.transition = 'opacity 0.3s ease';

        setTimeout(() => {
            // Build articles HTML
            let articlesHTML = '';
            if (articles && articles.length > 0) {
                articlesHTML = `
                <div class="mt-6 pt-4 border-t">
                    <div class="flex items-center justify-between mb-3">
                        <p class="nata-sans base font-semibold text-black">
                            Related Articles (${articleCount})
                        </p>
                    </div>
                    <div class="space-y-3">
                        ${articles.map(article => `
                            <a href="/help/articles/${article.id}" 
                               target="_blank"
                               rel="noopener noreferrer"
                               class="block group">
                                <div class="flex items-start justify-between gap-3 mb-2">
                                    <div class="flex items-start gap-3 flex-1">
                                        <div class="flex-1">
                                            <p class="nata-sans text-base font-semibold text-black mb-1">
                                                ${article.title}
                                            </p>
                                            <div class="nata-sans text-xs">
                                            ${article.excerpt}
                                            </div>
                                            
                                        </div>
                                    </div>
                                </div>
                                <div class="flex items-center gap-2 text-xs text-black">
                                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16" fill="currentColor" class="w-3 h-3">
                                        <path d="M8 3.5a.5.5 0 0 0-1 0V9a.5.5 0 0 0 .252.434l3.5 2a.5.5 0 0 0 .496-.868L8 8.71V3.5z"/>
                                        <path d="M8 16A8 8 0 1 0 8 0a8 8 0 0 0 0 16zm7-8A7 7 0 1 1 1 8a7 7 0 0 1 14 0z"/>
                                    </svg>
                                    <span class="nata-sans">${article.read_time} mins</span>
                                </div>
                            </a>
                        `).join('')}
                    </div>
                </div>
            `;
            }

            this.responseContainer.innerHTML = `
            <div class="px-5 pt-0 py-4 animate-fade-in">
                <div class="mb-4">
                    <div class="flex items-center gap-3 mb-2">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" class="w-5 h-5 text-green-500 flex-shrink-0 mt-0.5">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z"/>
                        </svg>
                        <div class="flex-1">
                            <p class="nata-sans text-xs font-semibold text-gray-700">AI Assistant:</p>
                        </div>
                    </div>
                    <div>
                        <div class="nata-sans text-sm text-gray-700">${this.formatResponse(response)}</div>
                    </div>
                </div>
                
                ${articlesHTML}
            </div>
        `;

            this.responseContainer.style.opacity = '1';

            // Store the response for copying
            this.lastResponse = response;

            // Scroll to response
            this.scrollToResponse();

            // Re-enable form
            if (this.submitBtn) this.submitBtn.disabled = false;
            if (this.textarea) this.textarea.disabled = false;

        }, 300);
    }

    showError(message) {
        if (!this.responseContainer) return;

        this.responseContainer.innerHTML = `
      <div class="px-5 py-4">
        <div class="flex items-start gap-3 p-3 bg-red-50 rounded-lg">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" class="w-5 h-5 text-red-500 flex-shrink-0">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
          </svg>
          <div class="flex-1">
            <p class="nata-sans text-sm text-red-700">${message}</p>
          </div>
        </div>
        <button type="button" class="error-reset-btn mt-3 nata-sans text-sm text-green-500 hover:underline">
          Try again
        </button>
      </div>
    `;

        // Add event listener to the reset button
        const resetBtn = this.responseContainer.querySelector('.error-reset-btn');
        if (resetBtn) {
            resetBtn.addEventListener('click', () => this.reset());
        }

        if (this.submitBtn) this.submitBtn.disabled = false;
        if (this.textarea) this.textarea.disabled = false;
    }

    reset() {
        if (!this.responseContainer) return;

        // Get all the elements that were changed in changeStyle()
        const topHelp = document.querySelector('.help-popup-top');
        const topHelpTitle = document.querySelector('.help-popup-title');
        const helpPopupBack = document.querySelector('.help-popup-back');
        const bottomHelp = document.querySelector('.help-popup-bottom');
        const bottomHelpContact = document.querySelector('.help-contact-bottom');

        // Revert the styling changes
        if (topHelp) topHelp.classList.remove('help-popup-top-active');
        if (bottomHelp) bottomHelp.classList.remove('help-popup-bottom-active');
        if (topHelpTitle) topHelpTitle.classList.remove('hidden');
        if (bottomHelpContact) bottomHelpContact.classList.remove('hidden');
        if (helpPopupBack) helpPopupBack.classList.add('hidden');

        // Fade out the response container
        this.responseContainer.style.opacity = '0';

        setTimeout(() => {
            // Restore original content (this shows the help-questions again)
            this.responseContainer.innerHTML = this.originalContent;
            this.responseContainer.style.opacity = '1';

            // Clear textarea value
            if (this.textarea) {
                this.textarea.value = '';
            }

            // Reset button state
            if (this.submitBtn) {
                this.submitBtn.disabled = false;
            }

            // Don't focus on textarea since we're going back to the original view

        }, 300);
    }


    copyResponse(button) {
        if (!this.lastResponse) return;

        navigator.clipboard.writeText(this.lastResponse).then(() => {
            const originalHTML = button.innerHTML;

            button.innerHTML = `
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16" fill="currentColor" height="14" width="14">
          <path d="M10.97 4.97a.75.75 0 0 1 1.07 1.05l-3.99 4.99a.75.75 0 0 1-1.08.02L4.324 8.384a.75.75 0 1 1 1.06-1.06l2.094 2.093 3.473-4.425a.267.267 0 0 1 .02-.022z"/>
        </svg>
        Copied!
      `;
            button.classList.add('text-green-500');

            setTimeout(() => {
                button.innerHTML = originalHTML;
                button.classList.remove('text-green-500');
            }, 2000);
        }).catch(err => {
            console.error('Failed to copy:', err);
        });
    }

    formatResponse(response) {
        // Convert markdown-style formatting to HTML
        let formatted = this.escapeHtml(response);

        // Bold text
        formatted = formatted.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>');

        // Italic text
        formatted = formatted.replace(/\*(.*?)\*/g, '<em>$1</em>');

        // Line breaks - convert double newlines to paragraphs
        formatted = formatted.replace(/\n\n/g, '</p><p class="mt-2">');

        // Single line breaks
        formatted = formatted.replace(/\n/g, '<br>');

        // Wrap in paragraph if not already
        if (!formatted.startsWith('<p>')) {
            formatted = '<p>' + formatted + '</p>';
        }

        return formatted;
    }

    escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    autoResizeTextarea() {
        if (!this.textarea) return;
        this.textarea.style.height = 'auto';
        this.textarea.style.height = Math.min(this.textarea.scrollHeight, 200) + 'px';
    }

    handleFocus() {
        if (!this.textarea) return;
        if (this.textarea.value === this.textarea.placeholder) {
            this.textarea.value = '';
        }
    }

    scrollToResponse() {
        if (!this.responseContainer) return;
        this.responseContainer.scrollIntoView({
            behavior: 'smooth',
            block: 'nearest'
        });
    }
}

// Initialize function
function initializeHelpPopup() {
    if (window.helpPopup) {
        // Re-initialize if it already exists
        window.helpPopup.initialize();
    } else {
        window.helpPopup = new HelpPopup();
    }
}

// Initialize on different events to handle Turbo
document.addEventListener('DOMContentLoaded', initializeHelpPopup);
document.addEventListener('turbo:load', initializeHelpPopup);
document.addEventListener('turbo:render', initializeHelpPopup);

// Also try after a short delay in case elements load later
setTimeout(initializeHelpPopup, 100);