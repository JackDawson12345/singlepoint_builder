// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "editor"
import "invoice_design"
import "help_popup"
import "editor_pages"
import "inbox"

window.closeHelpPopup = closeHelpPopup;
window.openHelpPopup = openHelpPopup;
window.resetHelpPopup = resetHelpPopup;
window.helpPopupMaximise = helpPopupMaximise;
window.helpPopupMinimise = helpPopupMinimise;
function closeHelpPopup(){

    const sidebar = document.querySelector('.help-popup-section');

    if (sidebar) {
        sidebar.classList.add('hidden');
    } else {
        console.log("Sidebar element not found!");
    }

}

function openHelpPopup(){

    const sidebar = document.querySelector('.help-popup-section');

    if (sidebar) {
        sidebar.classList.remove('hidden');
    } else {
        console.log("Sidebar element not found!");
    }

}

function resetHelpPopup() {
    // Clear the textarea
    document.getElementById('quick-search-input').value = '';

    // Reload the original help content
    fetch('<%= manage_help_search_path %>', {
        method: 'GET',
        headers: {
            'Accept': 'text/vnd.turbo-stream.html'
        }
    });
}

function helpPopupMaximise(){
    const helpPopup = document.querySelector('.help-popup-section');
    const helpPopupBottom = document.querySelector('.help-popup-bottom');

    const helpPopupMaximiseButton = document.querySelector('.help-popup-maximise-div');
    const helpPopupMinimiseButton = document.querySelector('.help-popup-minimise-div');

    if (helpPopup) {
        helpPopup.classList.add('help-popup-section-max');
        helpPopupBottom.classList.add('help-popup-bottom-max');

        helpPopupMaximiseButton.classList.add('hidden');
        helpPopupMinimiseButton.classList.remove('hidden');
    } else {
        console.log("Sidebar element not found!");
    }
}

function helpPopupMinimise(){
    const helpPopup = document.querySelector('.help-popup-section');
    const helpPopupBottom = document.querySelector('.help-popup-bottom');

    const helpPopupMaximiseButton = document.querySelector('.help-popup-maximise-div');
    const helpPopupMinimiseButton = document.querySelector('.help-popup-minimise-div');

    if (helpPopup) {
        helpPopup.classList.remove('help-popup-section-max');
        helpPopupBottom.classList.remove('help-popup-bottom-max');

        helpPopupMaximiseButton.classList.remove('hidden');
        helpPopupMinimiseButton.classList.add('hidden');
    } else {
        console.log("Sidebar element not found!");
    }
}