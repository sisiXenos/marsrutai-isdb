// =================== MAP SETUP ===================
const map = L.map("map").setView([54.6872, 25.2797], 12);

L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
  attribution: "© OpenStreetMap contributors",
}).addTo(map);

// =================== DOM ELEMENTS ===================
const routesList = document.getElementById("routes-list");
const filterType = document.getElementById("filter-type");
const filterActive = document.getElementById("filter-active");
const filterName = document.getElementById("filter-name");
const applyFiltersBtn = document.getElementById("apply-filters");
const clearFiltersBtn = document.getElementById("clear-filters");

// =================== GLOBAL VARIABLES ===================
let allRoutes = [];
let routeLayers = [];

// =================== HELPER FUNCTIONS ===================

// Clear all route layers (route lines + markers)
function clearRouteLayers() {
  routeLayers.forEach(layer => map.removeLayer(layer));
  routeLayers = [];
}

// Draw route on map
const stotelesList = document.getElementById("stoteles-list");

// modifikuota highlightRoute funkcija
async function highlightRoute(route) {
  clearRouteLayers();

  // Piešiame maršrutą
  if (route.kelias && route.kelias.coordinates) {
    const coords = route.kelias.coordinates.map(c => [c[1], c[0]]);
    const polyline = L.polyline(coords, { color: "blue" }).addTo(map);
    routeLayers.push(polyline);
    map.fitBounds(polyline.getBounds());
  }

  // Gauname stoteles
  try {
    const res = await fetch(`http://localhost:5000/api/stoteles/marsrutas/${route.marsrutas_id}`);
    const data = await res.json();

    stotelesList.innerHTML = ""; // išvalome senas stoteles

    if (data.success && data.data.length > 0) {
      data.data.forEach(stop => {
        // Markeriai žemėlapyje
        const marker = L.marker([stop.lat, stop.lon])
                        .bindPopup(`<b>${stop.pavadinimas}</b>`)
                        .addTo(map);
        routeLayers.push(marker);

        // Stotelių sąrašas HTML
        const li = document.createElement("li");
        li.textContent = stop.pavadinimas;
        stotelesList.appendChild(li);
      });
    } else {
      stotelesList.innerHTML = "<li>Nėra stotelių.</li>";
    }
  } catch (err) {
    console.error("Error fetching stops:", err);
    stotelesList.innerHTML = "<li>Klaida užkraunant stoteles.</li>";
  }
}

// Render route list in sidebar
function renderRoutes(routes) {
  routesList.innerHTML = "";
  if (routes.length === 0) {
    routesList.innerHTML = "<li>Nėra maršrutų duomenų.</li>";
    return;
  }

  routes.forEach(route => {
    const li = document.createElement("li");
    li.textContent = `${route.pavadinimas} (${route.atstumas_km} km, ${route.trukme_min} min)`;
    li.onclick = () => highlightRoute(route);
    routesList.appendChild(li);
  });
}

// Fetch all routes from backend
async function loadRoutes() {
  try {
    const res = await fetch("http://localhost:5000/api/marsrutai");
    const data = await res.json();

    if (data.success && data.data.length > 0) {
      allRoutes = data.data;
      renderRoutes(allRoutes);
    } else {
      routesList.innerHTML = "<li>Nėra maršrutų duomenų.</li>";
    }
  } catch (err) {
    console.error("Error loading routes:", err);
    routesList.innerHTML = "<li>Klaida užkraunant maršrutus.</li>";
  }
}

// Apply filters to routes
function applyFilters() {
  let filteredRoutes = allRoutes.slice();

  // Filter by name
  const nameFilter = filterName.value.trim().toLowerCase();
  if (nameFilter) {
    filteredRoutes = filteredRoutes.filter(r => r.pavadinimas.toLowerCase().includes(nameFilter));
  }

  // Filter by active status
  const activeFilter = filterActive.value;
  if (activeFilter === "active") {
    filteredRoutes = filteredRoutes.filter(r => r.aktyvus);
  } else if (activeFilter === "inactive") {
    filteredRoutes = filteredRoutes.filter(r => !r.aktyvus);
  }

  // Filter by route type
  const typeFilter = filterType.value;
  if (typeFilter) {
    const typeId = parseInt(typeFilter);
    filteredRoutes = filteredRoutes.filter(r => r.marsruto_tipas_id === typeId);
  }

  renderRoutes(filteredRoutes);
}

// =================== EVENT LISTENERS ===================
applyFiltersBtn.addEventListener("click", applyFilters);

clearFiltersBtn.addEventListener("click", () => {
  filterName.value = "";
  filterActive.value = "";
  filterType.value = "";
  renderRoutes(allRoutes);
  clearRouteLayers();
});

// =================== INITIAL LOAD ===================
loadRoutes();
