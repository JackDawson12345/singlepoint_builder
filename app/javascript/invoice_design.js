window.loadPartial = loadPartial;
window.loadTextPartial = loadTextPartial;

// Prevent duplicate event listeners
let eventListenersInitialized = false;

function loadPartial(partialName) {
    const url = document.querySelector('body').dataset.loadPartialUrl.replace('PARTIAL_PLACEHOLDER', partialName);

    fetch(url, {
        method: 'GET',
        headers: {
            'Accept': 'text/html',
            'X-Requested-With': 'XMLHttpRequest'
        }
    })
        .then(response => {
            if (!response.ok) {
                throw new Error('Network response was not ok');
            }
            return response.text();
        })
        .then(html => {
            document.getElementById('partial-container').innerHTML = html;
            setActiveButton(partialName);
        })
        .catch(error => {
            console.error('Error loading partial:', error);
        });
}

function loadTextPartial(partialName) {
    const url = document.querySelector('body').dataset.loadTextPartialUrl.replace('PARTIAL_PLACEHOLDER', partialName);

    fetch(url, {
        method: 'GET',
        headers: {
            'Accept': 'text/html',
            'X-Requested-With': 'XMLHttpRequest'
        }
    })
        .then(response => {
            if (!response.ok) {
                throw new Error('Network response was not ok');
            }
            return response.text();
        })
        .then(html => {
            document.getElementById('partial-container').innerHTML = html;

            // Update preview styles after the partial is loaded
            setTimeout(() => {
                updatePreviewStyles();
            }, 100);
        })
        .catch(error => {
            console.error('Error loading partial:', error);
        });
}

function setActiveButton(activeTool) {
    // Remove active classes from all buttons
    document.querySelectorAll('.tool-button-outer').forEach(el => {
        el.classList.remove('active-invoice-button-outer');
    });
    document.querySelectorAll('.tool-button-icon').forEach(el => {
        el.classList.remove('active-invoice-button');
    });
    document.querySelectorAll('.tool-button-text').forEach(el => {
        el.classList.remove('active-invoice-button-text');
    });

    // Add active classes to the selected button
    const activeButton = document.querySelector(`[data-tool="${activeTool}"]`);
    if (activeButton) {
        activeButton.classList.add('active-invoice-button-outer');
    }

    const activeIcon = document.querySelector(`[data-tool="${activeTool}"] .tool-button-icon`);
    if (activeIcon) {
        activeIcon.classList.add('active-invoice-button');
    }

    const activeText = document.querySelector(`[data-partial="${activeTool}"] .tool-button-text`);
    if (activeText) {
        activeText.classList.add('active-invoice-button-text');
    }
}

function getCurrentTextElement() {
    const currentTextElementField = document.querySelector('#invoice_template_current_text_element');
    return currentTextElementField ? currentTextElementField.value : 'headline';
}

// Debounce timer for auto-save
let saveTimeout = null;

function updateFormField(element, fieldType, value) {
    let field = document.querySelector(`input[data-element="${element}"].${fieldType}-field`);

    if (!field) {
        field = document.querySelector(`input[name*="[${element}][style][${fieldType}]"]`);
    }

    if (!field) {
        field = document.querySelector(`input[name*="design[text][${element}][style][${fieldType}]"]`);
    }

    if (field) {
        field.value = value;
        // Debounced auto-save
        debouncedAutoSave();
    }
}

function debouncedAutoSave() {
    // Clear existing timeout
    if (saveTimeout) {
        clearTimeout(saveTimeout);
    }

    // Set new timeout for 500ms delay
    saveTimeout = setTimeout(() => {
        autoSaveForm();
    }, 500);
}

function autoSaveForm() {
    const form = document.querySelector('.invoice-design-form');
    if (!form) return;

    const formData = new FormData(form);
    const url = form.action;

    // Add visual feedback
    showSaveIndicator('Saving...');

    fetch(url, {
        method: 'PATCH',
        body: formData,
        headers: {
            'X-Requested-With': 'XMLHttpRequest',
            'Accept': 'application/json',
            'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || ''
        }
    })
        .then(response => {
            if (response.ok) {
                return response.json();
            } else {
                throw new Error(`HTTP ${response.status}: ${response.statusText}`);
            }
        })
        .then(data => {
            if (data.status === 'success') {
                showSaveIndicator('Saved', 'success');
                // Update CSS styles after successful save
                updatePreviewStyles();
            } else {
                throw new Error(data.message || 'Save failed');
            }
        })
        .catch(error => {
            console.error('Auto-save error:', error);
            showSaveIndicator('Save failed', 'error');
        });
}

function updatePreviewStyles() {
    // Get all current form values
    const formData = getCurrentDesignData();

    // Debug logging - remove this once it's working
    console.log('Updating preview styles with data:', formData);

    // Update or create the dynamic stylesheet
    updateDynamicStylesheet(formData);
}

function getCurrentDesignData() {
    const data = { text: {} };
    const elements = ['headline', 'title', 'text', 'items'];

    elements.forEach(element => {
        // Try multiple selector patterns to find fields
        let fontField = document.querySelector(`input[data-element="${element}"].font-field`) ||
            document.querySelector(`input[name*="[${element}][font]"]`);

        let sizeField = document.querySelector(`input[data-element="${element}"].size-field`) ||
            document.querySelector(`input[name*="[${element}][size]"]`);

        let colorField = document.querySelector(`input[data-element="${element}"].color-field`) ||
            document.querySelector(`input[name*="[${element}][color]"]`);

        let boldField = document.querySelector(`input[data-element="${element}"].bold-field`) ||
            document.querySelector(`input[name*="[${element}][style][bold]"]`);

        let underlineField = document.querySelector(`input[data-element="${element}"].underline-field`) ||
            document.querySelector(`input[name*="[${element}][style][underline]"]`);

        let italicField = document.querySelector(`input[data-element="${element}"].italic-field`) ||
            document.querySelector(`input[name*="[${element}][style][italic]"]`);

        // Debug logging to see what values are actually in the fields
        console.log(`${element} field values:`, {
            font: fontField ? fontField.value : 'NOT_FOUND',
            size: sizeField ? sizeField.value : 'NOT_FOUND',
            color: colorField ? colorField.value : 'NOT_FOUND',
            bold: boldField ? boldField.value : 'NOT_FOUND'
        });

        data.text[element] = {
            font: fontField ? fontField.value : 'roboto',
            size: sizeField ? sizeField.value : '12px',
            color: colorField ? colorField.value : '#000000',
            style: {
                bold: boldField ? boldField.value : 'false',
                underline: underlineField ? underlineField.value : 'false',
                italic: italicField ? italicField.value : 'false'
            }
        };
    });

    return data;
}

function updateDynamicStylesheet(designData) {
    // Remove existing dynamic stylesheet if it exists
    const existingStyle = document.getElementById('dynamic-invoice-styles');
    if (existingStyle) {
        existingStyle.remove();
    }

    // Create new style element
    const styleElement = document.createElement('style');
    styleElement.id = 'dynamic-invoice-styles';

    // Generate CSS for each text element
    let cssContent = '';
    Object.keys(designData.text).forEach(elementType => {
        const config = designData.text[elementType];
        const fontFamily = getFontFamily(config.font);

        const numericValue = parseInt(config.size.replace('px', ''));
        const fontSize = (numericValue * 0.75) + 'px';

        cssContent += `
            .${elementType}-text-change {
                font-family: ${fontFamily};
                font-size: ${fontSize};
                color: ${config.color};
                font-weight: ${config.style.bold === 'true' ? 'bold' : '400'};
                text-decoration: ${config.style.underline === 'true' ? 'underline' : 'none'};
                font-style: ${config.style.italic === 'true' ? 'italic' : 'normal'};
            }
        `;
    });

    styleElement.textContent = cssContent;
    document.head.appendChild(styleElement);
}

function getFontFamily(fontKey) {
    const fontMap = {
        'roboto': '"Roboto", sans-serif',
        'arial': '"Arial", sans-serif',
        'helvetica': '"Helvetica", sans-serif',
        'times_new_roman': '"Times New Roman", serif',
        'georgia': '"Georgia", serif',
        'verdana': '"Verdana", sans-serif',
        'tahoma': '"Tahoma", sans-serif',
        'trebuchet_ms': '"Trebuchet MS", sans-serif',
        'impact': '"Impact", sans-serif'
    };

    return fontMap[fontKey] || fontMap['roboto'];
}

// Alternative simpler approach - embed design data in the page
function initializePreviewStyles() {
    // Try to get design data from a global variable first (simpler approach)
    if (window.invoiceDesignData) {
        updateDynamicStylesheet(window.invoiceDesignData);
        return;
    }
}



function showSaveIndicator(message, type = 'loading') {
    // Remove existing indicator
    const existingIndicator = document.querySelector('.save-indicator');
    if (existingIndicator) {
        existingIndicator.remove();
    }

    // Create new indicator
    const indicator = document.createElement('div');
    indicator.className = `save-indicator ${type}`;
    indicator.textContent = message;

    // Style the indicator
    indicator.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        padding: 8px 16px;
        border-radius: 4px;
        font-size: 14px;
        z-index: 1000;
        transition: opacity 0.3s ease;
    `;

    // Apply different styles based on type
    if (type === 'success') {
        indicator.style.backgroundColor = '#10b981';
        indicator.style.color = 'white';
    } else if (type === 'error') {
        indicator.style.backgroundColor = '#ef4444';
        indicator.style.color = 'white';
    } else {
        indicator.style.backgroundColor = '#3b82f6';
        indicator.style.color = 'white';
    }

    document.body.appendChild(indicator);

    // Auto-remove success/error messages
    if (type === 'success' || type === 'error') {
        setTimeout(() => {
            indicator.style.opacity = '0';
            setTimeout(() => {
                if (indicator.parentNode) {
                    indicator.remove();
                }
            }, 300);
        }, 2000);
    }
}

function initializeEventListeners() {
    if (eventListenersInitialized) {
        return;
    }
    eventListenersInitialized = true;

    // Initialize preview styles on main page load
    initializePreviewStyles();

    // Main tool buttons
    document.addEventListener('click', function(e) {
        if (e.target.closest('.tool-button')) {
            e.preventDefault();
            const button = e.target.closest('.tool-button');
            const partialName = button.dataset.partial;
            if (partialName) {
                loadPartial(partialName);
            }
        }
    });

    // Text invoice buttons (sub-navigation)
    document.addEventListener('click', function(e) {
        if (e.target.closest('.text-invoice-button')) {
            e.preventDefault();
            const button = e.target.closest('.text-invoice-button');
            const partialName = button.dataset.partial;
            if (partialName) {
                loadTextPartial(partialName);
            }
        }
    });

    // Back to text buttons
    document.addEventListener('click', function(e) {
        if (e.target.closest('.back-to-text')) {
            e.preventDefault();
            const button = e.target.closest('.back-to-text');
            const partialName = button.dataset.partial;
            if (partialName) {
                loadPartial(partialName);
            }
        }
    });

    // Font selector change button
    document.addEventListener('click', function(e) {
        if (e.target.closest('#changeButton')) {
            e.preventDefault();
            const textEditorSections = document.querySelectorAll('.text-editor-initial');
            const textEditorFonts = document.querySelector('.text-editor-fonts');
            if (textEditorSections && textEditorFonts) {
                textEditorSections.forEach(section => section.classList.add('hidden'));
                textEditorFonts.classList.add('active');
            }
        }
    });

    // Font selector back button
    document.addEventListener('click', function(e) {
        if (e.target.closest('#backButton')) {
            e.preventDefault();
            const textEditorSections = document.querySelectorAll('.text-editor-initial');
            const textEditorFonts = document.querySelector('.text-editor-fonts');
            if (textEditorSections && textEditorFonts) {
                textEditorFonts.classList.remove('active');
                textEditorSections.forEach(section => section.classList.remove('hidden'));
            }
        }
    });

    // Style buttons (Bold, Underline, Italic)
    document.addEventListener('click', function(e) {
        if (e.target.closest('.style-button')) {
            e.preventDefault();
            const button = e.target.closest('.style-button');
            const styleType = button.dataset.style;

            if (styleType) {
                button.classList.toggle('active-font-style');
                const isActive = button.classList.contains('active-font-style');
                const currentElement = getCurrentTextElement();

                updateFormField(currentElement, styleType, isActive ? 'true' : 'false');
            }
        }
    });

    // Font options selection
    document.addEventListener('click', function(e) {
        if (e.target.closest('.font-option')) {
            e.preventDefault();
            const option = e.target.closest('.font-option');
            const fontName = option.dataset.font;

            if (fontName) {
                const currentElement = getCurrentTextElement();
                const fontDisplay = document.querySelector('#current-font-display');

                // Remove active class from all font options
                document.querySelectorAll('.font-option').forEach(opt => {
                    opt.classList.remove('bg-blue-500', 'text-white');
                });

                // Add active class to selected option
                option.classList.add('bg-blue-500', 'text-white');

                // Update form field and display
                updateFormField(currentElement, 'font', fontName);
                if (fontDisplay) {
                    fontDisplay.textContent = fontName.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase());
                }

                // Go back to main view
                const textEditorFonts = document.querySelector('.text-editor-fonts');
                const textEditorSections = document.querySelectorAll('.text-editor-initial');
                if (textEditorFonts && textEditorSections) {
                    textEditorFonts.classList.remove('active');
                    textEditorSections.forEach(section => section.classList.remove('hidden'));
                }
            }
        }
    });

    // Font size slider and input sync
    document.addEventListener('input', function(e) {
        if (e.target.id === 'fontSlider') {
            const fontInput = document.querySelector('#fontInput');
            const currentElement = getCurrentTextElement();
            const value = parseInt(e.target.value);

            if (fontInput) fontInput.value = value;
            updateFormField(currentElement, 'size', value + 'px');
        }

        if (e.target.id === 'fontInput') {
            const fontSlider = document.querySelector('#fontSlider');
            const currentElement = getCurrentTextElement();
            const value = parseInt(e.target.value);

            if (value >= 8 && value <= 72) {
                if (fontSlider) fontSlider.value = value;
                updateFormField(currentElement, 'size', value + 'px');
            }
        }
    });

    // Color picker
    document.addEventListener('change', function(e) {
        if (e.target.id === 'colorPicker') {
            const currentElement = getCurrentTextElement();
            updateFormField(currentElement, 'color', e.target.value);
        }
    });
}

// Initialize on DOM content loaded
document.addEventListener('DOMContentLoaded', initializeEventListeners);

// Turbo support - reinitialize when Turbo loads new content
document.addEventListener('turbo:load', initializeEventListeners);
document.addEventListener('turbo:frame-load', initializeEventListeners);

// For older Turbolinks (if you're using it instead of Turbo)
document.addEventListener('turbolinks:load', initializeEventListeners);