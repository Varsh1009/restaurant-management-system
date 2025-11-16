/* Restaurant Management System - Main JavaScript */

// Global function to show alerts
function showAlert(type, message, duration = 5000) {
    const alertTypes = {
        'success': 'success',
        'error': 'danger',
        'danger': 'danger',
        'warning': 'warning',
        'info': 'info'
    };
    
    const alertClass = alertTypes[type] || 'info';
    const icons = {
        'success': 'fa-check-circle',
        'danger': 'fa-exclamation-circle',
        'warning': 'fa-exclamation-triangle',
        'info': 'fa-info-circle'
    };
    
    const alert = $(`
        <div class="alert alert-${alertClass} alert-dismissible fade show" role="alert">
            <i class="fas ${icons[alertClass]}"></i> ${message}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    `);
    
    $('#alertContainer').append(alert);
    
    setTimeout(() => {
        alert.fadeOut(300, function() {
            $(this).remove();
        });
    }, duration);
}

// Set active nav link
$(document).ready(function() {
    const currentPath = window.location.pathname;
    $('.nav-link').each(function() {
        const href = $(this).attr('href');
        if (currentPath === href || (currentPath === '/' && href === '/dashboard')) {
            $(this).addClass('active');
        }
    });
});

// Format currency
function formatCurrency(amount) {
    return new Intl.NumberFormat('en-US', {
        style: 'currency',
        currency: 'USD'
    }).format(amount);
}

// Format date
function formatDate(dateString) {
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
    });
}

// Confirm delete action
function confirmDelete(itemName) {
    return confirm(`Are you sure you want to delete ${itemName}? This action cannot be undone.`);
}

// Loading spinner
function showLoading(element) {
    $(element).html(`
        <div class="text-center py-5">
            <div class="spinner-border text-primary" role="status">
                <span class="visually-hidden">Loading...</span>
            </div>
            <p class="mt-2 text-muted">Loading...</p>
        </div>
    `);
}

// Show no data message
function showNoData(element, message = 'No data found') {
    $(element).html(`
        <tr>
            <td colspan="100" class="text-center py-5">
                <i class="fas fa-inbox fa-3x text-muted mb-3"></i>
                <p class="text-muted">${message}</p>
            </td>
        </tr>
    `);
}

// Debounce function for search
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

// Initialize tooltips
$(document).ready(function() {
    const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
    tooltipTriggerList.map(function (tooltipTriggerEl) {
        return new bootstrap.Tooltip(tooltipTriggerEl);
    });
});