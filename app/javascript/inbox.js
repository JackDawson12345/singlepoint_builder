window.openInboxChat = openInboxChat;
window.newInboxChat = newInboxChat;
window.reloadChatList = reloadChatList;
window.adminOpenInboxChat = adminOpenInboxChat;
window.adminNewInboxChat = adminNewInboxChat;
window.adminReloadChatList = adminReloadChatList;

function openInboxChat(id){
    const token = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

    fetch('/manage/inbox/get_message.json', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': token,
            'X-Requested-With': 'XMLHttpRequest'
        },
        body: JSON.stringify({
            chat_id: id,
        })
    })
        .then(response => response.json())
        .then(data => {
            document.querySelector('.inbox-chat-notice').style.display = 'none';
            document.querySelector('.inbox-chat-area').innerHTML = data.html;
            attachFormListeners();
            scrollToBottom();
        })
        .catch(error => {
            console.error('Error:', error);
        });
}
function adminOpenInboxChat(id){
    const token = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

    fetch('/admin/inbox/get_message.json', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': token,
            'X-Requested-With': 'XMLHttpRequest'
        },
        body: JSON.stringify({
            chat_id: id,
        })
    })
        .then(response => response.json())
        .then(data => {
            document.querySelector('.inbox-chat-notice').style.display = 'none';
            document.querySelector('.inbox-chat-area').innerHTML = data.html;
            adminAttachFormListeners();
            adminScrollToBottom();
        })
        .catch(error => {
            console.error('Error:', error);
        });
}

function newInboxChat(){
    const token = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

    fetch('/manage/inbox/get_new_chat.json', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': token,
            'X-Requested-With': 'XMLHttpRequest'
        },
        body: JSON.stringify({})
    })
        .then(response => response.json())
        .then(data => {
            document.querySelector('.inbox-chat-notice').style.display = 'none';
            document.querySelector('.inbox-chat-area').innerHTML = data.html;
            attachFormListeners();
        })
        .catch(error => {
            console.error('Error:', error);
        });
}
function adminNewInboxChat(){
    const token = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

    fetch('/admin/inbox/get_new_chat.json', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': token,
            'X-Requested-With': 'XMLHttpRequest'
        },
        body: JSON.stringify({})
    })
        .then(response => response.json())
        .then(data => {
            document.querySelector('.inbox-chat-notice').style.display = 'none';
            document.querySelector('.inbox-chat-area').innerHTML = data.html;
            adminAttachFormListeners();
        })
        .catch(error => {
            console.error('Error:', error);
        });
}

function reloadChatList() {
    location.reload();
}
function adminReloadChatList() {
    location.reload();
}

function addChatToSidebar(chatData) {
    console.log('Adding chat to sidebar:', chatData); // Debug log

    const chatListContainer = document.getElementById('chat-list-container');

    if (!chatListContainer) {
        console.error('Chat list container not found!');
        return;
    }

    // Get the existing logo image src from an existing chat
    let logoSrc = '';
    const existingLogo = document.querySelector('#chat-list-container img');
    if (existingLogo) {
        logoSrc = existingLogo.src;
    }

    // Create the chat element
    const chatElement = document.createElement('div');
    chatElement.onclick = function() { openInboxChat(chatData.id); };
    chatElement.className = 'flex gap-2 items-center inbox-chat-' + chatData.id;
    chatElement.style.cursor = 'pointer';
    chatElement.innerHTML = `
        <div class="">
            <div class="bg-green-500 p-2 rounded-full w-12 h-12">
                <img src="${logoSrc}" class="">
            </div>
        </div>
        <div class="w-3/5">
            <p class="text-sm font-bold nata-sans">SinglePoint Support</p>
            <p class="text-xs font-base nata-sans text-gray-500">${chatData.message_preview}</p>
        </div>
        <div class="w-1/5 flex flex-col items-end gap-0.5">
            <p class="text-xs font-base nata-sans text-gray-500 text-right">${chatData.time}</p>
            ${chatData.unread_count > 0 ? `<div class="w-4 h-4 bg-red-500 rounded-full flex items-center justify-center"><p style="font-size: 0.5rem" class="nata-sans text-white">${chatData.unread_count}</p></div>` : ''}
        </div>
    `;

    // Add to the top of the list
    if (chatListContainer.firstChild) {
        chatListContainer.insertBefore(chatElement, chatListContainer.firstChild);
    } else {
        chatListContainer.appendChild(chatElement);
    }

    console.log('Chat added successfully!'); // Debug log
}
function adminAddChatToSidebar(chatData) {
    console.log('Adding chat to sidebar:', chatData); // Debug log

    const chatListContainer = document.getElementById('chat-list-container');

    if (!chatListContainer) {
        console.error('Chat list container not found!');
        return;
    }

    // Get the existing logo image src from an existing chat
    let logoSrc = '';
    const existingLogo = document.querySelector('#chat-list-container img');
    if (existingLogo) {
        logoSrc = existingLogo.src;
    }

    // Create the chat element
    const chatElement = document.createElement('div');
    chatElement.onclick = function() { adminOpenInboxChat(chatData.id); };
    chatElement.className = 'flex gap-2 items-center inbox-chat-' + chatData.id;
    chatElement.style.cursor = 'pointer';
    chatElement.innerHTML = `
        <div class="">
            <div class="bg-green-500 p-2 rounded-full w-12 h-12">
                <img src="${logoSrc}" class="">
            </div>
        </div>
        <div class="w-3/5">
            <p class="text-sm font-bold nata-sans">SinglePoint Support</p>
            <p class="text-xs font-base nata-sans text-gray-500">${chatData.message_preview}</p>
        </div>
        <div class="w-1/5 flex flex-col items-end gap-0.5">
            <p class="text-xs font-base nata-sans text-gray-500 text-right">${chatData.time}</p>
            ${chatData.unread_count > 0 ? `<div class="w-4 h-4 bg-red-500 rounded-full flex items-center justify-center"><p style="font-size: 0.5rem" class="nata-sans text-white">${chatData.unread_count}</p></div>` : ''}
        </div>
    `;

    // Add to the top of the list
    if (chatListContainer.firstChild) {
        chatListContainer.insertBefore(chatElement, chatListContainer.firstChild);
    } else {
        chatListContainer.appendChild(chatElement);
    }

    console.log('Chat added successfully!'); // Debug log
}

function attachFormListeners() {
    const oldChatForm = document.querySelector('#old-chat-form');
    const newChatForm = document.querySelector('#new-chat-form');

    if (oldChatForm) {
        oldChatForm.addEventListener('submit', function(event) {
            event.preventDefault();
            event.stopPropagation();

            const formData = new FormData(this);
            const token = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

            const message = formData.get('message');
            const chatId = formData.get('chat_id');

            // Clear the input
            const messageInput = this.querySelector('input[name="message"]');
            if (messageInput) {
                messageInput.value = '';
            }

            fetch('/manage/inbox/old_chat_message.json', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-Token': token,
                    'X-Requested-With': 'XMLHttpRequest'
                },
                body: JSON.stringify({
                    message: message,
                    chat_id: chatId
                })
            })
                .then(response => {
                    if (!response.ok) {
                        throw new Error('Network response was not ok');
                    }
                    return response.json();
                })
                .then(data => {
                    document.querySelector('.inbox-chat-area').innerHTML = data.html;
                    attachFormListeners();
                    scrollToBottom();
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('Failed to send message. Please try again.');
                    if (messageInput) {
                        messageInput.value = message;
                    }
                });

            return false;
        });
    }

    if (newChatForm) {
        newChatForm.addEventListener('submit', function(event) {
            event.preventDefault();
            event.stopPropagation();

            const formData = new FormData(this);
            const token = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

            const message = formData.get('message');

            // Clear the input
            const messageInput = this.querySelector('input[name="message"]');
            if (messageInput) {
                messageInput.value = '';
            }

            fetch('/manage/inbox/new_chat_message.json', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-Token': token,
                    'X-Requested-With': 'XMLHttpRequest'
                },
                body: JSON.stringify({
                    message: message
                })
            })
                .then(response => {
                    if (!response.ok) {
                        throw new Error('Network response was not ok');
                    }
                    return response.json();
                })
                .then(data => {
                    console.log('Response data:', data); // Debug log

                    // Display the messages
                    document.querySelector('.inbox-chat-area').innerHTML = data.html;
                    attachFormListeners();
                    scrollToBottom();

                    // Add the new chat to the sidebar
                    if (data.chat_data) {
                        addChatToSidebar(data.chat_data);
                    } else {
                        console.error('No chat_data in response');
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('Failed to send message. Please try again.');
                    if (messageInput) {
                        messageInput.value = message;
                    }
                });

            return false;
        });
    }
}
function adminAttachFormListeners() {
    const oldChatForm = document.querySelector('#old-chat-form');
    const newChatForm = document.querySelector('#new-chat-form');

    if (oldChatForm) {
        oldChatForm.addEventListener('submit', function(event) {
            event.preventDefault();
            event.stopPropagation();

            const formData = new FormData(this);
            const token = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

            const message = formData.get('message');
            const chatId = formData.get('chat_id');

            // Clear the input
            const messageInput = this.querySelector('input[name="message"]');
            if (messageInput) {
                messageInput.value = '';
            }

            fetch('/admin/inbox/old_chat_message.json', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-Token': token,
                    'X-Requested-With': 'XMLHttpRequest'
                },
                body: JSON.stringify({
                    message: message,
                    chat_id: chatId
                })
            })
                .then(response => {
                    if (!response.ok) {
                        throw new Error('Network response was not ok');
                    }
                    return response.json();
                })
                .then(data => {
                    document.querySelector('.inbox-chat-area').innerHTML = data.html;
                    adminAttachFormListeners();
                    adminScrollToBottom();
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('Failed to send message. Please try again.');
                    if (messageInput) {
                        messageInput.value = message;
                    }
                });

            return false;
        });
    }

    if (newChatForm) {
        newChatForm.addEventListener('submit', function(event) {
            event.preventDefault();
            event.stopPropagation();

            const formData = new FormData(this);
            const token = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

            const message = formData.get('message');

            // Clear the input
            const messageInput = this.querySelector('input[name="message"]');
            if (messageInput) {
                messageInput.value = '';
            }

            fetch('/admin/inbox/new_chat_message.json', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-Token': token,
                    'X-Requested-With': 'XMLHttpRequest'
                },
                body: JSON.stringify({
                    message: message
                })
            })
                .then(response => {
                    if (!response.ok) {
                        throw new Error('Network response was not ok');
                    }
                    return response.json();
                })
                .then(data => {
                    console.log('Response data:', data); // Debug log

                    // Display the messages
                    document.querySelector('.inbox-chat-area').innerHTML = data.html;
                    adminAttachFormListeners();
                    adminScrollToBottom();

                    // Add the new chat to the sidebar
                    if (data.chat_data) {
                        adminAddChatToSidebar(data.chat_data);
                    } else {
                        console.error('No chat_data in response');
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('Failed to send message. Please try again.');
                    if (messageInput) {
                        messageInput.value = message;
                    }
                });

            return false;
        });
    }
}

function scrollToBottom() {
    setTimeout(() => {
        const chatArea = document.querySelector('.inbox-chat-area .bg-white');
        if (chatArea) {
            chatArea.scrollTop = chatArea.scrollHeight;
        }
    }, 100);
}
function adminScrollToBottom() {
    setTimeout(() => {
        const chatArea = document.querySelector('.inbox-chat-area .bg-white');
        if (chatArea) {
            chatArea.scrollTop = chatArea.scrollHeight;
        }
    }, 100);
}

// Initialize on page load
document.addEventListener('DOMContentLoaded', function() {
    attachFormListeners();
    adminAttachFormListeners();
});