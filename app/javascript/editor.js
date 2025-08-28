// Make it globally available
window.hideSidebar = hideSidebar;
window.showSectionsSidebar = showSectionsSidebar;
window.showPagesSidebar = showPagesSidebar;
window.showColourSidebar = showColourSidebar;
window.showNavigatorSidebar = showNavigatorSidebar;

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

    debugger

    if (contentArea && data) {
        // Replace the entire content area with the AJAX response
        contentArea.innerHTML = data.html || '';
    }
}

function showColourSidebar(title) {
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