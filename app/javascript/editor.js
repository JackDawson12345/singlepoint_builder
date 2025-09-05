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
window.showColourOption = showColourOption;
window.showTextOption = showTextOption;
window.showBackgroundOption = showBackgroundOption;

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


