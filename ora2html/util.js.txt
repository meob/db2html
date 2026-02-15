document.addEventListener('DOMContentLoaded', () => {
    document.querySelectorAll('table.sortable th').forEach(headerCell => {
        headerCell.addEventListener('click', () => {
            const tableElement = headerCell.closest('table');
            const headerIndex = Array.prototype.indexOf.call(headerCell.parentElement.children, headerCell);
            const currentIsAscending = headerCell.classList.contains('th-sort-asc');

            sortTableByColumn(tableElement, headerIndex, !currentIsAscending);
        });
    });
});

function sortTableByColumn(table, column, asc = true) {
    const dirModifier = asc ? 1 : -1;
    const tBody = table.tBodies[0];
    const rows = Array.from(tBody.querySelectorAll('tr'));

    // Sort each row
    const sortedRows = rows.sort((a, b) => {
        const aColText = a.querySelector(`td:nth-child(${column + 1})`).textContent.trim();
        const bColText = b.querySelector(`td:nth-child(${column + 1})`).textContent.trim();

        // Basic type detection for sorting
        const aNum = parseFloat(aColText.replace(/[^0-9.-]/g, '')); // Remove non-numeric for better parsing
        const bNum = parseFloat(bColText.replace(/[^0-9.-]/g, ''));

        if (!isNaN(aNum) && !isNaN(bNum)) {
            return (aNum > bNum ? 1 : -1) * dirModifier;
        } else {
            return (aColText > bColText ? 1 : -1) * dirModifier;
        }
    });

    // Remove old classes
    table.querySelectorAll('th').forEach(th => {
        th.classList.remove('th-sort-asc', 'th-sort-desc');
    });

    // Add new class to the clicked header
    table.querySelector(`th:nth-child(${column + 1})`).classList.toggle('th-sort-asc', asc);
    table.querySelector(`th:nth-child(${column + 1})`).classList.toggle('th-sort-desc', !asc);

    // Remove all existing TRs from the table
    while (tBody.firstChild) {
        tBody.removeChild(tBody.firstChild);
    }

    // Add the newly sorted rows
    tBody.append(...sortedRows);
}

document.addEventListener('click', function(event) {
  // Controlla se l'elemento cliccato ha la classe "truncate"
  if (event.target.classList.contains('truncate')) {
    // Aggiunge o rimuove la classe "expanded"
    event.target.classList.toggle('expanded');
  }
});