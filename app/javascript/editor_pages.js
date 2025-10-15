window.changePageType = changePageType;
window.addNewPage = addNewPage;
window.showInMenu = showInMenu;
window.deleteFromMenu = deleteFromMenu;
window.duplicateFromMenu = duplicateFromMenu;
window.renamePageFromMenu = renamePageFromMenu;

function changePageType(type, title, text){

    fetchPageTypeData(type, title, text);

}

function fetchPageTypeData(type, title, text) {
    // Get CSRF token for Rails
    const token = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

    fetch('/manage/website/editor/page_type', {  // Updated to match your namespace
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': token,
            'X-Requested-With': 'XMLHttpRequest'
        },
        body: JSON.stringify({
            type: type,
            title: title,
            text: text
        })
    })
        .then(response => response.json())
        .then(data => {
            // Update sidebar content with the received data
            updatePagesPopupContent(data);
        })
        .catch(error => {
            console.error('Error fetching sidebar data:', error);
        });
}

function updatePagesPopupContent(data){
    if(data.success) {
        const container = document.querySelector('#add-page-content');

        if(container) {
            container.innerHTML = data.html;
        } else {
            console.error('Container not found');
        }
    } else {
        console.error('Failed to load page templates:', data.error);
    }
}

function addNewPage(id){
    // Get CSRF token for Rails
    const token = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

    fetch('/manage/website/editor/add_page_template', {  // Updated to match your namespace
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': token,
            'X-Requested-With': 'XMLHttpRequest'
        },
        body: JSON.stringify({
            page_template_id: id
        })
    })
        .then(response => response.json())
        .then(data => {
            if (data.redirect_url) {
                window.location.href = data.redirect_url;
            }
        });
}

function showInMenu(menu_item_id, current_page_slug){
    const token = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

    fetch('/manage/website/editor/show_in_menu', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': token,
            'X-Requested-With': 'XMLHttpRequest'
        },
        body: JSON.stringify({
            menu_item_id: menu_item_id,
            current_page_slug: current_page_slug
        })
    })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                // Update the icon and text immediately
                const menuDiv = document.querySelector(`[data-menu-item-id="${menu_item_id}"]`);
                const showIcon = menuDiv.querySelector('.hide-in-menu-icon-show');
                const hideIcon = menuDiv.querySelector('.hide-in-menu-icon-hide');
                const text = menuDiv.querySelector('.show-in-menu-text');

                if (data.show_in_menu) {
                    hideIcon.classList.add('hidden');
                    showIcon.classList.remove('hidden');
                    text.textContent = 'Hide In Menu';
                } else {
                    hideIcon.classList.remove('hidden');
                    showIcon.classList.add('hidden');
                    text.textContent = 'Show In Menu';
                }

                // Update the entire page content with the new HTML
                document.querySelector('.w-19\\/20').innerHTML = data.html;
            }
        });
}

function deleteFromMenu(menu_item_id){
    if (confirm('Are you sure you want to delete this page? This action cannot be undone.')) {
        const token = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

        // Get the current page slug from the URL
        const pathParts = window.location.pathname.split('/');
        const currentPageSlug = pathParts[pathParts.length - 1] || '/';

        fetch('/manage/website/editor/delete_from_menu', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': token,
                'X-Requested-With': 'XMLHttpRequest'
            },
            body: JSON.stringify({
                menu_item_id: menu_item_id,
                current_page_slug: currentPageSlug
            })
        })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    if (data.is_current_page) {
                        // Redirect if we're on the deleted page
                        window.location.href = '/manage/website/editor/';
                    } else {
                        // Remove the menu item from the sidebar
                        const className = '.container-' + data.menu_item_id;
                        const menuContainer = document.querySelector(className);
                        if (menuContainer) {
                            menuContainer.remove();
                        }

                        // Update the page content with the new HTML
                        document.querySelector('.w-19\\/20').innerHTML = data.html;
                    }
                } else {
                    alert('Error: ' + (data.message || 'Failed to delete page'));
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('An error occurred while deleting the page');
            });
    } else {
        return;
    }
}

function duplicateFromMenu(menu_item_id){
    const token = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

    fetch('/manage/website/editor/duplicate_in_menu', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': token,
            'X-Requested-With': 'XMLHttpRequest'
        },
        body: JSON.stringify({
            menu_item_id: menu_item_id
        })
    })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                // Redirect to the new duplicated page
                window.location.href = `/manage/website/editor/${data.slug}`;
            } else {
                console.error('Error duplicating page:', data.error);
                // Optionally show an error message to the user
            }
        })
        .catch(error => {
            console.error('Error:', error);
            // Optionally show an error message to the user
        });
}

function renamePageFromMenu(menu_item_id, current_name){
    // Find the page link element
    const pageContainer = document.querySelector(`.container-${menu_item_id}`);
    if (!pageContainer) {
        console.error('Page container not found');
        return;
    }

    const pageLink = pageContainer.querySelector('a');
    if (!pageLink) {
        console.error('Page link not found');
        return;
    }

    // Store the original link HTML
    const originalHTML = pageLink.outerHTML;

    // Replace the link with an input field
    const input = document.createElement('input');
    input.type = 'text';
    input.value = current_name;
    input.className = 'nata-sans text-sm capitalize border border-green-500 rounded px-2 py-1 focus:outline-none focus:ring-2 focus:ring-green-500';
    input.style.width = '100%';

    // Replace the link with the input
    pageLink.replaceWith(input);

    // Focus and select the text
    input.focus();
    input.select();

    // Function to save the new name
    const saveName = () => {
        const newName = input.value.trim();

        // If name hasn't changed or is empty, revert
        if (!newName || newName === current_name) {
            input.outerHTML = originalHTML;
            return;
        }

        // Get current page slug from URL
        const pathParts = window.location.pathname.split('/');
        const currentPageSlug = pathParts[pathParts.length - 1] || '/';

        // Send rename request
        const token = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

        fetch('/manage/website/editor/rename_page', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': token,
                'X-Requested-With': 'XMLHttpRequest'
            },
            body: JSON.stringify({
                menu_item_id: menu_item_id,
                new_name: newName,
                current_page_slug: currentPageSlug
            })
        })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    // Check if we're on the renamed page
                    if (data.is_current_page) {
                        // Redirect to the new slug
                        window.location.href = `/manage/website/editor/${data.new_slug}`;
                    } else {
                        // Refresh the sidebar to show the updated name
                        const sidebar = document.querySelector('.editor-sidebar');
                        if (sidebar && sidebar.classList.contains('show')) {
                            // Close the sidebar
                            hideSidebar();

                            // Wait a moment then reopen it to refresh
                            setTimeout(() => {
                                managePagesSidebar('Site Pages and Menu');
                            }, 100);
                        } else {
                            // If sidebar is not open, just show a success message
                            console.log('Page renamed successfully');
                        }
                    }
                } else {
                    alert('Error: ' + (data.message || 'Failed to rename page'));
                    input.outerHTML = originalHTML;
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('An error occurred while renaming the page');
                input.outerHTML = originalHTML;
            });
    };

    // Save on blur (clicking away)
    input.addEventListener('blur', saveName);

    // Save on Enter key
    input.addEventListener('keydown', (e) => {
        if (e.key === 'Enter') {
            e.preventDefault();
            saveName();
        } else if (e.key === 'Escape') {
            // Revert on Escape
            input.outerHTML = originalHTML;
        }
    });
}