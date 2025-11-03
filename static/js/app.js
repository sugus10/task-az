// Global variables
let editModal;
let toast;

// Initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    editModal = new bootstrap.Modal(document.getElementById('editModal'));
    toast = new bootstrap.Toast(document.getElementById('toast'));
    
    // Add item form handler
    document.getElementById('addItemForm').addEventListener('submit', function(e) {
        e.preventDefault();
        addItem();
    });
    
    // Edit item form handler
    document.getElementById('editItemForm').addEventListener('submit', function(e) {
        e.preventDefault();
        updateItem();
    });
    
    // Event delegation for edit and delete buttons
    document.addEventListener('click', function(e) {
        if (e.target.classList.contains('edit-btn')) {
            const id = e.target.getAttribute('data-id');
            const name = e.target.getAttribute('data-name');
            const description = e.target.getAttribute('data-description');
            editItem(id, name, description);
        }
        
        if (e.target.classList.contains('delete-btn')) {
            const id = e.target.getAttribute('data-id');
            deleteItem(id);
        }
    });
});

// Show toast notification
function showToast(title, message, isError = false) {
    const toastElement = document.getElementById('toast');
    const toastTitle = document.getElementById('toastTitle');
    const toastBody = document.getElementById('toastBody');
    
    toastTitle.textContent = title;
    toastBody.textContent = message;
    
    // Change toast color based on success/error
    toastElement.className = isError ? 'toast text-bg-danger' : 'toast text-bg-success';
    
    toast.show();
}

// Add new item
async function addItem() {
    const name = document.getElementById('itemName').value.trim();
    const description = document.getElementById('itemDescription').value.trim();
    
    if (!name) {
        showToast('Error', 'Name is required', true);
        return;
    }
    
    try {
        const response = await fetch('/api/items', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                name: name,
                description: description
            })
        });
        
        const data = await response.json();
        
        if (response.ok) {
            showToast('Success', 'Item added successfully');
            document.getElementById('addItemForm').reset();
            loadItems();
        } else {
            showToast('Error', data.error || 'Failed to add item', true);
        }
    } catch (error) {
        showToast('Error', 'Network error: ' + error.message, true);
    }
}

// Load items from API
async function loadItems() {
    const loadingSpinner = document.getElementById('loadingSpinner');
    const itemsList = document.getElementById('itemsList');
    
    loadingSpinner.classList.remove('d-none');
    
    try {
        const response = await fetch('/api/items');
        const items = await response.json();
        
        if (response.ok) {
            displayItems(items);
        } else {
            showToast('Error', items.error || 'Failed to load items', true);
            itemsList.innerHTML = '<div class="text-center text-danger">Failed to load items</div>';
        }
    } catch (error) {
        showToast('Error', 'Network error: ' + error.message, true);
        itemsList.innerHTML = '<div class="text-center text-danger">Network error</div>';
    } finally {
        loadingSpinner.classList.add('d-none');
    }
}

// Display items in table
function displayItems(items) {
    const itemsList = document.getElementById('itemsList');
    
    if (items.length === 0) {
        itemsList.innerHTML = '<div class="text-center text-muted"><p>No items found. Add your first item above!</p></div>';
        return;
    }
    
    let html = `
        <div class="table-responsive">
            <table class="table table-striped">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Name</th>
                        <th>Description</th>
                        <th>Created</th>
                        <th>Updated</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
    `;
    
    items.forEach(item => {
        const createdAt = item.created_at ? new Date(item.created_at).toLocaleString() : 'N/A';
        const updatedAt = item.updated_at ? new Date(item.updated_at).toLocaleString() : 'N/A';
        
        html += `
            <tr>
                <td>${item.id}</td>
                <td>${escapeHtml(item.name)}</td>
                <td>${escapeHtml(item.description || 'N/A')}</td>
                <td>${createdAt}</td>
                <td>${updatedAt}</td>
                <td>
                    <button class="btn btn-sm btn-outline-primary edit-btn" 
                            data-id="${item.id}" 
                            data-name="${escapeHtml(item.name)}" 
                            data-description="${escapeHtml(item.description || '')}">Edit</button>
                    <button class="btn btn-sm btn-outline-danger delete-btn" 
                            data-id="${item.id}">Delete</button>
                </td>
            </tr>
        `;
    });
    
    html += `
                </tbody>
            </table>
        </div>
    `;
    
    itemsList.innerHTML = html;
}

// Edit item
function editItem(id, name, description) {
    document.getElementById('editItemId').value = id;
    document.getElementById('editItemName').value = name;
    document.getElementById('editItemDescription').value = description;
    
    editModal.show();
}

// Update item
async function updateItem() {
    const id = document.getElementById('editItemId').value;
    const name = document.getElementById('editItemName').value.trim();
    const description = document.getElementById('editItemDescription').value.trim();
    
    if (!name) {
        showToast('Error', 'Name is required', true);
        return;
    }
    
    try {
        const response = await fetch(`/api/items/${id}`, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                name: name,
                description: description
            })
        });
        
        const data = await response.json();
        
        if (response.ok) {
            showToast('Success', 'Item updated successfully');
            editModal.hide();
            loadItems();
        } else {
            showToast('Error', data.error || 'Failed to update item', true);
        }
    } catch (error) {
        showToast('Error', 'Network error: ' + error.message, true);
    }
}

// Delete item
async function deleteItem(id) {
    if (!confirm('Are you sure you want to delete this item?')) {
        return;
    }
    
    try {
        const response = await fetch(`/api/items/${id}`, {
            method: 'DELETE'
        });
        
        const data = await response.json();
        
        if (response.ok) {
            showToast('Success', 'Item deleted successfully');
            loadItems();
        } else {
            showToast('Error', data.error || 'Failed to delete item', true);
        }
    } catch (error) {
        showToast('Error', 'Network error: ' + error.message, true);
    }
}

// Utility function to escape HTML
function escapeHtml(text) {
    const map = {
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#039;'
    };
    return text.replace(/[&<>"']/g, function(m) { return map[m]; });
}