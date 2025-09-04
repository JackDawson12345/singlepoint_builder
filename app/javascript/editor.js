// Make it globally available
window.hideSidebar = hideSidebar;
window.showSectionsSidebar = showSectionsSidebar;
window.showPagesSidebar = showPagesSidebar;
window.showColourSidebar = showColourSidebar;
window.showNavigatorSidebar = showNavigatorSidebar;
window.initializeComponentSidebar = initializeComponentSidebar;
window.showEditorFieldsSidebar = showEditorFieldsSidebar;
window.addSection = addSection;
window.addSectionAbove = addSectionAbove;
window.removeSection = removeSection;
window.initializeDragAndDrop = initializeDragAndDrop;
window.updateComponentPositions = updateComponentPositions;
window.updateContentWidth = updateContentWidth;
window.initializeRealtimeUpdates = initializeRealtimeUpdates; // NEW

function hideSidebar(){
    const sidebar = document.querySelector('.editor-sidebar');
    if (sidebar) {
        sidebar.classList.remove('show');
        // Call the function when needed
        updateContentWidth();
    } else {
        console.log("Sidebar element not found!");
    }
}

function showSectionsSidebar(title, theme_page_id, area, current_component_id) {
    const sidebar = document.querySelector('.editor-sidebar');
    if (sidebar) {
        sidebar.classList.toggle('show');

        // Call the function when needed
        updateContentWidth();

        // If sidebar is being shown, fetch data via AJAX
        if (sidebar.classList.contains('show')) {
            fetchSectionsSidebarData(title, theme_page_id, area, current_component_id)
        }

        if (title) {
            const titleElement = sidebar.querySelector('.sidebar-title');
            if (titleElement) {
                titleElement.textContent = title;
            }
        }
    }
}

function showPagesSidebar(title) {
    const sidebar = document.querySelector('.editor-sidebar');
    if (sidebar) {
        sidebar.classList.toggle('show');

        // Call the function when needed
        updateContentWidth();

        // If sidebar is being shown, fetch data via AJAX
        if (sidebar.classList.contains('show')) {
            fetchSidebarData(title);
        }

        if (title) {
            const titleElement = sidebar.querySelector('.sidebar-title');
            if (titleElement) {
                titleElement.textContent = title;
            }
        }
    }
}

function showColourSidebar(title) {
    const sidebar = document.querySelector('.editor-sidebar');
    if (sidebar) {
        sidebar.classList.toggle('show');

        // Call the function when needed
        updateContentWidth();

        // If sidebar is being shown, fetch data via AJAX
        if (sidebar.classList.contains('show')) {
            fetchSidebarData(title);
        }

        if (title) {
            const titleElement = sidebar.querySelector('.sidebar-title');
            if (titleElement) {
                titleElement.textContent = title;
            }
        }
    }
}

function showNavigatorSidebar(title, theme_page_id) {
    const sidebar = document.querySelector('.editor-sidebar');
    if (sidebar) {
        sidebar.classList.toggle('show');

        // Call the function when needed
        updateContentWidth();

        // If sidebar is being shown, fetch data via AJAX
        if (sidebar.classList.contains('show')) {
            fetchNavigatorSidebarData(title, theme_page_id)
        }

        if (title) {
            const titleElement = sidebar.querySelector('.sidebar-title');
            if (titleElement) {
                titleElement.textContent = title;
            }
        }
    }
}

function fetchSidebarData(title) {
    // Get CSRF token for Rails
    const token = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

    fetch('/manage/website/editor/sidebar_data', {  // Updated to match your namespace
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': token,
            'X-Requested-With': 'XMLHttpRequest'
        },
        body: JSON.stringify({
            title: title
        })
    })
        .then(response => response.json())
        .then(data => {
            // Update sidebar content with the received data
            updateSidebarContent(data);
        })
        .catch(error => {
            console.error('Error fetching sidebar data:', error);
        });
}

function updateSidebarContent(data) {
    const sidebar = document.querySelector('.editor-sidebar');
    const contentArea = sidebar.querySelector('.sidebar-content');

    if (contentArea && data) {
        // Replace the entire content area with the AJAX response
        contentArea.innerHTML = data.html || '';

        // Initialize component sidebar functionality after content is loaded
        if (data.html && data.html.includes('menu-item')) {
            // Small delay to ensure DOM is ready
            setTimeout(() => {
                initializeComponentSidebar();
            }, 50);
        }
    }
}

function fetchNavigatorSidebarData(title, theme_page_id) {
    // Get CSRF token for Rails
    const token = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

    fetch('/manage/website/editor/sidebar_data', {  // Updated to match your namespace
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': token,
            'X-Requested-With': 'XMLHttpRequest'
        },
        body: JSON.stringify({
            title: title,
            theme_page_id: theme_page_id
        })
    })
        .then(response => response.json())
        .then(data => {
            // Update sidebar content with the received data
            updateSidebarContent(data);
        })
        .catch(error => {
            console.error('Error fetching sidebar data:', error);
        });
}

function fetchSectionsSidebarData(title, theme_page_id, area, current_component_id) {
    // Get CSRF token for Rails
    const token = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

    fetch('/manage/website/editor/sidebar_data', {  // Updated to match your namespace
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': token,
            'X-Requested-With': 'XMLHttpRequest'
        },
        body: JSON.stringify({
            title: title,
            theme_page_id: theme_page_id,
            area: area,
            current_component_id: current_component_id
        })
    })
        .then(response => response.json())
        .then(data => {
            // Update sidebar content with the received data
            updateSidebarContent(data);
        })
        .catch(error => {
            console.error('Error fetching sidebar data:', error);
        });
}

function initializeComponentSidebar() {
    const menuItems = document.querySelectorAll('.menu-item');
    const componentGroups = document.querySelectorAll('.component-group');
    const defaultMessage = document.getElementById('default-message');

    if (menuItems.length === 0) return;

    menuItems.forEach(item => {
        // Remove any existing listeners to prevent duplicates
        const newItem = item.cloneNode(true);
        item.parentNode.replaceChild(newItem, item);

        newItem.addEventListener('click', function() {
            const selectedCategory = this.dataset.category;

            // Remove active class from all menu items
            document.querySelectorAll('.menu-item').forEach(menuItem => {
                menuItem.classList.remove('bg-blue-100', 'border-l-4', 'border-blue-500');
            });

            // Add active class to clicked item
            this.classList.add('bg-blue-100', 'border-l-4', 'border-blue-500');

            // Hide all component groups
            document.querySelectorAll('.component-group').forEach(group => {
                group.classList.add('hidden');
            });

            // Hide default message
            const defaultMsg = document.getElementById('default-message');
            if (defaultMsg) {
                defaultMsg.classList.add('hidden');
            }

            // Show matching component group
            const matchingGroup = document.querySelector(`[data-type="${selectedCategory}"]`);
            if (matchingGroup) {
                matchingGroup.classList.remove('hidden');
            } else {
                if (defaultMsg) {
                    defaultMsg.innerHTML = '<p class="text-lg text-gray-500">No components found for this category.</p>';
                    defaultMsg.classList.remove('hidden');
                }
            }
        });
    });
}

function showEditorFieldsSidebar(component_id, component_type, theme_page_id, user_id, component_page_id) {
    const sidebar = document.querySelector('.editor-sidebar');
    if (sidebar) {
        sidebar.classList.toggle('show');

        // Call the function when needed
        updateContentWidth();

        // If sidebar is being shown, fetch data via AJAX
        if (sidebar.classList.contains('show')) {
            fetchEditorFieldsData(component_id, component_type, theme_page_id, user_id, component_page_id)
        }

        if (component_type) {
            const titleElement = sidebar.querySelector('.sidebar-title');
            if (titleElement) {
                titleElement.textContent = component_type;
            }
        }
    }
}

function fetchEditorFieldsData(component_id, component_type, theme_page_id, user_id, component_page_id) {
    // Get CSRF token for Rails
    const token = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

    fetch('/manage/website/editor/sidebar_editor_fields_data', {  // Updated to match your namespace
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': token,
            'X-Requested-With': 'XMLHttpRequest'
        },
        body: JSON.stringify({
            component_id: component_id,
            component_type: component_type,
            theme_page_id: theme_page_id,
            user_id: user_id,
            component_page_id: component_page_id
        })
    })
        .then(response => response.json())
        .then(data => {
            // Update sidebar content with the received data
            updateEditorFieldsContent(data, theme_page_id, component_page_id); // Updated to pass parameters
        })
        .catch(error => {
            console.error('Error fetching sidebar data:', error);
        });
}

function updateEditorFieldsContent(data, theme_page_id, component_page_id) {
    const sidebar = document.querySelector('.editor-sidebar');
    const contentArea = sidebar.querySelector('.sidebar-content');

    if (contentArea && data) {
        // Replace the entire content area with the AJAX response
        contentArea.innerHTML = data.html || '';

        // Initialize real-time updates for the new form - NEW
        if (theme_page_id && component_page_id) {
            setTimeout(() => {
                initializeRealtimeUpdates(theme_page_id, component_page_id);
            }, 100);
        }

        // Initialize component sidebar functionality after content is loaded
        if (data.html && data.html.includes('menu-item')) {
            // Small delay to ensure DOM is ready
            setTimeout(() => {
                initializeComponentSidebar();
            }, 50);
        }
    }
}

// NEW REAL-TIME UPDATES FUNCTIONALITY
function initializeRealtimeUpdates(themePageId, componentPageId) {
    // Get all form fields for this component
    const fieldSelector = `.field_${themePageId}_${componentPageId}_`;
    const formFields = document.querySelectorAll(`input[class*="field_${themePageId}_${componentPageId}_"]`);

    console.log(`Initializing real-time updates for ${themePageId}_${componentPageId}`);
    console.log(`Found ${formFields.length} form fields`);

    formFields.forEach(field => {
        // Extract field name from the class - UPDATED METHOD
        const classNames = field.className.split(' ');
        const fieldClass = classNames.find(cls => cls.startsWith(`field_${themePageId}_${componentPageId}_`));

        if (!fieldClass) {
            console.warn('Could not find field class in:', field.className);
            return;
        }

        const fieldName = fieldClass.replace(`field_${themePageId}_${componentPageId}_`, '');

        if (!fieldName) {
            console.warn('Could not extract field name from:', fieldClass);
            return;
        }

        // Find corresponding elements in the component that should be updated
        const targetClass = `${themePageId}_${componentPageId}_${fieldName}`;
        const targetSelector = `[class~="${targetClass}"]`;
        const targetElements = document.querySelectorAll(targetSelector);

        console.log(`Field: ${fieldName}, Target selector: ${targetSelector}, Found ${targetElements.length} targets`);

        if (targetElements.length === 0) {
            console.warn(`No target elements found for field: ${fieldName} with selector: ${targetSelector}`);
            return;
        }

        // Remove existing listeners to prevent duplicates
        const newField = field.cloneNode(true);
        field.parentNode.replaceChild(newField, field);

        // Add input event listener for real-time updates
        newField.addEventListener('input', function(e) {
            const newValue = e.target.value;

            targetElements.forEach(element => {
                // Handle different types of elements
                if (element.tagName === 'INPUT' || element.tagName === 'TEXTAREA') {
                    element.value = newValue;
                } else if (element.tagName === 'A') {
                    // For links, update href if it's a link field, otherwise update text content
                    if (fieldName.includes('link') || fieldName.includes('url') || fieldName.includes('href')) {
                        element.href = newValue;
                    } else {
                        element.textContent = newValue;
                    }
                } else {
                    // For other elements (spans, divs, h1, etc.), update text content
                    element.textContent = newValue;
                }
            });

            // Add visual feedback to show the update happened
            targetElements.forEach(element => {
                element.classList.add('field-updated');
                setTimeout(() => {
                    element.classList.remove('field-updated');
                }, 300);
            });

            console.log(`Updated ${targetElements.length} elements for field: ${fieldName} with value: ${newValue}`);
        });

        // Also listen for paste events
        newField.addEventListener('paste', function(e) {
            // Use setTimeout to get the pasted content after it's been inserted
            setTimeout(() => {
                newField.dispatchEvent(new Event('input', { bubbles: true }));
            }, 10);
        });
    });
}

function addSection(component_id, theme_page_id, user_id){
    const token = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

    fetch('/manage/website/editor/add_section', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': token,
            'X-Requested-With': 'XMLHttpRequest'
        },
        body: JSON.stringify({
            component_id: component_id,
            theme_page_id: theme_page_id,
            user_id: user_id
        })
    })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                // Update the main content area
                document.querySelector('.w-19\\/20').innerHTML = data.html;
                // Re-initialize drag and drop
                initializeDragAndDrop();
                // Hide the sidebar
                hideSidebar();
                console.log(data.message);
            } else {
                console.error(data.message);
                alert(data.message);
            }
        })
        .catch(error => {
            console.error('Error adding section:', error);
        });
}

function addSectionAbove(component_id, theme_page_id, user_id, current_component_id){
    const token = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

    fetch('/manage/website/editor/add_section_above', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': token,
            'X-Requested-With': 'XMLHttpRequest'
        },
        body: JSON.stringify({
            component_id: component_id,
            theme_page_id: theme_page_id,
            user_id: user_id,
            current_component_id: current_component_id
        })
    })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                // Update the main content area
                document.querySelector('.w-19\\/20').innerHTML = data.html;
                // Re-initialize drag and drop
                initializeDragAndDrop();
                // Hide the sidebar
                hideSidebar();
                console.log(data.message);
            } else {
                console.error(data.message);
                alert(data.message);
            }
        })
        .catch(error => {
            console.error('Error adding section:', error);
        });
}

function removeSection(component_id, theme_page_id, user_id, current_component_id){
    const token = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

    fetch('/manage/website/editor/remove_section', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': token,
            'X-Requested-With': 'XMLHttpRequest'
        },
        body: JSON.stringify({
            component_id: component_id,
            theme_page_id: theme_page_id,
            user_id: user_id,
            current_component_id: current_component_id
        })
    })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                // Update the main content area
                document.querySelector('.w-19\\/20').innerHTML = data.html;
                // Re-initialize drag and drop
                initializeDragAndDrop();
                // Hide the sidebar
                hideSidebar();
                console.log(data.message);
            } else {
                console.error(data.message);
                alert(data.message);
            }
        })
        .catch(error => {
            console.error('Error removing section:', error);
        });
}

// NEW DRAG AND DROP FUNCTIONALITY
function initializeDragAndDrop() {
    const sections = document.querySelectorAll('.edit-content-section');

    sections.forEach((section, index) => {
        section.draggable = true;
        section.style.cursor = 'move';

        // Add visual feedback
        section.addEventListener('dragstart', handleDragStart);
        section.addEventListener('dragover', handleDragOver);
        section.addEventListener('drop', handleDrop);
        section.addEventListener('dragend', handleDragEnd);
        section.addEventListener('dragenter', handleDragEnter);
        section.addEventListener('dragleave', handleDragLeave);
    });
}

let draggedElement = null;
let draggedIndex = null;

function handleDragStart(e) {
    draggedElement = this;
    draggedIndex = Array.from(this.parentNode.children).indexOf(this);
    this.style.opacity = '0.5';

    // Set drag effect
    e.dataTransfer.effectAllowed = 'move';
    e.dataTransfer.setData('text/html', this.outerHTML);
}

function handleDragOver(e) {
    if (e.preventDefault) {
        e.preventDefault();
    }

    e.dataTransfer.dropEffect = 'move';
    return false;
}

function handleDragEnter(e) {
    if (this !== draggedElement) {
        this.style.borderTop = '3px solid #3B82F6';
    }
}

function handleDragLeave(e) {
    this.style.borderTop = '';
}

function handleDrop(e) {
    if (e.stopPropagation) {
        e.stopPropagation();
    }

    if (draggedElement !== this) {
        const dropIndex = Array.from(this.parentNode.children).indexOf(this);
        const container = this.parentNode;

        // Remove border indicator
        this.style.borderTop = '';

        // Perform the DOM manipulation
        if (draggedIndex < dropIndex) {
            container.insertBefore(draggedElement, this.nextSibling);
        } else {
            container.insertBefore(draggedElement, this);
        }

        // Update positions via AJAX
        updateComponentPositions();
    }

    return false;
}

function handleDragEnd(e) {
    this.style.opacity = '1';

    // Remove all border indicators
    const sections = document.querySelectorAll('.edit-content-section');
    sections.forEach(section => {
        section.style.borderTop = '';
    });

    draggedElement = null;
    draggedIndex = null;
}

function updateComponentPositions() {
    const sections = document.querySelectorAll('.edit-content-section');
    const positions = [];

    // Extract component data and new positions
    sections.forEach((section, index) => {
        // You'll need to add data attributes to your ERB template to store these values
        const componentPageId = section.getAttribute('data-component-page-id');
        const componentId = section.getAttribute('data-component-id');

        if (componentPageId && componentId) {
            positions.push({
                component_page_id: componentPageId,
                component_id: parseInt(componentId),
                position: index + 1
            });
        }
    });

    // Get current page data
    const themePageId = document.querySelector('[data-theme-page-id]')?.getAttribute('data-theme-page-id');
    const userId = document.querySelector('[data-user-id]')?.getAttribute('data-user-id');

    if (!themePageId || !userId) {
        console.error('Missing theme_page_id or user_id');
        return;
    }

    // Send AJAX request to update positions
    const token = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

    fetch('/manage/website/editor/reorder_components', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': token,
            'X-Requested-With': 'XMLHttpRequest'
        },
        body: JSON.stringify({
            theme_page_id: themePageId,
            user_id: userId,
            positions: positions
        })
    })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                console.log('Component positions updated successfully');
            } else {
                console.error('Failed to update positions:', data.message);
                // Optionally reload the page or show error message
            }
        })
        .catch(error => {
            console.error('Error updating component positions:', error);
        });
}

// Initialize drag and drop when DOM is loaded
// Handle Turbo page loads
document.addEventListener('turbo:load', function() {
    initializeDragAndDrop();
});

function updateContentWidth() {
    const sidebar = document.querySelector('.editor-sidebar');
    const pageContentSections = document.querySelectorAll('.page-content-section');

    if (sidebar) {

        // Update page-content-section elements
        if (pageContentSections.length > 0) {
            pageContentSections.forEach(contentSection => {
                if (sidebar.classList.contains('show')) {
                    contentSection.style.width = 'calc(100% - 503px)';
                } else {
                    contentSection.style.width = ''; // Reset to default
                }
            });
        }
    }
}

// Add CSS for visual feedback
document.addEventListener('DOMContentLoaded', function() {
    const style = document.createElement('style');
    style.textContent = `
        .field-updated {
            transition: all 0.3s ease !important;
            background-color: rgba(59, 130, 246, 0.1) !important;
            border-color: #3b82f6 !important;
            box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1) !important;
        }
        
        .sidebar-field input:focus {
            outline: none !important;
            border-color: #3b82f6 !important;
            box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1) !important;
        }
    `;
    if (!document.querySelector('style[data-realtime-updates]')) {
        style.setAttribute('data-realtime-updates', 'true');
        document.head.appendChild(style);
    }
});




window.ImageUploadHandler = {
    triggerFileInput(fieldId) {
        document.getElementById(fieldId).click();
    },

    handleFileSelect(event, fieldId) {
        const file = event.target.files[0];
        if (!file) return;

        const container = document.querySelector(`[data-field-id="${fieldId}"]`);

        // Validate file type
        if (!file.type.startsWith('image/')) {
            this.showError(container, 'Please select a valid image file');
            return;
        }

        // Validate file size (5MB max)
        if (file.size > 5 * 1024 * 1024) {
            this.showError(container, 'Image size must be less than 5MB');
            return;
        }

        // Create preview
        const reader = new FileReader();
        reader.onload = (e) => {
            this.createImagePreview(container, e.target.result, fieldId);
        };
        reader.readAsDataURL(file);
    },

    createImagePreview(container, imageSrc, fieldId) {
        const previewHTML = `
      <div class="current-image-display group relative overflow-hidden rounded-xl border-2 border-green-300 bg-white shadow-lg transition-all duration-300 hover:shadow-xl animate-fade-in">
        <div class="aspect-video relative overflow-hidden bg-gray-50">
          <img src="${imageSrc}" 
               class="w-full h-full object-cover transition-transform duration-300 group-hover:scale-105"
               id="preview-${fieldId}">
          
          <div class="absolute inset-0 bg-black bg-opacity-0 group-hover:bg-opacity-30 transition-all duration-300 flex items-center justify-center">
            <div class="opacity-0 group-hover:opacity-100 transition-opacity duration-300">
              <div class="flex space-x-3">
                <button type="button" 
                        class="change-image-btn bg-white text-gray-700 px-4 py-2 rounded-lg font-medium shadow-lg hover:bg-gray-50 transition-colors flex items-center space-x-2"
                        onclick="ImageUploadHandler.triggerFileInput('${fieldId}')">
                  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-8l-4-4m0 0L8 8m4-4v12"/>
                  </svg>
                  <span>Change</span>
                </button>
                <button type="button" 
                        class="remove-image-btn bg-red-500 text-white px-4 py-2 rounded-lg font-medium shadow-lg hover:bg-red-600 transition-colors flex items-center space-x-2"
                        onclick="ImageUploadHandler.removeImage('${fieldId}')">
                  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/>
                  </svg>
                  <span>Remove</span>
                </button>
              </div>
            </div>
          </div>
        </div>
        
        <div class="p-4 bg-gradient-to-r from-green-50 to-emerald-50">
          <div class="flex items-center justify-between">
            <div class="flex items-center space-x-2">
              <div class="w-2 h-2 bg-green-500 rounded-full animate-pulse"></div>
              <span class="text-sm font-medium text-gray-700">New Image Selected</span>
            </div>
            <span class="text-xs text-green-700 bg-green-100 px-2 py-1 rounded-full">Ready to Upload</span>
          </div>
        </div>
      </div>
    `;

        container.innerHTML = previewHTML + container.querySelector('input[type="file"]').outerHTML;
    },

    removeImage(fieldId) {
        const container = document.querySelector(`[data-field-id="${fieldId}"]`);
        const fileInput = document.getElementById(fieldId);

        fileInput.value = '';

        const uploadHTML = `
      <div class="upload-drop-zone border-3 border-dashed border-gray-300 rounded-xl p-8 text-center transition-all duration-300 hover:border-blue-400 hover:bg-blue-50/30 cursor-pointer group"
           onclick="ImageUploadHandler.triggerFileInput('${fieldId}')"
           ondrop="ImageUploadHandler.handleDrop(event, '${fieldId}')"
           ondragover="ImageUploadHandler.handleDragOver(event)"
           ondragleave="ImageUploadHandler.handleDragLeave(event)">
        
        <div class="upload-content">
          <div class="mx-auto w-16 h-16 bg-gradient-to-br from-blue-100 to-indigo-200 rounded-full flex items-center justify-center mb-4 group-hover:from-blue-200 group-hover:to-indigo-300 transition-all duration-300">
            <svg class="w-8 h-8 text-blue-600 group-hover:text-blue-700" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12"/>
            </svg>
          </div>
          
          <h3 class="text-lg font-semibold text-gray-900 mb-2 group-hover:text-blue-900 transition-colors">
            Drop your image here
          </h3>
          <p class="text-gray-600 mb-4 group-hover:text-gray-700 transition-colors">
            or <span class="text-blue-600 font-medium">browse</span> to choose a file
          </p>
          
          <div class="flex items-center justify-center space-x-4 text-xs text-gray-500">
            <span class="bg-gray-100 px-2 py-1 rounded">JPG</span>
            <span class="bg-gray-100 px-2 py-1 rounded">PNG</span>
            <span class="bg-gray-100 px-2 py-1 rounded">GIF</span>
            <span class="bg-gray-100 px-2 py-1 rounded">WEBP</span>
          </div>
        </div>
      </div>
    `;

        container.innerHTML = uploadHTML + fileInput.outerHTML;
    },

    handleDrop(event, fieldId) {
        event.preventDefault();
        event.stopPropagation();

        const dropZone = event.currentTarget;
        dropZone.classList.remove('border-blue-500', 'bg-blue-100');
        dropZone.classList.add('border-gray-300');

        const files = event.dataTransfer.files;
        if (files.length > 0) {
            const fileInput = document.getElementById(fieldId);
            fileInput.files = files;
            this.handleFileSelect({target: fileInput}, fieldId);
        }
    },

    handleDragOver(event) {
        event.preventDefault();
        event.stopPropagation();

        const dropZone = event.currentTarget;
        dropZone.classList.add('border-blue-500', 'bg-blue-100');
        dropZone.classList.remove('border-gray-300');
    },

    handleDragLeave(event) {
        event.preventDefault();
        event.stopPropagation();

        const dropZone = event.currentTarget;
        dropZone.classList.remove('border-blue-500', 'bg-blue-100');
        dropZone.classList.add('border-gray-300');
    },

    showError(container, message) {
        const errorHTML = `
      <div class="error-message mt-4 p-3 bg-red-50 border border-red-200 rounded-lg text-red-700 text-sm animate-fade-in">
        ${message}
      </div>
    `;

        const existingError = container.querySelector('.error-message');
        if (existingError) {
            existingError.remove();
        }

        container.insertAdjacentHTML('beforeend', errorHTML);

        setTimeout(() => {
            const errorElement = container.querySelector('.error-message');
            if (errorElement) {
                errorElement.remove();
            }
        }, 5000);
    }
};