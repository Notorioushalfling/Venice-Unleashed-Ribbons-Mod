// Function to display a ribbon
function displayRibbon(ribbonName) {
    const ribbonContainer = document.getElementById('ribbon-container'); // Fixed ID
    
    // Create a new ribbon element
    const ribbon = document.createElement('div');
    ribbon.className = 'ribbon';
    ribbon.innerText = ribbonName; // Set the ribbon text

    // Append the ribbon to the container
    ribbonContainer.appendChild(ribbon);

    // Remove the ribbon after a delay (e.g., 3 seconds)
    setTimeout(() => {
        ribbonContainer.removeChild(ribbon);
    }, 3000);
}

// Example of how to use the displayRibbon function
// Replace this with the actual logic for your mod
setTimeout(() => {
    displayRibbon('Assault Rifle Ribbon');
}, 1000);

setTimeout(() => {
    displayRibbon('Anti Vehicle Ribbon');
}, 5000);