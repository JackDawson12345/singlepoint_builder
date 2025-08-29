// Make it globally available
window.hideSidebar = hideSidebar;
window.showSectionsSidebar = showSectionsSidebar;
window.showPagesSidebar = showPagesSidebar;
window.showColourSidebar = showColourSidebar;
window.showNavigatorSidebar = showNavigatorSidebar;
window.initializeComponentSidebar = initializeComponentSidebar;
window.showEditorFieldsSidebar = showEditorFieldsSidebar


function hideSidebar(){
    const sidebar = document.querySelector('.editor-sidebar');
    if (sidebar) {
        sidebar.classList.remove('show');
    } else {
        console.log("Sidebar element not found!");
    }
}

function showSectionsSidebar(title) {
    const sidebar = document.querySelector('.editor-sidebar');
    if (sidebar) {
        sidebar.classList.toggle('show');

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

function showPagesSidebar(title) {
    const sidebar = document.querySelector('.editor-sidebar');
    if (sidebar) {
        sidebar.classList.toggle('show');

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

function showNavigatorSidebar(title) {
    const sidebar = document.querySelector('.editor-sidebar');
    if (sidebar) {
        sidebar.classList.toggle('show');
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

function showEditorFieldsSidebar(component_id, component_type, theme_page_id, user_id) {

    const sidebar = document.querySelector('.editor-sidebar');
    if (sidebar) {
        sidebar.classList.toggle('show');

        // If sidebar is being shown, fetch data via AJAX
        if (sidebar.classList.contains('show')) {
            fetchEditorFieldsData(component_id, component_type, theme_page_id, user_id)
        }

        if (component_type) {
            const titleElement = sidebar.querySelector('.sidebar-title');
            if (titleElement) {
                titleElement.textContent = component_type;
            }
        }
    }
}

function fetchEditorFieldsData(component_id, component_type, theme_page_id, user_id) {
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
            user_id: user_id
        })
    })
        .then(response => response.json())
        .then(data => {
            // Update sidebar content with the received data
            updateEditorFieldsContent(data)
        })
        .catch(error => {
            console.error('Error fetching sidebar data:', error);
        });
}

function updateEditorFieldsContent(data) {
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