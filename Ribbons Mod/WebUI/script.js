// Function to display a ribbon
function displayRibbon(ribbonName) {
    const ribbonContainer = document.getElementById('ribbon-container');
    
    // Create a new ribbon element
    const ribbon = document.createElement('div');
    ribbon.className = 'ribbon';
    ribbon.innerText = ribbonName;

    // Append the ribbon to the container
    ribbonContainer.appendChild(ribbon);

    // Remove the ribbon after a delay (e.g., 3 seconds)
    setTimeout(() => {
        ribbonContainer.removeChild(ribbon);
    }, 3000);
}

// Function to create the WebSocket connection
function createWebSocket() {
    const protocol = window.location.protocol === "https:" ? "wss://" : "ws://";
    const host = window.location.host;
    const socket = new WebSocket(`${protocol}${host}`);

    socket.onopen = () => {
        console.log("WebSocket connection established.");
    };

    socket.onmessage = (event) => {
        const data = JSON.parse(event.data);
        if (data.ribbonName) {
            displayRibbon(data.ribbonName);
        }
    };

    socket.onclose = () => {
        console.log("WebSocket connection closed.");
    };

    socket.onerror = (error) => {
        console.error("WebSocket error: ", error);
    };
}

// Call the function to create the WebSocket
createWebSocket();