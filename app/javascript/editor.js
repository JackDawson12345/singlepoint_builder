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
window.initializeRealtimeUpdates = initializeRealtimeUpdates;
window.showColourOption = showColourOption;
window.showTextOption = showTextOption;
window.showBackgroundOption = showBackgroundOption;
window.showEditorFields = showEditorFields;
window.singleFieldTab = singleFieldTab;
window.initializeLiveStyleUpdates = initializeLiveStyleUpdates;
window.managePagesSidebar = managePagesSidebar;
window.openEditorPopup = openEditorPopup;
window.hideEditorPopup = hideEditorPopup;


function hideSidebar(){
    const sidebar = document.querySelector('.editor-sidebar');
    const editorPopup = document.querySelector('.editor-edit-popup-outer');
    if (editorPopup) {
        editorPopup.classList.add('hidden');
    }
    if (sidebar) {
        sidebar.classList.remove('show');
        // Call the function when needed
        updateContentWidth();
    } else {
        console.log("Sidebar element not found!");
    }
}

function hideEditorPopup(){
    const editorPopup = document.querySelector('.editor-edit-popup-outer');
    if (editorPopup) {
        editorPopup.classList.toggle('hidden');
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
            // Show loader, hide content
            const loader = sidebar.querySelector('.side-popup-loader');
            const titleElement = sidebar.querySelector('.side-popup-title');
            const content = sidebar.querySelector('.side-popup-content');

            loader.style.display = 'flex';
            titleElement.style.display = 'none';
            content.style.display = 'none';

            // After 1 second, hide loader and show content
            setTimeout(() => {
                loader.style.display = 'none';
                titleElement.style.display = 'flex';
                content.style.display = 'block';
            }, 700);

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
            // Show loader, hide content
            const loader = sidebar.querySelector('.side-popup-loader');
            const titleElement = sidebar.querySelector('.side-popup-title');
            const content = sidebar.querySelector('.side-popup-content');

            loader.style.display = 'flex';
            titleElement.style.display = 'none';
            content.style.display = 'none';

            // After 1 second, hide loader and show content
            setTimeout(() => {
                loader.style.display = 'none';
                titleElement.style.display = 'flex';
                content.style.display = 'block';
            }, 500);

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

function managePagesSidebar(title){
    const sidebar = document.querySelector('.editor-sidebar');
    if (sidebar) {
        sidebar.classList.toggle('show');

        // Call the function when needed
        updateContentWidth();

        // If sidebar is being shown, fetch data via AJAX
        if (sidebar.classList.contains('show')) {
            // Show loader, hide content
            const loader = sidebar.querySelector('.side-popup-loader');
            const titleElement = sidebar.querySelector('.side-popup-title');
            const content = sidebar.querySelector('.side-popup-content');

            loader.style.display = 'flex';
            titleElement.style.display = 'none';
            content.style.display = 'none';

            // After 1 second, hide loader and show content
            setTimeout(() => {
                loader.style.display = 'none';
                titleElement.style.display = 'flex';
                content.style.display = 'block';
            }, 500);

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
            // Show loader, hide content
            const loader = sidebar.querySelector('.side-popup-loader');
            const titleElement = sidebar.querySelector('.side-popup-title');
            const content = sidebar.querySelector('.side-popup-content');

            loader.style.display = 'flex';
            titleElement.style.display = 'none';
            content.style.display = 'none';

            // After 1 second, hide loader and show content
            setTimeout(() => {
                loader.style.display = 'none';
                titleElement.style.display = 'flex';
                content.style.display = 'block';
            }, 500);

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
            // Show loader, hide content
            const loader = sidebar.querySelector('.side-popup-loader');
            const titleElement = sidebar.querySelector('.side-popup-title');
            const content = sidebar.querySelector('.side-popup-content');

            loader.style.display = 'flex';
            titleElement.style.display = 'none';
            content.style.display = 'none';

            // After 1 second, hide loader and show content
            setTimeout(() => {
                loader.style.display = 'none';
                titleElement.style.display = 'flex';
                content.style.display = 'block';
            }, 500);

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

        // Initialize live style updates for single field forms
        if (data.html && data.html.includes('single-field-form')) {
            setTimeout(() => {
                initializeLiveStyleUpdates();
            }, 100);
        }

        // Initialize component sidebar functionality after content is loaded
        if (data.html && data.html.includes('menu-item')) {
            setTimeout(() => {
                initializeComponentSidebar();
            }, 50);
        }

        // ADD THIS: Initialize drag and drop for pages sidebar
        if (data.html && data.html.includes('draggable-page')) {
            setTimeout(() => {
                console.log('Sidebar loaded, initializing page drag-drop...');
                initializePageMenuDragDrop();
            }, 100);
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

function fetchColourSidebarData(title, theme_page_id){
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
            // Show loader, hide content
            const loader = sidebar.querySelector('.side-popup-loader');
            const titleElement = sidebar.querySelector('.side-popup-title');
            const content = sidebar.querySelector('.side-popup-content');

            loader.style.display = 'flex';
            titleElement.style.display = 'none';
            content.style.display = 'none';

            // After 1 second, hide loader and show content
            setTimeout(() => {
                loader.style.display = 'none';
                titleElement.style.display = 'flex';
                content.style.display = 'block';
            }, 500);

            fetchEditorFieldsData(component_id, component_type, theme_page_id, user_id, component_page_id)
        }

        if (component_type) {
            const titleElement = sidebar.querySelector('.sidebar-title');
            if (titleElement) {
                titleElement.textContent = component_type + ' Background';
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

        // Initialize real-time updates for the new form
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

// REAL-TIME UPDATES FUNCTIONALITY
function initializeRealtimeUpdates(themePageId, componentPageId) {
    // Get all form fields for this component
    const fieldSelector = `.field_${themePageId}_${componentPageId}_`;
    const formFields = document.querySelectorAll(`input[class*="field_${themePageId}_${componentPageId}_"], textarea[class*="field_${themePageId}_${componentPageId}_"]`);

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

// DRAG AND DROP FUNCTIONALITY
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
                    contentSection.style.width = 'calc(100% - 350px)';
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

function showColourOption(){
    const colourOption = document.querySelector('.colour-theme-tab');
    const textOption = document.querySelector('.text-theme-tab');
    const backgroundOption = document.querySelector('.page-background-tab');

    colourOption.classList.remove("show-sidebar-option");
    textOption.classList.remove("show-sidebar-option");
    backgroundOption.classList.remove("show-sidebar-option");

    colourOption.classList.add("show-sidebar-option");
    textOption.classList.add("hidden-sidebar-option");
    backgroundOption.classList.add("hidden-sidebar-option");
}

function showTextOption(){
    const colourOption = document.querySelector('.colour-theme-tab');
    const textOption = document.querySelector('.text-theme-tab');
    const backgroundOption = document.querySelector('.page-background-tab');
    colourOption.classList.remove("show-sidebar-option");
    textOption.classList.remove("show-sidebar-option");
    backgroundOption.classList.remove("show-sidebar-option");

    colourOption.classList.add("hidden-sidebar-option");
    textOption.classList.add("show-sidebar-option");
    backgroundOption.classList.add("hidden-sidebar-option");
}

function showBackgroundOption(){
    const colourOption = document.querySelector('.colour-theme-tab');
    const textOption = document.querySelector('.text-theme-tab');
    const backgroundOption = document.querySelector('.page-background-tab');
    colourOption.classList.remove("show-sidebar-option");
    textOption.classList.remove("show-sidebar-option");
    backgroundOption.classList.remove("show-sidebar-option");

    colourOption.classList.add("hidden-sidebar-option");
    textOption.classList.add("hidden-sidebar-option");
    backgroundOption.classList.add("show-sidebar-option");
}

function showEditorFields(field_class){
    const classes = splitUuidStringRegex(field_class)
    const fieldNameWithSpaces = classes.fieldName.replace(/_/g, ' ');
    const themePageId = classes.firstUuid
    const componentPageId = classes.secondUuid

    const sidebar = document.querySelector('.editor-sidebar');
    if (sidebar) {
        sidebar.classList.toggle('show');

        // Call the function when needed
        updateContentWidth();

        // If sidebar is being shown, fetch data via AJAX
        if (sidebar.classList.contains('show')) {
            // Show loader, hide content
            const loader = sidebar.querySelector('.side-popup-loader');
            const title = sidebar.querySelector('.side-popup-title');
            const content = sidebar.querySelector('.side-popup-content');

            loader.style.display = 'flex';
            title.style.display = 'none';
            content.style.display = 'none';

            // After 1 second, hide loader and show content
            setTimeout(() => {
                loader.style.display = 'none';
                title.style.display = 'flex';
                content.style.display = 'block';
            }, 500);

            fetchSingleFieldSidebarData(classes.fieldName, themePageId, componentPageId)
        }

        if (fieldNameWithSpaces) {
            const titleElement = sidebar.querySelector('.sidebar-title');
            if (titleElement) {
                titleElement.textContent = 'Edit ' + fieldNameWithSpaces;
            }
        }

    }
}

function splitUuidStringRegex(str) {
    // Regex to match: UUID_UUID_fieldname pattern
    const regex = /^([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})_([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})_(.+)$/;

    const match = str.match(regex);

    if (match) {
        return {
            firstUuid: match[1],
            secondUuid: match[2],
            fieldName: match[3]
        };
    } else {
        console.error('String does not match expected UUID_UUID_fieldname pattern');
        return null;
    }
}

function fetchSingleFieldSidebarData(field_name, theme_page_id, component_id){
    const token = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

    fetch('/manage/website/editor/single_field_data', {  // Updated to match your namespace
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': token,
            'X-Requested-With': 'XMLHttpRequest'
        },
        body: JSON.stringify({
            field_name: field_name,
            theme_page_id: theme_page_id,
            component_id: component_id
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

function singleFieldTab(tabType){
    if(tabType === 'content'){
        // Hide style form, show content form
        document.querySelector('.single-sidebar-form-style').style.display = 'none';
        document.querySelector('.single-sidebar-form-fields').style.display = 'block';

        // Update tab styling
        document.querySelector('.content-tab-title').classList.add('text-green-500');
        document.querySelector('.style-tab-title').classList.remove('text-green-500');

        document.querySelector('.content-tab-icon').classList.add('fill-green-500');
        document.querySelector('.style-tab-icon').classList.remove('fill-green-500');

    } else if(tabType === 'style'){
        // Show style form, hide content form
        document.querySelector('.single-sidebar-form-style').style.display = 'block';
        document.querySelector('.single-sidebar-form-fields').style.display = 'none';

        // Update tab styling
        document.querySelector('.style-tab-title').classList.add('text-green-500');
        document.querySelector('.content-tab-title').classList.remove('text-green-500');

        document.querySelector('.style-tab-icon').classList.add('fill-green-500');
        document.querySelector('.content-tab-icon').classList.remove('fill-green-500');
    }
}

// Live style updates for form fields
// Updated initializeLiveStyleUpdates function with proper CSS selector escaping
function initializeLiveStyleUpdates() {
    console.log('Initializing live style updates...');

    // Get the current field class from the form
    function getCurrentFieldClass() {
        const form = document.querySelector('.single-field-form');
        if (!form) return null;

        const themePageId = form.querySelector('[name="theme_page_id"]')?.value;
        const componentPageId = form.querySelector('[name="component_page_id"]')?.value;

        // Get the field name from the visible content field
        const contentField = form.querySelector('.single-sidebar-form-fields input[type="text"], .single-sidebar-form-fields textarea, .single-sidebar-form-fields input[type="hidden"]');
        if (contentField && themePageId && componentPageId) {
            const fieldName = contentField.name;
            return `${themePageId}_${componentPageId}_${fieldName}`;
        }
        return null;
    }

    // Escape CSS selector for classes that start with numbers or contain special characters
    function escapeSelector(selector) {
        // CSS.escape is the standard way, but if not available, use manual escaping
        if (typeof CSS !== 'undefined' && CSS.escape) {
            return CSS.escape(selector);
        }

        // Manual escaping for common cases
        return selector.replace(/^(\d)/, '\\3$1 ').replace(/([!"#$%&'()*+,.\/:;<=>?@[\\\]^`{|}~])/g, '\\$1');
    }

    // Update element style property
    function updateElementStyle(property, value, suffix = '') {
        const fieldClass = getCurrentFieldClass();
        if (!fieldClass) {
            console.warn('Could not get field class');
            return;
        }

        // Use attribute selector instead of class selector to avoid CSS parsing issues
        const element = document.querySelector(`[class~="${fieldClass}"]`);

        if (element) {
            element.style[property] = value + suffix;
            console.log(`Updated ${property} to ${value}${suffix} for field class: ${fieldClass}`);
        } else {
            console.warn(`Could not find element with class: ${fieldClass}`);

            // Fallback: try to find by escaped class selector
            try {
                const escapedClass = escapeSelector(fieldClass);
                const fallbackElement = document.querySelector(`.${escapedClass}`);
                if (fallbackElement) {
                    fallbackElement.style[property] = value + suffix;
                    console.log(`Updated ${property} using escaped selector for: ${fieldClass}`);
                } else {
                    console.warn(`No element found even with escaped selector: ${escapedClass}`);
                }
            } catch (e) {
                console.error('Error with escaped selector:', e);
            }
        }
    }

    // Map form field names to CSS properties
    const styleMapping = {
        'alignment': { property: 'textAlign', suffix: '' },
        'text_colour': { property: 'color', suffix: '' },
        'font_size': { property: 'fontSize', suffix: 'px' },
        'font_weight': { property: 'fontWeight', suffix: '' },
        'font_transform': { property: 'textTransform', suffix: '' },
        'font_style': { property: 'fontStyle', suffix: '' },
        'font_decoration': { property: 'textDecoration', suffix: '' },
        'line_height': { property: 'lineHeight', suffix: 'px' },
        'letter_spacing': { property: 'letterSpacing', suffix: 'px' },
        'word_spacing': { property: 'wordSpacing', suffix: 'px' }
    };

    // Add event listeners to all style form fields
    Object.keys(styleMapping).forEach(fieldName => {
        const field = document.querySelector(`[name="${fieldName}"]`);
        if (field) {
            const config = styleMapping[fieldName];
            console.log(`Found field: ${fieldName}, type: ${field.type}`);

            if (field.type === 'select-one') {
                field.addEventListener('change', function() {
                    let value = this.value;

                    // Handle special cases for default values
                    if (value === 'default' || value === '') {
                        switch(fieldName) {
                            case 'font_transform':
                                value = 'none';
                                break;
                            case 'font_style':
                                value = 'normal';
                                break;
                            case 'font_decoration':
                                value = 'none';
                                break;
                            default:
                                value = '';
                        }
                    }

                    // Handle alignment mapping
                    if (fieldName === 'alignment') {
                        if (value === 'justified') value = 'justify';
                    }

                    updateElementStyle(config.property, value, config.suffix);
                });
            } else if (field.type === 'number') {
                field.addEventListener('input', function() {
                    const value = this.value;
                    updateElementStyle(config.property, value, config.suffix);
                });
            } else if (field.type === 'color') {
                field.addEventListener('input', function() {
                    const value = this.value;
                    updateElementStyle(config.property, value, config.suffix);
                });
            }
        } else {
            console.warn(`Field not found: ${fieldName}`);
        }
    });

    // Handle font family separately as it might need special handling
    const fontFamilyField = document.querySelector('[name="font_family"]');
    if (fontFamilyField) {
        console.log('Found font family field');
        fontFamilyField.addEventListener('change', function() {
            // You might need to map these values to actual font names
            const fontMapping = {
                'value1': 'Arial, sans-serif',
                'value2': 'Georgia, serif',
                'value3': 'Courier New, monospace'
                // Add more mappings as needed
            };

            const value = fontMapping[this.value] || this.value;
            updateElementStyle('fontFamily', value, '');
        });
    }
}

// Drag and Drop for Pages Menu with Sub-page Support
// Drag and Drop for Pages Menu with Sub-page Support (including dragging sub-pages out)
function initializePageMenuDragDrop() {
    console.log('Initializing page menu drag and drop...');

    const draggablePages = document.querySelectorAll('.draggable-page');
    console.log('Found draggable pages:', draggablePages.length);

    if (draggablePages.length === 0) {
        console.error('No draggable pages found!');
        return;
    }

    let draggedElement = null;
    let placeholder = null;
    const INDENT_THRESHOLD = 40; // pixels from left to trigger sub-page

    // Create placeholder element
    function createPlaceholder(isSubPage = false) {
        const div = document.createElement('div');
        div.className = 'drag-placeholder';
        const marginLeft = isSubPage ? '1.5rem' : '0';
        div.style.cssText = `
            height: 50px;
            border: 2px dashed #10b981;
            background-color: #d1fae5;
            border-radius: 0.375rem;
            margin: 0.5rem 0;
            margin-left: ${marginLeft};
            display: flex;
            align-items: center;
            justify-content: center;
            color: #059669;
            font-size: 0.875rem;
            pointer-events: none;
            transition: margin-left 0.2s ease;
        `;
        div.innerHTML = isSubPage
            ? '<span>↳ Drop here as sub-page</span>'
            : '<span>Drop here</span>';
        return div;
    }

    draggablePages.forEach((page, index) => {
        page.draggable = true;

        page.addEventListener('dragstart', (e) => {
            console.log('Drag started');
            draggedElement = e.currentTarget;
            const element = e.currentTarget;
            element.style.opacity = '0.4';
            e.dataTransfer.effectAllowed = 'move';
            e.dataTransfer.setData('text/plain', index);

            setTimeout(() => {
                if (element) {
                    element.classList.add('dragging');
                }
            }, 0);
        });

        page.addEventListener('dragend', (e) => {
            console.log('Drag ended');
            if (e.currentTarget) {
                e.currentTarget.style.opacity = '1';
                e.currentTarget.classList.remove('dragging');
            }

            if (placeholder && placeholder.parentNode) {
                placeholder.parentNode.removeChild(placeholder);
                placeholder = null;
            }

            draggedElement = null;
        });

        page.addEventListener('dragover', (e) => {
            e.preventDefault();
            e.stopPropagation();

            if (!draggedElement || e.currentTarget === draggedElement || e.currentTarget.classList.contains('dragging')) {
                return;
            }

            e.dataTransfer.dropEffect = 'move';

            // Get horizontal position relative to page element
            const rect = e.currentTarget.getBoundingClientRect();
            const relativeX = e.clientX - rect.left;
            const midpoint = rect.top + rect.height / 2;
            const isTopHalf = e.clientY < midpoint;

            // Check if target is already a sub-page
            const isTargetSubPage = e.currentTarget.classList.contains('ml-6');

            // Check if dragged element is a sub-page
            const isDraggedSubPage = draggedElement.classList.contains('ml-6');

            // Determine if this should be a sub-page drop
            let shouldBeSubPage = false;

            if (!isTopHalf && !isTargetSubPage && relativeX > INDENT_THRESHOLD) {
                // Dragging below a main page with indentation = make it a sub-page
                shouldBeSubPage = true;
            } else if (isTargetSubPage && !isDraggedSubPage) {
                // Dragging onto an existing sub-page area from a main page = keep as sub-page
                shouldBeSubPage = true;
            } else if (isTargetSubPage && isDraggedSubPage && relativeX > INDENT_THRESHOLD) {
                // Dragging a sub-page onto another sub-page = keep as sub-page
                shouldBeSubPage = true;
            } else if (isDraggedSubPage && relativeX < INDENT_THRESHOLD) {
                // Dragging a sub-page to the left (outside threshold) = make it a main page
                shouldBeSubPage = false;
            }

            // Remove existing placeholder
            if (placeholder && placeholder.parentNode) {
                placeholder.parentNode.removeChild(placeholder);
            }

            // Create new placeholder
            placeholder = createPlaceholder(shouldBeSubPage);

            // Store metadata on placeholder for drop event
            placeholder.dataset.isSubPage = shouldBeSubPage;
            placeholder.dataset.targetPageId = e.currentTarget.dataset.pageId || '';

            // Insert placeholder in correct position
            if (isTopHalf) {
                e.currentTarget.parentNode.insertBefore(placeholder, e.currentTarget);
            } else {
                if (e.currentTarget.nextSibling) {
                    e.currentTarget.parentNode.insertBefore(placeholder, e.currentTarget.nextSibling);
                } else {
                    e.currentTarget.parentNode.appendChild(placeholder);
                }
            }
        });

        page.addEventListener('dragenter', (e) => {
            e.preventDefault();
        });

        page.addEventListener('drop', (e) => {
            e.preventDefault();
            e.stopPropagation();
            console.log('Drop event fired on page!');

            if (!draggedElement) {
                console.log('No dragged element');
                return;
            }

            if (placeholder && placeholder.parentNode) {
                const isSubPage = placeholder.dataset.isSubPage === 'true';
                console.log('Is sub-page:', isSubPage);

                // Insert element at placeholder position
                placeholder.parentNode.insertBefore(draggedElement, placeholder);

                // Add or remove sub-page styling
                if (isSubPage) {
                    draggedElement.classList.add('ml-6');
                    console.log('Added ml-6 class for sub-page');
                } else {
                    draggedElement.classList.remove('ml-6');
                    console.log('Removed ml-6 class for main page');
                }

                placeholder.parentNode.removeChild(placeholder);
                placeholder = null;
                draggedElement.style.opacity = '1';
                draggedElement.classList.remove('dragging');

                console.log('Item moved successfully');
                updatePageMenuOrder();
            }
        });
    });

    // Handle drop on the container itself (fallback)
    const container = draggablePages[0]?.parentNode;
    if (container) {
        container.addEventListener('dragover', (e) => {
            e.preventDefault();
            e.dataTransfer.dropEffect = 'move';
        });

        container.addEventListener('drop', (e) => {
            e.preventDefault();
            console.log('Drop on container - moving element');

            if (!draggedElement || !placeholder || !placeholder.parentNode) {
                console.log('Missing draggedElement or placeholder');
                return;
            }

            const isSubPage = placeholder.dataset.isSubPage === 'true';

            placeholder.parentNode.insertBefore(draggedElement, placeholder);
            placeholder.parentNode.removeChild(placeholder);
            placeholder = null;

            if (draggedElement) {
                draggedElement.style.opacity = '1';
                draggedElement.classList.remove('dragging');

                // Add or remove sub-page styling
                if (isSubPage) {
                    draggedElement.classList.add('ml-6');
                } else {
                    draggedElement.classList.remove('ml-6');
                }
            }

            console.log('Item moved successfully via container');
            updatePageMenuOrder();

            draggedElement = null;
        });
    }

    console.log('Page menu drag setup complete!');
}

function updatePageMenuOrder() {
    const pages = document.querySelectorAll('.draggable-page');
    const order = [];
    let currentParent = null;

    pages.forEach((page, index) => {
        const link = page.querySelector('a');
        const isSubPage = page.classList.contains('ml-6');

        if (link) {
            const pageData = {
                name: link.textContent.trim(),
                position: index,
                isSubPage: isSubPage
            };

            // If it's a sub-page, track which parent it belongs to
            if (isSubPage && currentParent) {
                pageData.parentPage = currentParent;
            } else if (!isSubPage) {
                currentParent = link.textContent.trim();
            }

            order.push(pageData);
        }
    });

    console.log('New page order with hierarchy:', order);

    // Get the current page slug (you'll need to add this to your page)
    // Option 1: From data attribute
    const currentPageSlug = document.querySelector('[data-current-page-slug]')?.dataset.currentPageSlug;

    // Option 2: From a hidden input or meta tag
    // const currentPageSlug = document.querySelector('input[name="current_page_slug"]')?.value;

    // Send to server
    const token = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');
    if (token) {
        fetch('/manage/website/editor/pages-reorder', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': token,
                'X-Requested-With': 'XMLHttpRequest'
            },
            body: JSON.stringify({
                pages: order,
                current_page_slug: currentPageSlug
            })
        })
            .then(response => response.json())
            .then(data => {
                console.log('Server response:', data);
                if (data.success) {
                    // Update the entire page content with the new HTML
                    document.querySelector('.w-19\\/20').innerHTML = data.html;
                }
            })
            .catch(error => {
                console.error('Error updating order:', error);
            });
    }
}

// Initialize on page load
document.addEventListener('DOMContentLoaded', initializePageMenuDragDrop);

// Initialize on Turbo load (if using Turbo)
document.addEventListener('turbo:load', initializePageMenuDragDrop);

// Initialize on turbolinks load (if using older Turbolinks)
document.addEventListener('turbolinks:load', initializePageMenuDragDrop);

function openEditorPopup(title){

    const editorPopup = document.querySelector('.editor-edit-popup-outer');
    if (editorPopup) {
        editorPopup.classList.toggle('hidden');
    }

    if (title) {
        const titleElement = editorPopup.querySelector('.editor-edit-popup-title');
        if (titleElement) {
            titleElement.textContent = title;
        }
    }

}